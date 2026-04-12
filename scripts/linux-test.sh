#!/usr/bin/env bash
# linux-test.sh — Sammelt System-Info und Testergebnisse auf Linux
# Ausgabe wird nach ~/home-baseline-tmp/linux-test-output.txt geschrieben
# und automatisch committet + gepusht.
#
# Verwendung: bash ~/home-baseline-tmp/scripts/linux-test.sh
set -euo pipefail

OUT="$HOME/home-baseline-tmp/linux-test-output.txt"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

{
  echo "Linux Test Output - ${DATE}"
  echo ""

  echo "=== System-Info ==="
  echo "OS:       $(uname -s) $(uname -r)"
  echo "Distro:   $(. /etc/os-release 2>/dev/null && echo "${PRETTY_NAME}" || echo 'unbekannt')"
  echo "Arch:     $(uname -m)"
  echo "Shell:    ${SHELL}"
  echo "bash:     $(bash --version | head -1)"
  echo ""

  echo "=== Paketmanager ==="
  for pm in apt dnf yum pacman zypper brew; do
    command -v "$pm" > /dev/null 2>&1 && echo "  OK  $pm: $(${pm} --version 2>/dev/null | head -1)" || echo "  --- $pm: nicht installiert"
  done
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
git add linux-test-output.txt
{
  git commit -m "test: Linux Test-Output (${DATE})" -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
  git push origin HEAD:main
} 2>&1 | tee -a "$OUT"
echo "Gepusht." | tee -a "$OUT"
