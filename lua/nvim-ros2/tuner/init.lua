local M = {}
local RosApi = require("nvim-ros2.api.ros2")
local Utils = require("nvim-ros2.utils")
local Engine = require("nvim-ros2.tuner.engine")
local UI = require("nvim-ros2.tuner.ui")
local Config = require("nvim-ros2.config")
-- State Management
M._cache = {}
local buffer_states = {}
local param_metadata_cache = {}

local SYSTEMIC_PARAMS = {
  use_sim_time = true,
  qos_overrides = true,
  start_type_description_service = true,
  automatically_declare_parameters_from_overrides = true,
  allow_undeclared_parameters = true,
}

local function is_systemic(param_name)
  if SYSTEMIC_PARAMS[param_name] then
    return true
  end
  if param_name:match("^qos_overrides") then
    return true
  end
  return false
end

local function parse_yaml_footprints(lines)
  local file_data = { root_keys = {}, footprints = {} }
  local path_stack = {}
  local ros_params_depth = nil
  local current_root = nil

  for _, line in ipairs(lines) do
    -- Cleans up the line by removing inline comments and trailing whitespace.
    -- "^(.-)%s+#.*$" captures everything before a space-padded '#' comment.
    -- "^(.-)%s*$" acts as a fallback to simply trim trailing whitespace if no comment exists.
    -- The non-greedy '(.-)' ensures we don't accidentally swallow the whitespace we want to trim.
    local clean_line = line:match("^(.-)%s+#.*$") or line:match("^(.-)%s*$")
    -- Parses the line to extract its leading indentation and the YAML key name.
    -- "^(%s*)" captures all leading whitespace to determine nesting depth.
    -- "['\"]?([%w_%-%.%/%*]+)['\"]?:" captures the key name (ignoring optional quotes) up to the colon.
    local indent, key = clean_line:match("^(%s*)['\"]?([%w_%-%.%/%*]+)['\"]?:")

    if key then
      local depth = #indent

      -- Clear any stack entries that are at a deeper or equal indent level
      while #path_stack > 0 and path_stack[#path_stack].depth >= depth do
        table.remove(path_stack)
      end
      table.insert(path_stack, { depth = depth, key = key })

      if ros_params_depth and depth <= ros_params_depth then
        ros_params_depth = nil
        current_root = nil
      end

      if key == "ros__parameters" then
        ros_params_depth = depth
        local root_parts = {}
        for i = 1, #path_stack - 1 do
          table.insert(root_parts, path_stack[i].key)
        end
        current_root = "/" .. table.concat(root_parts, "/")
        current_root = current_root:gsub("//+", "/") -- Safely normalize slashes

        if not file_data.footprints[current_root] then
          table.insert(file_data.root_keys, current_root)
          file_data.footprints[current_root] = {}
        end
      elseif ros_params_depth and depth > ros_params_depth and current_root then
        local param_parts = {}
        for i = 1, #path_stack do
          if path_stack[i].depth > ros_params_depth then
            table.insert(param_parts, path_stack[i].key)
          end
        end
        local param_name = table.concat(param_parts, ".")
        if not is_systemic(param_name) then
          file_data.footprints[current_root][param_name] = true
        end
      end
    end
  end
  return file_data
end

local function get_state(bufnr)
  if not buffer_states[bufnr] then
    buffer_states[bufnr] =
      { last_line = "", last_val = "", last_param = "", last_row = -1, debounce = nil }
  end
  return buffer_states[bufnr]
end

-- Global Cache Cleanup
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.yaml", "*.param" },
  callback = function(args)
    for k, _ in pairs(param_metadata_cache) do
      param_metadata_cache[k] = nil
    end
    local written = vim.api.nvim_buf_get_name(args.buf)
    for ws_root, _ in pairs(M._cache) do
      if written:sub(1, #ws_root) == ws_root then
        M._cache[ws_root] = nil
      end
    end
  end,
})

-- =====================================================================
-- Lifecycle & Orchestration
-- =====================================================================

