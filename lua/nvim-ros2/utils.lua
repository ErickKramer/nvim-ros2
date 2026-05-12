-- lua/nvim-ros2/utils.lua

local M = {}

-- Session cache for workspace packages
local _pkg_cache = {}
local _merged_cache = {} -- [NEW] Independent cache for the async merged list
-- Auto-invalidate cache if a package.xml is edited/saved
local cache_group = vim.api.nvim_create_augroup("Ros2UtilsCache", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "package.xml",
  group = cache_group,
  callback = function()
    _pkg_cache = {}
    _merged_cache = {}
  end,
})
-- Private Helper: Handles both Buffer IDs and String Paths (Explorer Agnostic).
-- Note: The regex aggressively strips ANY protocol prefix (e.g., oil://, neo-tree://).
-- It will also strip remote protocols like scp:// or ssh://, silently falling back to getcwd().
-- This is an acceptable trade-off for local ROS 2 workspace generality.
local function get_search_path(target)
  local path = ""
  -- 1. Resolve input to a string path
  if type(target) == "string" then
    path = target
  else
    path = vim.api.nvim_buf_get_name(target or 0)
  end
  -- 2. Universally strip ANY protocol prefix (e.g., oil://, neo-tree://, etc.)
  -- Matches any word starting with a letter, followed by letters/numbers/hyphens, ending in "://"
  path = path:gsub("^%a[%w%-]+://", "")

  -- 3. Fallback to cwd if empty
  if path == "" then
    return vim.fn.getcwd()
  end

  -- 4. Check real disk existence.
  -- If it's a virtual plugin buffer (like 'NvimTree_1'), stat will be nil.
  local stat = vim.uv.fs_stat(path)
  if stat then
    if stat.type == "directory" then
      return path
    end
    return vim.fs.dirname(path)
  end

  -- Fallback if the path doesn't actually exist on disk
  return vim.fn.getcwd()
end

function M.normalize_fqn(name)
  if not name then
    return ""
  end
  name = name:match("^%s*(.-)%s*$")
  if not name:match("^/") then
    name = "/" .. name
  end
  return name:gsub("/+$", "")
end

function M.get_base_name(fqn)
  return fqn:match("([^/]+)$") or fqn:gsub("^/", "")
end

--- Locates the root of the ROS 2 workspace robustly.
--- Scans upwards checking for the parallel existence of src/ and either build/ or install/
function M.get_workspace_root(target)
  local search_path = get_search_path(target)
  local current = search_path

  while current and current ~= "/" do
    local has_build = vim.uv.fs_stat(current .. "/build")
    local has_install = vim.uv.fs_stat(current .. "/install")
    local has_src = vim.uv.fs_stat(current .. "/src")

    if (has_build or has_install) and has_src then
      return current
    end
    current = vim.fs.dirname(current)
  end

  -- Fallback to package root if not in a standard Colcon workspace
  return M.get_package_root(target)
end

--- 📦 PACKAGE FINDER: Locates the specific package root (where package.xml lives).
--- 📦 PACKAGE FINDER: Locates the specific package root (where package.xml lives).
function M.get_package_root(target)
  local search_path = get_search_path(target)

  -- Pass 1: Strict package.xml search (Highest Priority for ROS 2)
  local root = vim.fs.find({ "package.xml" }, {
    path = search_path,
    upward = true,
  })[1]

  -- Pass 2: Fallback to .git if we are outside a ROS package but in a repo
  if not root then
    root = vim.fs.find({ ".git" }, {
      path = search_path,
      upward = true,
    })[1]
  end

  return root and vim.fs.dirname(root) or vim.fn.getcwd()
end

M.find_package_root = M.get_package_root

--- Scans the workspace and returns a table mapping ROS 2 package names to their directory paths.
function M.get_workspace_packages(ws_root)
  if not ws_root then
    return {}
  end

  if _pkg_cache[ws_root] then
    return _pkg_cache[ws_root]
  end

  local cmd = vim.fn.executable("fd") == 1
      and {
        "fd",
        "-t",
        "f",
        "^package.xml$",
        ws_root,
        "-E",
        "build/",
        "-E",
        "install/",
        "-E",
        "log/",
      }
    or {
      "find",
      ws_root,
      "-type",
      "f",
      "-name",
      "package.xml",
      "-not",
      "-path",
      "*/build/*",
      "-not",
      "-path",
      "*/install/*",
      "-not",
      "-path",
      "*/log/*",
    }

  local xml_files = vim.fn.systemlist(cmd)
  local packages = {}

  for _, xml_path in ipairs(xml_files) do
    local pkg_dir = vim.fs.dirname(xml_path)
    local pkg_name = vim.fs.basename(pkg_dir)

    -- Parse XML for the true package name
    local f = io.open(xml_path, "r")
    if f then
      local content = f:read("*a")
      f:close()
      pkg_name = content:match("<name>%s*(.-)%s*</name>") or pkg_name
    end

    packages[pkg_name] = pkg_dir
  end

  _pkg_cache[ws_root] = packages
  return packages
end

--- Opens a directory using the user's preferred file explorer
--- Falls back to native netrw (Explore) if no popular plugin is found
function M.open_directory(path)
  -- 1. Oil.nvim
  if pcall(require, "oil") then
    require("oil").open(path)

    -- 2. Mini.files
  elseif pcall(require, "mini.files") then
    require("mini.files").open(path)

    -- 3. Neo-tree
  elseif pcall(require, "neo-tree.command") then
    require("neo-tree.command").execute({ action = "focus", dir = path })

    -- 4. Nvim-tree
  elseif pcall(require, "nvim-tree.api") then
    require("nvim-tree.api").tree.open({ path = path })

    -- 5. Fallback to native netrw
  else
    vim.cmd("Explore " .. vim.fn.fnameescape(path))
  end
end

--- Asynchronously merges local and global ROS 2 packages into a unified, sorted list.
function M.get_merged_packages(ws_root, show_global, cb)
  -- 1. Check Cache
  local cache_key = (ws_root or "none") .. "_" .. tostring(show_global)
  if _merged_cache[cache_key] then
    return cb(_merged_cache[cache_key])
  end

  -- 2. Fetch Local Packages (Async)
  local cmd = vim.fn.executable("fd") == 1
      and {
        "fd",
        "-t",
        "f",
        "^package.xml$",
        ws_root,
        "-E",
        "build/",
        "-E",
        "install/",
        "-E",
        "log/",
      }
    or {
      "find",
      ws_root,
      "-type",
      "f",
      "-name",
      "package.xml",
      "-not",
      "-path",
      "*/build/*",
      "-not",
      "-path",
      "*/install/*",
      "-not",
      "-path",
      "*/log/*",
    }

  vim.system(cmd, { text = true }, function(local_out)
    vim.schedule(function()
      local local_pkgs = {}
      if local_out.code == 0 and local_out.stdout ~= "" then
        for _, xml_path in ipairs(vim.split(local_out.stdout, "\n", { trimempty = true })) do
          local pkg_dir = vim.fs.dirname(xml_path)
          local pkg_name = vim.fs.basename(pkg_dir)

          local f = io.open(xml_path, "r")
          if f then
            local content = f:read("*a")
            f:close()
            pkg_name = content:match("<name>%s*(.-)%s*</name>") or pkg_name
          end

          local_pkgs[pkg_name] = pkg_dir
        end
      end

      local items = {}
      for pkg_name, pkg_dir in pairs(local_pkgs) do
        table.insert(items, { text = pkg_name, pkg_dir = pkg_dir, is_global = false, sort_idx = 1 })
      end

      -- 3. Return early if globals are disabled
      if not show_global then
        table.sort(items, function(a, b)
          return a.text < b.text
        end)
        _merged_cache[cache_key] = items
        return cb(items)
      end

      -- 4. Fetch Global Packages via API (Async)
      -- Require locally to prevent circular dependency with api/ros2.lua
      local RosApi = require("nvim-ros2.api.ros2")
      RosApi.get_all_packages(function(global_pkgs)
        for _, pkg_name in ipairs(global_pkgs) do
          if not local_pkgs[pkg_name] then
            table.insert(items, { text = pkg_name, pkg_dir = nil, is_global = true, sort_idx = 2 })
          end
        end

        table.sort(items, function(a, b)
          if a.sort_idx ~= b.sort_idx then
            return a.sort_idx < b.sort_idx
          end
          return a.text < b.text
        end)

        _merged_cache[cache_key] = items
        cb(items)
      end)
    end)
  end)
end

_G._ros2_last_standard_win = _G._ros2_last_standard_win or nil
local win_track_group = vim.api.nvim_create_augroup("Ros2WindowTracker", { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group = win_track_group,
  callback = function()
    local win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == "" then
      _G._ros2_last_standard_win = win
    end
  end,
})

--- Safely resolves the correct target window, completely bypassing floating pickers
function M.get_target_window()
  if _G._ros2_last_standard_win and vim.api.nvim_win_is_valid(_G._ros2_last_standard_win) then
    return _G._ros2_last_standard_win
  end
  return vim.api.nvim_get_current_win()
end

return M
