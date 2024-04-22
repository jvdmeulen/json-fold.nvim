-- Load the Treesitter utility module
local ts_utils = require 'nvim-treesitter.ts_utils'

-- Module definition
local M = {}

M.opts = {
	-- Debug flag, set to 1 to enable debug logging
	debug = false
}

function M.setup(opts)
	M.opts = vim.tbl_deep_extend('force', M.opts, opts or {})
	vim.api.nvim_create_user_command('JsonUnfoldFromCursor', function() M.process_json('unfoldfromcursor') end, {nargs = 0})
	vim.api.nvim_create_user_command('JsonFoldFromCursor', function() M.process_json('foldfromcursor') end, {nargs = 0})
end

-- Function to log debug messages
local function log_debug(msg)
	if M.opts.debug == true then
		print(msg)
	end
end

-- Function to retrieve a JSON node at the cursor position
local function get_json_node_at_cursor()
	local cursor_node = ts_utils.get_node_at_cursor()
	if not cursor_node then return nil end -- Return nil if no node at cursor

	while cursor_node do
		local type = cursor_node:type()
		-- Check if the node type is 'object' or 'array'
		if type == 'object' or type == 'array' then
			return cursor_node
		end
		cursor_node = cursor_node:parent() -- Move to parent node
	end

	return nil
end

-- Function to process JSON data based on a mode (foldfromcursor or unfoldfromcursor)
local function process_json(mode)
	local bufnr = vim.api.nvim_get_current_buf() -- Get the current buffer number
	local node = get_json_node_at_cursor()    -- Get the JSON node at cursor
	if not node then
		log_debug("No valid JSON node found near the cursor")
		return
	end

	-- Get the text range of the node
	local start_row, start_col, end_row, end_col = vim.treesitter.get_node_range(node)
	-- Extract the text content from the buffer based on the node's position
	local content = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})
	log_debug(string.format("object or array found: \n%s", table.concat(content, "\n")))
	local json_content = table.concat(content, "\n") -- Combine lines into a single string
	local new_content

	-- Determine action based on mode
	if mode == 'foldfromcursor' then
		-- FoldFromCusor JSON using 'jq'
		new_content = vim.fn.system("echo " .. vim.fn.shellescape(json_content) .. " | jq -c .")
	elseif mode == 'unfoldfromcursor' then
		-- UnfoldFromCursor JSON using 'jq'
		new_content = vim.fn.system("echo " .. vim.fn.shellescape(json_content) .. " | jq .")
	else
		log_debug("Invalid modus given: " .. mode)
		return
	end
	-- Check if jq is not installed
	if new_content:find("jq: command not found") then
		print(string.format("jq is not installed, we're trying a fallback ( json_decode )"))
		new_content = vim.fn.json_encode(vim.fn.json_decode(json_content))
	end

	-- Split new content into lines
	local lines = vim.split(new_content, "\n")
	-- Remove an empty line at the end if present
	if lines[#lines] == "" then
		table.remove(lines, #lines)
	end

	-- Replace the text in the buffer with the new JSON content
	vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, lines)

	-- Construct and execute a command to reformat the edited region
	local command = string.format("normal! %dG%d|%dG=%dG", start_row + 1, start_col, start_row, start_row + #lines)
	vim.api.nvim_exec(command, false)

	log_debug( mode  .. " operation done on JSON data.")
end

-- Expose the process_json function to the module
M.process_json = process_json

-- Return the module
return M

