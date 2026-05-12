local M = {}
local Utils = require("nvim-ros2.utils")
local Ros2 = require("nvim-ros2.api.ros2")
local function ros_picker(opts)
  local output = Ros2.get_command_output(opts.system_cmd)
  if not output then
    return
  end

  -- Sprint 5+: Build actions table with custom injects
  local actions = {
    ["default"] = function(selected)
      if opts.on_select and selected and #selected > 0 then
        opts.on_select(selected[1])
      end
    end,
  }

  if opts.custom_actions then
    for key, def in pairs(opts.custom_actions) do
      -- Translate Neovim "<C-t>" to fzf-lua "ctrl-t"
      local fzf_key = key:gsub("<[cC]%-(.)>", "ctrl-%1"):lower()
      actions[fzf_key] = function(selected)
        if selected and #selected > 0 then
          def.callback(selected[1])
        end
      end
    end
  end

  local fzf = require("fzf-lua")
  fzf.fzf_exec(output, {
    prompt = opts.prompt_title .. "> ",
    preview = function(selected)
      if not selected or #selected == 0 then
        return {}
      end
      local item = selected[1]
      local cmd = { "ros2", opts.command, opts.mode, item }
      if opts.args and opts.args ~= "" then
        table.insert(cmd, opts.args)
      end
      return vim.fn.systemlist(cmd)
    end,
    actions = actions,
  })
end

-- lua/nvim-ros2/pickers/fzf.lua
-- Replace your current M.interfaces() function entirely:

function M.interfaces()
  local command = { "ros2", "interface", "list" }
  local raw_output = Ros2.get_command_output(command)
  if not raw_output then
    return
  end

  local items = {}
  for _, line in ipairs(raw_output) do
    local section_header = line:match("^%s*(%a+):$")
    if not section_header then
      local trimmed_line = line:match("^%s*(.-)%s*$")
      if trimmed_line ~= "" then
        table.insert(items, trimmed_line)
      end
    end
  end

  local fzf = require("fzf-lua")
  fzf.fzf_exec(items, {
    prompt = "Select Interface> ",
    preview = function(selected)
      if not selected or #selected == 0 then
        return {}
      end
      local item = selected[1]
      local cmd = { "ros2", "interface", "show", item }
      return vim.fn.systemlist(cmd)
    end,
    actions = {
      -- [NEW] Wire up the default selection action to our Utils jumper
      ["default"] = function(selected)
        if not selected or #selected == 0 then
          return
        end
        Ros2.jump_to_interface(selected[1])
      end,
    },
  })
end

function M.nodes(opts)
  opts = opts or {}
  local node_opts = vim.tbl_extend("force", {
    prompt_title = "Active Nodes",
    system_cmd = { "ros2", "node", "list" },
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
        desc = "Attach ROS Tuner",
        callback = function(node_name)
          if require("nvim-ros2.config").options.tuner then
            require("nvim-ros2.tuner").attach_node(node_name, true)
          else
            vim.notify("ROS Tuner is disabled in config", vim.log.levels.WARN)
          end
        end,
      },
    },
  }, opts)

  ros_picker(node_opts)
end

function M.actions()
  ros_picker({
    prompt_title = "Active Actions",
    system_cmd = { "ros2", "action", "list" },
    command = "action",
    mode = "info",
    args = "--show-types",
  })
end

function M.services()
  ros_picker({
    prompt_title = "Active Services",
    system_cmd = { "ros2", "service", "list" },
    command = "service",
    mode = "type",
    args = "",
  })
end

function M.topics_info()
  ros_picker({
    prompt_title = "Active Topics",
    system_cmd = { "ros2", "topic", "list" },
    command = "topic",
    mode = "info",
    args = "--verbose",
  })
end

function M.topics_echo()
  ros_picker({
    prompt_title = "Listen to Topic",
    system_cmd = { "ros2", "topic", "list" },
    command = "topic",
    mode = "info",
    args = "",
    on_select = Ros2.listen_topic,
  })
end

