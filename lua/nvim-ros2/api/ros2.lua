-- lua/nvim-ros2/api/ros2.lua

local M = {}
local Utils = require("nvim-ros2.utils")

--------------------------------------------------------------------------------
-- 1. CORE EXECUTION
--------------------------------------------------------------------------------

--- Safely executes a synchronous system command, verifying the ros2 executable exists.
function M.get_command_output(cmd)
  if vim.fn.executable("ros2") ~= 1 then
    vim.notify("ros2 not found", vim.log.levels.ERROR)
    return nil
  end
  return vim.fn.systemlist(cmd)
end

-- Add this under "1. CORE EXECUTION" in api/ros2.lua
--- Fetches all ROS 2 packages known to the environment (local + global)
function M.get_all_packages(cb)
  vim.system({ "ros2", "pkg", "list" }, { text = true, timeout = 5000 }, function(out)
    vim.schedule(function()
      if out.code ~= 0 or out.stdout == "" then
        cb({})
      else
        cb(vim.split(out.stdout, "\n", { trimempty = true }))
      end
    end)
  end)
end

--------------------------------------------------------------------------------
-- 2. NAVIGATION & TOPICS
--------------------------------------------------------------------------------

--- Parses a ROS 2 interface string (e.g., "std_msgs/msg/String") and jumps to its source file.
function M.jump_to_interface(item_text)
  if not item_text or item_text == "" then
    return
  end

  local pkg, sub, name = item_text:match("^([^/]+)/([^/]+)/(.+)$")
  if not pkg or not name then
    return
  end

  local ext = sub == "msg" and ".msg" or sub == "srv" and ".srv" or ".action"
  local filename = name .. ext

  local ws_root = Utils.get_workspace_root(0)

  local function open_file(path)
    local realpath = vim.uv.fs_realpath(path) or path
    vim.schedule(function()
      vim.cmd("edit " .. realpath)
    end)
  end

  vim.system({ "ros2", "pkg", "prefix", pkg }, { text = true }, function(out)
    vim.schedule(function()
      if out.code == 0 and out.stdout ~= "" then
        local prefix = out.stdout:gsub("%s+", "")
        local install_path = string.format("%s/share/%s/%s/%s", prefix, pkg, sub, filename)

        if prefix:match("^/opt/ros/") then
          if vim.fn.filereadable(install_path) == 1 then
            return open_file(install_path)
          end
        end

        if ws_root then
          local workspace_packages = Utils.get_workspace_packages(ws_root)
          local target_pkg_dir = workspace_packages[pkg]

          if target_pkg_dir then
            local target_file = string.format("%s/%s/%s", target_pkg_dir, sub, filename)
            if vim.fn.filereadable(target_file) == 1 then
              return open_file(target_file)
            end
          end
        end

        if vim.fn.filereadable(install_path) == 1 then
          open_file(install_path)
        else
          vim.notify("Definition not found in src or install space.", vim.log.levels.WARN)
        end
      else
        vim.notify("Could not locate package: " .. pkg, vim.log.levels.ERROR)
      end
    end)
  end)
end

