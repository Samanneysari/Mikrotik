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
  docs/winbox/README.md
  docs/winbox/menu-manifest.tsv
  docs/winbox/submenu-manifest.tsv
  docs/winbox/05-ip-core.md
  docs/winbox/12-tools.md
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

# The WinBox field manual is contract-driven: every manifest entry must point
# to a non-empty reference, and each baseline sidebar menu must remain listed in
# the manual index. This prevents a future reorganization from silently dropping
# a menu family.
manifest="docs/winbox/menu-manifest.tsv"
while IFS=$'\t' read -r id menu menu_path reference; do
  [[ "$id" == \#* || -z "$id" ]] && continue
  if [[ ! -s "docs/winbox/$reference" ]]; then
    echo "ERROR WinBox manifest reference missing or empty: $reference ($menu)" >&2
    failures=$((failures + 1))
  fi
  if ! rg -F -q "| $menu |" docs/winbox/README.md; then
    echo "ERROR WinBox sidebar menu absent from index: $menu" >&2
    failures=$((failures + 1))
  fi
done < "$manifest"

submenu_manifest="docs/winbox/submenu-manifest.tsv"
while IFS=$'\t' read -r menu_path reference; do
  [[ "$menu_path" == \#* || -z "$menu_path" ]] && continue
  if [[ ! -s "docs/winbox/$reference" ]]; then
    echo "ERROR WinBox submenu reference missing or empty: $reference ($menu_path)" >&2
    failures=$((failures + 1))
    continue
  fi
  if ! rg -F -q "$menu_path" "docs/winbox/$reference"; then
    echo "ERROR WinBox submenu absent from reference: $menu_path -> $reference" >&2
    failures=$((failures + 1))
  fi
done < "$submenu_manifest"

winbox_required_paths=(
  'IP → Addresses'
  'IP → ARP'
  'IP → DHCP Client'
  'IP → DHCP Server'
  'IP → DNS'
  'IP → Firewall'
  'IP → IPsec'
  'IP → Services'
  'IP → Hotspot'
  'IP → VRF'
  'Tools → Ping'
  'Tools → Traceroute'
  'Tools → IP Scan'
  'Tools → Torch'
  'Tools → Packet Sniffer'
  'Tools → Bandwidth Test'
  'Tools → Profile'
  'Tools → Netwatch'
)
for menu_path in "${winbox_required_paths[@]}"; do
  if ! rg -F -q "$menu_path" docs/winbox; then
    echo "ERROR required WinBox submenu not documented: $menu_path" >&2
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
