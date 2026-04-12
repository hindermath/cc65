#!/usr/bin/env bash
# bootstrap-workspace.sh
# Richtet ein neues Projektverzeichnis als privates GitHub- oder GitLab-Repo ein:
#   git init · .gitignore · Scripts kopieren · repo create · push · Hooks installieren
#
# Verwendung:
#   bash ~/scripts/bootstrap-workspace.sh <Verzeichnisname> [Repo-Name] [Beschreibung]
#
# Beispiel:
#   bash ~/scripts/bootstrap-workspace.sh WebstormProjects webstorm-baseline "Workspace-Konfiguration für WebStorm-Projekte"
#   bash ~/scripts/bootstrap-workspace.sh WebstormProjects --platform gitlab
#
# Optionen:
#   --dry-run               Zeigt alle Schritte ohne Ausführung
#   --platform <github|gitlab>
#   --gitlab-url <https://gitlab.example.com>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "${1:-}" = "--teardown" ]; then
  shift
  exec bash "$SCRIPT_DIR/teardown-workspace.sh" "$@"
fi

# --- Hilfsfunktionen -----------------------------------------------------------

usage() {
  echo "Verwendung: $(basename "$0") [OPTIONEN] <Verzeichnisname> [Repo-Name] [Beschreibung]"
  echo "            $(basename "$0") --dry-run <Verzeichnisname> ..."
  exit 1
}

log()  { echo "  $*"; }
ok()   { echo "✓ $*"; }
info() { echo "→ $*"; }

normalize_name() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g'
}

# --- Parameter parsen ----------------------------------------------------------

DRY_RUN=0
PLATFORM="github"
GITLAB_URL="https://gitlab.com"
GITLAB_HOSTNAME=""
WORKSPACE_NAME=""
REPO_NAME=""
REPO_DESC=""

while [ $# -gt 0 ]; do
  case "${1:-}" in
    --dry-run)
      DRY_RUN=1
      ;;
    --platform)
      PLATFORM="${2:-}"
      shift
      ;;
    --gitlab-url)
      GITLAB_URL="${2:-}"
      shift
      ;;
    --help|-h)
      usage
      ;;
    --)
      shift
      if [ $# -gt 0 ] && [ -z "$WORKSPACE_NAME" ]; then WORKSPACE_NAME="$1"; shift; fi
      if [ $# -gt 0 ] && [ -z "$REPO_NAME" ]; then REPO_NAME="$1"; shift; fi
      if [ $# -gt 0 ] && [ -z "$REPO_DESC" ]; then REPO_DESC="$1"; shift; fi
      continue
      ;;
    --*)
      echo "Fehler: Unbekannte Option: $1" >&2
      echo "Error: Unknown option: $1" >&2
      exit 1
      ;;
    *)
      if [ -z "$WORKSPACE_NAME" ]; then
        WORKSPACE_NAME="$1"
      elif [ -z "$REPO_NAME" ]; then
        REPO_NAME="$1"
      elif [ -z "$REPO_DESC" ]; then
        REPO_DESC="$1"
      else
        echo "Fehler: Zu viele Positionsargumente." >&2
        echo "Error: Too many positional arguments." >&2
        exit 1
      fi
      ;;
  esac
  shift
done

[ -z "$WORKSPACE_NAME" ] && usage

case "$PLATFORM" in
  github|gitlab) ;;
  *)
    echo "Fehler: Ungültige Plattform '$PLATFORM'. Gültige Werte: github, gitlab." >&2
    echo "Error: Invalid platform '$PLATFORM'. Valid values: github, gitlab." >&2
    exit 1
    ;;
esac

if [ "$PLATFORM" = "gitlab" ]; then
  case "$GITLAB_URL" in
    https://*) ;;
    *)
      echo "Fehler: --gitlab-url muss mit 'https://' beginnen." >&2
      echo "Error: --gitlab-url must start with 'https://'." >&2
      exit 1
      ;;
  esac
  GITLAB_HOSTNAME="${GITLAB_URL#https://}"
  GITLAB_HOSTNAME="${GITLAB_HOSTNAME%/}"
fi

HOME_DIR="$(cd ~ && pwd)"
WORKSPACE_DIR="$HOME_DIR/$WORKSPACE_NAME"
SCRIPTS_SRC="$HOME_DIR/scripts"

if [ -z "$REPO_NAME" ]; then
  REPO_NAME="$(echo "$WORKSPACE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/projects$/-baseline/' | sed 's/ /-/g')"
fi
if [ -z "$REPO_DESC" ]; then
  REPO_DESC="Gemeinsame Workspace-Konfiguration für $WORKSPACE_NAME"
fi