--- Creates a live-updating scratch buffer attached to a continuous ROS 2 topic echo.
function M.listen_topic(topic_name)
  if not topic_name or topic_name == "" then
    return
  end
  local active_win = Utils.get_target_window()
  vim.notify("🎧 Listening to " .. topic_name .. "...", vim.log.levels.INFO)

  local scratch = vim.api.nvim_create_buf(false, true)
  vim.bo[scratch].buftype = ""
  vim.bo[scratch].bufhidden = "wipe"
  vim.bo[scratch].filetype = "yaml"
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = scratch,
    callback = function()
      vim.notify("Topic listener is read-only.", vim.log.levels.WARN)
      vim.bo[scratch].modified = false
    end,
  })
  pcall(vim.api.nvim_buf_set_name, scratch, "ROS_LISTEN_" .. topic_name:gsub("/", "_"))
  if vim.api.nvim_win_is_valid(active_win) then
    vim.api.nvim_set_current_win(active_win)
  end
  vim.api.nvim_set_current_buf(scratch)

  local msg_accumulator = {}
  local cmd = { "ros2", "topic", "echo", "--no-arr", topic_name }

  local job_id = vim.fn.jobstart(cmd, {
    stdout_buffered = false,
    env = { PYTHONUNBUFFERED = "1", RCUTILS_COLORIZED_OUTPUT = "0" },
    on_stdout = function(_, data, _)
      if not data then
        return
      end

      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(scratch) then
          return
        end

        vim.bo[scratch].modifiable = true

        for _, line in ipairs(data) do
          local clean_line = line:gsub("\r", "")

          if clean_line:match("^%-%-%-") then
            if #msg_accumulator > 0 then
              vim.api.nvim_buf_set_lines(scratch, 0, -1, false, msg_accumulator)
            end
            msg_accumulator = {}
          elseif clean_line ~= "" then
            table.insert(msg_accumulator, clean_line)
          end
        end

        vim.bo[scratch].modifiable = false
        vim.bo[scratch].modified = false
      end)
    end,
    on_stderr = function(_, data, _)
      if not data then
        return
      end
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(scratch) then
          return
        end
        vim.bo[scratch].modifiable = true
        local errs = {}
        for _, line in ipairs(data) do
          local clean = line:gsub("\r", "")
          if clean ~= "" then
            table.insert(errs, "# STDERR: " .. clean)
          end
        end
        if #errs > 0 then
          vim.api.nvim_buf_set_lines(scratch, -1, -1, false, errs)
        end
        vim.bo[scratch].modifiable = false
        vim.bo[scratch].modified = false
      end)
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(scratch) then
          vim.bo[scratch].modifiable = true
          if #msg_accumulator > 0 then
            vim.api.nvim_buf_set_lines(scratch, 0, -1, false, msg_accumulator)
          end
          vim.api.nvim_buf_set_lines(
            scratch,
            -1,
            -1,
            false,
            { "", "# Subscriber closed (code " .. code .. ")." }
          )
          vim.bo[scratch].modifiable = false
          vim.bo[scratch].modified = false
        end
      end)
    end,
  })

  if job_id <= 0 then
    vim.notify("❌ Failed to launch topic listener!", vim.log.levels.ERROR)
  end

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = scratch,
    callback = function()
      if job_id > 0 then
        vim.fn.jobstop(job_id)
        vim.notify("Stopped listening to " .. topic_name, vim.log.levels.INFO)
      end
    end,
  })
end

--------------------------------------------------------------------------------
-- 3. PAYLOAD DISCOVERY API
--------------------------------------------------------------------------------

local _payload_cache = {}
local cache_group = vim.api.nvim_create_augroup("Ros2PayloadCache", { clear = true })

-- Auto-invalidate the payload cache whenever a YAML/Param file is edited
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.yaml", "*.param" },
  group = cache_group,
  callback = function()
    _payload_cache = {}
  end,
})

--- Scans the current package for saved YAML payloads matching the specified interface type.
function M.get_saved_payloads(interface_type, bufnr, cb)
  if not interface_type or interface_type == "" then
    return cb({})
  end

  local safe_type = interface_type:gsub("%s+", "")
  local ws_root = Utils.get_workspace_root(bufnr)
  local cache_key = ws_root .. "_" .. safe_type

  if _payload_cache[cache_key] then
    return cb(_payload_cache[cache_key])
  end

  local find_cmd = vim.fn.executable("fd") == 1
      and {
        "fd",
        ".",
        ws_root,
        "-e",
        "yaml",
        "-e",
        "param",
        "-E",
        "build",
        "-E",
        "install",
        "-E",
        "log",
      }
    or {
      "find",
      ws_root,
      "-type",
      "f",
      "(",
      "-name",
      "*.yaml",
      "-o",
      "-name",
      "*.param",
      ")",
      "-not",
      "-path",
      "*/build/*",
      "-not",
      "-path",
      "*/install/*",
      "-not",
      "-path",
      "*/log/*",
    }

  vim.system(find_cmd, { text = true }, function(out)
    vim.schedule(function()
      local compatible_files = {}

      if out.code == 0 and out.stdout and out.stdout ~= "" then
        for _, f in ipairs(vim.split(out.stdout, "\n", { trimempty = true })) do
          local clean_f = f:gsub("\r", "")
          local file = io.open(clean_f, "r")

          if file then
            for _ = 1, 5 do
              local line = file:read("*l")
              if not line then
                break
              end

              local file_type = line:match("^#%s*Type:%s*(%S+)")
              if file_type and file_type:gsub("%s+", "") == safe_type then
                table.insert(compatible_files, clean_f)
                break
              end
            end
            file:close()
          end
        end
      end

      _payload_cache[cache_key] = compatible_files
      cb(compatible_files)
    end)
  end)
