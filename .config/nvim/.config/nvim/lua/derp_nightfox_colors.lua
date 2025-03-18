local derp_colors = {
	palettes = {
		all = {
			-- sel0 = "#4a0080", -- Popup bg, visual selection bg
			sel1 = "#660080", -- Popup sel bg, search bg
			bg1 = "#19151e", -- Default bg
			bg3 = "#241f2d", -- Lighter bg (cursor line)
			-- fg3 = "#4a0080", -- Darker fg (line numbers, fold columns)
		},
	},
	specs = {
		all = {
			syntax = {
				variable = "white",
				string = "magenta.bright",
				number = "magenta",
				type = "green.bright",
				const = "green",
				func = "blue.bright",
				field = "magenta.dim",
				builtin0 = "pink.bright", -- builtin variables
				builtin1 = "green.dim", -- builtin types
				-- builtin2 = "yellow", -- builtin constants
				-- bracket = "cyan.bright",
				comment = "#52527a",
				operator = "cyan.dim",
				-- statement = "red",
				-- ident = "red",
				keyword = "magenta",
				conditional = "blue",
				-- preproc = "yellow",
				-- regex = "yellow",
				-- dep = "yellow", -- deprecated text objects
			},
		},
	},
}

return derp_colors
