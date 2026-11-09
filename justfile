# Research project tasks (research-skills).

set shell := ["bash", "-euo", "pipefail", "-c"]

papers := env_var("HOME") / ".agents/skills/setup-research/scripts/papers.py"
collection := "Research/Xb"

# List the recipes.
default:
    @just --list

# Run every check in checks/, build every note, then build the paper.
check: checks notes paper

# Run every check in checks/: *.py with uv, *.wl on the Wolfram kernel, *.jl with Julia. Files starting with _ are helpers.
checks:
    #!/usr/bin/env bash
    set -uo pipefail
    shopt -s nullglob
    failed=()
    ran=0
    for f in checks/*.py checks/*.wl checks/*.jl; do
        [[ $(basename "$f") == _* ]] && continue
        ran=1
        echo "== $f"
        case $f in
            *.py) uv run --quiet --script "$f" ;;
            *.wl) math -script "$f" ;;
            *.jl) julia --project=checks --startup-file=no "$f" ;;
        esac || failed+=("$f")
    done
    if (( ! ran )); then
        echo "checks: no checks yet"
        exit 0
    fi
    if (( ${#failed[@]} )); then
        printf 'FAILED: %s\n' "${failed[@]}"
        exit 1
    fi
    echo "checks: all passed"

# Build every LaTeX or Typst note: notes/*, literature/*/notes.*, literature/*/bridge.*, literature/survey.*. Files starting with _ are inputs.
notes:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    tex_docs=()
    typst_docs=()
    for f in notes/*.{tex,typ} literature/*/notes.{tex,typ} literature/*/bridge.{tex,typ} literature/survey.{tex,typ}; do
        [[ -f $f && $(basename "$f") != _* ]] || continue
        case $f in
            *.tex) tex_docs+=("$f") ;;
            *.typ) typst_docs+=("$f") ;;
        esac
    done
    if (( ! ${#tex_docs[@]} && ! ${#typst_docs[@]} )); then
        echo "notes: no notes yet"
        exit 0
    fi
    if (( ${#tex_docs[@]} )); then
        "{{just_executable()}}" --justfile "{{justfile()}}" tex "${tex_docs[@]}"
    fi
    if (( ${#typst_docs[@]} )); then
        "{{just_executable()}}" --justfile "{{justfile()}}" typst "${typst_docs[@]}"
    fi

# Build paper/main.tex with tex, into paper/build/.
paper:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ ! -f paper/main.tex ]]; then
        echo "paper: no paper yet"
        exit 0
    fi
    "{{just_executable()}}" --justfile "{{justfile()}}" tex paper/main.tex

# Build LaTeX documents with tectonic, each into a build/ folder beside it; an undefined citation or reference fails the document.
[positional-arguments]
tex +files:
    #!/usr/bin/env bash
    set -uo pipefail
    cd "{{invocation_directory()}}"
    failed=()
    for f in "$@"; do
        out=$(dirname "$f")/build
        name=$(basename "$f" .tex)
        mkdir -p "$out"
        echo "== $f"
        if ! tectonic --chatter minimal --keep-logs -o "$out" "$f"; then
            failed+=("$f")
        elif grep -E "(Citation|Reference) .* undefined|There were undefined references" "$out/$name.log"; then
            echo "$f: undefined citations or references ($out/$name.log)" >&2
            failed+=("$f")
        else
            echo "built $out/$name.pdf"
        fi
    done
    if (( ${#failed[@]} )); then
        printf 'FAILED: %s\n' "${failed[@]}"
        exit 1
    fi

# Build Typst documents into a build/ folder beside each source, with the repository root available for imports and refs.bib.
[positional-arguments]
typst +files:
    #!/usr/bin/env bash
    set -uo pipefail
    cd "{{invocation_directory()}}"
    failed=()
    for f in "$@"; do
        out=$(dirname "$f")/build
        name=$(basename "$f" .typ)
        mkdir -p "$out"
        echo "== $f"
        if typst compile --root "{{justfile_directory()}}" "$f" "$out/$name.pdf"; then
            echo "built $out/$name.pdf"
        else
            failed+=("$f")
        fi
    done
    if (( ${#failed[@]} )); then
        printf 'FAILED: %s\n' "${failed[@]}"
        exit 1
    fi

# Start a note: .typ selects Typst with preamble.typ; otherwise .tex is added if missing, using preamble.tex. Both use refs.bib; an existing file is left alone.
[positional-arguments]
new file title="":
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{invocation_directory()}}"
    f=$1
    title=${2-}
    case $f in
        *.tex|*.typ) ;;
        *) f=$f.tex ;;
    esac
    if [[ -e $f ]]; then
        echo "new: $f already exists" >&2
        exit 1
    fi
    mkdir -p "$(dirname "$f")"
    up=$(realpath --relative-to="$(dirname "$f")" "{{justfile_directory()}}")/
    if [[ $up == ./ ]]; then up=; fi
    if [[ $f == *.typ ]]; then
        typst_string() {
            local value=$1
            value=${value//\\/\\\\}
            value=${value//\"/\\\"}
            value=${value//$'\n'/\\n}
            value=${value//$'\r'/\\r}
            value=${value//$'\t'/\\t}
            printf '"%s"' "$value"
        }
        {
            printf '#import %s: *\n' "$(typst_string "${up}preamble.typ")"
            printf '%s\n' '#show: note.with('
            printf '  title: %s,\n' "$(typst_string "$title")"
            printf '%s\n' '  author: "",'
            printf '  date: datetime(year: %s, month: %s, day: %s),\n' "$(date +%Y)" "$(date +%-m)" "$(date +%-d)"
            printf '%s\n' ')' '' \
                '// Math helpers: bra(psi), ket(psi), braket(phi, psi), mel(phi, A, psi),' \
                '// avg(A), dv(f, x), pdv(f, x), qty(10, GeV); also MeV.' \
                '// Built-ins: abs(x), norm(v), bold(p), mat(a, b; c, d).' \
                '// Label an equation: $ ... $ <eq-name>; refer with @eq-name.' \
                '// Cite with @Zhang:2026iyr; specify the version and equation in prose.' '' ''
            printf '#bibliography(%s, style: "american-physics-society")\n' "$(typst_string "${up}refs.bib")"
        } > "$f"
    else
        {
            printf '%s\n' '\documentclass[11pt]{article}' "\\input{${up}preamble}"
            if [[ -n $title ]]; then
                printf '%s\n' "\\title{$title}" '\author{}' "\\date{$(date +%F)}" '\begin{document}' '\maketitle'
            else
                printf '%s\n' '\begin{document}'
            fi
            printf '%s\n' '' '' "\\bibliography{${up}refs}" '\end{document}'
        } > "$f"
    fi
    echo "new: $f"

# Add a paper (arXiv ID or DOI) to this project's Zotero collection and print its citekey.
add-paper id:
    @uv run --quiet --script {{papers}} add --collection "{{collection}}" "{{id}}"

# Download the LaTeX source of an arXiv paper (pin a version: 1705.00141v3) into literature/<citekey>/src/.
fetch-source citekey id:
    @uv run --quiet --script {{papers}} source "{{id}}" "literature/{{citekey}}/src"

# Check the one-time Zotero setup on this machine.
zotero-doctor:
    @uv run --quiet --script {{papers}} doctor
