-- Telescope includes
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

-- Local previewers
local ros_previewers = require("nvim-ros2.telescope.previewers")

local M = {}

--- Telescope picker to select ROS 2 interfaces
function M.interfaces()
	local command = { "ros2", "interface", "list" }
	local raw_output = nil
	if vim.fn.executable("ros2") == 1 then
		raw_output = vim.fn.systemlist(command)
	else
		vim.notify("ros2 not found", vim.log.levels.ERROR)
		return
	end

	-- Process command output
	local filtered_output = {}
	for _, line in ipairs(raw_output) do
		-- Identify output headers (e.g. "Messages:") to ignore them
		local section_header = line:match("^%s*(%a+):$")
		if not section_header then
			-- trim leading and trailing whitespaces
			local trimmed_line = line:match("^%s*(.-)%s*$")
			if trimmed_line ~= "" then
				table.insert(filtered_output, trimmed_line)
			end
		end
	end
	local opts = {
		preview_title = "Show",
		prompt_title = "Select",
		results_title = "Interfaces",
		filtered_output = filtered_output,
	}
	pickers
		.new(opts, {
			finder = finders.new_table({
				results = opts.filtered_output,
				entry_maker = opts.entry_maker,
			}),
			sorter = conf.generic_sorter(),
			previewer = ros_previewers.preview_interface(),
			dynamic_filter = true,
			attach_mappings = function(_, map)
				-- Disable enter behavior
				map("i", "<CR>", function(_) end)
				map("n", "<CR>", function(_) end)
				return true
			end,
		})
		:find()
end

--- Wrapper for a Telescope picker to select ROS 2 elements
local function ros_picker(opts)
	local command_output = nil
	if vim.fn.executable("ros2") == 1 then
		command_output = vim.fn.systemlist(opts.system_cmd)
	else
		vim.notify("ros2 not found", vim.log.levels.ERROR)
		return
	end
	pickers
		.new(opts, {
			finder = finders.new_table({
				results = command_output,
				entry_maker = opts.entry_maker,
			}),
			sorter = conf.generic_sorter(),
			previewer = ros_previewers.preview_elements(opts),
			dynamic_filter = true,
			attach_mappings = function(_, map)
				-- Disable enter behavior
				map("i", "<CR>", function(_) end)
				map("n", "<CR>", function(_) end)
				return true
			end,
		})
		:find()
end

-- Picker of active ROS 2 Nodes
function M.nodes()
	local system_cmd = { "ros2", "node", "list" }

	-- Process command output
	local opts = {
		preview_title = "Node Info",
		prompt_title = "Search",
		results_title = "Active Nodes",
		system_cmd = system_cmd,
		command = "node",
		mode = "info",
		args = "--include-hidden",
	}
	ros_picker(opts)
end

-- Picker of active ROS 2 actions
function M.actions()
	local system_cmd = { "ros2", "action", "list" }

	-- Process command output
	local opts = {
		preview_title = "Action Info",
		prompt_title = "Search",
		results_title = "Active Actions",
		system_cmd = system_cmd,
		command = "action",
		mode = "info",
		args = "--show-types",
	}
	ros_picker(opts)
end

-- Picker of active ROS 2 Services
function M.services()
	local system_cmd = { "ros2", "service", "list" }

	-- Process command output
	local opts = {
		preview_title = "Service Type",
		prompt_title = "Search",
		results_title = "Active Services",
		system_cmd = system_cmd,
		command = "service",
		mode = "type",
		args = "",
	}
	ros_picker(opts)
end

-- Picker of active ROS 2 topics
function M.topics()
	local system_cmd = { "ros2", "topic", "list" }

	-- Process command output
	local opts = {
		preview_title = "Topic Info",
		prompt_title = "Search",
		results_title = "Active Topics",
		system_cmd = system_cmd,
		command = "topic",
		mode = "info",
		args = "--verbose",
	}
	ros_picker(opts)
end

return M
