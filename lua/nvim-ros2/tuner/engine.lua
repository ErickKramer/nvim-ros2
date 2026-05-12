local Utils = require("nvim-ros2.utils")
local M = {}

local param_type_map = {
  integer_scalar = "integer",
  float_scalar = "double",
  boolean_scalar = "boolean",
  string_scalar = "string",
  flow_sequence = "array",
  block_sequence = "array",
}

local function get_yaml_value_type(value_node)
  local actual_node = value_node
  while
    actual_node
    and (
      actual_node:type() == "flow_node"
      or actual_node:type() == "block_node"
      or actual_node:type() == "plain_scalar"
    )
  do
    local child = actual_node:named_child(0)
    if not child then
      break
    end
    actual_node = child
  end
  if not actual_node then
    return nil
  end -- guard
  local t = actual_node:type()
  return param_type_map[t] or t
end

--- Resolves the parameter name, node namespace, and value under the cursor.
function M.resolve_parameter_context(bufnr, pos)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not pos then
    local winid = vim.fn.bufwinid(bufnr)
    if winid == -1 then
      return nil
    end
    local cursor = vim.api.nvim_win_get_cursor(winid)
    pos = { cursor[1] - 1, cursor[2] }
  end
  local node = vim.treesitter.get_node({ bufnr = bufnr, pos = pos })
  if not node then
    return nil
  end

  local path_keys, current, value_node, value_type = {}, node, nil, "unknown"
  while current do
    if current:type() == "block_mapping_pair" then
      local key_node = current:field("key")[1]
      if key_node then
        table.insert(path_keys, 1, vim.treesitter.get_node_text(key_node, bufnr))
      end
      if not value_node then
        value_node = current:field("value")[1]
        if value_node then
          value_type = get_yaml_value_type(value_node)
        end
      end
    end
    current = current:parent()
  end

  if #path_keys < 2 or value_type == "unknown" or value_type:match("mapping") then
    return nil
  end

  local ros_param_idx = nil
  for i, key in ipairs(path_keys) do
    if key == "ros__parameters" then
      ros_param_idx = i
      break
    end
  end
  if not ros_param_idx or ros_param_idx == #path_keys then
    return nil
  end

  local param_parts = {}
  for i = ros_param_idx + 1, #path_keys do
    table.insert(param_parts, path_keys[i])
  end
  local param_name = table.concat(param_parts, ".")
  if param_name == "" then
    return nil
  end

  local node_parts = {}
  for i = 1, ros_param_idx - 1 do
    table.insert(node_parts, path_keys[i])
  end
  local node_root = "/" .. table.concat(node_parts, "/")
  node_root = node_root:gsub("//+", "/") -- Safely normalize slashes

  return node_root,
    param_name,
    value_type,
    value_node and vim.treesitter.get_node_text(value_node, bufnr) or "unknown"
end

