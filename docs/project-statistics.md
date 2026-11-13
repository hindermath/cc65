# Projektstatistik / Project Statistics — cc65

> **Lebendiges Dokument / Living document** — nach jedem abgeschlossenen Feature,
> jeder Spec-Kit-Phase und auf explizite Anfrage aktualisieren.
>
> *Update after every completed feature, Spec-Kit phase, or on explicit request.*

---

## Fortschreibungsprotokoll / Update Log

Ältester Eintrag oben, neuester Eintrag unten.
*Oldest entry at top, newest entry at bottom.*

| Datum / Date | Phase / Branch | Aktivtage ges. | Zeilen ges. | Commits ges. | Hauptarbeitspakete / Main Work Packages |
|---|---|---:|---:|---:|---|
| 2026-04-12 | 0 — Bootstrap | 1 | — | 1 | Initialer Projekt-Bootstrap via bootstrap-project |
| 2026-07-23 | Intake Authoring und Review | — | — | — | Drei aktive Lastenhefte mit expliziter cc65-C89-/6502-Nicht-MSL-Grenze normalisiert und als `Ready` geprüft; kein Produktcode oder Build geändert |

---

| 2026-09-13 | Intake-Lifecycle-Preset-Rollout / Intake lifecycle preset rollout | N/A | N/A | N/A | Vorhandene Authoring-/Review-/Sequencing-Presets auf 0.3.2/0.2.2/0.2.4 aktualisiert; optionale Profile und Dokumentation nachgefuehrt. Pruefnachweise in docs/maintenance/intake-lifecycle-fleet-rollout.json. / Update existing presets and profile references; preserve other presets and project extensions. |
| 2026-09-13 | Mermaid und Abschlussberichte | N/A | N/A | N/A | Neue textbasierte Diagrammregel, Berichtsvorlage, Agent-Paritaet und versionierte Governance; kein Produktcode. / Text-first diagram and completion-report governance; no product code. |

| 2026-09-19 | Statistik-/Assurance-Rollout / Statistics and assurance rollout | N/A | N/A | N/A | Assurance v0.1.3 und Statistik v0.1.0; getrennte reproduzierbare Projekttransparenz, Legacy 80/100 unveraendert. Technische Nachweise und fachliche Abnahme getrennt. / Separate reproducible transparency, unchanged legacy references; no product changes. |

## Gesamtstand des Repositories / Repository Snapshot

Stand / As of: 2026-04-12 — *Erste Einträge nach dem initialen Arbeitspaket eintragen.*

| Kategorie / Category | Dateien / Files | Zeilen / Lines | Anteil / Share |
|---|---:|---:|---:|
| Produktionscode / Production code | — | — | — |
| Tests / Tests | — | — | — |
| Dokumentation / Documentation (.md) | — | — | — |
| **Gesamt / Total** | — | — | — |

---

### 2026-09-19 - OpenCode-Pfadmigration / OpenCode path migration

41 Befehlsdateien unter `.opencode/command/` vereinheitlicht; Inhalte
hashgeprüft, Manifestpfade und Ignore-Regeln angepasst. Drei Paritätstests
bestanden. Documentation Impact: UpdateRequired.
[Nachweis / Evidence](maintenance/opencode-path-migration-20260919.md).

*Migrated 41 commands to the singular path with hash verification,
manifest and ignore alignment. Three parity tests passed.*

## Statistikprofil-1-Archiv / Statistics Profile 1 Archive
*Wird nach dem ersten dokumentierten Arbeitspaket befüllt.*
*To be filled after the first documented work package.*

| Kennzahl / Metric | Verdichteter Gesamtblick / Condensed Overview |
|---|---:|
| Artefaktbasis gesamt | — |
| Beobachtbarer Projektzeitraum | 2026-04-12 bis — |
| Sichtbare Git-Aktivtage | — |
| Repo-weiter Speedup gg. 80-Zeilen-Referenz | — |
| Repo-weiter Speedup gg. Thorsten-Referenz | — |

### 2026-11-03 - Dependabot-Wartung / Dependabot maintenance