# --- Vorabprüfungen ------------------------------------------------------------

if [ ! -d "$WORKSPACE_DIR" ]; then
  echo "Fehler: Verzeichnis '$WORKSPACE_DIR' existiert nicht." >&2
  exit 1
fi

if [ -d "$WORKSPACE_DIR/.git" ]; then
  echo "Fehler: '$WORKSPACE_DIR' ist bereits ein Git-Repository." >&2
  exit 1
fi

if [ "$PLATFORM" = "github" ]; then
  if ! command -v gh >/dev/null 2>&1; then
    echo "Fehler: gh (GitHub CLI) ist nicht installiert." >&2
    echo "Error: gh (GitHub CLI) is not installed." >&2
    exit 1
  fi

  GH_USER=$(gh api user --jq '.login' 2>/dev/null || true)
  if [ -z "$GH_USER" ]; then
    echo "Fehler: Konnte GitHub-Benutzername nicht ermitteln. Bitte 'gh auth login' ausführen." >&2
    echo "Error: Could not retrieve GitHub username. Please run 'gh auth login'." >&2
    exit 1
  fi

  REPO_SLUG="$REPO_NAME"
  SLUG_CHANGED=0
else
  if ! command -v glab >/dev/null 2>&1; then
    echo "Fehler: glab (GitLab CLI) ist nicht installiert." >&2
    echo "  macOS/Linux: brew install glab" >&2
    echo "  Windows:     winget install GLabCLI.GlabCLI" >&2
    echo "Error: glab (GitLab CLI) is not installed." >&2
    exit 1
  fi

  if ! GITLAB_HOST="$GITLAB_HOSTNAME" glab auth status >/dev/null 2>&1; then
    echo "Fehler: Nicht bei GitLab ($GITLAB_HOSTNAME) authentifiziert. Bitte 'glab auth login' ausführen." >&2
    echo "Error: Not authenticated with GitLab ($GITLAB_HOSTNAME). Please run 'glab auth login'." >&2
    exit 1
  fi

  GITLAB_USER="$(
    glab api user --hostname "$GITLAB_HOSTNAME" 2>/dev/null \
      | tr -d '\r\n' \
      | sed -n 's/.*"username":"\([^"]*\)".*/\1/p'
  )"
  if [ -z "$GITLAB_USER" ]; then
    echo "Fehler: Konnte GitLab-Benutzername nicht ermitteln." >&2
    echo "Error: Could not retrieve GitLab username." >&2
    exit 1
  fi

  REPO_SLUG="$(normalize_name "$REPO_NAME")"
  SLUG_CHANGED=0
  [ "$REPO_SLUG" != "$REPO_NAME" ] && SLUG_CHANGED=1
fi

# --- Zusammenfassung anzeigen --------------------------------------------------

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  bootstrap-workspace – Neue Workspace-Einrichtung               ║"
echo "╠══════════════════════════════════════════════════════════════════╣"
printf "║  Verzeichnis : %-51s║\n" "$WORKSPACE_DIR"
printf "║  Beschreibung: %-51s║\n" "${REPO_DESC:0:51}"
if [ "$PLATFORM" = "github" ]; then
  printf "║  GitHub-Repo : %-51s║\n" "$GH_USER/$REPO_NAME (privat)"
  printf "║  Plattform   : %-51s║\n" "GitHub (privat)"
else
  printf "║  GitLab-Repo : %-51s║\n" "$GITLAB_USER/$REPO_SLUG (privat)"
  printf "║  Plattform   : %-51s║\n" "GitLab — $GITLAB_URL (privat)"
  if [ "$SLUG_CHANGED" -eq 1 ]; then
    printf "║  GitLab-Slug : %-51s║\n" "$REPO_SLUG (normalisiert von: $REPO_NAME)"
  fi
fi
echo "╚══════════════════════════════════════════════════════════════════╝"
[ "$DRY_RUN" -eq 1 ] && echo "  [DRY RUN – keine Änderungen werden vorgenommen]"
echo ""

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  [dry-run] $*"
  else
    eval "$@"
  fi
}

# --- Sub-Repos ermitteln (bestehende .git-Verzeichnisse) ----------------------

info "Suche bestehende Sub-Repositories …"
SUB_REPOS=()
while IFS= read -r sub; do
  sub_name="$(basename "$(dirname "$sub")")"
  SUB_REPOS+=("$sub_name")
  log "Gefunden: $sub_name/"
done < <(find "$WORKSPACE_DIR" -maxdepth 2 -name ".git" -type d | sort)

# --- .gitignore erstellen ------------------------------------------------------

info "Erstelle .gitignore …"
GITIGNORE_PATH="$WORKSPACE_DIR/.gitignore"

