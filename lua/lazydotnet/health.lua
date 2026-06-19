local M = {}

local function parse_version(ver_str)
  local major, minor, patch = string.match(ver_str, "(%d+)%.(%d+)%.(%d+)")
  if major then
    return { major = tonumber(major), minor = tonumber(minor), patch = tonumber(patch) }
  end
  return nil
end

local function check_min_version(ver, min_ver)
  if ver.major > min_ver.major then return true end
  if ver.major < min_ver.major then return false end
  if ver.minor > min_ver.minor then return true end
  if ver.minor < min_ver.minor then return false end
  return ver.patch >= min_ver.patch
end

M.check = function()
  vim.health.start("lazydotnet")

  -- Read the configured command from our plugin (default to just "lazydotnet")
  local ok, lazydotnet = pcall(require, "lazydotnet")
  local cmd_table = (ok and lazydotnet.config and lazydotnet.config.cmd) or { "lazydotnet" }
  local cmd_bin = cmd_table[1]

  if vim.fn.executable(cmd_bin) == 0 then
    vim.health.warn("executable '" .. cmd_bin .. "' not found in PATH.", {
      "Install lazydotnet globally: dotnet tool install -g lazydotnet",
      "Or configure a custom path in your setup(): require('lazydotnet').setup({ cmd = { '/path/to/bin' } })"
    })
    return
  else
    vim.health.ok("executable '" .. cmd_bin .. "' found.")
  end

  local ver_cmd = vim.deepcopy(cmd_table)
  table.insert(ver_cmd, "--version")
  
  local out = vim.fn.system(ver_cmd)
  if vim.v.shell_error ~= 0 then
    vim.health.error("Failed to run version check: `" .. table.concat(ver_cmd, " ") .. "`", { out })
    return
  end

  local ver_str = vim.trim(out)
  local ver = parse_version(ver_str)
  
  if not ver then
    vim.health.warn("Could not parse lazydotnet version from string: '" .. ver_str .. "'")
    return
  end

  local min_ver = { major = 0, minor = 8, patch = 0 }

  if check_min_version(ver, min_ver) then
    vim.health.ok("Version " .. ver_str .. " meets the minimum requirement (>= 0.7.0)")
  else
    vim.health.error(
      "Version " .. ver_str .. " is too old.",
      { "Please upgrade to at least version 0.7.0 to support robust Neovim IPC wrappers." }
    )
  end
end

return M