DE: Branch `codex/dependabot-maintenance-20261103`, Arbeitsfenster 2026-11-03.
Repository-spezifische Versions-/Sicherheitsgruppen und zweisprachige
Wartungshinweise ergaenzt. Kein Produktions- oder Testcode geaendert;
Konfigurations-/Dokumentationsumfang ist im PR-Diff belegt. Profil 2 wird
aus der committed Inhaltsrevision gerendert; bestehende Referenzen bleiben.
YAML/Schema, Manifestabdeckung, Policy, Dokumentation, Liefermenge und
Secret-Scan bestanden. Hosted-Checks werden am PR verfolgt. Keine Pakete
aktualisiert; Git-basierte Statistik misst keine KI-Zeitersparnis.

EN: Branch `codex/dependabot-maintenance-20261103`, work window 2026-11-03.
Adds repository-specific version/security groups and bilingual maintenance
guidance. No production or test code changed; the PR diff records the exact
configuration/documentation scope. Profile 2 is rendered from the committed
content revision with existing references. YAML/schema, manifest coverage,
policy, documentation, delivery scope and secret scan passed. Hosted checks
are tracked on the PR. No packages updated; Git statistics do not measure
AI time savings.

### 2026-11-03 - Claude-GitHub-Integration entfernt / Claude GitHub integration retired

DE: Zwei Claude-PR-/Issue-Workflows auf Ownerwunsch entfernt; GitHub-App widerrufen.
Technische Checks und manuelle Review-Grenzen bleiben verbindlich. Source-only.

EN: Removes two Claude PR/issue workflows at the owner's request and revokes the app.
Technical checks and manual review boundaries remain binding. Source-only.

### 2026-11-09 - Dependabot PR #52 / Dependabot maintenance

DE: Branch codex/dependabot-repair-20261109-cc65--52; sichtbares Wartungsfenster 09.11.2026, keine
Stoppuhrmessung. chore(deps): bump astral-sh/setup-uv from 6.8.0 to 10.3.3. Dokumentationsentscheidung: NoUpdateRequired
fuer die technische Aenderung; GeneratedUpdate fuer beide vorhandenen
Statistikprofile. Bestehende Referenzwerte bleiben erhalten. Die beobachtete
Liefermenge ist keine Messung von Lernleistung oder KI-Zeitersparnis.
Aktuelle Head-/Plattform-Pruefungen sind vor dem Merge erforderlich.
Owner: Repository-Maintainer; Source-only, kein Home-Sync.

EN: Branch codex/dependabot-repair-20261109-cc65--52; observable maintenance window 9 November 2026,
not stopwatch time. chore(deps): bump astral-sh/setup-uv from 6.8.0 to 10.3.3. Documentation impact: NoUpdateRequired for
the technical change; GeneratedUpdate for the existing statistics profiles.
Existing references remain unchanged. Delivery volume is not a measurement
of learning outcomes or AI time savings. Current head/platform checks are
required before merge. Owner: repository maintainer; source-only, no Home sync.
### 2026-11-12 — Sicherheitsrichtlinie / Security policy

DE: Genehmigte Sicherheitsrichtlinie DE zuerst/EN danach auf CEFR-B2-Niveau
harmonisiert, projektspezifische Grenzen und bestehende Reaktionsziele erhalten.
Private Advisory-Links und Sprach-/Überschriftenstruktur geprüft.
Documentation Impact: UpdateRequired; Nachweis unter
`docs/documentation-impact/security-policy-2026-11-12.json`.
Keine Produktlogik geändert; CodeQL unter Tools wird nach Lieferung separat
eingerichtet. Keine AI-Scan-Aktivierung oder neue praktische A11Y-Abnahme.

EN: Harmonised the approved German-first/English-second security policy at
CEFR B2, preserving project boundaries and existing response targets. Checked
private advisory links, language boundaries and heading structure.
Documentation Impact: UpdateRequired; see the evidence path above.
No product logic changed; CodeQL under Tools is configured separately after
delivery. No AI Scan activation or new practical accessibility acceptance.

### 2026-11-13 — Gemeinsame Preset-Sicherheitswartung / Shared preset security maintenance

Vierzehn veroeffentlichte Patch-Releases sind ueber echte Quellen- und Installationsbindungen uebernommen. Gemeinsame Workflow-Rechte sind explizit begrenzt; Produktlogik und Lifecycle bleiben unveraendert. Offene CodeQL-Belegluecken bleiben offen, ohne automatische Alert-Verwerfung.