if [ "$DRY_RUN" -eq 0 ]; then
  {
    echo "# Sub-Verzeichnisse mit eigenen Git-Repositories (automatisch erkannt)"
    for repo in "${SUB_REPOS[@]+"${SUB_REPOS[@]}"}"; do
      echo "$repo/"
    done
    echo ""
    cat <<'STATIC'
# macOS
.DS_Store
.AppleDouble
.LSOverride

# JetBrains IDEs
.idea/
*.iws
*.iml

# VS Code (lokale Einstellungen)
.vscode/c_cpp_properties.json
.vscode/settings.json

# Build-Artefakte
bin/
obj/
build/
node_modules/
STATIC
  } > "$GITIGNORE_PATH"
  ok ".gitignore erstellt"
else
  sub_repos_display="keine"
  if [ "${#SUB_REPOS[@]}" -gt 0 ]; then
    sub_repos_display="${SUB_REPOS[*]}"
  fi
  echo "  [dry-run] .gitignore würde erstellt mit Einträgen für: $sub_repos_display"
fi

# --- Scripts kopieren ----------------------------------------------------------

info "Kopiere Scripts …"
run "mkdir -p '$WORKSPACE_DIR/scripts/hooks'"
run "cp '$SCRIPTS_SRC/scan-agent-secrets.sh'  '$WORKSPACE_DIR/scripts/'"
run "cp '$SCRIPTS_SRC/scan-agent-secrets.ps1'  '$WORKSPACE_DIR/scripts/'"
run "cp '$SCRIPTS_SRC/install-hooks.sh'         '$WORKSPACE_DIR/scripts/'"
run "cp '$SCRIPTS_SRC/install-hooks.ps1'         '$WORKSPACE_DIR/scripts/'"
run "cp '$SCRIPTS_SRC/hooks/pre-push'            '$WORKSPACE_DIR/scripts/hooks/'"
run "chmod +x '$WORKSPACE_DIR/scripts/'*.sh '$WORKSPACE_DIR/scripts/hooks/pre-push'"
ok "Scripts kopiert"

# --- git init + commit ---------------------------------------------------------

info "Initialisiere Git-Repository …"
run "git -C '$WORKSPACE_DIR' init"
run "git -C '$WORKSPACE_DIR' add .gitignore scripts/"
run "git -C '$WORKSPACE_DIR' commit -m 'chore: initiale Baseline-Konfiguration für $WORKSPACE_NAME

- .gitignore        – schließt Sub-Repos und Artefakte aus
- scripts/          – Secret-Scan, Hook-Installation (Bash + PowerShell)

Nach dem Clonen auf neuem Gerät:
  bash scripts/install-hooks.sh       (macOS/Linux)
  pwsh scripts/install-hooks.ps1      (Windows)

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>'"
ok "Initialer Commit erstellt"

# --- GitHub-Repo erstellen und pushen ------------------------------------------

if [ "$PLATFORM" = "github" ]; then
  info "Erstelle privates GitHub-Repository '$REPO_NAME' …"
  run "gh repo create '$REPO_NAME' --private --description '$REPO_DESC' --source '$WORKSPACE_DIR' --remote origin --push"
  ok "GitHub-Repo erstellt und gepusht"
else
  REMOTE_URL="https://${GITLAB_HOSTNAME}/${GITLAB_USER}/${REPO_SLUG}.git"
  info "Erstelle privates GitLab-Repository '$REPO_SLUG' …"
  run "GITLAB_HOST='$GITLAB_HOSTNAME' glab repo create '$REPO_SLUG' --private --description '$REPO_DESC'"
  ok "GitLab-Repo erstellt"
  run "git -C '$WORKSPACE_DIR' remote add origin '$REMOTE_URL'"
  run "git -C '$WORKSPACE_DIR' push -u origin HEAD"
  ok "Remote gesetzt und gepusht"
fi

# --- Hooks installieren --------------------------------------------------------

info "Installiere Git-Hooks …"
run "bash '$WORKSPACE_DIR/scripts/install-hooks.sh'"
ok "Hooks installiert"

# --- ~/README.md aktualisieren ------------------------------------------------

HOME_README="$HOME_DIR/README.md"
if [ "$PLATFORM" = "github" ]; then
  REPO_URL="https://github.com/$GH_USER/$REPO_NAME"
  DISPLAY_REPO="$REPO_NAME"
else
  REPO_URL="${GITLAB_URL%/}/$GITLAB_USER/$REPO_SLUG"
  DISPLAY_REPO="$REPO_SLUG"
fi
NEW_ROW="| \`~/$WORKSPACE_NAME/\` | [$DISPLAY_REPO]($REPO_URL) | \`bootstrap-workspace\` |"

