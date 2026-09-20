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

## Gesamtstatistik / Overall Statistics

<!-- project-statistics-v2:begin -->

Profil 2 verwendet Git-getrackte Textdateien und sichtbare Git-Aktivitaet. Die Werte beschreiben Lieferdichte, keine persoenliche Arbeitszeit.

*Profile 2 uses Git-tracked text files and visible Git activity. The values describe delivery density, not personal working time.*

| Kennzahl / Metric | Wert / Value |
|---|---:|
| Textbasis / Text base | 726317 lines |
| Textdateien / Text files | 5093 |
| Beobachtbarer Zeitraum / Observable period | 2025-09-28..2026-09-20 |
| Aktivtage / Active days | 124 |
| Relevante Commits / Relevant commits | 358 |
| Zeilen je Aktivtag / Lines per active day | 5857.4 |
| Peak-Tag im Fenster / Peak day in window | 2026-07-02 / 29374 |
| Peak-Woche im Fenster / Peak week in window | 2026-06-28 / 33755 |
| Laengste Serie / Longest streak | 11 days |
| Speedup vs. 80 lines/day | 73.2x |
| Speedup vs. 100 lines/day | 58.6x |
| Methodik / Methodology | v2; source `8b6d8bcdc83e` |

### Artefaktmix / Artifact Mix

```text
Produktiv / Production          [######..............]  30.6% | 221934
Tests                           [####................]  22.4% | 162977
Dokumentation / Documentation   [####................]  20.1% | 145672
Skripte / Scripts               [#...................]   4.5% | 32731
Konfiguration / Configuration   [#...................]   0.2% | 1657
Daten und Medien / Data and media [....................]   0.0% | 0
Sonstiger Text / Other text     [####................]  22.2% | 161346
```

Die Balken teilen die aktuelle getrackte Textbasis in stabile Kategorien. Prozent und Zeilenwert sind die genaue, textorientierte Aussage.

*The bars split the current tracked text base into stable categories. Percentages and line counts provide the exact text-first result.*

### Tagesaktivitaet / Daily Activity

```text
Wochen / Weeks 01..26 | 2025-09-28..2026-03-28
So/Su  1 1 0 1 3 2 1 0 0 0 1 0 0 0 0 2 2 0 0 0 0 0 1 0 0 2
Mo/Mo  0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 1 0 0 0 0 0 0 0 0 0 1
Di/Tu  1 0 0 1 0 0 0 2 0 0 0 0 0 0 0 4 0 0 0 0 0 0 0 4 0 0
Mi/We  0 0 2 1 0 0 0 1 0 2 0 0 0 0 3 3 0 0 0 0 0 0 0 3 1 0
Do/Th  0 0 2 1 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 1 0 0 1 2 0 3
Fr/Fr  0 1 2 0 0 1 0 1 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 3 0 0
Sa/Sa  0 0 0 0 1 0 0 0 0 2 0 0 0 0 3 2 1 0 0 0 0 0 0 0 2 2
```

```text
Wochen / Weeks 27..52 | 2026-03-29..2026-09-26
So/Su  1 0 4 2 1 0 0 1 1 2 0 4 0 0 0 1 4 3 1 4 4 0 0 0 4 4
Mo/Mo  0 0 1 4 0 0 0 0 2 0 0 1 1 0 1 4 4 0 0 0 2 0 0 0 0 -
Di/Tu  4 0 0 0 1 0 0 1 2 0 0 0 0 0 0 3 4 4 0 0 0 0 2 0 0 -
Mi/We  0 0 0 3 0 2 3 0 0 2 2 0 0 0 0 0 2 4 1 0 0 0 0 0 0 -
Do/Th  2 0 0 0 4 0 0 0 4 0 3 0 1 4 0 1 4 0 0 4 0 0 0 0 0 -
Fr/Fr  4 0 2 4 0 1 1 2 2 0 1 0 0 2 4 4 4 1 0 1 0 0 0 0 0 -
Sa/Sa  0 0 0 0 0 0 0 0 0 0 0 2 0 4 4 2 4 2 1 2 0 0 0 3 4 -
```

DE: 0 = keine Aenderung; 1 = 1..79; 2 = 80..399; 3 = 400..1599; 4 = 1600+ geaenderte Textzeilen; - = noch nicht abgelaufen.

*EN: 0 = no change; 1 = 1..79; 2 = 80..399; 3 = 400..1599; 4 = 1600+ changed text lines; - = not elapsed.*

### Wochenvolumen / Weekly Volume

```text
Wochen / Weeks 01..26 | 2025-09-28..2026-03-28
   cap 10000 | . . . . . . . . . . . . . . . . . . . . . . . . . .
        8333 | . . . . . . . . . . . . . . . . . . . . . . . . . .
        6667 | . . . . . . . . . . . . . . . . . . . . . . . . . .
        5000 | . . . . . . . . . . . . . . . . . . . . . . . # . .
        3333 | . . . . . . . . . . . . . . . # . . . . . . . # . .
        1667 | . . . . . . . . . . . . . . # # . . . . . . . # . .
           0 +-----------------------------------------------------
```

