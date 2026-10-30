# Research project tasks (research-skills).

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

# Add a paper (arXiv ID or DOI) to this project's Zotero collection and print its citekey.
add-paper id:
    @uv run --quiet --script {{papers}} add --collection "{{collection}}" "{{id}}"

# Download the LaTeX source of an arXiv paper (pin a version: 1705.00141v3) into literature/<citekey>/src/.
fetch-source citekey id:
    @uv run --quiet --script {{papers}} source "{{id}}" "literature/{{citekey}}/src"

# Check the one-time Zotero setup on this machine.
zotero-doctor:
    @uv run --quiet --script {{papers}} doctor
