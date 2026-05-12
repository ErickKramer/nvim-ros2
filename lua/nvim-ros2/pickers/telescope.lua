-- Telescope includes
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local Utils = require("nvim-ros2.utils")
local Ros2 = require("nvim-ros2.api.ros2")
local ros_previewers = require("nvim-ros2.telescope.previewers")
-- Local previewers

local M = {}

--- Telescope picker to select ROS 2 interfaces
-- lua/nvim-ros2/pickers/telescope.lua
-- Replace your current M.interfaces() function entirely:

function M.interfaces()
  local command = { "ros2", "interface", "list" }
  local raw_output = Ros2.get_command_output(command)
  if not raw_output then
    return
  end

  -- Process command output
  local filtered_output = {}
  for _, line in ipairs(raw_output) do
    local section_header = line:match("^%s*(%a+):$")
    if not section_header then
      local trimmed_line = line:match("^%s*(.-)%s*$")
      if trimmed_line ~= "" then
        table.insert(filtered_output, trimmed_line)
      end
    end
  end

  local opts = {
    preview_title = "Show",
    prompt_title = "Select",
    results_title = "Interfaces",
    filtered_output = filtered_output,
  }

  pickers
    .new(opts, {
      finder = finders.new_table({
        results = opts.filtered_output,
        entry_maker = opts.entry_maker,
      }),
      sorter = conf.generic_sorter(),
      previewer = ros_previewers.preview_interface(),
      dynamic_filter = true,
      attach_mappings = function(prompt_bufnr, map)
        -- [NEW] Wire up the confirm action to our Utils jumper
        local confirm = function()
          local selection = require("telescope.actions.state").get_selected_entry()
          require("telescope.actions").close(prompt_bufnr)
          if selection then
            local item_text = selection.value or selection[1]
            Ros2.jump_to_interface(item_text)
          end
        end

        map("i", "<CR>", confirm)
        map("n", "<CR>", confirm)
        return true
      end,
    })
    :find()
end

local function ros_picker(opts)
  local command_output = nil
  if vim.fn.executable("ros2") == 1 then
    command_output = vim.fn.systemlist(opts.system_cmd)
  else
    vim.notify("ros2 not found", vim.log.levels.ERROR)
    return
  end

  require("telescope.pickers")
    .new(opts, {
      finder = require("telescope.finders").new_table({
        results = command_output,
        entry_maker = opts.entry_maker,
      }),
      sorter = require("telescope.config").values.generic_sorter(),
      previewer = require("nvim-ros2.telescope.previewers").preview_elements(opts),
      dynamic_filter = true,
      attach_mappings = function(prompt_bufnr, map)
        -- Sprint 5+: Inject custom actions (like <C-t> for Tuner)
        if opts.custom_actions then
          for key, def in pairs(opts.custom_actions) do
            map({ "i", "n" }, key, function()
              local selection = require("telescope.actions.state").get_selected_entry()
              require("telescope.actions").close(prompt_bufnr)
              if selection then
                def.callback(selection[1])
              end
            end, { desc = def.desc })
          end
        end

        if opts.on_select then
          require("telescope.actions").select_default:replace(function()
            local selection = require("telescope.actions.state").get_selected_entry()
            require("telescope.actions").close(prompt_bufnr)
            opts.on_select(selection[1])
          end)
        else
          map("i", "<CR>", function(_) end)
          map("n", "<CR>", function(_) end)
        end
        return true
      end,
    })
    :find()
end

function M.nodes(opts)
  opts = opts or {}
  local system_cmd = { "ros2", "node", "list" }
  local node_opts = vim.tbl_extend("force", {
    preview_title = "Node Info",
    prompt_title = "Search",
    results_title = "Active Nodes",
    system_cmd = system_cmd,
    command = "node",
    mode = "info",
    args = "--include-hidden",
    custom_actions = {
      ["<C-t>"] = {
        desc = "Attach ROS Tuner",
        callback = function(node_name)
          if require("nvim-ros2.config").options.tuner then
            require("nvim-ros2.tuner").attach_node(node_name, false)
          else
            vim.notify("ROS Tuner is disabled in config", vim.log.levels.WARN)
          end
        end,
      },
      ["<C-r>"] = {
        desc = "Attach Scratch Proxy",
        callback = function(node_name)
          if require("nvim-ros2.config").options.tuner then
            require("nvim-ros2.tuner").attach_node(node_name, true)
          end
        end,
      },
    },
  }, opts)

  ros_picker(node_opts)
