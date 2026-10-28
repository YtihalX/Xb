# Standards

What the referee's Standards axis enforces in this project. Where a rule here and referee's built-in red-flag baseline disagree, this file wins. Rules come from research-retro findings and advisor rulings; each new rule says why it exists.

- **Dimensions are consistent.** Every equation in notes/ and paper/ balances in mass dimension; a dimensionless ratio is stated as one.
- **Limits are checked.** Each result is shown to reproduce its known limits (static, massless, threshold, weak coupling, a literature special case), by a check or a stated argument.
- **Conventions point to CONVENTIONS.md.** A sign, normalisation, or scheme is used as agreed there, and a deviation names the entry it departs from.
- **Every claim has a check or a citation.** A claim in notes/ or paper/ is backed by a check in checks/ or a pinned citation.
- **Numerics carry uncertainty and convergence evidence.** A computed number states its error and how it was estimated (grid, cutoff, truncation, statistics), with the convergence run that supports it.
- **Citations are pinned to a version and an equation.** `[@key] vN, Eq. (n)` in Markdown; in LaTeX the version and equation appear in the text or a comment beside `\cite{key}`.
