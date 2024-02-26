local M = {}

local defaults = {
	autocmds = true,
	telescope = true,
	treesitter = true,
}

M.options = {}

function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end
return M