function M.start_session(preselected_node)
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.b[bufnr].ros_tuner_active then
    vim.notify("ROS Tuner already active.", vim.log.levels.WARN)
    return
  end
  vim.notify("🔍 Scanning DDS for YAML matches...", vim.log.levels.INFO)
  M.match_file_to_node(bufnr, function(mappings)
    if #mappings == 0 then
      vim.notify("No live nodes matched. Operating Offline.", vim.log.levels.WARN)
      M.setup_scratch_buffer(bufnr, {})
    else
      local function resolve(idx)
        if idx > #mappings then
          return M.setup_scratch_buffer(bufnr, mappings)
        end
        local map = mappings[idx]
        if map.is_instanced then
          if preselected_node and vim.tbl_contains(map.tied, preselected_node) then
            map.fqn = preselected_node
            resolve(idx + 1)
          else
            vim.ui.select(
              map.tied,
              { prompt = "Select instance for '" .. map.yaml_root .. "':" },
              function(choice)
                if choice then
                  map.fqn = choice
                  resolve(idx + 1)
                end
              end
            )
          end
        else
          resolve(idx + 1)
        end
      end
      resolve(1)
    end
  end)
end

function M.attach_node(target_node, force_scratch)
  local fqn = Utils.normalize_fqn(target_node)
  if force_scratch then
    return M.open_synthetic_proxy(target_node)
  end

  M.match_node_to_file(target_node, function(candidates)
    if #candidates == 0 then
      M.open_synthetic_proxy(target_node)
    elseif #candidates == 1 then
      -- Fast Path: Exactly 1 match, open it directly
      vim.cmd("edit " .. candidates[1].path)
      vim.schedule(function()
        M.start_session(fqn)
      end)
    else
      vim.ui.select(candidates, {
        prompt = "Select config for " .. target_node .. ":",
        format_item = function(i)
          return string.format("[%d] %s", i.score, vim.fs.basename(i.path))
        end,
      }, function(choice)
        if choice then
          vim.cmd("edit " .. choice.path)
          vim.schedule(function()
            M.start_session(fqn)
          end)
        end
      end)
    end
  end)
end

function M.open_synthetic_proxy(node_name)
  vim.notify("⏳ Connecting to live node: " .. node_name .. "...", vim.log.levels.INFO)
  RosApi.dump_params(node_name, function(dump)
    if not dump then
      vim.notify("Failed to dump parameters for " .. node_name, vim.log.levels.ERROR)
      return
    end

    local scratch = vim.api.nvim_create_buf(false, true)
    local open_mode = Config.options.tuner_open_mode or "split"

    if open_mode == "tab" then
      vim.cmd("tabnew")
    elseif open_mode == "split" or open_mode == "vsplit" then
      vim.cmd("vsplit")
    end

    vim.api.nvim_set_current_buf(scratch)
    vim.bo[scratch].buftype, vim.bo[scratch].bufhidden, vim.bo[scratch].filetype =
      "nofile", "wipe", "yaml"
    local safe_node_name = node_name:gsub("^/", ""):gsub("/", "_")
    pcall(vim.api.nvim_buf_set_name, scratch, "ROS_LIVE_" .. safe_node_name)
    local fqn = Utils.normalize_fqn(node_name)
    vim.b[scratch].ros_mappings = { [fqn] = node_name }
    vim.b[scratch].is_synthetic = true
    local lines = vim.split(dump, "\n", { trimempty = true })
    vim.api.nvim_buf_set_lines(scratch, 0, -1, false, lines)

    local parser = vim.treesitter.get_parser(scratch, "yaml")
    if parser then
      parser:parse(true)
    end

    for row, line in ipairs(lines) do
      if line:find("[^%s]") then
        local _, p_name, _, val =
          Engine.resolve_parameter_context(scratch, { row - 1, line:find("[^%s]") - 1 })
        if p_name then
          UI.set_sync_extmark(scratch, row - 1, "  # [Live: " .. val .. "]", nil, "synced")
        end
      end
    end

    M.attach_to_buffer(scratch)
    vim.bo[scratch].modified = false
    vim.notify("🔗 Attached to proxy for " .. node_name, vim.log.levels.INFO)
  end)
end

