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
    vim.notify(
      "nvim-ros2: Invalid picker option '" .. tostring(picker_name) .. "'",
      vim.log.levels.ERROR
    )
    return nil
  end
end

function M.interfaces()
  local picker = M.get_picker()
  if picker then
    picker.interfaces()
  end
end

function M.nodes(opts)
  local picker = M.get_picker()
  if picker then
    picker.nodes(opts)
  end
end

function M.actions()
  local picker = M.get_picker()
  if picker and picker.actions then
    picker.actions()
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

function M.packages()
  local picker = M.get_picker()
  if picker then
    picker.packages()
  end
end

function M.sniper(subdir)
  local picker = M.get_picker()
  if picker then
    picker.sniper(subdir)
  end
end

function M.find_files_package()
  local picker = M.get_picker()
  if picker then
    picker.find_files_package()
  end
end

function M.grep_package()
  local picker = M.get_picker()
  if picker then
    picker.grep_package()
  end
end

function M.edit_cmake()
  local Utils = require("nvim-ros2.utils")
  local pkg = Utils.get_package_root(0)
  if pkg then
    vim.cmd("edit " .. pkg .. "/CMakeLists.txt")
  end
end

function M.edit_package_xml()
  local Utils = require("nvim-ros2.utils")
  local pkg = Utils.get_package_root(0)
  if pkg then
    vim.cmd("edit " .. pkg .. "/package.xml")
  end
end

function M.saved_payloads()
  local picker = M.get_picker()
  if picker and picker.saved_payloads then
    picker.saved_payloads()
  else
    vim.notify(
      "Saved payloads picker not implemented for " .. require("nvim-ros2.config").options.picker,
      vim.log.levels.WARN
    )
  end
end

return M
