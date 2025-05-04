require("luasnip.session.snippet_collection").clear_snippets("markdown")

local lifeos_relative_path = function()
	return f(function(_args, snip)
		local path = vim.fn.fnamemodify(vim.fn.expand("%"), ":h")
		-- if we're at the root of lifeOS, path is just an extra `.` so we return an empty string
		if path == "." then
			return ""
		end
		return ("/" .. path) or "oops"
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
			{
				-- we have to put this in a funtion node so the file name is evaluated where the snippet is being expanded
				-- otherwise the filename is read as this file (`vimwiki.lua`), and not the file the snippet is being generated in
				filename = f(function(_args, snip)
					local name = vim.fn.fnamemodify(vim.fn.expand("%"), ":t:r")
					return name or "oops"
				end),
				entry = i(0),
			}
		)
	),

	s( -- add a new page with link using our directory structure
		"+lifeOS new page",
		fmt(
			"[{pagename}]({path}/{filename})",
			{ pagename = i(1, "new_page"), path = lifeos_relative_path(), filename = rep(1) }
		)
	),

	s( -- add a new directory with link using our directory structure
		"+lifeOS new directory",
		fmt(
			"[{pagename}]({path}/{directory}/.{filename})",
			{ pagename = i(1, "new_dir"), path = lifeos_relative_path(), directory = rep(1), filename = rep(1) }
		)
	),
}
