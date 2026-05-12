local M = {}
local ns_id = vim.api.nvim_create_namespace("ros_tuner")

--- Standardizes how virtual text and gutter signs are rendered.
function M.set_sync_extmark(bufnr, row, anchor_text, range, state)
  local conf = {
    synced = { sign = "●", hl = "DiagnosticOk", text = " Synced" },
    unused = { sign = "!", hl = "DiagnosticWarn", text = " Unused" },
    offline = { sign = "○", hl = "Comment", text = " Offline" },
    discovered = { sign = "+", hl = "Comment", text = " Synced" },
  }
  local c = conf[state]
  if not c then
    return
  end
  local marks = vim.api.nvim_buf_get_extmarks(
    bufnr,
    ns_id,
    { row, 0 },
    { row, -1 },
    { details = true }
  )

  -- Preserve the original File value prefix if anchor is omitted
  if not anchor_text then
    if #marks > 0 and marks[1][4].virt_text and marks[1][4].virt_text[1] then
      local old_text = marks[1][4].virt_text[1][1]
      anchor_text = old_text:match("^(%s*#%s*%[.-%])") or ""
    else
      anchor_text = ""
    end
  end

  vim.api.nvim_buf_set_extmark(bufnr, ns_id, row, 0, {
    id = #marks > 0 and marks[1][1] or nil,
    virt_text = { { anchor_text .. c.text .. (range or ""), c.hl } },
    virt_text_pos = "eol",
    sign_text = c.sign,
    sign_hl_group = c.hl,
    undo_restore = true,
  })
end

--- Exposes buffer health to external statuslines.
function M.tuner_status(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.b[bufnr].ros_tuner_active then
    return ""
  end

  local is_synthetic = vim.b[bufnr].is_synthetic
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local display_name = ""

  if is_synthetic then
    display_name = bufname:match("ROS_LIVE_(.*)$") or "Proxy"
    display_name = "[Proxy: " .. display_name .. "]"
  else
    display_name = bufname:match("ROS_TUNER_(.*)$") or "File"
    display_name = "[File: " .. display_name .. "]"
  end

  local marks = vim.api.nvim_buf_get_extmarks(
    bufnr,
    ns_id,
    { 0, 0 },
    { -1, -1 },
    { details = true }
  )
  local synced, unused, offline = 0, 0, 0
  for _, mark in ipairs(marks) do
    local sign = mark[4].sign_text
    if sign == "●" or sign == "+" then
      synced = synced + 1
    elseif sign == "!" then
      unused = unused + 1
    elseif sign == "○" then
      offline = offline + 1
    end
  end

  local status = {}
  if synced > 0 then
    table.insert(status, "● " .. synced)
  end
  if unused > 0 then
    table.insert(status, "! " .. unused)
  end
  if offline > 0 then
    table.insert(status, "○ " .. offline)
  end

  local counts = #status == 0 and "" or table.concat(status, " ")
  return "🤖 " .. display_name .. (counts ~= "" and (" " .. counts) or "")
end

return M