function M.setup_scratch_buffer(orig_buf, mappings)
  local orig_lines = vim.api.nvim_buf_get_lines(orig_buf, 0, -1, false)
  local orig_win = vim.api.nvim_get_current_win()
  local orig_name = vim.fs.basename(vim.api.nvim_buf_get_name(orig_buf))

  local scratch = vim.api.nvim_create_buf(false, true)
  local open_mode = Config.options.tuner_open_mode or "split"

  if open_mode == "tab" then
    vim.cmd("tabnew")
  elseif open_mode == "split" or open_mode == "vsplit" then
    vim.cmd("vsplit")
  elseif open_mode == "hide" then
    -- buffer will just replace current window's buffer below.
  end
  vim.api.nvim_set_current_buf(scratch)
  vim.bo[scratch].buftype, vim.bo[scratch].bufhidden, vim.bo[scratch].filetype =
    "acwrite", "wipe", "yaml"
  pcall(vim.api.nvim_buf_set_name, scratch, "ROS_TUNER_" .. orig_name)
  local mappings_dict = {}
  for _, m in ipairs(mappings) do
    local normalized_root = Utils.normalize_fqn(m.yaml_root)
    mappings_dict[normalized_root] = m.fqn
  end
  vim.b[scratch].ros_mappings = mappings_dict

  local old_ul = vim.bo[scratch].undolevels
  vim.bo[scratch].undolevels = -1
  vim.api.nvim_buf_set_lines(scratch, 0, -1, false, orig_lines)
  vim.bo[scratch].undolevels = old_ul

  local parser = vim.treesitter.get_parser(scratch, "yaml")
  if parser then
    parser:parse(true)
  end

  for row, line in ipairs(orig_lines) do
    local col = line:find("[^%s]")
    if col then
      local _, p_name, _, val = Engine.resolve_parameter_context(scratch, { row - 1, col - 1 })
      if p_name then
        UI.set_sync_extmark(scratch, row - 1, "  # [File: " .. val .. "]", nil, "offline")
      end
    end
  end

  M.attach_to_buffer(scratch)
  M.setup_crucible_autocmds(scratch, orig_buf, orig_win)

  if #mappings > 0 then
    M.global_resync(scratch)
  end
end

function M.setup_crucible_autocmds(scratch, orig_buf, orig_win)
  local group = vim.api.nvim_create_augroup("RosTunerLifecycle_" .. scratch, { clear = true })
  vim.api.nvim_create_autocmd({ "BufDelete", "BufUnload", "BufWipeout" }, {
    group = group,
    buffer = orig_buf,
    callback = function()
      vim.schedule(function()
        pcall(vim.api.nvim_buf_delete, scratch, { force = true })
      end)
    end,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    pattern = tostring(orig_win),
    callback = function()
      vim.schedule(function()
        pcall(vim.api.nvim_buf_delete, scratch, { force = true })
      end)
    end,
  })
  vim.api.nvim_create_autocmd("QuitPre", {
    group = group,
    buffer = scratch,
    callback = function()
      local open_mode = Config.options.tuner_open_mode or "split"
      if
        open_mode == "hide"
        and not vim.b[scratch].crucible_active
        and vim.api.nvim_buf_is_valid(orig_buf)
      then
        local cur_win = vim.api.nvim_get_current_win()
        -- Silently spawn the original buffer right before the current window dies
        vim.cmd("leftabove sbuffer " .. orig_buf)
        -- Return focus to the Tuner so `:q` kills it, leaving the original buffer untouched
        vim.api.nvim_set_current_win(cur_win)
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = group,
    buffer = scratch,
    callback = function()
      local open_mode = Config.options.tuner_open_mode or "split"
      if
        open_mode == "hide"
        and not vim.b[scratch].crucible_active
        and vim.api.nvim_buf_is_valid(orig_buf)
      then
        local target_win = nil
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_buf(win) == scratch then
            target_win = win
            break
          end
        end
        if target_win then
          vim.schedule(function()
            if vim.api.nvim_win_is_valid(target_win) and vim.api.nvim_buf_is_valid(orig_buf) then
              pcall(vim.api.nvim_win_set_buf, target_win, orig_buf)
            end
          end)
        end
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = group,
    buffer = scratch,
    callback = function()
      if vim.b[scratch].crucible_active then
        return
      end

      -- Check if original buffer is currently visible
      local target_win = nil
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == orig_buf then
          target_win = win
          break
        end
      end

      -- If hidden (because of 'hide' mode), forcefully split to reveal it side-by-side
      if not target_win then
        vim.cmd("vsplit")
        vim.api.nvim_set_current_buf(orig_buf)
        target_win = vim.api.nvim_get_current_win()
        vim.cmd("wincmd p") -- Return focus to the scratch buffer
      end

      vim.b[scratch].crucible_active = true
      vim.api.nvim_buf_clear_namespace(scratch, vim.api.nvim_create_namespace("ros_tuner"), 0, -1)

      -- Enter Vimdiff
      vim.cmd("diffthis")
      vim.opt_local.foldenable = false
      vim.api.nvim_set_current_win(target_win)
      vim.cmd("diffthis")
      vim.opt_local.foldenable = false

      -- Ensure focus is returned to the scratch buffer
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(w) == scratch then
          vim.api.nvim_set_current_win(w)
          break
        end
      end

      vim.bo[scratch].modified = false
      vim.notify(
        "⚔️ Crucible Mode: Use 'dp' to push tuned values to the original file.",
        vim.log.levels.WARN
      )
    end,
  })
