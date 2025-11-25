local Config = require("nvim-ros2.config")
local M = {}

function M.get_picker()
	local picker_name = Config.options.picker
	if picker_name == "telescope" then
		return require("nvim-ros2.pickers.telescope")
	elseif picker_name == "snacks" then
		return require("nvim-ros2.pickers.snacks")
	elseif picker_name == "fzf" then
		return require("nvim-ros2.pickers.fzf")
	else
		vim.notify("nvim-ros2: Invalid picker option '" .. tostring(picker_name) .. "'", vim.log.levels.ERROR)
		return nil
	end
end

function M.interfaces()
	local picker = M.get_picker()
	if picker then
		picker.interfaces()
	end
end

function M.nodes()
	local picker = M.get_picker()
	if picker then
		picker.nodes()
	end
end

function M.services()
	local picker = M.get_picker()
	if picker then
		picker.services()
	end
end

function M.topics_info()
	local picker = M.get_picker()
	if picker then
		picker.topics_info()
	end
end

function M.topics_echo()
	local picker = M.get_picker()
	if picker then
		picker.topics_echo()
	end
end

function M.actions()
	local picker = M.get_picker()
	if picker then
		picker.actions()
	end
end

return M
