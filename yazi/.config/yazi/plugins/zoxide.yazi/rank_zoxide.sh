#!/bin/bash
set -euo pipefail

query="${1-}"
if [[ -z "${query// }" ]]; then
  query="${FZF_QUERY-}"
fi

if [[ -z "${query// }" ]]; then
  output="$(zoxide query -ls 2>/dev/null || true)"
else
  output="$(zoxide query -ls -- "$query" 2>/dev/null || true)"
fi

if [[ -z "$output" ]]; then
  exit 0
fi

Z_OUT="$output" python3 - "$query" <<'PY'
import os
import sys

query = sys.argv[1].strip()
lines = [line for line in os.environ.get("Z_OUT", "").splitlines() if line.strip()]

if not lines:
    sys.exit(0)

query_norm = query.rstrip('/')
query_lower = query_norm.lower()

entries = []
for idx, line in enumerate(lines):
    score = 0.0
    path = line.strip()
    parts = line.split(None, 1)
    if len(parts) == 2:
        score_str, path = parts
        try:
            score = float(score_str)
        except ValueError:
            path = line.strip()
    entries.append((idx, score, path))

if not entries:
    sys.exit(0)


def rank(path: str) -> int:
    norm = path.rstrip('/')
    lower = norm.lower()
    basename = lower.rsplit('/', 1)[-1]
    if query_lower and lower == query_lower:
        return 0
    if query_lower and basename == query_lower:
        return 1
    if query_lower and lower.endswith('/' + query_lower):
        return 2
    if query_lower and query_lower in basename:
        return 3
    if query_lower and query_lower in lower:
        return 4
    return 5


HIGHLIGHT_START = "\033[38;2;251;146;60m"
HIGHLIGHT_END = "\033[0m"


def highlight_path(path: str) -> str:
    if not query_lower:
        return path

    lower = path.lower()
    needle = query_lower
    needle_len = len(needle)

    if needle_len == 0:
        return path

    result = []
    idx = 0
    while True:
        match_idx = lower.find(needle, idx)
        if match_idx == -1:
            result.append(path[idx:])
            break
        result.append(path[idx:match_idx])
        result.append(f"{HIGHLIGHT_START}{path[match_idx:match_idx + needle_len]}{HIGHLIGHT_END}")
        idx = match_idx + needle_len

    return ''.join(result)


sorted_entries = sorted(
    entries,
    key=lambda item: (
        rank(item[2]),
        -item[1],
        item[0],
    ),
)

for _, score, path in sorted_entries:
    highlighted_path = highlight_path(path)
    display = f"{score:g} {highlighted_path}"
    print(f"{score:g}\t{path}\t{display}")
PY
