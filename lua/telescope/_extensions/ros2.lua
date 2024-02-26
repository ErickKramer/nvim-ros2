local pickers = require("nvim-ros2.telescope.pickers")

return require("telescope").register_extension({
	-- setup = function(ext_config, config)
	--   -- access extension config and user config
	-- end,
	exports = {
		actions = pickers.actions,
		interfaces = pickers.interfaces,
		nodes = pickers.nodes,
		services = pickers.services,
		topics = pickers.topics,
	},
})