end

-- 1. Update the signature to accept force_pull
function M.global_resync(bufnr, cb, force_pull)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local mappings = vim.b[bufnr].ros_mappings or {}
  local global_live = {}
  local pending = 0
  for _, _ in pairs(mappings) do
    pending = pending + 1
  end

  if pending == 0 then
    return cb and cb()
  end

  for root, fqn in pairs(mappings) do
    RosApi.dump_params(fqn, function(dump)
      pending = pending - 1
      if dump then
        local params = Engine.parse_ros2_dump(dump, root)
        for k, v in pairs(params) do
          global_live[k] = v
        end
      end
      if pending == 0 then
        -- [MODIFIED] Pass force_pull down the chain
        M.reconcile_live_parameters(bufnr, global_live, force_pull)
        if cb then
          cb()
        end
      end
    end)
  end
end

function M.reconcile_live_parameters(scratch_buf, global_live_params, force_pull)
  local parser = vim.treesitter.get_parser(scratch_buf, "yaml")
  if parser then
    parser:parse(true)
  end

  local lines = vim.api.nvim_buf_get_lines(scratch_buf, 0, -1, false)
  local old_ul = vim.bo[scratch_buf].undolevels
  vim.bo[scratch_buf].undolevels = -1

  local matched_keys, missing_params, synced_count, injected_count = {}, {}, 0, 0
  local skipped_count = 0
  local should_pull = vim.b[scratch_buf].is_synthetic
    or Config.options.tuner_pull_missing
    or force_pull
  -- Phase 1: Drift Detection
  for row, line in ipairs(lines) do
    local col = line:find("[^%s]")
    if col then
      local node, p_name, _, val =
        Engine.resolve_parameter_context(scratch_buf, { row - 1, col - 1 })
      if node and p_name then
        local key = node .. ":" .. p_name
        matched_keys[key] = true
        local live = global_live_params[key]
        if live then
          if live ~= val then
            local escaped_val = val:gsub("([%.%+%-%*%?%[%]%^%$%(%)%%])", "%%%1")
            local safe_live = live:gsub("%%", "%%%%")
            local new_line =
              line:gsub("(:%s*)" .. escaped_val .. "(%s*.*)$", "%1" .. safe_live .. "%2")
            if new_line ~= line then
              vim.api.nvim_buf_set_lines(scratch_buf, row - 1, row, false, { new_line })
              synced_count = synced_count + 1
            end
          end
          UI.set_sync_extmark(scratch_buf, row - 1, "  # [File: " .. val .. "]", nil, "synced")
        else
          UI.set_sync_extmark(scratch_buf, row - 1, "  # [File: " .. val .. "]", nil, "unused")
        end
      end
    end
  end

  -- Phase 2: Missing Injection
  for composite_key, live_val in pairs(global_live_params) do
    if not matched_keys[composite_key] then
      local node, param = composite_key:match("^(.-):(.+)$")
      if not is_systemic(param) then
        if should_pull then
          -- [MODIFIED] Only build the insertion tree if pulling is allowed
          missing_params[node] = missing_params[node] or {}
          missing_params[node][param] = live_val
        else
          skipped_count = skipped_count + 1
        end
      end
    end
  end

  local current_lines = vim.api.nvim_buf_get_lines(scratch_buf, 0, -1, false)
  local offset = 0
  local path_stack = {}

  for i, line in ipairs(current_lines) do
    local clean_line = line:match("^(.-)%s+#.*$") or line:match("^(.-)%s*$")
    local indent, key = clean_line:match("^(%s*)['\"]?([%w_%-%.%/%*]+)['\"]?:")

    if key then
      local depth = #indent
      while #path_stack > 0 and path_stack[#path_stack].depth >= depth do
        table.remove(path_stack)
      end
      table.insert(path_stack, { depth = depth, key = key })

      if key == "ros__parameters" then
        local root_parts = {}
        for j = 1, #path_stack - 1 do
          table.insert(root_parts, path_stack[j].key)
        end
        local current_node = "/" .. table.concat(root_parts, "/")
        current_node = current_node:gsub("//+", "/")

        if missing_params[current_node] then
          local block_end_idx = i
          for k = i + 1, #current_lines do
            local next_clean = current_lines[k]:match("^(.-)%s+#.*$")
              or current_lines[k]:match("^(.-)%s*$")
            if next_clean ~= "" then
              local next_indent_str = next_clean:match("^(%s*)%S")
              if next_indent_str and #next_indent_str <= depth then
                break
              end
            end
            block_end_idx = k
          end

          local base_indent_str = line:match("^(%s*)")
          local missing_tree = Engine.build_nested_tree(missing_params[current_node])
          local pending_insertions = {}
          Engine.compute_tree_insertions(
            missing_tree,
            i + 1,
            block_end_idx,
            base_indent_str,
            current_lines,
            pending_insertions
          )

          local insertion_list = {}
          for _, v in pairs(pending_insertions) do
            table.insert(insertion_list, v)
          end
          table.sort(insertion_list, function(a, b)
            return a.idx ~= b.idx and a.idx > b.idx or a.depth < b.depth
          end)

          local node_added_lines = 0
          for _, data in ipairs(insertion_list) do
            local insert_pos = data.idx + offset
            vim.api.nvim_buf_set_lines(scratch_buf, insert_pos, insert_pos, false, data.lines)
            for j, mark_needed in ipairs(data.marks) do
              if mark_needed then
                UI.set_sync_extmark(
                  scratch_buf,
                  insert_pos + j - 1,
                  "  # [Discovered]",
                  nil,
                  "discovered"
                )
                injected_count = injected_count + 1
              end
            end
            node_added_lines = node_added_lines + #data.lines
          end
          offset = offset + node_added_lines
          missing_params[current_node] = nil
        end
      end
    end
  end

  vim.bo[scratch_buf].modified = false
  vim.bo[scratch_buf].undolevels = old_ul
  if vim.b[scratch_buf].crucible_active and injected_count > 0 then
    vim.cmd("diffupdate")
  end

  -- [MODIFIED] Smart Notification
  if synced_count > 0 or injected_count > 0 or skipped_count > 0 then
    local msg = string.format("✅ Sync Complete: %d drifted", synced_count)
    if injected_count > 0 then
      msg = msg .. string.format(", %d discovered!", injected_count)
    end
    if skipped_count > 0 then
      msg = msg .. string.format(" 👻 %d skipped (use --pull)", skipped_count)
    end
    -- Switched from WARN to INFO since partial pulls are now expected behavior
    vim.notify(msg, vim.log.levels.INFO)
  end
