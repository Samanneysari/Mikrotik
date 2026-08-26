#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

failures=0

required=(
  README.md
  docs/00-start-here.md
  docs/01-networking-foundations.md
  docs/04-winbox-complete-tour.md
  docs/08-firewall-nat.md
  docs/16-ospf.md
  docs/17-bgp.md
  docs/18-mpls.md
  docs/coverage-matrix.md
  labs/README.md
  exams/mtcna-practice-01.md
  exams/mtcre-practice-01.md
  exams/mtcine-practice-01.md
)

for path in "${required[@]}"; do
  if [[ ! -s "$path" ]]; then
    echo "ERROR required file missing or empty: $path" >&2
    failures=$((failures + 1))
  fi
done

while IFS= read -r path; do
  if [[ ! -s "$path" ]]; then
    echo "ERROR empty Markdown file: $path" >&2
    failures=$((failures + 1))
  fi
done < <(rg --files -g '*.md' | sort)

while IFS=$'\t' read -r source target; do
  target="${target%% *}"
  case "$target" in
    ""|http://*|https://*|mailto:*|tel:*|\#*) continue ;;
  esac

  target="${target%%#*}"
  target="${target#<}"
  target="${target%>}"
  candidate="$(dirname "$source")/$target"
  if [[ ! -e "$candidate" ]]; then
    echo "ERROR broken local link: $source -> $target" >&2
    failures=$((failures + 1))
  fi
done < <(
  while IFS= read -r path; do
    perl -ne 'while (/\[[^]]*\]\(([^)]+)\)/g) { print "$ARGV\t$1\n" }' "$path"
  done < <(rg --files -g '*.md' | sort)
)

if rg -n --hidden -g '!scripts/check-docs.sh' \
  'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|PRIVATE_KEY_BASE64_REAL' .; then
  echo "ERROR possible private key material found" >&2
  failures=$((failures + 1))
fi

chapter_count="$(find docs -maxdepth 1 -type f -name '[0-9][0-9]-*.md' | wc -l | tr -d ' ')"
if [[ "$chapter_count" -ne 22 ]]; then
  echo "ERROR expected 22 numbered chapters, found $chapter_count" >&2
  failures=$((failures + 1))
fi

for exam in exams/*-practice-01.md; do
  question_count="$(awk '/^## Answer key/{exit} /^[0-9]+\. /{count++} END{print count+0}' "$exam")"
  if [[ "$question_count" -ne 25 ]]; then
    echo "ERROR expected 25 questions in $exam, found $question_count" >&2
    failures=$((failures + 1))
  fi
done

if [[ "$failures" -ne 0 ]]; then
  echo "Documentation checks failed: $failures error(s)." >&2
  exit 1
fi

echo "Documentation checks passed."
