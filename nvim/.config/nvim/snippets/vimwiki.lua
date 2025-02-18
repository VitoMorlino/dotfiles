require("luasnip.session.snippet_collection").clear_snippets("vimwiki")

-- we have to put this in its own function otherwise the filename is read as this file, and not the file the snippet is being generated in
local filename = function()
	return f(function(_args, snip)
		local name = vim.fn.fnamemodify(vim.fn.expand("%"), ":t:r")
		return name or "oops"
	end)
end

return {
	s(
		"lifeOS new game",
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
}