end

-- =====================================================================
-- Event Loops & Proxy Hardware
-- =====================================================================

function M.attach_to_buffer(bufnr)
  local group = vim.api.nvim_create_augroup("RosTuner_" .. bufnr, { clear = true })
  vim.b[bufnr].ros_tuner_active = true

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    buffer = bufnr,
    callback = function()
      local state = get_state(bufnr)
      state.last_line = vim.api.nvim_get_current_line()
      state.last_row = vim.api.nvim_win_get_cursor(0)[1]
      local _, _, _, val = Engine.resolve_parameter_context(bufnr)
      state.last_val = val
    end,
  })

  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    buffer = bufnr,
    callback = function()
      local state = get_state(bufnr)
      if vim.api.nvim_win_get_cursor(0)[1] ~= state.last_row then
        return
      end
      if vim.api.nvim_get_current_line() == state.last_line then
        return
      end

      local node, param, type, val = Engine.resolve_parameter_context(bufnr)
      local fqn = vim.b[bufnr].ros_mappings and vim.b[bufnr].ros_mappings[node] or node
      if fqn and param and val ~= "unknown" and val ~= state.last_val then
        RosApi.set_param(fqn, param, type, val, function()
          state.last_val = val
          UI.set_sync_extmark(bufnr, state.last_row - 1, nil, nil, "synced")
        end)
      end
    end,
  })

  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    buffer = bufnr,
    callback = function()
      local state = get_state(bufnr)
      if state.debounce then
        state.debounce:stop()
        if not state.debounce:is_closing() then
          state.debounce:close()
        end
      end

      state.debounce = vim.uv.new_timer()
      state.debounce:start(
        300,
        0,
        vim.schedule_wrap(function()
          if not vim.api.nvim_buf_is_valid(bufnr) then
            return
          end
          local winid = vim.fn.bufwinid(bufnr)
          if winid == -1 then
            return
          end

          local captured_row = vim.api.nvim_win_get_cursor(winid)[1] - 1
          local node, param, _, val = Engine.resolve_parameter_context(bufnr)
          local fqn = vim.b[bufnr].ros_mappings and vim.b[bufnr].ros_mappings[node] or node

          if fqn and param and param ~= state.last_param then
            state.last_param = param

            local cache_key = fqn .. ":" .. param
            RosApi.get_param(fqn, param, function(live_val)
              if live_val and live_val ~= val and live_val ~= "unknown" then
                local line =
                  vim.api.nvim_buf_get_lines(bufnr, captured_row, captured_row + 1, false)[1]
                if line then
                  local escaped_val = val:gsub("([%.%+%-%*%?%[%]%^%$%(%)%%])", "%%%1")
                  local safe_live = tostring(live_val):gsub("%%", "%%%%")
                  local new_line =
                    line:gsub("(:%s*)" .. escaped_val .. "(%s*.*)$", "%1" .. safe_live .. "%2")

                  if new_line ~= line then
                    vim.api.nvim_buf_set_lines(
                      bufnr,
                      captured_row,
                      captured_row + 1,
                      false,
                      { new_line }
                    )
                    UI.set_sync_extmark(
                      bufnr,
                      captured_row,
                      "  # [Drift Auto-Corrected]",
                      nil,
                      "synced"
                    )
                    -- Update internal state so InsertLeave doesn't undo this
                    local state = get_state(bufnr)
                    if state then
                      state.last_val = live_val
                    end
                  end
                end
              end
            end)
            -- Fetch Range Metadata
            if param_metadata_cache[cache_key] and param_metadata_cache[cache_key].range then
              UI.set_sync_extmark(
                bufnr,
                captured_row,
                nil,
                " | Range: " .. param_metadata_cache[cache_key].range,
                "synced"
              )
              return
            end

            RosApi.get_param_metadata(fqn, param, function(meta)
              param_metadata_cache[cache_key] = meta
              if meta.range then
                UI.set_sync_extmark(bufnr, captured_row, nil, " | Range: " .. meta.range, "synced")
              end
            end)
          end
        end)
      )
    end,
  })

  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = group,
    buffer = bufnr,
    callback = function()
      local state = buffer_states[bufnr]
      if state and state.debounce then
        state.debounce:stop()
        if not state.debounce:is_closing() then
          state.debounce:close()
        end
      end
      buffer_states[bufnr] = nil
      vim.b[bufnr].ros_tuner_active = false
    end,
  })
