#!/usr/bin/env bash
# mac-test.sh - Mac Test Output Collector
set -euo pipefail
OUT="$HOME/home-baseline-tmp/mac-test-output.txt"
DATE=$(date "+%Y-%m-%d %H:%M:%S")
{
  echo "Mac Test Output - ${DATE}"
  echo "macOS: $(sw_vers -productVersion)"
  echo ""
  echo "=== Homebrew ==="
  brew --version 2>&1 || echo "brew: nicht gefunden"
  echo ""
  echo "=== Tools ==="
  for cmd in git gh rg pwsh node uv python3 specify; do
    command -v "$cmd" > /dev/null 2>&1 && echo "  OK  $cmd" || echo "  --- $cmd: fehlt"
  done
  echo ""
  echo "=== sync-home ==="
  bash ~/home-baseline-tmp/scripts/sync-home.sh --no-pull 2>&1
  echo ""
  echo "=== check-homogeneity ==="
  bash ~/scripts/check-homogeneity.sh ~/ 2>&1
} | tee "$OUT"
cd ~/home-baseline-tmp
git pull --rebase --autostash origin main 2>&1 | cat
git add mac-test-output.txt
git commit -m "test: Mac Test-Output (${DATE})" -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>" 2>&1
git push origin HEAD:main 2>&1
echo "Gepusht."
