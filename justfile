# Research project tasks (research-skills). Run `just check` before every commit.

set shell := ["bash", "-euo", "pipefail", "-c"]

papers := env_var("HOME") / ".agents/skills/setup-research/scripts/papers.py"
collection := "Research/Xb"

# List the recipes.
default:
    @just --list

# Run every check in checks/, then build the paper.
check: checks paper

# Run every check in checks/: *.py with uv, *.wl on the Wolfram kernel, *.jl with Julia. Files starting with _ are helpers.
checks:
    #!/usr/bin/env bash
    set -uo pipefail
    shopt -s nullglob
    failed=()
    for f in checks/*.py checks/*.wl checks/*.jl; do
        [[ $(basename "$f") == _* ]] && continue
        echo "== $f"
        case $f in
            *.py) uv run --quiet --script "$f" ;;
            *.wl) math -script "$f" ;;
            *.jl) julia --project=checks --startup-file=no "$f" ;;
        esac || failed+=("$f")
    done
    if (( ${#failed[@]} )); then
        printf 'FAILED: %s\n' "${failed[@]}"
        exit 1
    fi
    echo "checks: all passed"

# Build paper/main.tex with tectonic into paper/build/; an undefined citation or reference fails the build.
paper:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p paper/build
    tectonic --keep-logs -o paper/build paper/main.tex
    if grep -E "(Citation|Reference) .* undefined|There were undefined references" paper/build/main.log; then
        echo "paper: undefined citations or references (paper/build/main.log)" >&2
        exit 1
    fi
    echo "paper: built paper/build/main.pdf"

# Language gate: every GLOSSARY.md entry agreed, and the ## Core section of CONVENTIONS.md non-empty with every entry agreed.
gate:
    #!/usr/bin/env bash
    set -uo pipefail
    closed=0
    for f in GLOSSARY.md CONVENTIONS.md; do
        [[ -f $f ]] || { echo "  $f is missing"; closed=1; }
    done
    # An entry is agreed when it carries exactly one Status line, and that line reads `Status: agreed`.
    if [[ -f GLOSSARY.md ]]; then
        awk 'function settle() { if (entry != "" && st != "agreed") { print "  GLOSSARY.md, not agreed: " entry; bad++ } entry = "" }
             /^\*\*.+\*\*:/ { settle(); entry = $0; st = ""; n++; next }
             entry != "" && /^Status:/ { st = (st == "" && $0 ~ /^Status:[[:space:]]*agreed[[:space:]]*$/) ? "agreed" : "bad" }
             END { settle(); if (n == 0) print "  GLOSSARY.md has no entries"; exit (bad > 0 || n == 0) }' GLOSSARY.md || closed=1
    fi
    if [[ -f CONVENTIONS.md ]]; then
        awk 'function settle() { if (entry != "" && st != "agreed") { print "  CONVENTIONS.md Core, not agreed: " entry; bad++ } entry = "" }
             /^## / { settle(); core = ($0 ~ /^## Core[[:space:]]*$/); next }
             core && /^### / { settle(); entry = $0; st = ""; n++; next }
             entry != "" && /^Status:/ { st = (st == "" && $0 ~ /^Status:[[:space:]]*agreed[[:space:]]*$/) ? "agreed" : "bad" }
             END { settle(); if (n == 0) print "  CONVENTIONS.md has no entries under ## Core"; exit (bad > 0 || n == 0) }' CONVENTIONS.md || closed=1
    fi
    if (( closed )); then
        echo "gate: closed"
        exit 1
    fi
    echo "gate: open"

# Add a paper (arXiv ID or DOI) to this project's Zotero collection and print its citekey.
add-paper id:
    @uv run --quiet --script {{papers}} add --collection "{{collection}}" "{{id}}"

# Download the LaTeX source of an arXiv paper (pin a version: 1705.00141v3) into literature/<citekey>/src/.
fetch-source citekey id:
    @uv run --quiet --script {{papers}} source "{{id}}" "literature/{{citekey}}/src"

# Check the one-time Zotero setup on this machine.
zotero-doctor:
    @uv run --quiet --script {{papers}} doctor