end

-- Picker of active ROS 2 actions
function M.actions()
  local system_cmd = { "ros2", "action", "list" }

  -- Process command output
  local opts = {
    preview_title = "Action Info",
    prompt_title = "Search",
    results_title = "Active Actions",
    system_cmd = system_cmd,
    command = "action",
    mode = "info",
    args = "--show-types",
  }
  ros_picker(opts)
end

-- Picker of active ROS 2 Services
function M.services()
  local system_cmd = { "ros2", "service", "list" }

  -- Process command output
  local opts = {
    preview_title = "Service Type",
    prompt_title = "Search",
    results_title = "Active Services",
    system_cmd = system_cmd,
    command = "service",
    mode = "type",
    args = "",
  }
  ros_picker(opts)
end

-- Picker of active ROS 2 topics
function M.topics_info()
  local system_cmd = { "ros2", "topic", "list" }

  -- Process command output
  local opts = {
    preview_title = "Topic Info",
    prompt_title = "Search",
    results_title = "Active Topics",
    system_cmd = system_cmd,
    command = "topic",
    mode = "info",
    args = "--verbose",
  }
  ros_picker(opts)
end

function M.topics_echo()
  local system_cmd = { "ros2", "topic", "list" }
  local opts = {
    preview_title = "Topic Info",
    prompt_title = "Listen to Topic",
    results_title = "Active Topics",
    system_cmd = system_cmd,
    command = "topic",
    mode = "info",
    args = "",
    on_select = Ros2.listen_topic,
  }
  ros_picker(opts)
end

-- lua/nvim-ros2/pickers/telescope.lua
-- Replace your current M.packages() function:

function M.packages()
  local ws_root = Utils.get_workspace_root(0)
  local config = require("nvim-ros2.config").options
  local show_global = config.pickers
    and config.pickers.packages
    and config.pickers.packages.show_global ~= false

  Utils.get_merged_packages(ws_root, show_global, function(items)
    if #items == 0 then
      vim.notify("No ROS 2 packages found.", vim.log.levels.WARN)
      return
    end

    local results = {}
    for _, item in ipairs(items) do
      table.insert(results, {
        display = item.text .. (item.is_global and " 🌐" or " 📦"),
        ordinal = item.text,
        pkg_dir = item.pkg_dir,
        is_global = item.is_global,
      })
    end

    require("telescope.pickers")
      .new({}, {
        prompt_title = "ROS 2 Packages",
        finder = require("telescope.finders").new_table({
          results = results,
          entry_maker = function(entry)
            return { value = entry, display = entry.display, ordinal = entry.ordinal }
          end,
        }),
        sorter = require("telescope.config").values.generic_sorter({}),
        previewer = require("telescope.previewers").new_buffer_previewer({
          title = "Package Content",
          define_preview = function(self, entry, _)
            local item = entry.value
            if item.is_global and not item.pkg_dir then
              vim.api.nvim_buf_set_lines(
                self.state.bufnr,
                0,
                -1,
                false,
                { "Loading global package path..." }
              )
              vim.system({ "ros2", "pkg", "prefix", item.ordinal }, { text = true }, function(out)
                vim.schedule(function()
                  if not vim.api.nvim_buf_is_valid(self.state.bufnr) then
                    return
                  end
                  if out.code == 0 and out.stdout ~= "" then
                    item.pkg_dir = out.stdout:gsub("%s+", "")
                    local share_dir = item.pkg_dir .. "/share/" .. item.ordinal
                    vim.api.nvim_buf_set_lines(
                      self.state.bufnr,
                      0,
                      -1,
                      false,
                      vim.fn.systemlist("ls -la " .. share_dir)
                    )
                    require("telescope.previewers.utils").highlighter(self.state.bufnr, "bash")
                  end
                end)
              end)
            else
              local target = item.is_global and (item.pkg_dir .. "/share/" .. item.ordinal)
                or item.pkg_dir
              vim.api.nvim_buf_set_lines(
                self.state.bufnr,
                0,
                -1,
                false,
                vim.fn.systemlist("ls -la " .. target)
              )
              require("telescope.previewers.utils").highlighter(self.state.bufnr, "bash")
            end
          end,
        }),
        attach_mappings = function(prompt_bufnr, map)
          local confirm = function()
            local selection = require("telescope.actions.state").get_selected_entry()
            require("telescope.actions").close(prompt_bufnr)
            if not selection then
              return
            end

            local item = selection.value
            if item.pkg_dir then
              local target = item.is_global and (item.pkg_dir .. "/share/" .. item.ordinal)
                or item.pkg_dir
              Utils.open_directory(target)
            elseif item.is_global then
              vim.system({ "ros2", "pkg", "prefix", item.ordinal }, { text = true }, function(out)
                vim.schedule(function()
                  if out.code == 0 and out.stdout ~= "" then
                    local prefix = out.stdout:gsub("%s+", "")
                    Utils.open_directory(prefix .. "/share/" .. item.ordinal)
                  end
                end)
              end)
            end
          end
          map("i", "<CR>", confirm)
          map("n", "<CR>", confirm)
          return true
        end,
      })
      :find()
  end)