```text
Wochen / Weeks 27..52 | 2026-03-29..2026-09-26
   cap 50000 | . . . . . . . . . . . . . . . . . . . . . . . . . .
       41667 | . . . . . . . . . . . . . . . . . . . . . . . . . .
       33333 | . . . . . . . . . . . . . # . . . . . . . . . . . .
       25000 | . . . . . . . . . . . . . # . . # . . . . . . . . .
       16667 | . . . . . . . . . . . . . # . . # . . . . . . . . .
        8333 | # . # # . . . . # . . . . # # # # # . # . . . . # .
           0 +-----------------------------------------------------
```

Das Wochenvolumen zeigt Additionen plus Loeschungen. Es ist Aenderungsaktivitaet, nicht die aktuelle Groesse des Repositories.

*Weekly volume shows additions plus deletions. It represents change activity, not the current repository size.*

### Kumulative Entwicklung / Cumulative Development

```text
Wochen / Weeks 01..26 | 2025-09-28..2026-03-28
   cap 20000 | . . . . . . . . . . . . . . . . . . . . . . . . . .
       16667 | . . . . . . . . . . . . . . . . . . . . . . . . . .
       13333 | . . . . . . . . . . . . . . . . . . . . . . . # # #
       10000 | . . . . . . . . . . . . . . . . . . . . . . . # # #
        6667 | . . . . . . . . . . . . . . . # # # # # # # # # # #
        3333 | . . . . . . . . . . . . . . # # # # # # # # # # # #
           0 +-----------------------------------------------------
```

```text
Wochen / Weeks 27..52 | 2026-03-29..2026-09-26
  cap 500000 | . . . . . . . . . . . . . . . . . . . . . . . . . .
      416667 | . . . . . . . . . . . . . . . . . . . . . . . . . .
      333333 | . . . . . . . . . . . . . . . . . . . . . . . . . .
      250000 | . . . . . . . . . . . . . . . . . . . . . . . . . .
      166667 | . . . . . . . . . . . . . . . . . # # # # # # # # #
       83333 | . . . . . . . . . . . . . # # # # # # # # # # # # #
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
      100000 | . . . . . . . . . # . .
       66667 | . . . . . . . . . # . .
       33333 | . . . . . . . . . # . .
           0 +-------------------------
```

Es liegen keine belastbaren Phasendaten vor. Deshalb zeigt dieses Diagramm Monate und erfindet keine Projektphasen.

*No reliable phase series is available. This chart therefore shows months and does not invent project phases.*

### Beschleunigungsfaktoren / Acceleration Factors

```text
Scale: 0..100x
80 lines/day       [###############.....] 73.2x
100 lines/day      [############........] 58.6x
```

Die Faktoren vergleichen sichtbare Lieferdichte mit den dokumentierten manuellen Referenzen. Sie messen keine Arbeitszeit.

*The factors compare visible delivery density with documented manual references. They do not measure working time.*

### Durchsatzvergleich / Throughput Comparison

```text
Scale: 0..10000 lines/day
Experienced manual [#...................] 80
Thorsten solo      [#...................] 100
Visible repository [############........] 5857.4
```

Die gemeinsame Skala vergleicht Referenzen und sichtbare Lieferdichte. Sie schreibt die Git-Aktivitaet keiner Person oder KI pauschal zu.

*The common scale compares references with visible delivery density. It does not attribute Git activity to a person or AI by default.*

### Textalternative / Text Alternative

DE: Das Fenster beginnt am 2025-09-28 und endet am 2026-09-20. Es enthaelt 124 aktive und 234 inaktive vergangene Tage. Peak-Tag: 2026-07-02 / 29374. Peak-Woche: 2026-06-28 / 33755. Laengste Serie: 11 Tage (2026-07-16..2026-07-26).

*EN: The window starts on 2025-09-28 and ends on 2026-09-20. It contains 124 active and 234 inactive elapsed days. Peak day: 2026-07-02 / 29374. Peak week: 2026-06-28 / 33755. Longest streak: 11 days (2026-07-16..2026-07-26).*

| Monat / Month | Geaenderte Textzeilen / Changed text lines |
|---|---:|
| 2025-10 | 1338 |
| 2025-11 | 349 |
| 2025-12 | 298 |
| 2026-01 | 6764 |
| 2026-02 | 29 |
| 2026-03 | 19022 |
| 2026-04 | 25347 |
| 2026-05 | 10352 |
| 2026-06 | 4726 |
| 2026-07 | 106576 |
| 2026-08 | 12309 |
| 2026-09 | 22216 |

<!-- project-statistics-v2:end -->
