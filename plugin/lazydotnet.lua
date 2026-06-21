local term_buf = nil

_G.LazyDotnetCloseFloat = function()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == term_buf then
			vim.api.nvim_win_close(win, false)
			break
		end
	end
	return ""
end

vim.api.nvim_create_user_command("LazyDotnet", function()
	local ok, lazydotnet = pcall(require, "lazydotnet")
	if not ok then
		vim.notify("lazydotnet lua module not found", vim.log.levels.ERROR)
		return
	end

	if not lazydotnet.ensure_valid_version() then
		return
	end

	local bridge_path = vim.fn.stdpath("data") .. "/lazydotnet_bridge.lua"

	local script_content = [[
local host = os.getenv("NVIM")
local nvim_bin = os.getenv("NVIM_BIN") or "nvim"
if not host then return end

local arg1 = _G.arg[1]
local arg2 = _G.arg[2]
local line = nil
local file = nil

if arg1 and string.match(arg1, "^%+%d+$") then
  -- Vim style: +line file
  line = string.match(arg1, "^%+(%d+)$")
  file = arg2
elseif arg1 and string.match(arg1, ":%d+$") then
  -- Default style: file:line (handles Windows C:\ paths properly)
  file, line = string.match(arg1, "^(.*):(%d+)$")
else
  file = arg1
end

if not file then return end

-- 1. Close float
vim.fn.system({nvim_bin, "--server", host, "--remote-expr", "v:lua.LazyDotnetCloseFloat()"})

-- 2. Open file safely
vim.fn.system({nvim_bin, "--server", host, "--remote", file})

-- 3. Go to line if provided
if line then
  vim.fn.system({nvim_bin, "--server", host, "--remote-send", "<C-\\><C-n>:" .. line .. "<CR>"})
end
]]

	local f = io.open(bridge_path, "w")
	if f then
		f:write(script_content)
		f:close()
	end

	local win_cfg = lazydotnet.config.window
	local width = math.floor(vim.o.columns * win_cfg.width_ratio)
	local height = math.floor(vim.o.lines * win_cfg.height_ratio)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = win_cfg.border,
	}

	if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
		local is_open = false
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == term_buf then
				vim.api.nvim_win_close(win, true)
				is_open = true
			end
		end

		if is_open then
			return
		end

		vim.api.nvim_open_win(term_buf, true, win_opts)
		vim.cmd("startinsert")
		return
	end

	term_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_open_win(term_buf, true, win_opts)

	-- Build the command to run the bridge script using the PR branch's argument parsing
	local editor_cmd = vim.v.progpath .. " -l " .. bridge_path

	vim.fn.jobstart(lazydotnet.config.cmd, {
		term = true,
		env = {
			EDITOR = editor_cmd,
			NVIM = vim.env.NVIM,
			NVIM_BIN = vim.v.progpath,
			COLORTERM = vim.env.COLORTERM,
		},
		on_exit = function(job_id, code, event)
			if code == 0 then
				if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == term_buf then
							vim.api.nvim_win_close(win, true)
						end
					end
					vim.api.nvim_buf_delete(term_buf, { force = true })
				end
			end
			term_buf = nil
			vim.cmd("checktime")
		end,
	})
	vim.cmd("startinsert")
end, {})