end

-- =====================================================================
-- Smartmatch Discovery
-- =====================================================================

local function score_candidate(
  live_fqn,
  live_footprint,
  yaml_root,
  yaml_footprint,
  yaml_filename,
  footprint_available
)
  local norm_live = Utils.normalize_fqn(live_fqn)
  local norm_yaml = Utils.normalize_fqn(yaml_root)
  local live_base = Utils.get_base_name(norm_live)
  local score, base_score, match_reason = 0, 0, ""

  local matching_keys, total_yaml_keys = 0, 0
  for k, _ in pairs(yaml_footprint) do
    if not is_systemic(k) then
      total_yaml_keys = total_yaml_keys + 1
      if live_footprint[k] then
        matching_keys = matching_keys + 1
      end
    end
  end

  local overlap = (footprint_available and total_yaml_keys > 0)
      and (matching_keys / total_yaml_keys)
    or 0

  local shares_params = matching_keys > 0

  if norm_yaml == norm_live then
    base_score, match_reason = 100, "Exact FQN"
  elseif norm_yaml:match("^/") and Utils.get_base_name(norm_yaml) == live_base then
    base_score, match_reason = 75, "Base Name"
  elseif norm_yaml:match("/%*%*$") then
    local prefix = norm_yaml:gsub("/%*%*$", "")
    if norm_live:sub(1, #prefix) == prefix and (not footprint_available or shares_params) then
      base_score, match_reason = 60, "Scoped Wildcard"
    end
  elseif norm_yaml == "/**" and (not footprint_available or shares_params) then
    base_score, match_reason = 40, "Global Wildcard"
  end

  if base_score == 0 then
    return nil
  end
  score = base_score

  -- RESTORED: Strict and Fuzzy Filename Scoring
  if yaml_filename then
    if yaml_filename == live_base then
      score = score + 15
      match_reason = match_reason .. " + Strict File"
    else
      local fuzzy_res = vim.fn.matchfuzzypos({ yaml_filename }, live_base)
      if fuzzy_res and fuzzy_res[1] and #fuzzy_res[1] > 0 then
        local fuzzy_score = fuzzy_res[3][1]
        if fuzzy_score > 50 then
          score = score + 5
          match_reason = match_reason .. " + Fuzzy File"
        end
      end
    end
  end

  if footprint_available and overlap >= 0.5 then
    score = score + 10
    match_reason = match_reason .. " + Overlap"
  end

  return {
    score = score,
    overlap = overlap,
    root_key = norm_yaml,
    fqn = norm_live,
    base_name = live_base,
    path = "",
    match_reason = match_reason,
  }
end
function M._evaluate_cached_workspace(ws_root, fqn, live_footprint, footprint_available)
  local candidates, best_per_file = {}, {}
  local match_mode = Config.options.tuner_match_mode or "smart"
  local live_base = Utils.get_base_name(Utils.normalize_fqn(fqn))

  for path, data in pairs(M._cache[ws_root].files) do
    local filename = vim.fs.basename(path):gsub("%.yaml$", ""):gsub("%.param$", "")

    if match_mode == "all" then
      -- Mode: ALL - Bypass parsing entirely and return every YAML file in the workspace
      table.insert(candidates, {
        score = 1,
        overlap = 0,
        path = path,
        match_reason = "Mode: All Files",
      })
    else
      for _, yaml_root in ipairs(data.root_keys) do
        if match_mode == "simple" then
          -- Mode: SIMPLE - Check if the base name of the node matches the YAML root key
          local yaml_base = Utils.get_base_name(Utils.normalize_fqn(yaml_root))
          if yaml_base == live_base or yaml_root == "/**" then
            if not best_per_file[path] then
              best_per_file[path] = {
                score = 10,
                overlap = 0,
                path = path,
                match_reason = "Mode: Simple (Root Match)",
              }
            end
          end
        else
          -- Mode: SMART - Use footprint overlap and fuzzy filename scoring
          local cand = score_candidate(
            fqn,
            live_footprint,
            yaml_root,
            data.footprints[yaml_root] or {},
            filename,
            footprint_available
          )
          if cand then
            cand.path = path
            if not best_per_file[path] or cand.score > best_per_file[path].score then
              best_per_file[path] = cand
            end
          end
        end
      end
    end
  end

  -- Flatten the dictionary into an array (only needed for simple/smart)
  if match_mode ~= "all" then
    for _, cand in pairs(best_per_file) do
      table.insert(candidates, cand)
    end
  end

  -- Sort: Highest score -> Highest overlap -> Alphabetical path
  table.sort(candidates, function(a, b)
    if a.score ~= b.score then
      return a.score > b.score
    end
    if a.overlap ~= b.overlap then
      return a.overlap > b.overlap
    end
    return a.path < b.path
  end)

  return candidates
end

function M.match_node_to_file(fqn, cb, bufnr)
  local ws_root = Utils.get_workspace_root(bufnr)
  RosApi.dump_params(fqn, function(dump_out)
    local live_footprint, footprint_available = {}, dump_out ~= nil
    if footprint_available then
      for line in dump_out:gmatch("[^\r\n]+") do
        local param = line:match("^%s*['\"]?([%w_%-%.]+)['\"]?:")
        if param and param ~= "ros__parameters" and not is_systemic(param) then
          live_footprint[param] = true
        end
      end
    end

    if M._cache[ws_root] then
      cb(M._evaluate_cached_workspace(ws_root, fqn, live_footprint, footprint_available))
      return
    end

    local find_cmd = vim.fn.executable("fd") == 1
        and { "fd", "-e", "yaml", "-e", "param", "-E", "build/", "-E", "install/", ".", ws_root }
      or {
        "find",
        ws_root,
        "-type",
        "f",
        "-not",
        "-path",
        ws_root .. "/build/*",
        "-not",
        "-path",
        ws_root .. "/install/*",
        "(",
        "-name",
        "*.yaml",
        "-o",
        "-name",
        "*.param",
        ")",
        "-print",
      }

    vim.system(find_cmd, { text = true }, function(find_out)
      local files = {}
      if find_out.code == 0 and find_out.stdout ~= "" then
        for _, f in ipairs(vim.split(find_out.stdout, "\n", { trimempty = true })) do
          if not f:match("/build/") and not f:match("/install/") then
            local file_data = { root_keys = {}, footprints = {} }
            local current_root = nil
            local has_ros_params = false -- NEW: Gatekeeper variable

            local file_handle = io.open(f, "r")
            if file_handle then
              local lines = {}
              for line in file_handle:lines() do
                table.insert(lines, line)
              end
              file_handle:close()

              -- Use the new indentation-aware parser
              local file_data = parse_yaml_footprints(lines)

              -- Only cache the file if we actually found valid ROS 2 blocks inside it
              if #file_data.root_keys > 0 then
                files[f] = file_data
              end
            end
          end
        end
      end
      vim.schedule(function()
        M._cache[ws_root] = { files = files }
        cb(M._evaluate_cached_workspace(ws_root, fqn, live_footprint, footprint_available))
      end)
    end)
  end)
end

function M.match_file_to_node(bufnr, cb)
  local filename =
    vim.fs.basename(vim.api.nvim_buf_get_name(bufnr)):gsub("%.yaml$", ""):gsub("%.param$", "")
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local file_data = parse_yaml_footprints(lines)
  local footprints = file_data.footprints
  RosApi.list_nodes(function(active_nodes)
    if #active_nodes == 0 then
      return cb({})
    end
    local mappings, instanced_conflicts = {}, {}

    for _, yaml_root in ipairs(file_data.root_keys) do
      local best_score, tied_fqns, root_footprint = 0, {}, footprints[yaml_root] or {}
      for _, live_fqn in ipairs(active_nodes) do
        local cand =
          score_candidate(live_fqn, root_footprint, yaml_root, root_footprint, filename, false)
        if cand and cand.score > 0 then
          if cand.score > best_score then
            best_score = cand.score
            tied_fqns = { live_fqn }
          elseif cand.score == best_score then
            table.insert(tied_fqns, live_fqn)
          end
        end
      end
      if best_score > 0 then
        if #tied_fqns == 1 then
          table.insert(mappings, { yaml_root = yaml_root, fqn = tied_fqns[1] })
        else
          instanced_conflicts[yaml_root] = tied_fqns
        end
      end
    end
    for yaml_root, fqns in pairs(instanced_conflicts) do
      table.insert(
        mappings,
        { yaml_root = yaml_root, fqn = fqns[1], is_instanced = true, tied = fqns }
      )
    end
    cb(mappings)
  end)
end

return M
