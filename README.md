# 🎮 🐢 nvim-ros2

**nvim-ros2** is a simple lua plugin that adds useful features to enhance your development workflow
while developing ROS 2 modules.

## 🪄 Features

### 🌳 Treesitter Parser

- Custom grammar with syntax [highlights](./queries/ros2/highlights.scm) for [ROS 2 interfaces](https://docs.ros.org/en/humble/Concepts/Basic/About-Interfaces.html) following official conventions.
- After configuring the plugin, the grammar can be installed using `TSInstall ros2`

#### ✨ Highlights Examples

- `.msg` file

![ROS 2 msg](./assets/ros2_msg.png)

- `.srv` file

![ROS 2 srv](./assets/ros2_srv.png)

- `.action` file

![ROS 2 action](./assets/ros2_action.png)

### 🔭 Telescope

- [Telescope](https://github.com/nvim-telescope/telescope.nvim) extension that adds pickers for ROS 2 components

#### Active Actions with info preview

![telescope actions](./assets/actions.gif)

#### Active interfaces with show preview

![telescope interfaces](./assets/interfaces.gif)

#### Active Nodes with info preview

![telescope nodes](./assets/nodes.gif)

#### Active Services with type preview

![telescope services](./assets/services.gif)

#### Active topics with info preview

![telescope topics](./assets/topics.gif)

### Autocommands

- Configure `*.action`, `*.msg`, and `*.srv` files as `ros` filetype
- Configure `*.launch`, `*.xacro`, and `*.urdf` files as `xml` filetype

## 🧰 Installation

[lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
	"ErickKramer/nvim-ros2",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
    opts = {
        -- Add any custom options here
			autocmds = true,
			telescope = true,
			treesitter = true,
    }
},
```

## Related Projects

- [taDachs/ros-nvim](https://github.com/taDachs/ros-nvim)
- [thibthib18/ros-nvim](https://github.com/thibthib18/ros-nvim)

## Disclaimer

The functionalities here provided were validated using [ROS 2 humble](https://docs.ros.org/en/humble/index.html).

![ROS humble](https://docs.ros.org/en/humble/_static/humble-small.png)