end

function M.sniper(subdir)
  local pkg = Utils.get_package_root(0)
  if not pkg then
    return
  end
  local target = pkg .. "/" .. subdir

  -- Create dir if missing
  if vim.fn.isdirectory(target) == 0 then
    vim.fn.mkdir(target, "p")
  end

  local files = vim.split(vim.fn.glob(target .. "/*"), "\n", { trimempty = true })
  if #files == 1 then
    vim.cmd("edit " .. files[1])
  elseif #files > 1 then
    require("telescope.builtin").find_files({ cwd = target, prompt_title = subdir .. " Files" })
  else
    Utils.open_directory(target)
  end
end

function M.find_files_package()
  local pkg = Utils.get_package_root(0)
  if pkg then
    require("telescope.builtin").find_files({
      cwd = pkg,
      prompt_title = "Find in Package: " .. vim.fs.basename(pkg),
    })
  else
    vim.notify("Not inside a ROS 2 package", vim.log.levels.WARN)
  end
end

function M.grep_package()
  local pkg = Utils.get_package_root(0)
  if pkg then
    require("telescope.builtin").live_grep({
      cwd = pkg,
      prompt_title = "Grep in Package: " .. vim.fs.basename(pkg),
    })
  else
    vim.notify("Not inside a ROS 2 package", vim.log.levels.WARN)
  end
end

function M.saved_payloads()
  local bufnr = vim.api.nvim_get_current_buf()
  local state = vim.b[bufnr].ros_rpc_state
  if not state or not state.type then
    vim.notify("Not in an active ROS RPC buffer", vim.log.levels.WARN)
    return
  end

  Ros2.get_saved_payloads(state.type, bufnr, function(files)
    if #files == 0 then
      vim.notify("No compatible payloads found for " .. state.type, vim.log.levels.WARN)
      return
    end

    local ws_root = Utils.get_workspace_root(bufnr)
    local results = {}
    for _, f in ipairs(files) do
      table.insert(results, {
        display = f:sub(#ws_root + 2),
        path = f,
        ordinal = f:sub(#ws_root + 2),
      })
    end

    require("telescope.pickers")
      .new({}, {
        prompt_title = "Load Payload (" .. state.type .. ")",
        finder = require("telescope.finders").new_table({
          results = results,
          entry_maker = function(entry)
            return {
              value = entry.path,
              display = entry.display,
              ordinal = entry.ordinal,
              path = entry.path, -- Used by Telescope's file previewer
            }
          end,
        }),
        sorter = require("telescope.config").values.generic_sorter({}),
        previewer = require("telescope.config").values.grep_previewer({}),
        attach_mappings = function(prompt_bufnr, map)
          local confirm = function()
            local selection = require("telescope.actions.state").get_selected_entry()
            require("telescope.actions").close(prompt_bufnr)
            if selection and selection.value then
              vim.schedule(function()
                if vim.api.nvim_buf_is_valid(bufnr) then
                  local target_win = nil
                  for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_get_buf(win) == bufnr then
                      target_win = win
                      break
                    end
                  end
                  if target_win then
                    vim.api.nvim_set_current_win(target_win)
                    vim.cmd("RosRpc load " .. vim.fn.fnameescape(selection.value))
                  else
                    vim.api.nvim_buf_call(bufnr, function()
                      vim.cmd("RosRpc load " .. vim.fn.fnameescape(selection.value))
                    end)
                  end
                end
              end)
            end
          end
          map("i", "<CR>", confirm)
          map("n", "<CR>", confirm)
          return true
        end,
      })
      :find()
  end)
end

return M
