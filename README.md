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

![telescope topics_info](./assets/topics.gif)

### Autocommands

- Configure `*.action`, `*.msg`, and `*.srv` files as `ros` filetype
- Configure `*.launch`, `*.xacro`, and `*.urdf` files as `xml` filetype


### 🧭 Workspace Navigator

Package-aware pickers designed to scope your searches to the specific ROS 2 package you are currently editing. Available across Telescope, Snacks, and Fzf-lua.

- **Scoped Searches:** Find files or live grep exclusively within the boundaries of the active package.
- **Package Hub:** List all ROS 2 packages in your workspace and open them in your file explorer.
- **Quick-Edits:** Instantly jump to the `CMakeLists.txt` or `package.xml` of your current package.
- **Snipers:** Fast directory navigation to jump directly into `msg/`, `srv/`, `action/`, or `include/` folders.
- **Smart Attach:** Press `<C-t>` while hovering over a node in the Active Nodes picker to instantly attach the ROS Tuner to its matching file, or `<C-r>` to attach a raw Scratch Proxy.
- **Topic Echo:** Select an active topic to spawn a live, safely-managed buffer streaming YAML output.
- **Interface Jumper:** Search `msg`, `srv`, or `action` definitions and press `<CR>` to instantly jump to the source file, resolving via `install` or local `src` directories automatically.
When opening directories via the **Package Hub** or **Snipers**, the plugin automatically detects and uses your preferred file explorer. It currently supports out-of-the-box integration with:
- [oil.nvim](https://github.com/stevearc/oil.nvim)
- [mini.files](https://github.com/echasnovski/mini.files)
- [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)
- [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)

#### Package Navigation

![packages navigation](./assets/packages_navigation.gif)

#### Interface Jumper

![interfaces goto](./assets/interfaces-goto.gif)



### 🚀 The RPC Engine (Services & Actions)

Launch ephemeral, auto-cleaning scratch buffers to execute ROS 2 calls just like Postman or Insomnia. 

- **Live Streaming:** Trigger long-running actions. The engine intercepts Python CLI outputs and continuously rewrites the buffer's response section with clean, readable YAML.
- **Safe Execution:** Stop long-running actions gracefully. Pressing `s` sends a native `SIGINT` (Ctrl-C) to trigger the Action Server's cancellation pipeline.
- **Payload Management:** Save your YAML payloads to disk. The engine injects interface metadata so the **Smart Load Picker** (`<leader>l`) only displays payloads compatible with the current Service/Action.

#### RPC Tools Demo

![rpc tools](./assets/ros2_rpc_tools.gif)

### 🎛️ ROS 2 Tuner

A hardware-in-the-loop tuning engine to safely synchronize local parameter files (`.yaml` / `.param`) with live DDS nodes on your robot. 

- **Node-First Workflow (`:RosTune attach <node>`):** Select a live node from the network. The engine will instantly open its matching `.yaml` source file. 
  - *Want to just mess around safely?* Add `--scratch` (or hit `<C-r>` in the Nodes Picker) to bypass your local files and spawn a temporary, synthetic proxy buffer perfectly synced to the live node.
- **File-First Workflow (`:RosTune`):** Open any local parameter file and run the command. The engine scans the DDS network, fuzzily matches your YAML keys to active nodes, and spawns a connected Tuning Console.
- **Crucible Mode (Safe Git Integration):** After experimenting with live values in the Tuning Console, simply save the file (`:w`). Both the console and your original file will enter Neovim's `diffthis` mode side-by-side, allowing you to selectively push (`dp`) your tuned values back to the source code.
- **Live Event Loop:** Values and boundaries (Ranges) are dynamically fetched as virtual text. Modifying a value in Insert mode safely triggers a `ros2 param set` network call in the background.

#### Smart Attach & Live Tuning

![node tuner](./assets/node_tuner.gif)

### 🎛️ ROS 2 Tuner Auto-Discovery

To prevent flooding your curated `.yaml` configuration files with ROS 2 systemic and component defaults, the Tuner does not automatically inject missing parameters by default.

* **File-backed Buffers:** Syncing will only update the values of parameters already present in your file. 
  * Use `:RosTune resync --pull` (or `<leader>rp`) to explicitly fetch and inject newly discovered parameters.
  * Set `tuner_pull_missing = true` in your `opts` to automatically pull them every time.
* **Synthetic Proxy Buffers:** When using `:RosTune attach` without a backing file, the Tuner will always pull and display all live parameters regardless of this setting.

#### Missing Parameter Injection

![tuner pull](./assets/tuner_pull.gif)

#### 📊 Statusline Integration
You can expose the buffer's tuning health (synced, unused, or offline parameters) directly in your statusline (e.g., Lualine):
```lua
require("lualine").setup({
  sections = {
    lualine_x = { require("nvim-ros2").tuner_status },
  }
})
```

## 🧰 Installation

## Configuration

### Lazy.nvim

#### Default (Telescope)

```lua
return {
  "ErickKramer/nvim-ros2",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    picker = "telescope",
    autocmds = true,
    treesitter = true,
    tuner = true, -- Enables the :RosTune command and hardware proxy
    tuner_match_mode = "smart", -- "smart" (algorithm), "simple" (root keys), or "all" (skip filter)
    tuner_open_mode = "hide",
  },
config = function(_, opts)
    require("nvim-ros2").setup(opts)

    -- RPC Engine Keymaps (Buffer-Local)
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "ROS_CALL_*",
      callback = function(args)
        local bufnr = args.buf
        local map_opts = { buffer = bufnr, silent = true }

        -- Execute the payload
        vim.keymap.set("n", "<CR>", "<cmd>RosRpc send<CR>", vim.tbl_extend("force", map_opts, { desc = "Send RPC Call" }))
        -- Gracefully cancel
        vim.keymap.set("n", "s", "<cmd>RosRpc stop<CR>", vim.tbl_extend("force", map_opts, { desc = "Stop RPC Call" }))
        -- Save with metadata
        vim.keymap.set("n", "<leader>s", "<cmd>RosRpc save<CR>", vim.tbl_extend("force", map_opts, { desc = "Save Payload" }))
        -- Smart Load compatible payloads
        vim.keymap.set("n", "<leader>l", function() require("nvim-ros2.pickers").saved_payloads() end, vim.tbl_extend("force", map_opts, { desc = "Load Payload" }))
        -- Quick exit
        vim.keymap.set("n", "q", "<cmd>q<CR>", vim.tbl_extend("force", map_opts, { desc = "Close RPC Buffer" }))
      end,
    })
  end,
  keys = {
    -- Base Pickers
    { "<leader>li", function() require("nvim-ros2").pickers.interfaces() end, desc = "[ROS 2]: List interfaces" },
    { "<leader>ln", function() require("nvim-ros2").pickers.nodes() end, desc = "[ROS 2]: List nodes" },
    { "<leader>la", function() require("nvim-ros2").pickers.actions() end, desc = "[ROS 2]: List actions" },
    { "<leader>lt", function() require("nvim-ros2").pickers.topics_info() end, desc = "[ROS 2]: List topics with info" },
    { "<leader>le", function() require("nvim-ros2").pickers.topics_echo() end, desc = "[ROS 2]: List topics with echo" },
    { "<leader>ls", function() require("nvim-ros2").pickers.services() end, desc = "[ROS 2]: List services" },
    
    -- Workspace Navigator
    { "<leader>fp", function() require("nvim-ros2").pickers.packages() end, desc = "[F]ind ROS2 [P]ackage" },
    { "<leader>pf", function() require("nvim-ros2").pickers.find_files_package() end, desc = "Find in Package" },
    { "<leader>pg", function() require("nvim-ros2").pickers.grep_package() end, desc = "Grep in Package" },
    { "<leader>pc", function() require("nvim-ros2").pickers.edit_cmake() end, desc = "Edit CMakeLists.txt" },
    { "<leader>pp", function() require("nvim-ros2").pickers.edit_package_xml() end, desc = "Edit package.xml" },
    
    -- Snipers
    { "<leader>pm", function() require("nvim-ros2").pickers.sniper("msg") end, desc = "Sniper: msg/" },
    { "<leader>ps", function() require("nvim-ros2").pickers.sniper("srv") end, desc = "Sniper: srv/" },
    { "<leader>pa", function() require("nvim-ros2").pickers.sniper("action") end, desc = "Sniper: action/" },
    { "<leader>pi", function() require("nvim-ros2").pickers.sniper("include") end, desc = "Sniper: include/" },

    -- Tuner
    { "<leader>rt", "<cmd>RosTune<cr>", desc = "Start ROS Tuner" },
    { "<leader>rs", "<cmd>RosTune resync<CR>", desc = "[T]uner [R]esync" },
    { "<leader>rp", "<cmd>RosTune resync --pull<CR>", desc = "[T]uner [P]ull Missing Params" },
  },
}
```

#### Snacks.nvim

```lua
return {
  "tcozic/nvim-ros2",
  dependencies = {
    "folke/snacks.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    picker = "snacks",
    autocmds = true,
    treesitter = true,
    tuner = true,
    tuner_match_mode = "smart",
  },
  keys = {
    -- Base Pickers
    { "<leader>li", function() require("nvim-ros2").pickers.interfaces() end, desc = "[ROS 2]: List interfaces" },
    { "<leader>ln", function() require("nvim-ros2").pickers.nodes() end, desc = "[ROS 2]: List nodes" },
    { "<leader>la", function() require("nvim-ros2").pickers.actions() end, desc = "[ROS 2]: List actions" },
    { "<leader>lt", function() require("nvim-ros2").pickers.topics_info() end, desc = "[ROS 2]: List topics with info" },
    { "<leader>le", function() require("nvim-ros2").pickers.topics_echo() end, desc = "[ROS 2]: List topics with echo" },
    { "<leader>ls", function() require("nvim-ros2").pickers.services() end, desc = "[ROS 2]: List services" },
    
    -- Workspace Navigator
    { "<leader>fp", function() require("nvim-ros2").pickers.packages() end, desc = "[F]ind ROS2 [P]ackage" },
    { "<leader>pf", function() require("nvim-ros2").pickers.find_files_package() end, desc = "Find in Package" },
    { "<leader>pg", function() require("nvim-ros2").pickers.grep_package() end, desc = "Grep in Package" },
    { "<leader>pc", function() require("nvim-ros2").pickers.edit_cmake() end, desc = "Edit CMakeLists.txt" },
    { "<leader>pp", function() require("nvim-ros2").pickers.edit_package_xml() end, desc = "Edit package.xml" },
    
    -- Snipers
    { "<leader>pm", function() require("nvim-ros2").pickers.sniper("msg") end, desc = "Sniper: msg/" },
    { "<leader>ps", function() require("nvim-ros2").pickers.sniper("srv") end, desc = "Sniper: srv/" },
    { "<leader>pa", function() require("nvim-ros2").pickers.sniper("action") end, desc = "Sniper: action/" },
    { "<leader>pi", function() require("nvim-ros2").pickers.sniper("include") end, desc = "Sniper: include/" },

    -- Tuner
    { "<leader>rt", "<cmd>RosTune<cr>", desc = "Start ROS Tuner" },
    { "<leader>rs", "<cmd>RosTune resync<CR>", desc = "[T]uner [R]esync" },
    { "<leader>rp", "<cmd>RosTune resync --pull<CR>", desc = "[T]uner [P]ull Missing Params" },
  },
}
```

#### Fzf-lua

```lua
return {
  "tcozic/nvim-ros2",
  dependencies = {
    "ibhagwan/fzf-lua",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    picker = "fzf",
    autocmds = true,
    treesitter = true,
    tuner = true,
    tuner_match_mode = "smart",
  },
  keys = {
    -- Base Pickers
    { "<leader>li", function() require("nvim-ros2").pickers.interfaces() end, desc = "[ROS 2]: List interfaces" },
    { "<leader>ln", function() require("nvim-ros2").pickers.nodes() end, desc = "[ROS 2]: List nodes" },
    { "<leader>la", function() require("nvim-ros2").pickers.actions() end, desc = "[ROS 2]: List actions" },
    { "<leader>lt", function() require("nvim-ros2").pickers.topics_info() end, desc = "[ROS 2]: List topics with info" },
    { "<leader>le", function() require("nvim-ros2").pickers.topics_echo() end, desc = "[ROS 2]: List topics with echo" },
    { "<leader>ls", function() require("nvim-ros2").pickers.services() end, desc = "[ROS 2]: List services" },
    
    -- Workspace Navigator
    { "<leader>fp", function() require("nvim-ros2").pickers.packages() end, desc = "[F]ind ROS2 [P]ackage" },
    { "<leader>pf", function() require("nvim-ros2").pickers.find_files_package() end, desc = "Find in Package" },
    { "<leader>pg", function() require("nvim-ros2").pickers.grep_package() end, desc = "Grep in Package" },
    { "<leader>pc", function() require("nvim-ros2").pickers.edit_cmake() end, desc = "Edit CMakeLists.txt" },
    { "<leader>pp", function() require("nvim-ros2").pickers.edit_package_xml() end, desc = "Edit package.xml" },
    
    -- Snipers
    { "<leader>pm", function() require("nvim-ros2").pickers.sniper("msg") end, desc = "Sniper: msg/" },
    { "<leader>ps", function() require("nvim-ros2").pickers.sniper("srv") end, desc = "Sniper: srv/" },
    { "<leader>pa", function() require("nvim-ros2").pickers.sniper("action") end, desc = "Sniper: action/" },
    { "<leader>pi", function() require("nvim-ros2").pickers.sniper("include") end, desc = "Sniper: include/" },

    -- Tuner
    { "<leader>rt", "<cmd>RosTune<cr>", desc = "Start ROS Tuner" },
    { "<leader>rs", "<cmd>RosTune resync<CR>", desc = "[T]uner [R]esync" },
    { "<leader>rp", "<cmd>RosTune resync --pull<CR>", desc = "[T]uner [P]ull Missing Params" },
  },
}
```

## Related Projects

- [taDachs/ros-nvim](https://github.com/taDachs/ros-nvim)
- [thibthib18/ros-nvim](https://github.com/thibthib18/ros-nvim)

## Disclaimer

The functionalities here provided were validated using [ROS 2 humble](https://docs.ros.org/en/humble/index.html).

![ROS humble](https://docs.ros.org/en/humble/_static/humble-small.png)
