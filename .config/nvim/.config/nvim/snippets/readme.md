# NOTE: snippet labels should be prepended with a `+`
Example: `s("+test", t("tested"))`
- I have snippet completion set to give completion options as soon as I type the first character that matches one of my snippets
- This meant that snippet suggestions would pop up often when I was just trying to type and it was very distracting.
- To fix that, I told `nvim-cmp` to only provide `luasnip` completions if a `+` was inserted before one or more matching characters:
   `keyword_pattern = [[+\k\+]] ` 
- I did it this way so that I could still have completions from the first character from sources other than snippets
