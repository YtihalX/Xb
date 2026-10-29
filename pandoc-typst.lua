-- pandoc-typst.lua: make project Markdown compile with --pdf-engine=typst.
-- texmath (pandoc's TeX -> typst math converter) lacks \rm, which the project's
-- notes and slices use (e.g. V^{\rm(OME)}, V_{\rm forward}). Rewrite it to
-- \mathrm with a braced argument, preserving the original grouping, before the
-- writer runs. Add further rewrites only for commands texmath actually rejects:
-- every added line must be paired with a failing example in a notes/ or
-- plan/slices/ file.

local function rewrite(text)
  -- \rm(...)  ->  \mathrm{...}
  text = text:gsub("\\rm%(([^()]*)%)", "\\mathrm{%1}")
  -- \rm Word  ->  \mathrm{Word}
  text = text:gsub("\\rm +([A-Za-z]+)", "\\mathrm{%1}")
  -- bare \rm  ->  \mathrm
  text = text:gsub("\\rm", "\\mathrm")
  return text
end

return {
  {
    Math = function(el)
      local text = rewrite(el.text)
      return pandoc.Math(el.mathtype, text)
    end,
  },
}