Fourteen published patches are recorded through real source and installed bindings. Shared workflow permissions are explicitly restricted; product logic and lifecycle remain unchanged. Open CodeQL evidence gaps remain open without automatic alert dismissal.

Documentation Impact: UpdateRequired; [Wartungsnachweis / maintenance evidence](maintenance/shared-security-rollout-2026-11-13.md).

### 2026-11-13 — Intake Authoring 0.3.14 / Intake-Authoring-Folgekorrektur

DE: Die geprüfte Patch-Version 0.3.14 ergänzt den Sicherheitsrollout; Quellen- und Installationsbindungen sowie kompatible Nachweise bleiben getrennt nachvollziehbar. Keine neue Produktfunktion oder menschliche Sicherheitsabnahme.

EN: Verified patch 0.3.14 supplements the security rollout; source, installation and compatible evidence remain separately traceable. No new product feature or human security acceptance.

Documentation Impact: UpdateRequired; [Nachweis / evidence](maintenance/shared-security-rollout-2026-11-13.md).

### 2026-11-13 — npm-Agent-Proben begrenzt / Bound npm agent probes

DE: Die verteilten Wartungsskripte begrenzen npm-Agent-Proben vor der Ausfuehrung. TinyPl0 behaelt seine ausdrueckliche Freigabe fuer alternative Registries. Es wird kein Spec-Kit-Lauf hinzugezaehlt.

EN: Distributed maintenance scripts bound npm agent probes before execution. TinyPl0 retains its explicit opt-in for alternate registries. No Spec Kit run is added.

Documentation Impact: UpdateRequired; [Nachweis / evidence](maintenance/shared-security-rollout-2026-11-13.md).

+### 2026-11-13 — npm-Cachepfad gebunden / Bound npm cache path

DE: Die verteilte Speicherwartung liest den tatsächlich konfigurierten
npm-Cachepfad, prüft ihn innerhalb des Home-Verzeichnisses und bindet genau
diesen Pfad an verify und clean. Eine abweichende Projekt-.npmrc kann die
spätere Bereinigung nicht mehr umleiten. Kein Spec-Kit-Lauf wird ergänzt.

EN: Distributed storage maintenance reads npm's effective cache path, checks
it inside home, and binds that exact path to verify and clean. A different
project .npmrc path can no longer redirect the later cleanup. No Spec Kit run
is added.

Documentation Impact: UpdateRequired; [Nachweis / evidence](documentation-impact/npm-cache-boundary-2026-11-13.json).
## Gesamtstatistik / Overall Statistics

<!-- project-statistics-v2:begin -->

Profil 2 verwendet Git-getrackte Textdateien und sichtbare Git-Aktivitaet. Die Werte beschreiben Lieferdichte, keine persoenliche Arbeitszeit.

*Profile 2 uses Git-tracked text files and visible Git activity. The values describe delivery density, not personal working time.*

| Kennzahl / Metric | Wert / Value |
|---|---:|
| Textbasis / Text base | 783652 lines |
| Textdateien / Text files | 5736 |
| Beobachtbarer Zeitraum / Observable period | 2025-11-16..2026-11-13 |
| Aktivtage / Active days | 134 |
| Relevante Commits / Relevant commits | 421 |
| Zeilen je Aktivtag / Lines per active day | 5848.1 |
| Peak-Tag im Fenster / Peak day in window | 2026-11-13 / 57577 |
| Peak-Woche im Fenster / Peak week in window | 2026-11-08 / 57821 |
| Laengste Serie / Longest streak | 11 days |
| Speedup vs. 80 lines/day | 73.1x |
| Speedup vs. 100 lines/day | 58.5x |
| Methodik / Methodology | v2; source `dbf1d92625e8` |

### Artefaktmix / Artifact Mix

```text
Produktiv / Production          [######..............]  28.3% | 222113
Tests                           [####................]  21.2% | 165864
Dokumentation / Documentation   [#####...............]  24.7% | 193239
Skripte / Scripts               [#...................]   4.7% | 36832
Konfiguration / Configuration   [#...................]   0.2% | 1779
Daten und Medien / Data and media [....................]   0.0% | 0
Sonstiger Text / Other text     [####................]  20.9% | 163825
```

