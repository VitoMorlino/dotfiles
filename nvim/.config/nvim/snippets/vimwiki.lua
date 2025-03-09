require("luasnip.session.snippet_collection").clear_snippets("vimwiki")

-- we have to put this in its own function otherwise the filename is read as this file (`vimwiki.lua`), and not the file the snippet is being generated in
local filename = function()
	return f(function(_args, snip)
		local name = vim.fn.fnamemodify(vim.fn.expand("%"), ":t:r")
		return name or "oops"
	end)
end

local lifeos_relative_path = function()
	return f(function(_args, snip)
		local path = vim.fn.fnamemodify(vim.fn.expand("%"), ":h")
		if path == "." then
			return ""
		end
		return "/" .. path or "oops"
	end)
end

return {
	s(
		"+lifeOS new game",
		fmt(
			[[
	# {filename}

	## What are we doing?
	- {entry}
	- 
	
	## Future plans
	- 
	- 
	]],
			{ filename = filename(), entry = i(0) }
		)
	),

	-- add a new page with link using our directory structure
	s(
		"+lifeOS new page",
		fmt(
			"[{pagename}]({path}/{filename})",
			{ pagename = i(1, "new_page"), path = lifeos_relative_path(), filename = rep(1) }
		)
	),

	-- add a new directory with link using our directory structure
	s(
		"+lifeOS new directory",
		fmt(
			"[{pagename}]({path}/{directory}/.{filename})",
			{ pagename = i(1, "new_dir"), path = lifeos_relative_path(), directory = rep(1), filename = rep(1) }
		)
	),
}
