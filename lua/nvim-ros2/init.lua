local Config = require("nvim-ros2.config")
local M = {}

-- Get path to the nvim-ros2 plugin directory
local function get_parser_path()
	for _, p in pairs(vim.api.nvim_list_runtime_paths()) do
		if string.match(p, "nvim%-ros2") then
			return p
		end
	end
end

-- Configure custom treesitter grammar for ROS2 files
function M.setup_ros2_treesitter()
	local treesitter = require("nvim-treesitter.parsers")
	if treesitter ~= nil then
		local parser_config = treesitter.get_parser_configs()
		parser_config.ros2 = {
			install_info = {
				url = get_parser_path() .. "/treesitter-ros2/",
				files = { "src/parser.c" },
				generate_requires_npm = false,
				requires_generate_from_grammar = false,
			},
			filetype = "ros",
		}
	end
end

-- Configure ROS 2 autocommands
function M.setup_ros2_autocmds()
	local ros2_group = vim.api.nvim_create_augroup("nvim-ros2", { clear = true })
	-- Specify filetype for ROS 2 interfaces
	vim.api.nvim_create_autocmd(
		{ "BufRead", "BufNewFile" },
		{ pattern = { "*.action", "*.msg", "*.srv" }, command = "set filetype=ros", group = ros2_group }
	)
	-- Specify filetype other common ROS files
	vim.api.nvim_create_autocmd(
		{ "BufRead", "BufNewFile" },
		{ pattern = { "*.launch", "*.xacro", "*.urdf" }, command = "set filetype=xml", group = ros2_group }
	)
end

function M.setup(opts)
	-- Get default values
	Config.setup(opts)

	if Config.options.telescope then
		require("telescope").load_extension("ros2")
	end

	if Config.options.treesitter then
		M.setup_ros2_treesitter()
	end
	if Config.options.autocmds then
		M.setup_ros2_autocmds()
	end
end

return M