Die Balken teilen die aktuelle getrackte Textbasis in stabile Kategorien. Prozent und Zeilenwert sind die genaue, textorientierte Aussage.

*The bars split the current tracked text base into stable categories. Percentages and line counts provide the exact text-first result.*

### Tagesaktivitaet / Daily Activity

```text
Wochen / Weeks 01..26 | 2025-11-16..2026-05-16
So/Su  0 0 0 1 0 0 0 0 2 2 0 0 0 0 0 1 0 0 2 1 0 4 2 1 0 0
Mo/Mo  0 0 1 0 1 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 0 1 4 0 0 0
Di/Tu  2 0 0 0 0 0 0 0 4 0 0 0 0 0 0 0 4 0 0 4 0 0 0 1 0 0
Mi/We  1 0 2 0 0 0 0 3 3 0 0 0 0 0 0 0 3 1 0 0 0 0 3 0 2 3
Do/Th  0 0 0 0 0 0 0 1 0 1 0 0 1 0 0 1 2 0 3 2 0 0 0 4 0 0
Fr/Fr  1 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 3 0 0 4 0 2 4 0 1 1
Sa/Sa  0 0 2 0 0 0 0 3 2 1 0 0 0 0 0 0 0 2 2 0 0 0 0 0 0 0
```

```text
Wochen / Weeks 27..52 | 2026-05-17..2026-11-14
So/Su  1 1 2 0 4 0 0 0 1 4 3 1 4 4 0 1 0 4 4 0 4 0 3 3 0 0
Mo/Mo  0 2 0 0 1 1 0 1 4 4 0 0 0 2 0 0 0 0 4 3 0 0 2 0 0 2
Di/Tu  1 2 0 0 0 0 0 0 3 4 4 0 0 0 0 2 0 0 0 0 1 0 2 1 3 0
Mi/We  0 0 2 2 0 0 0 0 0 2 4 1 0 0 0 2 0 0 0 1 1 2 2 0 0 0
Do/Th  0 4 0 3 0 1 4 0 1 4 0 0 4 0 0 0 0 0 1 0 0 2 1 0 0 2
Fr/Fr  2 2 0 1 0 0 2 4 4 4 1 0 1 0 0 0 0 0 0 0 0 0 2 0 0 4
Sa/Sa  0 0 0 0 2 0 4 4 2 4 2 1 2 0 0 0 3 4 4 3 3 0 0 0 0 -
```

DE: 0 = keine Aenderung; 1 = 1..79; 2 = 80..399; 3 = 400..1599; 4 = 1600+ geaenderte Textzeilen; - = noch nicht abgelaufen.

*EN: 0 = no change; 1 = 1..79; 2 = 80..399; 3 = 400..1599; 4 = 1600+ changed text lines; - = not elapsed.*

### Wochenvolumen / Weekly Volume

```text
Wochen / Weeks 01..26 | 2025-11-16..2026-05-16
   cap 20000 | . . . . . . . . . . . . . . . . . . . . . . . . . .
       16667 | . . . . . . . . . . . . . . . . . . . . . . . . . .
       13333 | . . . . . . . . . . . . . . . . . . . # . . . . . .
       10000 | . . . . . . . . . . . . . . . . . . . # . . # . . .
        6667 | . . . . . . . . . . . . . . . . . . . # . # # . . .
        3333 | . . . . . . . . # . . . . . . . # . . # . # # . . .
           0 +-----------------------------------------------------
```

```text
Wochen / Weeks 27..52 | 2026-05-17..2026-11-14
  cap 100000 | . . . . . . . . . . . . . . . . . . . . . . . . . .
       83333 | . . . . . . . . . . . . . . . . . . . . . . . . . .
       66667 | . . . . . . . . . . . . . . . . . . . . . . . . . .
       50000 | . . . . . . . . . . . . . . . . . . . . . . . . . #
       33333 | . . . . . . # . . . . . . . . . . . . . . . . . . #
       16667 | . . . . . . # . . # . . . . . . . . # . . . . . . #
           0 +-----------------------------------------------------
```

Das Wochenvolumen zeigt Additionen plus Loeschungen. Es ist Aenderungsaktivitaet, nicht die aktuelle Groesse des Repositories.

*Weekly volume shows additions plus deletions. It represents change activity, not the current repository size.*

