local previewers = require("telescope.previewers")
local _, Job = pcall(require, "plenary.job")

local M = {}

-- Previewer specifically designed for ROS 2 interfaces
function M.preview_interface()
	local timer
	return previewers.new_buffer_previewer({
		get_buffer_by_name = function(_, entry)
			return entry.name
		end,
		define_preview = function(self, entry)
			local bufnr = self.state.bufnr
			if self.state.bufname ~= entry.name or vim.api.nvim_buf_line_count(bufnr) == 1 then
				if timer then
					vim.fn.timer_stop(timer)
				end
				timer = vim.fn.timer_start(100, function()
					local job = Job:new({
						enable_recording = true,
						command = "ros2",
						args = { "interface", "show", entry.value },
						on_exit = vim.schedule_wrap(function(j_self, _, code)
							if code == 0 then
								-- Only update the buffer if the job exited successfully
								local result = j_self:result()
								vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result)
								vim.api.nvim_buf_set_option(bufnr, "filetype", "ros")
							end
						end),
					})
					job:start()
				end)
			end
		end,
	})
end

function M.preview_elements(preview_opts)
	local timer
	local current_job
	return previewers.new_buffer_previewer({
		get_buffer_by_name = function(_, entry)
			return entry.name
		end,
		define_preview = function(self, entry)
			local bufnr = self.state.bufnr
			if self.state.bufname ~= entry.name or vim.api.nvim_buf_line_count(bufnr) == 1 then
				if timer then
					vim.fn.timer_stop(timer)
					timer = nil
				end
				if current_job then
					current_job:shutdown()
					current_job = nil
				end
				local job_args = { preview_opts.command, preview_opts.mode, entry.value }
				-- Check if preview_opts.args exists and is not an empty string
				if preview_opts.args and preview_opts.args ~= "" then
					table.insert(job_args, preview_opts.args)
				end
				timer = vim.fn.timer_start(100, function()
					current_job = Job:new({
						enable_recording = true,
						command = "ros2",
						args = job_args,
						on_exit = vim.schedule_wrap(function(j, _, code)
							local result = j:result()
							if vim.tbl_isempty(result) then
								vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Failed to preview " .. entry.value })
							else
								vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result)
							end
						end),
					})
					current_job:start()
				end)
			end
		end,
	})
end

return M