if [ -f "$HOME_README" ]; then
  info "Aktualisiere ~/README.md …"
  if grep -qF "~/$WORKSPACE_NAME/" "$HOME_README"; then
    log "Eintrag für '$WORKSPACE_NAME' bereits vorhanden – übersprungen."
  else
    if [ "$DRY_RUN" -eq 0 ]; then
      NEW_ROW="$NEW_ROW" perl -0pi -e 's/\Q<!-- workspace-table-end -->\E/$ENV{NEW_ROW}."\n<!-- workspace-table-end -->"/e' "$HOME_README"
      ok "~/README.md aktualisiert"
    else
      echo "  [dry-run] ~/README.md: neue Zeile würde eingefügt: $NEW_ROW"
    fi
  fi
fi

# --- home-baseline committen und pushen ----------------------------------------

HOME_GIT="$HOME_DIR/.git"
if [ -d "$HOME_GIT" ]; then
  info "Committe Änderungen in home-baseline …"
  run "git -C '$HOME_DIR' add README.md"
  run "git -C '$HOME_DIR' commit -m 'chore: $WORKSPACE_NAME in Workspace-Übersicht eingetragen

Automatisch durch bootstrap-workspace.sh hinzugefügt.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>'"
  if git -C "$HOME_DIR" remote get-url origin >/dev/null 2>&1; then
    run "git -C '$HOME_DIR' push"
    ok "home-baseline aktualisiert und gepusht"
  else
    ok "home-baseline committed (kein Remote konfiguriert — Push übersprungen / no remote configured — push skipped)"
  fi
fi



# --- Git Scope-Isolierung -------------------------------------------------------

info "Git Scope-Isolierung / Git Scope Isolation:"
NORMALIZED_NAME=$(normalize_name "$WORKSPACE_NAME")
GITCONFIG_D="${HOME_DIR}/.gitconfig.d"
GITCONFIG="${HOME_DIR}/.gitconfig"

if [ -d "$GITCONFIG_D" ]; then
  # core.autocrlf im lokalen .git/config setzen
  run "git -C '$WORKSPACE_DIR' config --local core.autocrlf input"

  # Idempotenz-Prüfung: bereits ein includeIf-Block für diesen Workspace?
  if ! grep -qF "gitdir:~/${WORKSPACE_NAME}/" "${GITCONFIG}" 2>/dev/null; then
    if [ "$DRY_RUN" -eq 0 ]; then
      printf '\n[includeIf "gitdir:~/%s/"]\n\tpath = ~/.gitconfig.d/%s.inc\n' \
        "${WORKSPACE_NAME}" "${NORMALIZED_NAME}" >> "${GITCONFIG}"
    else
      echo "  [dry-run] ~/.gitconfig: [includeIf \"gitdir:~/${WORKSPACE_NAME}/\"] würde hinzugefügt"
    fi
    log "✓ includeIf für ${WORKSPACE_NAME} / includeIf for ${WORKSPACE_NAME} eingetragen"
  else
    log "→ includeIf für ${WORKSPACE_NAME} bereits vorhanden — übersprungen / already present — skipped"
  fi

  # .inc-Placeholder erstellen wenn nicht vorhanden
  INC_FILE="${GITCONFIG_D}/${NORMALIZED_NAME}.inc"
  if [ ! -f "$INC_FILE" ]; then
    if [ "$DRY_RUN" -eq 0 ]; then
      printf '# %s workspace git configuration\n# [user]\n#   email = work@example.com\n' \
        "${WORKSPACE_NAME}" > "$INC_FILE"
    else
      echo "  [dry-run] ~/.gitconfig.d/${NORMALIZED_NAME}.inc würde erstellt"
    fi
    log "✓ ~/.gitconfig.d/${NORMALIZED_NAME}.inc erstellt / created"
  else
    log "→ ~/.gitconfig.d/${NORMALIZED_NAME}.inc bereits vorhanden — übersprungen / already exists — skipped"
  fi
else
  log "→ ~/.gitconfig.d/ nicht vorhanden — Scope-Isolierung übersprungen / not found — skipping scope isolation"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  Einrichtung abgeschlossen!                                      ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
if [ "$PLATFORM" = "gitlab" ] && [ "$SLUG_CHANGED" -eq 1 ]; then
  echo "  GitLab-Slug : $REPO_SLUG (normalisiert von: $REPO_NAME)"
fi
echo "  Repo   : $REPO_URL"
echo "  Clone  : git clone ${REPO_URL}.git ~/$WORKSPACE_NAME"
echo "  Hooks  : bash scripts/install-hooks.sh  (oder pwsh scripts/install-hooks.ps1)"
echo ""