end

--------------------------------------------------------------------------------
-- 4. RPC EXECUTION HELPERS
--------------------------------------------------------------------------------

-- Fetches interface type asynchronously
local function rpc_fetch_type(target_category, target_name, cb)
  if target_category == "action" then
    vim.system({ "ros2", "action", "list", "-t" }, { text = true, timeout = 3000 }, function(out)
      vim.schedule(function()
        for _, line in ipairs(vim.split(out.stdout or "", "\n")) do
          local n, type_str = line:match("^(%S+)%s+%[(.-)%]")
          if n == target_name then
            return cb(type_str)
          end
        end
        cb(nil)
      end)
    end)
  else
    vim.system(
      { "ros2", "service", "type", target_name },
      { text = true, timeout = 3000 },
      function(out)
        vim.schedule(function()
          local t = out.code == 0 and out.stdout:match("^%s*(.-)%s*$")
          cb(t ~= "" and t or nil)
        end)
      end
    )
  end
end

-- Extracts the payload from the scratch buffer
local function rpc_get_payload(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local raw_lines, clean_lines = {}, {}
  local start_idx, end_idx = -1, -1
  local in_payload = false

  for i, l in ipairs(lines) do
    if l:match("^#%s*%-%-%-%s*RESPONSE") then
      end_idx = i
      break
    end
    if in_payload then
      table.insert(raw_lines, l)
      if not l:match("^%s*#") and not l:match("^%s*$") then
        table.insert(clean_lines, l)
      end
    end
    if l:match("^%-%-%-") and not l:match("RESPONSE") then
      in_payload = true
      start_idx = i
    end
  end
  return raw_lines, clean_lines, start_idx, end_idx
end

-- Saves the payload to disk with Type Metadata
local function rpc_save(bufnr, filepath)
  local state = vim.b[bufnr].ros_rpc_state
  local raw_lines, _, _, _ = rpc_get_payload(bufnr)

  local function write_to_disk(path)
    local f = io.open(path, "w")
    if f then
      if #raw_lines == 0 or not raw_lines[1]:match("^# Type:") then
        f:write("# Type: " .. state.type .. "\n")
      end
      f:write(table.concat(raw_lines, "\n"))
      f:close()

      state.path = path
      vim.b[bufnr].ros_rpc_state = state
      vim.notify("💾 Payload saved: " .. path, vim.log.levels.INFO)
    else
      vim.notify("Failed to save payload to: " .. path, vim.log.levels.ERROR)
    end
  end

  if filepath and filepath ~= "" then
    write_to_disk(filepath)
  elseif state.path then
    write_to_disk(state.path)
  else
    local default = Utils.get_package_root(bufnr) .. "/" .. state.name:gsub("/", "_") .. ".yaml"
    vim.ui.input(
      { prompt = "Save payload as: ", default = default, completion = "file" },
      function(input)
        if input and input ~= "" then
          write_to_disk(input)
        end
      end
    )
  end
end

-- Loads a payload from disk into the buffer (Pure command)
local function rpc_load(bufnr, filepath)
  local state = vim.b[bufnr].ros_rpc_state

  local function read_from_disk(path)
    if vim.fn.filereadable(path) == 1 then
      local lines = {}
      for line in io.lines(path) do
        if not line:match("^#%s*Type:") then
          table.insert(lines, line)
        end
      end

      local _, _, start_idx, end_idx = rpc_get_payload(bufnr)
      vim.bo[bufnr].modifiable = true
      local replace_end = (end_idx ~= -1) and (end_idx - 1) or -1
      vim.api.nvim_buf_set_lines(bufnr, start_idx, replace_end, false, lines)
      vim.bo[bufnr].modifiable = false

      state.path = path
      vim.b[bufnr].ros_rpc_state = state
      vim.notify("📂 Loaded: " .. path, vim.log.levels.INFO)
    else
      vim.notify("File not found or not readable: " .. path, vim.log.levels.ERROR)
    end
  end

  if filepath and filepath ~= "" then
    read_from_disk(filepath)
  else
    vim.ui.input({
      prompt = "Load YAML: ",
      default = Utils.get_package_root(bufnr) .. "/",
      completion = "file",
    }, function(input)
      if input and input ~= "" then
        read_from_disk(input)
      end
    end)
  end
end

-- Sends a SIGINT (Ctrl-C) to the running Action/Service
local function rpc_stop(bufnr)
  local state = vim.b[bufnr].ros_rpc_state
  if state and state.job_id then
    local pid = vim.fn.jobpid(state.job_id)
    if pid > 0 then
      vim.fn.system({ "kill", "-INT", tostring(pid) })
      vim.notify("Sent cancel request (SIGINT) to action server.", vim.log.levels.INFO)
    else
      vim.fn.jobstop(state.job_id)
    end
    state.job_id = nil
    vim.b[bufnr].ros_rpc_state = state
  else
    vim.notify("No process is currently running.", vim.log.levels.WARN)
  end
end

-- Helper: Cleans Pythonic CLI output into standard YAML
-- Helper: Safely parses Pythonic CLI output into standard YAML without corrupting nested data
local function rpc_format_to_yaml(line)
  if
    line:match("requester:")
    or line:match("making request")
    or line:match("Goal accepted")
    or line:match("waiting for result")
    or line:match("Waiting for an action")
    or line:match("Sending goal")
    or line:match("Goal finished")
    or line:match("^[Ff]eedback:$")
    or line:match("^[Rr]esult:$")
    or line:match("^[Rr]esponse:$")
    or line:match("^%s*$")
  then
    return nil
  end

  local inner = line:match("[%w_%.]+%((.*)%)") or line
  local clean = inner:gsub("([%w_]+)%s*=%s*", "%1: "):gsub("True", "true"):gsub("False", "false")

  -- Depth-aware string walker to safely break top-level fields into YAML lines
  local out = ""
  local depth = 0
  local in_quote = false
  local quote_char = ""
  local i = 1

  while i <= #clean do
    local c = clean:sub(i, i)
    local prev_c = i > 1 and clean:sub(i - 1, i - 1) or ""

    if (c == "'" or c == '"') and prev_c ~= "\\" then
      if not in_quote then
        in_quote = true
        quote_char = c
      elseif quote_char == c then
        in_quote = false
      end
    elseif not in_quote then
      if c == "(" or c == "[" or c == "{" then
        depth = depth + 1
      elseif c == ")" or c == "]" or c == "}" then
        depth = depth - 1
      elseif c == "," and depth == 0 then
        local remainder = clean:sub(i + 1)
        -- Only split if the comma is at depth 0 AND is immediately followed by a standard key: pair
        if remainder:match("^%s*([%w_]+):") then
          out = out .. "\n"
          local spaces = remainder:match("^(%s*)")
          i = i + #spaces
          c = "" -- Drop the comma
        end
      end
    end
    out = out .. c
    i = i + 1
  end

  return out:gsub("^\n", ""):gsub("^%s+", "")
end
-- Executes the ROS 2 call and streams the feedback
local function rpc_execute(bufnr)
  local state = vim.b[bufnr].ros_rpc_state
  if state.job_id then
    vim.notify("Process already running. Run :RosRpc stop to abort.", vim.log.levels.WARN)
    return
  end

  local _, clean_payload, _, response_header_idx = rpc_get_payload(bufnr)
  local final_payload = #clean_payload > 0 and table.concat(clean_payload, "\n") or "{}"

  local cmd = state.category == "service"
      and { "ros2", "service", "call", state.name, state.type, final_payload }
    or { "ros2", "action", "send_goal", "--feedback", state.name, state.type, final_payload }

  vim.bo[bufnr].modifiable = true
  local header = {
    "",
    "# --- RESPONSE",
    "# Started at: " .. os.date("%H:%M:%S"),
    "# Run :RosRpc stop to cancel",
  }

  local response_data_start = 0
  if response_header_idx ~= -1 then
    vim.api.nvim_buf_set_lines(bufnr, response_header_idx - 1, -1, false, header)
    response_data_start = response_header_idx - 1 + #header
  else
    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, header)
    response_data_start = vim.api.nvim_buf_line_count(bufnr)
  end
  vim.bo[bufnr].modifiable = false

  local log_lines = {}
  local current_block = {}
  local current_mode = "Response"
  local last_feedback_str = ""

  local function flush_block()
    if #current_block == 0 then
      return
    end
    local block_str = table.concat(current_block, "\n")
    if current_mode == "Feedback" then
      if block_str ~= last_feedback_str then
        last_feedback_str = block_str
        table.insert(log_lines, "")
        table.insert(log_lines, "# [Feedback - " .. os.date("%H:%M:%S") .. "]")
        for _, l in ipairs(current_block) do
          table.insert(log_lines, l)
        end
      end
    else
      if current_mode == "Result" then
        table.insert(log_lines, "")
        table.insert(log_lines, "# [Result]")
      end
      for _, l in ipairs(current_block) do
        table.insert(log_lines, l)
      end
    end
    current_block = {}

    -- Limit buffer growth for high-frequency actions
    while #log_lines > 500 do
      table.remove(log_lines, 1)
    end
  end

  state.job_id = vim.fn.jobstart(cmd, {
    stdout_buffered = false,
    env = { PYTHONUNBUFFERED = "1", RCUTILS_COLORIZED_OUTPUT = "0" },
    on_stdout = function(_, data)
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        local updated = false

        for _, raw in ipairs(data) do
          local l = raw:gsub("\r", "")
          if l:match("^[Ff]eedback:$") then
            flush_block()
            current_mode = "Feedback"
          elseif l:match("^[Rr]esult:$") then
            flush_block()
            current_mode = "Result"
          elseif l:match("^[Rr]esponse:$") then
            flush_block()
            current_mode = "Response"
          else
            local clean = rpc_format_to_yaml(l)
            if clean and clean ~= "" then
              for _, s in ipairs(vim.split(clean, "\n")) do
                table.insert(current_block, s)
                updated = true
              end
            end
          end
        end

        if updated then
          local render_lines = {}
          for _, l in ipairs(log_lines) do
            table.insert(render_lines, l)
          end
          if #current_block > 0 then
            if current_mode == "Feedback" then
              local temp_str = table.concat(current_block, "\n")
              if temp_str ~= last_feedback_str then
                table.insert(render_lines, "")
                table.insert(render_lines, "# [Feedback - " .. os.date("%H:%M:%S") .. "]")
                for _, l in ipairs(current_block) do
                  table.insert(render_lines, l)
                end
              end
            else
              if current_mode == "Result" then
                table.insert(render_lines, "")
                table.insert(render_lines, "# [Result]")
              end
              for _, l in ipairs(current_block) do
                table.insert(render_lines, l)
              end
            end
          end
          if #render_lines > 0 then
            vim.bo[bufnr].modifiable = true
            vim.api.nvim_buf_set_lines(bufnr, response_data_start, -1, false, render_lines)
            vim.bo[bufnr].modifiable = false
          end
        end
      end)
    end,
    on_stderr = function(_, data)
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        local err_updated = false
        for _, l in ipairs(data) do
          local clean = l:gsub("\r", "")
          if clean ~= "" then
            table.insert(log_lines, "# STDERR: " .. clean)
            err_updated = true
          end
        end
        if err_updated then
          local render_lines = {}
          for _, l in ipairs(log_lines) do
            table.insert(render_lines, l)
          end
          for _, l in ipairs(current_block) do
            table.insert(render_lines, l)
          end
          vim.bo[bufnr].modifiable = true
          vim.api.nvim_buf_set_lines(bufnr, response_data_start, -1, false, render_lines)
          vim.bo[bufnr].modifiable = false
        end
      end)
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        flush_block()
        local render_lines = {}
        for _, l in ipairs(log_lines) do
          table.insert(render_lines, l)
        end
        table.insert(render_lines, "")
        table.insert(
          render_lines,
          "# Completed " .. (code == 0 and "✅" or "❌ (code " .. code .. ")")
        )

        vim.bo[bufnr].modifiable = true
        vim.api.nvim_buf_set_lines(bufnr, response_data_start, -1, false, render_lines)
        vim.bo[bufnr].modifiable = false

        local current_state = vim.b[bufnr].ros_rpc_state
        current_state.job_id = nil
        vim.b[bufnr].ros_rpc_state = current_state
      end)
    end,
  })
  vim.b[bufnr].ros_rpc_state = state