-- lua/nvim-ros2/pickers/fzf.lua
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

    local fzf_items = {}
    for _, item in ipairs(items) do
      local icon = item.is_global and "🌐" or "📦"
      -- Hide state inside the string: Text Icon \t is_global \t pkg_dir
      local hidden_data = string.format("%s\t%s", tostring(item.is_global), item.pkg_dir or "")
      table.insert(fzf_items, string.format("%s %s\t%s", item.text, icon, hidden_data))
    end

    require("fzf-lua").fzf_exec(fzf_items, {
      prompt = "ROS 2 Packages> ",
      preview = function(selected)
        if not selected or #selected == 0 then
          return {}
        end
        local display, is_global_str, pkg_dir = selected[1]:match("^(.-)\t(.-)\t(.*)$")
        local pkg_name = display:match("^(%S+)")
        local is_global = is_global_str == "true"

        if is_global and pkg_dir == "" then
          -- FZF's preview is synchronous. A slight block (50ms) here on hover is standard for its engine
          local out = vim.fn.systemlist("ros2 pkg prefix " .. pkg_name)
          if #out > 0 then
            local prefix = out[1]:gsub("%s+", "")
            return vim.fn.systemlist("ls -la " .. prefix .. "/share/" .. pkg_name)
          end
          return { "Failed to resolve path." }
        else
          local target = is_global and (pkg_dir .. "/share/" .. pkg_name) or pkg_dir
          return vim.fn.systemlist("ls -la " .. target)
        end
      end,
      actions = {
        ["default"] = function(selected)
          if not selected or #selected == 0 then
            return
          end
          local display, is_global_str, pkg_dir = selected[1]:match("^(.-)\t(.-)\t(.*)$")
          local pkg_name = display:match("^(%S+)")
          local is_global = is_global_str == "true"

          if pkg_dir ~= "" then
            local target = is_global and (pkg_dir .. "/share/" .. pkg_name) or pkg_dir
            Utils.open_directory(target)
          else
            vim.system({ "ros2", "pkg", "prefix", pkg_name }, { text = true }, function(out)
              vim.schedule(function()
                if out.code == 0 and out.stdout ~= "" then
                  local prefix = out.stdout:gsub("%s+", "")
                  Utils.open_directory(prefix .. "/share/" .. pkg_name)
                end
              end)
            end)
          end
        end,
      },
    })
  end)
end

function M.sniper(subdir)
  local pkg = Utils.get_package_root(0)
  if not pkg then
    return
  end
  local target = pkg .. "/" .. subdir

  if vim.fn.isdirectory(target) == 0 then
    vim.fn.mkdir(target, "p")
  end

  local files = vim.split(vim.fn.glob(target .. "/*"), "\n", { trimempty = true })
  if #files == 1 then
    vim.cmd("edit " .. files[1])
  elseif #files > 1 then
    require("fzf-lua").files({ cwd = target, prompt = subdir .. " Files> " })
  else
    Utils.open_directory(target)
  end
end

function M.find_files_package()
  local pkg = Utils.get_package_root(0)
  if pkg then
    require("fzf-lua").files({ cwd = pkg, prompt = "Find in Package> " })
  else
    vim.notify("Not inside a ROS 2 package", vim.log.levels.WARN)
  end
end

function M.grep_package()
  local pkg = Utils.get_package_root(0)
  if pkg then
    require("fzf-lua").live_grep({ cwd = pkg, prompt = "Grep in Package> " })
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
    local items = {}
    for _, f in ipairs(files) do
      -- Format string to hide the absolute path but let the previewer read it
      table.insert(items, string.format("%s\t%s", f:sub(#ws_root + 2), f))
    end

    require("fzf-lua").fzf_exec(items, {
      prompt = "Load Payload (" .. state.type .. ")> ",
      previewer = "builtin",
      fn_transform = function(x)
        return require("fzf-lua.make_entry").file(x:match("\t(.*)$"))
      end,
      actions = {
        ["default"] = function(selected)
          if not selected or #selected == 0 then
            return
          end
          local file_path = selected[1]:match("\t(.*)$")
          if file_path then
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
                  vim.cmd("RosRpc load " .. vim.fn.fnameescape(file_path))
                else
                  vim.api.nvim_buf_call(bufnr, function()
                    vim.cmd("RosRpc load " .. vim.fn.fnameescape(file_path))
                  end)
                end
              end
            end)
          end
        end,
      },
    })
  end)
end

return M
