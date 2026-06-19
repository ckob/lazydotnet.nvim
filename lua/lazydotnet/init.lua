local M = {}

---@class lazydotnet.WindowConfig
---@field width_ratio? number The width of the floating window relative to the editor width (0.0 to 1.0)
---@field height_ratio? number The height of the floating window relative to the editor height (0.0 to 1.0)
---@field border? "none" | "single" | "double" | "rounded" | "solid" | "shadow" The border style of the floating window

---@class lazydotnet.Config
---@field cmd? string[] The command and arguments to launch lazydotnet
---@field window? lazydotnet.WindowConfig Configuration for the floating window

---@type lazydotnet.Config
M.config = {
	cmd = { "lazydotnet" },
	window = {
		width_ratio = 0.9,
		height_ratio = 0.9,
		border = "rounded",
	},
}

---@param opts? lazydotnet.Config
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

local function parse_version(ver_str)
	local major, minor, patch = string.match(ver_str, "(%d+)%.(%d+)%.(%d+)")
	if major then
		return { major = tonumber(major), minor = tonumber(minor), patch = tonumber(patch) }
	end
	return nil
end

local function check_min_version(ver, min_ver)
	if ver.major > min_ver.major then
		return true
	end
	if ver.major < min_ver.major then
		return false
	end
	if ver.minor > min_ver.minor then
		return true
	end
	if ver.minor < min_ver.minor then
		return false
	end
	return ver.patch >= min_ver.patch
end

M._version_checked = false
M._version_valid = false

function M.ensure_valid_version()
	if M._version_checked then
		return M._version_valid
	end

	local cmd_bin = M.config.cmd[1]
	if vim.fn.executable(cmd_bin) == 0 then
		vim.notify(
			"lazydotnet executable '"
				.. cmd_bin
				.. "' not found. Install it or configure require('lazydotnet').setup({cmd=...})",
			vim.log.levels.ERROR
		)
		return false
	end

	local ver_cmd = vim.deepcopy(M.config.cmd)
	table.insert(ver_cmd, "--version")

	local out = vim.fn.system(ver_cmd)
	if vim.v.shell_error ~= 0 then
		vim.notify("Failed to check lazydotnet version: " .. out, vim.log.levels.ERROR)
		return false
	end

	local ver_str = vim.trim(out)
	local ver = parse_version(ver_str)
	if not ver then
		vim.notify("Could not parse lazydotnet version: " .. ver_str, vim.log.levels.ERROR)
		return false
	end

	local min_ver = { major = 0, minor = 8, patch = 0 }
	if not check_min_version(ver, min_ver) then
		vim.notify("lazydotnet version " .. ver_str .. " is too old. Please upgrade to >= 0.7.0", vim.log.levels.ERROR)
		return false
	end

	M._version_checked = true
	M._version_valid = true
	return true
end

return M
