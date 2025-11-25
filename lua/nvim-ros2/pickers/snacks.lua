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

	local items = {}
	for _, line in ipairs(output) do
		table.insert(items, {
			text = line,
			item = line,
		})
	end

	Snacks.picker.pick({
		title = opts.prompt_title,
		items = items,
		format = "text",
		preview = function(ctx)
			local item = ctx.item
			local cmd = { "ros2", opts.command, opts.mode, item.text }
			if opts.args and opts.args ~= "" then
				table.insert(cmd, opts.args)
			end
			
			local preview_output = vim.fn.systemlist(cmd)
			ctx.preview:set_lines(preview_output)
			ctx.preview:highlight({ lang = "yaml" }) -- Assuming yaml/text output
		end,
		confirm = function() 
			-- No-op as per original requirement
		end,
	})
end

function M.interfaces()
	local command = { "ros2", "interface", "list" }
	local raw_output = get_command_output(command)
	if not raw_output then return end

	local items = {}
	for _, line in ipairs(raw_output) do
		local section_header = line:match("^%s*(%a+):$")
		if not section_header then
			local trimmed_line = line:match("^%s*(.-)%s*$")
			if trimmed_line ~= "" then
				table.insert(items, {
					text = trimmed_line,
					item = trimmed_line,
				})
			end
		end
	end

	Snacks.picker.pick({
		title = "Select Interface",
		items = items,
		format = "text",
		preview = function(ctx)
			local item = ctx.item
			local cmd = { "ros2", "interface", "show", item.text }
			local preview_output = vim.fn.systemlist(cmd)
			ctx.preview:set_lines(preview_output)
			ctx.preview:highlight({ lang = "msg" }) -- ROS msg format
		end,
		confirm = function() end,
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