function M.build_nested_tree(flat_params)
  local tree = {}
  for p_name, p_val in pairs(flat_params) do
    local parts = vim.split(p_name, "%.")
    local curr = tree
    for k = 1, #parts - 1 do
      curr[parts[k]] = curr[parts[k]] or {}
      curr = curr[parts[k]]
    end
    curr[parts[#parts]] = p_val
  end
  return tree
end

function M.compute_tree_insertions(
  tree,
  start_idx,
  end_idx,
  parent_indent_str,
  current_lines,
  pending_insertions
)
  local keys = vim.tbl_keys(tree)
  table.sort(keys)
  local child_indent_str = parent_indent_str .. "  "
  for idx = start_idx, end_idx do
    local l = current_lines[idx]
    -- Checks if a line is either completely blank or a YAML/Python style comment.
    -- "^%s*#" matches lines starting with optional whitespace followed by a '#'.
    -- "^%s*$" matches lines consisting entirely of whitespace (or completely empty).
    if l and not l:match("^%s*#") and not l:match("^%s*$") then
      -- "^(%s*)" captures all consecutive space/tab characters from the start of the string.
      local detect_indent = l:match("^(%s*)")
      if #detect_indent > #parent_indent_str then
        child_indent_str = detect_indent
        break
      end
    end
  end
  for _, k in ipairs(keys) do
    local v, found_idx = tree[k], nil
    -- Searches for any of: . + - * ? [ ] ^ $ ( ) %
    -- And prefixes them with a '%' so they are treated as literal characters in subsequent matches.
    local escaped_k = k:gsub("([%.%+%-%*%?%[%]%^%$%(%)%%])", "%%%1")
    for idx = start_idx, end_idx do
      if
        current_lines[idx]
        -- "^%s*#" matches lines starting with optional whitespace followed by a '#'.
        and not current_lines[idx]:match("^%s*#")
        and current_lines[idx]:match("^" .. child_indent_str .. escaped_k .. ":")
      then
        found_idx = idx
        break
      end
    end
    if found_idx then
      local child_start = found_idx + 1
      local child_end = child_start - 1
      for idx = child_start, end_idx do
        if
          current_lines[idx]
          -- "^%s*#" matches lines starting with optional whitespace followed by a '#'.
          -- "^%s*$" matches lines consisting entirely of whitespace (or completely empty).
          and not current_lines[idx]:match("^%s*#")
          and not current_lines[idx]:match("^%s*$")
        then
          -- "^(%s*)" captures all consecutive space/tab characters from the start of the string.
          if #current_lines[idx]:match("^(%s*)") <= #child_indent_str then
            break
          end
        end
        child_end = idx
      end
      if type(v) == "table" then
        M.compute_tree_insertions(
          v,
          child_start,
          child_end,
          child_indent_str,
          current_lines,
          pending_insertions
        )
      end
    else
      local dict_key = end_idx .. "_" .. #parent_indent_str
      pending_insertions[dict_key] = pending_insertions[dict_key]
        or { idx = end_idx, depth = #parent_indent_str, lines = {}, marks = {} }
      local function build_lines(sub_tree, sub_indent)
        local sub_keys = vim.tbl_keys(sub_tree)
        table.sort(sub_keys)
        for _, sk in ipairs(sub_keys) do
          local sv = sub_tree[sk]
          if type(sv) == "table" then
            table.insert(pending_insertions[dict_key].lines, sub_indent .. sk .. ":")
            table.insert(pending_insertions[dict_key].marks, false)
            build_lines(sv, sub_indent .. "  ")
          else
            table.insert(pending_insertions[dict_key].lines, sub_indent .. sk .. ": " .. sv)
            table.insert(pending_insertions[dict_key].marks, true)
          end
        end
      end
      if type(v) == "table" then
        table.insert(pending_insertions[dict_key].lines, child_indent_str .. k .. ":")
        table.insert(pending_insertions[dict_key].marks, false)
        build_lines(v, child_indent_str .. "  ")
      else
        table.insert(pending_insertions[dict_key].lines, child_indent_str .. k .. ": " .. v)
        table.insert(pending_insertions[dict_key].marks, true)
      end
    end
  end
end

function M.parse_ros2_dump(dump_text, active_node)
  local live_params = {}
  local path_stack = {}
  for line in dump_text:gmatch("[^\r\n]+") do
    -- Parses a standard YAML/dictionary line into indent, key, and value components.
    -- Group 1: "^(%s*)" captures leading indentation.
    -- Group 2: "['\"]?([%w_%-%.]+)['\"]?" captures the key name, ignoring optional surrounding quotes.
    -- Group 3: ":%s*(.*)$" captures the remaining string after the colon as the value.
    local indent, key, val = line:match("^(%s*)['\"]?([%w_%-%.]+)['\"]?:%s*(.*)$")
    if key then
      local depth = math.floor(#indent / 2) + 1
      path_stack[depth] = key
      if val ~= "" and val ~= nil then
        -- Cleans up the value string by removing inline comments and trailing whitespace.
        -- "^(.-)%s+#.*$" captures everything before a space-padded '#' comment.
        -- "^(.-)%s*$" acts as a fallback to simply trim trailing whitespace if no comment exists.
        -- The non-greedy '(.-)' ensures we don't accidentally swallow the whitespace we want to trim.
        local clean_val = val:match("^(.-)%s+#.*$") or val:match("^(.-)%s*$")
        local full_path = {}
        -- [NOTE] Skip depth 1 (i=1). 'ros2 param dump' places the node's FQN at the top level of the YAML.
        -- Because we already prepend the 'active_node' FQN string below, we only want to extract
        -- the actual parameter path starting from depth 2.
        for i = 2, depth do
          if path_stack[i] ~= "ros__parameters" then
            table.insert(full_path, path_stack[i])
          end
        end
        if #full_path > 0 then
          live_params[active_node .. ":" .. table.concat(full_path, ".")] = clean_val
        end
      end
    end
  end
  return live_params
end

return M
