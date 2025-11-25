local M = {}

local defaults = {
	autocmds = true,
	treesitter = true,
	picker = "telescope", -- "telescope", "snacks", "fzf"
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