end

-- Command Router for the :RosRpc subcommands
local function rpc_command_router(opts)
  local args = vim.split(opts.args, "%s+", { trimempty = true })
  local action = args[1]
  local filepath = args[2]
  local bufnr = vim.api.nvim_get_current_buf()

  if action == "send" then
    rpc_execute(bufnr)
  elseif action == "load" then
    rpc_load(bufnr, filepath)
  elseif action == "save" then
    rpc_save(bufnr, filepath)
  elseif action == "stop" then
    rpc_stop(bufnr)
  else
    vim.notify("Usage: :RosRpc send | load [path] | save [path] | stop", vim.log.levels.ERROR)
  end
end

--------------------------------------------------------------------------------
-- 5. RPC MAIN ENGINE
--------------------------------------------------------------------------------

function M.call_rpc(target_category, item_text)
  if not item_text or item_text == "" then
    return
  end
  local target_name = item_text:match("^(%S+)")

  -- Check if type is already embedded from picker payload
  local interface_type = item_text:match("%[(.-)%]")
  local active_win = Utils.get_target_window()
  local function on_type_fetched(itype)
    if not itype then
      vim.notify("Could not determine type for " .. target_name, vim.log.levels.ERROR)
      return
    end

    vim.system({ "ros2", "interface", "proto", itype }, { text = true }, function(out)
      vim.schedule(function()
        local proto_yaml = (out.code == 0 and out.stdout ~= "") and out.stdout or "{}"
        proto_yaml = proto_yaml:gsub("^%s*[\"']", ""):gsub("[\"']%s*$", "")

        local scratch = vim.api.nvim_create_buf(false, true)
        vim.bo[scratch].buftype = ""
        vim.bo[scratch].bufhidden = "wipe"
        vim.bo[scratch].filetype = "yaml"
        pcall(vim.api.nvim_buf_set_name, scratch, "ROS_CALL_" .. target_name:gsub("/", "_"))

        -- Inject State safely into the buffer
        vim.b[scratch].ros_rpc_state = {
          category = target_category,
          name = target_name,
          type = itype,
          job_id = nil,
          path = nil,
        }

        local content = {
          "# 🚀 ROS 2 " .. target_category:upper() .. " CALLER",
          "# Target: " .. target_name,
          "# Commands: :RosRpc send | load [file] | save [file] | stop",
          "---",
        }

        for _, line in ipairs(vim.split(proto_yaml, "\n", { trimempty = true })) do
          table.insert(content, (line:gsub('^"', ""):gsub('"$', "")))
        end
        vim.api.nvim_buf_set_lines(scratch, 0, -1, false, content)

        if vim.api.nvim_win_is_valid(active_win) then
          vim.api.nvim_set_current_win(active_win)
        end
        vim.api.nvim_set_current_buf(scratch)

        -- Register Unified Command
        vim.api.nvim_buf_create_user_command(scratch, "RosRpc", rpc_command_router, {
          nargs = "*",
          desc = "Manage ROS 2 RPC calls",
          complete = function(arglead, cmdline)
            local parts = vim.split(cmdline, "%s+")
            if #parts == 2 then
              return vim.tbl_filter(function(v)
                return vim.startswith(v, arglead)
              end, { "send", "load", "save", "stop" })
            elseif #parts == 3 and (parts[2] == "load" or parts[2] == "save") then
              return vim.fn.getcompletion(arglead, "file")
            end
            return {}
          end,
        })

        -- Auto-save on standard :w
        vim.api.nvim_create_autocmd("BufWriteCmd", {
          buffer = scratch,
          callback = function()
            local state = vim.b[scratch].ros_rpc_state
            if state.path then
              rpc_save(scratch, state.path)
              vim.bo[scratch].modified = false
            else
              vim.notify("No save path set. Use :RosRpc save <path> first.", vim.log.levels.WARN)
            end
          end,
        })

        -- Prevent Neovim from ever asking to save this ephemeral scratch buffer on exit
        vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
          buffer = scratch,
          callback = function()
            vim.bo[scratch].modified = false
          end,
        })

        -- Cleanup jobs on close
        vim.api.nvim_create_autocmd("BufWipeout", {
          buffer = scratch,
          callback = function()
            local state = vim.b[scratch].ros_rpc_state
            if state and state.job_id then
              vim.fn.jobstop(state.job_id)
            end
          end,
        })
      end)
    end)
  end

  if interface_type then
    on_type_fetched(interface_type)
  else
    rpc_fetch_type(target_category, target_name, on_type_fetched)
  end
