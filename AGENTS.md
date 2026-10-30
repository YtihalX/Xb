## Markdown compilation

- Compile markdown notes to pdf with `pandoc` and the `typst` pdf engine, always with citeproc, the project bibliography, and the math filter:

  ```bash
  pandoc file.md -o file.pdf --pdf-engine=typst --citeproc --bibliography=refs.bib --lua-filter=pandoc-typst.lua
  ```

  The flags are load-bearing: without `--citeproc --bibliography` the `[@key]` citations reach typst unresolved and fail the build; without the filter, the `\rm` math the notes use fails the TeX-to-typst conversion.

- `Xb.tex`: the finished paper [@Zhang:2026iyr]. Do not edit it during follow-up work; its bibliography is the frozen `Xb.bib`.
- `followup.tex`: the collaborators' follow-up list. Starting material for grill-research; the paper itself lives in `paper/`.
- `learning/`: the user's study notes. Not a source of truth: never draft GLOSSARY or CONVENTIONS entries from it, never cite it, never count its scripts as checks.
- `old/`: archive of superseded drafts. Never a source.
- `code/HadronDynamics.jl`: submodule of fkguo/HadronDynamics.jl. Changes go upstream by pull request.

<!-- research-skills:start -->
## Research skills

- **Notebook**: `NOTEBOOK.md` is the project's state: read it first. At the end of each task, update it (rewrite the state at the top; append dated decisions and dead ends to the log) and show the diff in your report.
- **One task at a time**: do the task the user names and show every intermediate step and assumption. Halt at each physics choice not yet settled (route, approximation, convention, what counts as a check) and put it to the user. End by proposing the next step; start it when the user says so.
- **Subagents** may take any part of the work, physics included; they return every step, and their result counts once the user has read it.
- **Checks**: a result counts as checked when an independent route confirms it (a limit, a symmetry, dimensions, a Ward identity, a second method, a pinned literature value). Propose candidate checks; the user picks (`cross-check`).
- **Language**: `GLOSSARY.md` (terms) and `CONVENTIONS.md` (notation) are binding; an entry is added or changed with the user's OK (`research-language`).
- **Writing**: paper text in `paper/` is physics prose for a journal reader; file paths, check names, and provenance stay in `notes/`. When the user gives a route or notation for a derivation, follow it and fill in every intermediate step.
- **Commits** happen when the user asks for one.
- **Layout**: derivations in `notes/`, checks in `checks/`, numerics in `code/`, toy models in `toy/`, the paper in `paper/`; create a folder when first needed. Working files are Markdown with LaTeX math (`$…$`); the paper is LaTeX, built with tectonic.
- **Literature**: `literature/<citekey>/` holds a paper's notes, source, and (once its formulas are used) its notation bridge. Add papers with `just add-paper <arXiv ID or DOI>`. `refs.bib` is exported by Zotero: fix the Zotero item, not the file. Cite `[@key]` in Markdown, `\cite{key}` in LaTeX.
- **Skill map**: cross-check over tdd, referee over code-review, discrepancy-hunt over diagnosing-bugs, toy-model over prototype, lit-check over research, research-language over domain-modeling; the code skills apply to `code/`.
<!-- research-skills:end -->
