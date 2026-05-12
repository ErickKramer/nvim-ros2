local M = {}

local defaults = {
  autocmds = true,
  treesitter = true,
  picker = "telescope", -- "telescope", "snacks", "fzf"
  pickers = {
    packages = {
      show_global = true, -- Enable/disable /opt/ros packages
    },
  },
  tuner = true, -- New option
  tuner_match_mode = "smart", -- Options: "smart", "simple", "all"
  tuner_open_mode = "split", -- Options: "split", "tab", "hide"
  tuner_pull_missing = false, -- Gating auto-injection of discovered parameters
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})

  -- Backward compatibility
  if M.options.telescope == false and opts and opts.picker == nil then
    M.options.picker = "none"
  elseif M.options.telescope == true and opts and opts.picker == nil then
    M.options.picker = "telescope"
  end
end

return M
