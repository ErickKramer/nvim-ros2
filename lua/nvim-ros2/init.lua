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
  local parser_path = get_parser_path() .. "/treesitter-ros2"
  local parser_config = {
    install_info = {
      path = parser_path,
    },
  }

  -- Register parser config immediately for healthcheck
  require("nvim-treesitter.parsers").ros2 = parser_config

  -- Also register in TSUpdate autocommand as recommended
  vim.api.nvim_create_autocmd("User", {
    pattern = "TSUpdate",
    callback = function()
      require("nvim-treesitter.parsers").ros2 = parser_config
    end,
  })

  vim.treesitter.language.register("ros2", "ros")
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
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.launch", "*.xacro", "*.sdf", "*.urdf" },
    command = "set filetype=xml",
    group = ros2_group,
  })
end

-- lua/nvim-ros2/init.lua

function M.setup(opts)
  -- Get default values
  Config.setup(opts)

  if Config.options.picker == "telescope" then
    require("telescope").load_extension("ros2")
  end

  if Config.options.tuner then
    vim.api.nvim_create_user_command("RosTune", function(o)
      local args = vim.split(o.args, " ", { trimempty = true })
      local Tuner = require("nvim-ros2.tuner")

      if #args == 0 then
        Tuner.start_session()
      elseif args[1] == "attach" then
        local force_scratch = false
        local target_node = nil

        for i = 2, #args do
          if args[i] == "--scratch" then
            force_scratch = true
          elseif not target_node then
            target_node = args[i]
          end
        end

        if target_node then
          Tuner.attach_node(target_node, force_scratch)
        else
          vim.notify("ROS Tuner: Node name required.", vim.log.levels.ERROR)
        end
      elseif args[1] == "resync" then
        -- Check if any subsequent argument is the pull flag
        local force_pull = false
        for i = 2, #args do
          if args[i] == "--pull" then
            force_pull = true
            break
          end
        end
        -- Pass the flag to global_resync (bufnr=0 means current buffer)
        Tuner.global_resync(0, nil, force_pull)
      end
    end, {
      nargs = "*",
      complete = function(arglead, cmdline)
        local normalized_cmd = cmdline:gsub("^%s*", ""):gsub("%s+", " ")
        if vim.startswith(normalized_cmd, "RosTune resync") then
          return vim.tbl_filter(function(v)
            return vim.startswith(v, arglead) -- Safe prefix matching
          end, { "--pull" })
        end
        if normalized_cmd:match("^RosTune attach [%w_/%-]+") then
          return vim.tbl_filter(function(v)
            return vim.startswith(v, arglead)
          end, { "--scratch" })
        end
        -- Default completion for the base command
        return vim.tbl_filter(function(v)
          return vim.startswith(v, arglead) -- Safe prefix matching
        end, { "attach", "resync" })
      end,
    })
  end

  if Config.options.treesitter then
    M.setup_ros2_treesitter()
  end

  if Config.options.autocmds then
    M.setup_ros2_autocmds()
  end
end

M.pickers = require("nvim-ros2.pickers")
function M.tuner_status()
  if Config.options.tuner then
    return require("nvim-ros2.tuner.ui").tuner_status()
  end
  return ""
end

return M
