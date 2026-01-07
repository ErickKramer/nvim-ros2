local M = {}

local function get_command_output(cmd)
  if vim.fn.executable("ros2") ~= 1 then
    vim.notify("ros2 not found", vim.log.levels.ERROR)
    return nil
  end
  return vim.fn.systemlist(cmd)
end

local function ros_picker(opts)
  local output = get_command_output(opts.system_cmd)
  if not output then
    return
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
    actions = {
      ["default"] = function() end, -- No-op
    },
  })
end

function M.interfaces()
  local command = { "ros2", "interface", "list" }
  local raw_output = get_command_output(command)
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
      ["default"] = function() end,
    },
  })
end

function M.nodes()
  ros_picker({
    prompt_title = "Active Nodes",
    system_cmd = { "ros2", "node", "list" },
    command = "node",
    mode = "info",
    args = "--include-hidden",
  })
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
    prompt_title = "Active Topics",
    system_cmd = { "ros2", "topic", "list" },
    command = "topic",
    mode = "echo",
    args = "--once",
  })
end

return M
