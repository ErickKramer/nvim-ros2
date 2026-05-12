local M = {}
local Utils = require("nvim-ros2.utils")
local Ros2 = require("nvim-ros2.api.ros2")

local function ros_picker(opts)
  local output = Ros2.get_command_output(opts.system_cmd)
  if not output then
    return
  end
  local items = {}
  for _, line in ipairs(output) do
    table.insert(items, { text = line, item = line })
  end

  -- Sprint 5+: Dynamic Custom Actions Mapping
  local win_keys = {}
  local actions = {
    confirm = function(picker, item)
      picker:close()
      if opts.on_select and item then
        opts.on_select(item.text)
      end
    end,
  }

  if opts.custom_actions then
    for key, def in pairs(opts.custom_actions) do
      local action_name = "action_" .. key:gsub("%W", "")
      win_keys[key] = { action_name, mode = { "i", "n" }, desc = def.desc }
      actions[action_name] = function(picker, item)
        picker:close()
        if item and item.text then
          def.callback(item.text)
        end
      end
    end
  end

  Snacks.picker.pick({
    title = opts.prompt_title,
    items = items,
    format = "text",
    win = { input = { keys = win_keys } },
    actions = actions,
    preview = function(ctx)
      local item = ctx.item
      local cmd = { "ros2", opts.command, opts.mode, item.text }
      if opts.args and opts.args ~= "" then
        table.insert(cmd, opts.args)
      end

      ctx.preview:set_lines({ "Loading..." })

      vim.system(cmd, { timeout = opts.timeout or 5000 }, function(result)
        vim.schedule(function()
          pcall(function()
            if result.code == 124 then
              ctx.preview:set_lines({ "Timeout: No data received" })
            elseif result.stdout and result.stdout ~= "" then
              ctx.preview:set_lines(vim.split(result.stdout, "\n", { trimempty = true }))
              ctx.preview:highlight({ lang = "yaml" })
            elseif result.stderr and result.stderr ~= "" then
              ctx.preview:set_lines(vim.split(result.stderr, "\n", { trimempty = true }))
            else
              ctx.preview:set_lines({ "No data" })
            end
          end)
        end)
      end)
    end,
  })