end

--------------------------------------------------------------------------------
-- 6. PARAMETER TUNER
--------------------------------------------------------------------------------
function M.list_nodes(cb)
  vim.system({ "ros2", "node", "list" }, { text = true, timeout = 2000 }, function(out)
    vim.schedule(function()
      if out.code ~= 0 or out.stdout == "" then
        cb({})
      else
        cb(vim.split(out.stdout, "\n", { trimempty = true }))
      end
    end)
  end)
end

function M.get_param_metadata(node_name, param_name, cb)
  vim.system(
    { "ros2", "param", "describe", node_name, param_name },
    { text = true, timeout = 2000 },
    function(out)
      vim.schedule(function()
        local meta = {}
        if out.code == 0 then
          local min_val = out.stdout:match("Min value:%s*([%d%.%-]+)")
          local max_val = out.stdout:match("Max value:%s*([%d%.%-]+)")
          if min_val and max_val then
            meta.range = string.format("[%s - %s]", min_val, max_val)
          end
        end
        cb(meta)
      end)
    end
  )
end

function M.get_param(node_name, param_name, cb)
  vim.system(
    { "ros2", "param", "get", node_name, param_name },
    { text = true, timeout = 2000 },
    function(out)
      vim.schedule(function()
        if out.code ~= 0 or out.signal ~= 0 then
          local err = (out.stderr ~= "" and out.stderr) or out.stdout
          if not err:match("Parameter not set") then
            vim.notify("ROS 2 Get Failed: " .. err, vim.log.levels.ERROR)
          end
          return
        end
        local match = out.stdout:match("value is:%s*(.-)%s*\n")
          or out.stdout:match("value is:%s*(.-)%s*$")
        if cb and match then
          cb(match)
        end
      end)
    end
  )
end

function M.set_param(node_name, param_name, value_type, value_text, cb)
  local val = (value_type == "boolean") and value_text:lower() or value_text
  vim.system(
    { "ros2", "param", "set", node_name, param_name, val },
    { text = true, timeout = 2000 },
    function(out)
      vim.schedule(function()
        if out.code ~= 0 or out.signal ~= 0 then
          local err = (out.stderr and out.stderr ~= "") and out.stderr or out.stdout
          vim.notify("ROS 2 Set Failed: " .. err, vim.log.levels.ERROR)
        elseif cb then
          cb()
        else
          vim.notify(string.format("🚀 Tuned! %s = %s", param_name, val), vim.log.levels.INFO)
        end
      end)
    end
  )
end

function M.dump_params(node_name, cb)
  vim.system({ "ros2", "param", "dump", node_name }, { text = true, timeout = 3000 }, function(out)
    vim.schedule(function()
      cb(out.code == 0 and out.stdout or nil)
    end)
  end)
end

return M
