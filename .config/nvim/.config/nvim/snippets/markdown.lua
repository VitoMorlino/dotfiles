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


	## What are we doing?
	- {entry}
	- 

	## Future plans
	- 
	- 
	]],
			{ entry = i(0) }
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
