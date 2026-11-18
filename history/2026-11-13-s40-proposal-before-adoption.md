# `notes/07-continued-lse/s40-proposal.tex` before the S40 decision (2026-11-13)

Lines of the draft as they stood before the user adopted the sheet-as-a-sign form of the deformed SP method on 2026-11-13 (history/LOG.md, same date). Line numbers are those of the draft before the edit. The rest of the draft (R1–R6, L1–L7, the figures) is unchanged; L8 and the paragraph "Rectangles" were added after line 211.

Line 4:

```tex
\title{S40 proposal: one path rule for every energy region}
```

Line 10:

```tex
\noindent A draft for \file{notes/07-continued-lse.tex}; nothing in note~07 changes until the user adopts it. If adopted, it replaces S40 (\texttt{st:shape}) and amends S41 (\texttt{st:diagnostic}), S38 (\texttt{st:validator}) and condition (P) of S23 (\texttt{st:admissible}) with \file{NOTEBOOK.md}, Decisions, Admissibility. Statement numbers are those of note~07.
```

Line 196:

```tex
An alternative to R1 (the user, 2026-11-13), not adopted; R2--R6 stay. With Sokhotski--Plemelj the sheet enters channel $\alpha$ only through the sign $\sigma_\alpha$ in
```

Lines 231–240:

```tex
\section{What changes if adopted}
\begin{itemize}
\item S40 becomes R1--R4 with the scenario table; the remark after the path table (the margin $d_k$ limiting near thresholds) goes. $d_k$ keeps its meaning for the S40 path, kept as the second path of the Stage~6 path-independence check.
\item S41: R5 replaces ``one path certified for the whole rectangle''.
\item S38: in the first five rows the certification is structural (L1, L2, L4); the validator reports the slopes, the S35 bound and the placement, and samples only in the row next to $E_{3,1}$ and beyond.
\item S23 (P) and Decisions, Admissibility: a flipped pole may lie on the path at a vertex, read as the limit of paths passing just below it (L3).
\item S30: for the rule, $\mathcal H$ is the homotopy (L3); S30's fixed path still certifies $D$ but not on-shell quantities once $|\operatorname{Im}k_F|>m_\pi/2$ (L5).
\item S32 is unchanged; along $\mathcal H$ its first condition and its depth window hold by L5.
\item Code: a path builder for R1 and R4 in \file{code/Xb2Continuation}, and the extra nodes of Eq.~\eqref{eq:W} in the Stage~6 solver.
\end{itemize}
```

Line 244 (first item of "Choices"):

```tex
\item Adopt R1--R6 and the scenario table as S40, with R1 either the polygon through the flipped poles or the sheet-as-a-sign form of Sec.~\ref{sec:sign}.
```
