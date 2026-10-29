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

This is a research project run with the research skills; `ask-research` maps them.

- **Language**: `GLOSSARY.md` (terms) and `CONVENTIONS.md` (notation) are canonical. Use agreed entries only; a new term or convention pauses the work until the user agrees it (`research-language`).
- **Language gate**: while `just gate` fails, write no `plan/PLAN.md`, slice, wayfinder map, or run-plan run; run the language phase first.
- **Decisions**: `decisions/`. Advisor rulings (`Decided by: advisor`) are settled.
- **Work**: claims in `plan/PLAN.md`, claim slices in `plan/slices/`, derivations in `notes/`, checks in `checks/`, numerics in `code/`, toy models in `toy/`, the paper in `paper/`. Working files are Markdown with LaTeX math (`$…$`); the paper is LaTeX, built with tectonic.
- **Checks**: `just check` runs every check and builds the paper. Run it before every commit.
- **Literature**: `literature/<citekey>/` holds each paper's bridge, notes, and source. Add papers with `just add-paper <arXiv ID or DOI>`. `refs.bib` is exported by Zotero; edit the Zotero item, never the file. Cite `[@key]` in Markdown, `\cite{key}` in LaTeX.
- **Review standards**: `STANDARDS.md`.

### Skill map

In this project:

- checks-first, not tdd, for physics claims; tdd only for code under `code/`.
- referee, not code-review, except for diffs confined to `code/`.
- discrepancy-hunt, not diagnosing-bugs, except for code bugs.
- toy-model, not prototype.
- lit-check, not research.
- result-brief, not pr, except when writing an actual pull request.
- research-language, never domain-modeling.
<!-- research-skills:end -->
