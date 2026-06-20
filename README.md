The cc65 cross-compiler suite
=============================

cc65 is a complete cross-development package for 65(C)02 systems,
including a powerful macro assembler, a C compiler, linker, archiver,
simulator and several other tools.  cc65 has C and runtime library
support for many of the old 6502 machines.  For details look at
the [cc65 web site](https://cc65.github.io):

| Company / People        | Machine / Environment               |
|-------------------------|-------------------------------------|
| Apple                   | Apple II                            |
|                         | Apple IIe enhanced                  |
| Atari                   | Atari 400/800                       |
|                         | Atari 2600                          |
|                         | Atari 5200                          |
|                         | Atari 7800                          |
|                         | Atari XL                            |
|                         | Lynx                                |
| Tangerine               | Oric Atmos                          |
| Eureka                  | Oric Telestrat                      |
| Acorn                   | BBC series                          |
| Commodore               | C128                                |
|                         | C16                                 |
|                         | C64                                 |
|                         | CBM 510/610                         |
|                         | PET                                 |
|                         | Plus/4                              |
|                         | VIC-20                              |
| VTech                   | CreatiVision                        |
| Commander X16 Community | Commander X16                       |
| Bit Corporation         | Gamate                              |
| Berkeley Softworks      | GEOS (Apple/CBM)                    |
| LUnix Team              | LUnix (C64)                         |
| Nintendo                | Nintendo Entertainment System (NES) |
| Ohio Scientific         | OSI C1P                             |
| MOS Technology, Inc.    | KIM-1                               |
| NEC                     | PC Engine (PCE)                     |
| Rumbledethumps          | Picocomputer 6502 (RP6502)          |
| Watara                  | Watara/QuickShot Supervision        |
| Synertek                | SYM-1                               |
| USSR                    | Agat-7/9                            |

A generic configuration to adapt cc65 to new targets is also around.

## People

cc65 is originally based on the "Small C" compiler by Ron Cain and
enhanced by James E. Hendrix.

### Project founders

* John R. Dunning: [original implementation](https://public.websites.umich.edu/~archive/atari/8bit/Languages/Cc65/)
  of the C compiler and runtime library, Atari hosted.
* Ullrich von Bassewitz:
  * moved Dunning's code to modern systems,
  * rewrote most parts of the compiler,
  * rewrote all of the runtime library.

### Core team members

* [Christian Groessler](https://github.com/groessler): Atari, Atari5200, and CreatiVision library Maintainer
* [dqh](https://github.com/dqh-au): GHA help
* [Greg King](https://github.com/greg-king5): all around hackery
* [groepaz](https://github.com/mrdudz): CBM library, Project Maintainer
* [Oliver Schmidt](https://github.com/oliverschmidt): Apple II library Maintainer

### External contributors

* [acqn](https://github.com/acqn): various compiler fixes
* [jedeoric](https://github.com/jedeoric): Telestrat target
* [jmr](https://github.com/jmr): compiler fixes
* [karrika](https://github.com/karrika): Atari 7800 target
* [Stephan Mühlstrasser](https://github.com/smuehlst): osic1p target
* [Wayne Parham](https://github.com/WayneParham): Sym-1 target
* [Dave Plummer](https://github.com/davepl): KIM-1 target
* [Rumbledethumps](https://github.com/rumbledethumps): RP6502 target

*(The above list is incomplete, if you feel left out - please speak up or add yourself in a PR)*

For a complete list look at the [full team list](https://github.com/orgs/cc65/teams)
or the list of [all contributors](https://github.com/cc65/cc65/graphs/contributors).

# Contact

For general discussion, questions, etc subscribe to the
[mailing list](https://cc65.github.io/mailing-lists.html)
or use the [github discussions](https://github.com/cc65/cc65/discussions).

Some of us may also be around on IRC [#cc65](https://web.libera.chat/#cc65) on libera.chat.

# Documentation

* The main [Documentation](https://cc65.github.io/doc) for users and
  developers.
* Info on [Contributing](Contributing.md) to the CC65 project. Please
  read this before working on something you want to contribute, and
  before reporting bugs.
* The [Wiki](https://github.com/cc65/wiki/wiki) contains some extra info
  that does not fit into the regular documentation.

# Downloads

* [Windows 64bit Snapshot](https://sourceforge.net/projects/cc65/files/cc65-snapshot-win64.zip)
* [Windows 32bit Snapshot](https://sourceforge.net/projects/cc65/files/cc65-snapshot-win32.zip)
* [Linux Snapshot DEB and RPM](https://software.opensuse.org/download.html?project=home%3Astrik&package=cc65)

# Building from source

To build the cc65 suite from source, a simple `make` in the root directory
is usually enough:

```bash
make
```

By default, the build includes debug information. To create a release build
without debug information, you can set the `DEBUG` variable to `0`:

```bash
make DEBUG=0
```

[![Snapshot Build](https://github.com/cc65/cc65/actions/workflows/snapshot-on-push-master.yml/badge.svg?branch=master)](https://github.com/cc65/cc65/actions/workflows/snapshot-on-push-master.yml)

---

## Fork-Entwicklungsinfrastruktur / Fork development tooling

Dieser Fork enthält in `.dev-tools/` lokale Hilfsskripte für den Pre-Push Secret-Scan.
Sie liegen bewusst in einem versteckten Verzeichnis, um nicht mit der Upstream-Struktur zu kollidieren.

*This fork includes local helper scripts in `.dev-tools/` for pre-push secret scanning.
They are intentionally placed in a hidden directory to avoid conflicts with the upstream structure.*

### Ersteinrichtung nach dem Clonen / Initial setup after cloning

```bash
# macOS / Linux
git clone https://github.com/hindermath/cc65.git
cd cc65
bash .dev-tools/install-hooks.sh
```

```powershell
# Windows (PowerShell Core >= 7)
git clone https://github.com/hindermath/cc65.git
Set-Location cc65
pwsh .dev-tools/install-hooks.ps1
```

### Verfügbare Skripte / Available scripts

| Skript / Script | Beschreibung / Description |
|---|---|
| `.dev-tools/install-hooks.sh` | Git-Hooks installieren (Bash) |
| `.dev-tools/install-hooks.ps1` | Git-Hooks installieren (PowerShell Core) |
| `.dev-tools/scan-agent-secrets.sh` | Secret-Scan manuell ausführen (Bash) |
| `.dev-tools/scan-agent-secrets.ps1` | Secret-Scan manuell ausführen (PowerShell Core) |
| `.dev-tools/hooks/pre-push` | Pre-Push Hook – blockiert Push bei Secrets |

Der `pre-push`-Hook läuft automatisch bei jedem `git push` und prüft alle
git-getrackten Dateien auf Credentials, Tokens und andere Secrets.

*The `pre-push` hook runs automatically on every `git push` and checks all
git-tracked files for credentials, tokens, and other secrets.*

## Secure-Development-Hardening-Intake

Dieser Fork ist bewusst ein Nicht-MSL-Repository: C89 und 6502-Assembly sind
wegen Zielplattform, Toolchain-Zweck und historischer Kompatibilitaet
erforderlich. Spaetere Spec-Kit-Haertungslaeufe starten deshalb nicht mit der
vollen MSL-Dokumentenbasis der C#-Level-2-Repos, sondern mit dem gezielten
Intake `Lastenheft_Secure-Development-Hardening.md`.

Das Lastenheft ist nur Vorbereitung. Es startet keinen Spec-Kit-Lauf, aendert
keine Makefile-Kette und erzeugt keine Release-Artefakte. Der spaetere Lauf
soll C/C89-, 6502-Assembly-, Makefile-, Artefakt-, SBOM-, VEX-, SLSA- und
AI-SBOM-`N/A`-Entscheidungen pruefbar dokumentieren. Die aktive Reihenfolge
fuer spaetere Laeufe steht in `Lastenheft_Abarbeitungsreihenfolge.md`.

*This fork is intentionally a non-MSL repository: C89 and 6502 assembly are
required because of the target platforms, toolchain purpose, and historical
compatibility. Later Spec Kit hardening runs therefore start from the targeted
intake `Lastenheft_Secure-Development-Hardening.md`, not from the full MSL
documentation baseline used by the C# Level-2 repositories. The intake is
preparation only; it does not start a Spec Kit run, change the Makefile chain,
or create release artifacts.*

## Spec-Kit-Governance-Presets / Spec Kit Governance Presets

Alle sechs Governance-Presets sind seit 2026-05-04 im `github/spec-kit`
Community-Katalog enthalten. Für C#/.NET-Level-2-Projekte ist die
Standardentscheidung in dieser Workspace-Familie: alle sechs Presets
installieren, sofern das Projekt keine begründete Ausnahme dokumentiert.

Standard-Preset-Set:

- `security-governance` v0.6.0, Priority 10
- `architecture-governance` v0.5.0, Priority 20
- `isaqb-architecture-governance` v0.2.0, Priority 30
- `a11y-governance` v0.4.0, Priority 40
- `cross-platform-governance` v0.2.0, Priority 50
- `agent-parity-governance` v0.3.0, Priority 60

`architecture-governance` v0.5.0 ergänzt `BSI C3A` als bedingte Cloud-Autonomie-Evidenz und `BSI C5` als bedingte Cloud-Compliance-Assurance-Evidenz. `security-governance` v0.6.0 führt `AI-SBOM` weiter als bedingt anwendbare Supply-Chain-Evidenz, ergänzt sprachspezifische Secure-Coding-Profile und ergänzt regulatorische Anwendbarkeit für NIS2, CRA, EU AI Act und DORA. `a11y-governance` v0.4.0 ergänzt didaktische Inline-Code-Kommentar-Governance. Alle sechs Presets erzeugen oder verlangen audit-ready Spec-Kit-Run-Evidenz mit `Applicable` / `N/A` / `Open`, Begründung, Evidenzpfad, Reviewer, Restrisiko und Follow-up.

*`architecture-governance` v0.5.0 adds conditional `BSI C3A` cloud-autonomy evidence and `BSI C5` cloud-compliance assurance evidence. `security-governance` v0.6.0 keeps conditional `AI-SBOM` evidence, adds language-specific secure-coding profiles, and adds regulatory applicability screening for NIS2, CRA, EU AI Act, and DORA. `a11y-governance` v0.4.0 adds didactic inline-code-comment governance. All six presets produce or require audit-ready Spec-Kit run evidence with `Applicable` / `N/A` / `Open`, rationale, evidence path, reviewer, residual risk, and follow-up.*

Nach Installation oder Update prüfen:

```bash
specify preset list
specify preset info security-governance
specify preset resolve constitution-template.md
```

Wenn Presets Projekt-Policy sind, `.specify/presets/` und erzeugte
Agenten-/Command-Dateien committen; `.specify/presets/.cache/` nicht committen.

*All six governance presets are included in the `github/spec-kit` community
catalog as of 2026-05-04. C#/.NET Level-2 projects default to all six presets
unless a justified exception is documented. Commit `.specify/presets/` and
generated agent/command files when presets are project policy; do not commit
`.specify/presets/.cache/`.*
## Barrierefreiheit / Accessibility (A11Y)

Dieses Projekt folgt grundlegenden Barrierefreiheitsstandards für alle
dokumentierten Inhalte und Benutzeroberflächen.

Richtlinien für Markdown-Dokumentation:

- Überschriften folgen einer klaren Hierarchie (h1 → h2 → h3 — keine Ebene überspringen)
- Alle Bilder haben aussagekräftige Alt-Texte (`![Beschreibung](bild.png)`)
- Linkbeschriftungen sind beschreibend (`[Installationsanleitung](...)` statt `[hier](...)`)
- Code-Blöcke geben die Sprache an (` ```bash `, ` ```powershell `)
- Tabellen haben Kopfzeilen für alle Spalten
- Keine Informationen werden ausschließlich über Farbe vermittelt

---

This project follows basic accessibility standards for all documented
content and user interfaces.

Guidelines for Markdown documentation:

- Headings follow a clear hierarchy (h1 → h2 → h3 — no level skipped)
- All images have meaningful alt texts (`![Description](image.png)`)
- Link labels are descriptive (`[Installation guide](...)` instead of `[here](...)`)
- Code blocks specify the language (` ```bash `, ` ```powershell `)
- Tables have header rows for all columns
- No information is conveyed through colour alone

## Spec-kit-Workflow

Neue Features in diesem Workspace werden nach dem **Specification-Driven Development (SDD)**-Workflow entwickelt.
Der Workflow verwendet das `speckit`-CLI-Tool (GitHub Copilot Skill).

Schritte für ein neues Feature:

1. **Spezifikation erstellen** — `speckit specify "Feature-Name"` → `specs/{branch}/spec.md`
2. **Klärungsfragen** — `speckit clarify` → offene Fragen in `spec.md` beantworten
3. **Implementierungsplan** — `speckit plan` → `specs/{branch}/plan.md`
4. **Aufgabenliste** — `speckit tasks` → `specs/{branch}/tasks.md`
5. **Implementieren** — `speckit implement` → Aufgaben aus `tasks.md` abarbeiten
6. **Validieren** — `bash scripts/check-homogeneity.sh` → Compliance-Score prüfen

Alle Spec-Artefakte werden im Branch-Verzeichnis `specs/{branch}/` gespeichert und versioniert.

---

## Spec-kit Workflow

New features in this workspace are developed following the **Specification-Driven Development (SDD)** workflow.
The workflow uses the `speckit` CLI tool (GitHub Copilot Skill).

Steps for a new feature:

1. **Create specification** — `speckit specify "Feature Name"` → `specs/{branch}/spec.md`
2. **Clarification questions** — `speckit clarify` → answer open questions in `spec.md`
3. **Implementation plan** — `speckit plan` → `specs/{branch}/plan.md`
4. **Task list** — `speckit tasks` → `specs/{branch}/tasks.md`
5. **Implement** — `speckit implement` → work through tasks in `tasks.md`
6. **Validate** — `bash scripts/check-homogeneity.sh` → check compliance score

All spec artefacts are stored and versioned in the branch directory `specs/{branch}/`.

---

## Homogeneity Guardian — Skript-Kurzreferenz / Script Quick Reference

### `.dev-tools/check-homogeneity.sh` / `.dev-tools/check-homogeneity.ps1`

Prüft dieses Projekt auf Compliance (constitution.md, A11Y, Spec-kit, Azubis-Abschnitte, STATS.md).
*Checks this project for compliance (constitution.md, A11Y, Spec-kit, Azubis sections, STATS.md).*

```bash
bash .dev-tools/check-homogeneity.sh

# JSON-Ausgabe für CI/Scripting / JSON output for CI/scripting
bash .dev-tools/check-homogeneity.sh --json
```

```powershell
pwsh .dev-tools/check-homogeneity.ps1
pwsh .dev-tools/check-homogeneity.ps1 -Json
```

---

### `.dev-tools/init-stats.sh` / `.dev-tools/init-stats.ps1`

Schreibt einen Baseline-Eintrag in `STATS.md`. Einmalig nach dem Einrichten ausführen.
*Writes a baseline entry to `STATS.md`. Run once after initial setup.*

```bash
bash .dev-tools/init-stats.sh
```

```powershell
pwsh .dev-tools/init-stats.ps1
```

---

### `.dev-tools/rename-lastenheft.sh` / `.dev-tools/rename-lastenheft.ps1`

Benennt eine Lastenheft-Datei via `git mv` um und committet — fügt Branch-Suffix hinzu.
*Renames a Lastenheft file via `git mv` and commits — adds branch suffix.*

```bash
# Datei umbenennen und committen / Rename and commit
bash .dev-tools/rename-lastenheft.sh Lastenheft_foo.md 002-feature-branch
# Ergebnis / Result: Lastenheft_foo.002-feature-branch.md
```

```powershell
pwsh .dev-tools/rename-lastenheft.ps1 -File Lastenheft_foo.md -Branch 002-feature-branch
```

---

### `.dev-tools/install-hooks.sh` / `.dev-tools/install-hooks.ps1`

Installiert den `pre-push`-Hook nach dem Clonen auf einem neuen Gerät.
*Installs the `pre-push` hook after cloning on a new device.*

```bash
bash .dev-tools/install-hooks.sh
```

```powershell
pwsh .dev-tools/install-hooks.ps1
```

## Für Azubis / For Apprentices

Willkommen! Diese Sektion beschreibt den Einstieg in die Entwicklungsumgebung
für Fachinformatiker-Azubis und andere Einsteiger.

**Voraussetzungen:**

- Git (macOS: `brew install git` / Windows: `winget install Git.Git`)
- PowerShell 7+ (Windows: `winget install Microsoft.PowerShell`)
- ripgrep (macOS: `brew install ripgrep` / Windows: `winget install BurntSushi.ripgrep.MSVC`)
- GitHub CLI (macOS: `brew install gh` / Windows: `winget install GitHub.cli`)

**Ersten Schritt ausführen:**

```bash
# Repository klonen
git clone <repo-url>
cd <projekt-verzeichnis>

# Hooks installieren
bash scripts/install-hooks.sh

# Compliance prüfen
bash scripts/check-homogeneity.sh
```

**Hilfreiche Befehle:**

| Befehl | Beschreibung |
|--------|--------------|
| `bash scripts/check-homogeneity.sh` | Compliance-Bericht anzeigen |
| `bash scripts/init-stats.sh` | Compliance-Baseline in STATS.md schreiben |
| `git log --oneline -10` | Letzte 10 Commits anzeigen |

Bei Fragen: Issue im GitHub-Repository erstellen oder Mentor ansprechen.

---

Welcome! This section describes how to get started with the development
environment for apprentice software developers (Fachinformatiker-Azubis) and
other beginners.

**Prerequisites:**

- Git (macOS: `brew install git` / Windows: `winget install Git.Git`)
- PowerShell 7+ (Windows: `winget install Microsoft.PowerShell`)
- ripgrep (macOS: `brew install ripgrep` / Windows: `winget install BurntSushi.ripgrep.MSVC`)
- GitHub CLI (macOS: `brew install gh` / Windows: `winget install GitHub.cli`)

**First steps:**

```bash
# Clone the repository
git clone <repo-url>
cd <project-directory>

# Install hooks
bash scripts/install-hooks.sh

# Check compliance
bash scripts/check-homogeneity.sh
```

**Useful commands:**

| Command | Description |
|---------|-------------|
| `bash scripts/check-homogeneity.sh` | Show compliance report |
| `bash scripts/init-stats.sh` | Write compliance baseline to STATS.md |
| `git log --oneline -10` | Show last 10 commits |

For questions: open an issue in the GitHub repository or ask your mentor.