end

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
        table.insert(items, {
          text = trimmed_line,
          item = trimmed_line,
        })
      end
    end
  end

  Snacks.picker.pick({
    title = "Select Interface",
    items = items,
    format = "text",
    preview = function(ctx)
      local item = ctx.item
      local cmd = { "ros2", "interface", "show", item.text }
      local preview_output = vim.fn.systemlist(cmd)
      ctx.preview:set_lines(preview_output)
      ctx.preview:highlight({ lang = "ros2" })
    end,
    confirm = function(picker, item)
      picker:close()
      if item and item.text then
        Ros2.jump_to_interface(item.text)
      end
    end,
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
            vim.notify("ROS Tuner is disabled in config.", vim.log.levels.WARN)
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

function M.actions()
  ros_picker({
    prompt_title = "Active Actions",
    system_cmd = { "ros2", "action", "list" },
    command = "action",
    mode = "info",
    args = "--show-types",
    on_select = function(item_text)
      Ros2.call_rpc("action", item_text)
    end, -- [NEW]
  })
end

function M.services()
  ros_picker({
    prompt_title = "Active Services",
    system_cmd = { "ros2", "service", "list" },
    command = "service",
    mode = "type",
    args = "",
    on_select = function(item_text)
      Ros2.call_rpc("service", item_text)
    end, -- [NEW]
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

function M.packages()
  local ws_root = Utils.get_workspace_root(0)
  local config = require("nvim-ros2.config").options

  local show_global = true
  if config.pickers and config.pickers.packages and config.pickers.packages.show_global ~= nil then
    show_global = config.pickers.packages.show_global
  end

  Utils.get_merged_packages(ws_root, show_global, function(base_items)
    if #base_items == 0 then
      vim.notify("No ROS 2 packages found.", vim.log.levels.WARN)
      return
    end

    local items = {}
    for _, item in ipairs(base_items) do
      local preview_file = item.pkg_dir

      -- Attempt to locate README for local packages
      if not item.is_global and item.pkg_dir then
        for _, v in ipairs({ "/README.md", "/README" }) do
          if vim.uv.fs_stat(item.pkg_dir .. v) then
            preview_file = item.pkg_dir .. v
            break
          end
        end
      end

      table.insert(items, {
        text = item.text,
        icon = item.is_global and "🌐" or "📦",
        pkg_dir = item.pkg_dir,
        file = preview_file,
        is_global = item.is_global,
      })
    end

    Snacks.picker.pick({
      title = "ROS 2 Packages",
      items = items,
      format = function(item, _)
        local hl = item.is_global and "Comment" or "Normal"
        return {
          { item.icon .. " ", "Normal" },
          { item.text, hl },
        }
      end,
      preview = function(ctx)
        local item = ctx.item

        -- Helper to trigger the native file/directory previewer
        local function show_native()
          -- Safely invoke the native Snacks previewer (renders both files and beautiful directory trees)
          local ok = pcall(function()
            Snacks.picker.preview.file(ctx)
          end)
          if not ok then
            ok = pcall(function()
              require("snacks.picker.preview").file(ctx)
            end)
          end

          -- Ultimate fallback ONLY if the Snacks API is entirely unavailable/incompatible
          if not ok then
            vim.schedule(function()
              ctx.preview:set_lines(
                vim.fn.systemlist("ls -la " .. (item.file or item.pkg_dir or "."))
              )
              ctx.preview:highlight({ lang = "bash" })
            end)
          end
        end

        -- 1. Lazy Path Resolution for Global Packages
        if item.is_global and not item.pkg_dir then
          ctx.preview:set_lines({ "Loading global package path..." })
          vim.system({ "ros2", "pkg", "prefix", item.text }, { text = true }, function(out)
            vim.schedule(function()
              if out.code == 0 and out.stdout ~= "" then
                local prefix = out.stdout:gsub("%s+", "")
                item.pkg_dir = prefix
                item.file = prefix .. "/share/" .. item.text

                -- Hand off to the native tree renderer
                show_native()
              else
                ctx.preview:set_lines({ "Failed to locate package prefix." })
              end
            end)
          end)
          return
        end

        -- 2. Ensure item.file is set for global items that are already resolved
        if item.is_global and item.pkg_dir and not item.file then
          item.file = item.pkg_dir .. "/share/" .. item.text
        end

        -- 3. Ensure item.file is set for local items without a README
        if not item.file and item.pkg_dir then
          item.file = item.pkg_dir
        end

        -- 4. Delegate entirely to the beautiful native Snacks file/directory previewer!
        show_native()
      end,
      actions = {
        confirm = function(picker, item)
          picker:close()
          if not item then
            return
          end

          -- If resolved (local, or hovered global)
          if item.pkg_dir then
            local target = item.is_global and (item.pkg_dir .. "/share/" .. item.text)
              or item.pkg_dir
            Utils.open_directory(target)

            -- If skipped preview and confirmed immediately (Lazy fetch)
          elseif item.is_global then
            vim.notify("Resolving global package...", vim.log.levels.INFO)
            vim.system({ "ros2", "pkg", "prefix", item.text }, { text = true }, function(out)
              vim.schedule(function()
                if out.code == 0 and out.stdout ~= "" then
                  local prefix = out.stdout:gsub("%s+", "")
                  Utils.open_directory(prefix .. "/share/" .. item.text)
                else
                  vim.notify("Could not find package path", vim.log.levels.ERROR)
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
    vim.notify("Created missing directory: " .. subdir, vim.log.levels.INFO)
  end

  local files = vim.split(vim.fn.glob(target .. "/*"), "\n", { trimempty = true })
  if #files == 1 then
    vim.cmd("edit " .. files[1])
  elseif #files > 1 then
    Snacks.picker.files({ cwd = target, title = subdir .. " Files" })
  else
    Utils.open_directory(target)
  end
end

function M.find_files_package()
  local pkg = Utils.get_package_root(0)
  if pkg then
    Snacks.picker.files({
      cwd = pkg,
      title = "Find in Package: " .. vim.fs.basename(pkg),
    })
  else
    vim.notify("Not inside a ROS 2 package", vim.log.levels.WARN)
  end
end

function M.grep_package()
  local pkg = Utils.get_package_root(0)
  if pkg then
    Snacks.picker.grep({
      cwd = pkg,
      title = "Grep in Package: " .. vim.fs.basename(pkg),
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

    local items = {}
    local ws_root = Utils.get_workspace_root(bufnr)

    for _, f in ipairs(files) do
      table.insert(items, {
        -- Show nice relative paths in the picker UI
        text = f:sub(#ws_root + 2),
        file = f,
      })
    end

    Snacks.picker.pick({
      title = "Load Payload (" .. state.type .. ")",
      items = items,
      format = "file",
      actions = {
        confirm = function(picker, item)
          picker:close()
          if item and item.file then
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(bufnr) then
                -- Find the actual window holding our scratch buffer
                local target_win = nil
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  if vim.api.nvim_win_get_buf(win) == bufnr then
                    target_win = win
                    break
                  end
                end

                -- Forcefully move the cursor to that window before executing the load
                if target_win then
                  vim.api.nvim_set_current_win(target_win)
                  vim.cmd("RosRpc load " .. vim.fn.fnameescape(item.file))
                else
                  -- Fallback if the buffer is somehow completely hidden
                  vim.api.nvim_buf_call(bufnr, function()
                    vim.cmd("RosRpc load " .. vim.fn.fnameescape(item.file))
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