### Kumulative Entwicklung / Cumulative Development

```text
Wochen / Weeks 01..26 | 2025-11-16..2026-05-16
  cap 100000 | . . . . . . . . . . . . . . . . . . . . . . . . . .
       83333 | . . . . . . . . . . . . . . . . . . . . . . . . . .
       66667 | . . . . . . . . . . . . . . . . . . . . . . . . . .
       50000 | . . . . . . . . . . . . . . . . . . . . . . . # # #
       33333 | . . . . . . . . . . . . . . . . . . . . . # # # # #
       16667 | . . . . . . . . . . . . . . . . . . . # # # # # # #
           0 +-----------------------------------------------------
```

```text
Wochen / Weeks 27..52 | 2026-05-17..2026-11-14
  cap 500000 | . . . . . . . . . . . . . . . . . . . . . . . . . .
      416667 | . . . . . . . . . . . . . . . . . . . . . . . . . .
      333333 | . . . . . . . . . . . . . . . . . . . . . . . . . .
      250000 | . . . . . . . . . . . . . . . . . . . . . . . . . #
      166667 | . . . . . . . . . . # # # # # # # # # # # # # # # #
       83333 | . . . . . . # # # # # # # # # # # # # # # # # # # #
           0 +-----------------------------------------------------
```

Die kumulative Kurve summiert nur das Brutto-Aenderungsvolumen im Fenster. Sie darf nicht als aktuelle Codebasis gelesen werden.

*The cumulative curve sums gross change volume within the window only. It must not be read as the current code base.*

### Monatsvolumen / Monthly Volume

```text
Last 12 calendar months
  cap 200000 | . . . . . . . . . . . .
      166667 | . . . . . . . . . . . .
      133333 | . . . . . . . . . . . .
      100000 | . . . . . . . # . . . .
       66667 | . . . . . . . # . . . .
       33333 | . . . . . . . # . # . #
           0 +-------------------------
```

Es liegen keine belastbaren Phasendaten vor. Deshalb zeigt dieses Diagramm Monate und erfindet keine Projektphasen.

*No reliable phase series is available. This chart therefore shows months and does not invent project phases.*

### Beschleunigungsfaktoren / Acceleration Factors

```text
Scale: 0..100x
80 lines/day       [###############.....] 73.1x
100 lines/day      [############........] 58.5x
```

Die Faktoren vergleichen sichtbare Lieferdichte mit den dokumentierten manuellen Referenzen. Sie messen keine Arbeitszeit.

*The factors compare visible delivery density with documented manual references. They do not measure working time.*

### Durchsatzvergleich / Throughput Comparison

```text
Scale: 0..10000 lines/day
Experienced manual [#...................] 80
Thorsten solo      [#...................] 100
Visible repository [############........] 5848.1
```

Die gemeinsame Skala vergleicht Referenzen und sichtbare Lieferdichte. Sie schreibt die Git-Aktivitaet keiner Person oder KI pauschal zu.

*The common scale compares references with visible delivery density. It does not attribute Git activity to a person or AI by default.*

### Textalternative / Text Alternative

DE: Das Fenster beginnt am 2025-11-16 und endet am 2026-11-13. Es enthaelt 134 aktive und 229 inaktive vergangene Tage. Peak-Tag: 2026-11-13 / 57577. Peak-Woche: 2026-11-08 / 57821. Laengste Serie: 11 Tage (2026-07-16..2026-07-26).

*EN: The window starts on 2025-11-16 and ends on 2026-11-13. It contains 134 active and 229 inactive elapsed days. Peak day: 2026-11-13 / 57577. Peak week: 2026-11-08 / 57821. Longest streak: 11 days (2026-07-16..2026-07-26).*

| Monat / Month | Geaenderte Textzeilen / Changed text lines |
|---|---:|
| 2025-12 | 298 |
| 2026-01 | 6764 |
| 2026-02 | 29 |
| 2026-03 | 19022 |
| 2026-04 | 25347 |
| 2026-05 | 10352 |
| 2026-06 | 4726 |
| 2026-07 | 106576 |
| 2026-08 | 12322 |
| 2026-09 | 38941 |
| 2026-10 | 10354 |
| 2026-11 | 58917 |

<!-- project-statistics-v2:end -->
