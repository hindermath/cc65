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

## Gesamtstand des Repositories / Repository Snapshot

Stand / As of: 2026-04-12 — *Erste Einträge nach dem initialen Arbeitspaket eintragen.*

| Kategorie / Category | Dateien / Files | Zeilen / Lines | Anteil / Share |
|---|---:|---:|---:|
| Produktionscode / Production code | — | — | — |
| Tests / Tests | — | — | — |
| Dokumentation / Documentation (.md) | — | — | — |
| **Gesamt / Total** | — | — | — |

---

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
| Textbasis / Text base | 690306 lines |
| Textdateien / Text files | 4846 |
| Beobachtbarer Zeitraum / Observable period | 2025-08-03..2026-07-28 |
| Aktivtage / Active days | 115 |
| Relevante Commits / Relevant commits | 328 |
| Zeilen je Aktivtag / Lines per active day | 6002.7 |
| Peak-Tag im Fenster / Peak day in window | 2026-07-02 / 29374 |
| Peak-Woche im Fenster / Peak week in window | 2026-06-28 / 33755 |
| Laengste Serie / Longest streak | 8 days |
| Speedup vs. 80 lines/day | 75.0x |
| Speedup vs. 100 lines/day | 60.0x |
| Methodik / Methodology | v2; source `659f350ccfe5` |

### Artefaktmix / Artifact Mix

```text
Produktiv / Production          [######..............]  32.1% | 221865
Tests                           [#####...............]  23.0% | 158802
Dokumentation / Documentation   [####................]  19.0% | 130940
Skripte / Scripts               [#...................]   2.3% | 16053
Konfiguration / Configuration   [#...................]   0.2% | 1344
Daten und Medien / Data and media [....................]   0.0% | 0
Sonstiger Text / Other text     [#####...............]  23.4% | 161302
```

Die Balken teilen die aktuelle getrackte Textbasis in stabile Kategorien. Prozent und Zeilenwert sind die genaue, textorientierte Aussage.

*The bars split the current tracked text base into stable categories. Percentages and line counts provide the exact text-first result.*

### Tagesaktivitaet / Daily Activity

```text
Wochen / Weeks 01..26 | 2025-08-03..2026-01-31
So/Su  0 0 1 0 0 0 1 0 1 1 0 1 3 2 1 0 0 0 1 0 0 0 0 2 2 0
Mo/Mo  0 0 1 0 0 2 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 1 0 0
Di/Tu  0 0 0 2 0 0 0 0 1 0 0 1 0 0 0 2 0 0 0 0 0 0 0 4 0 0
Mi/We  0 0 0 0 0 0 1 0 0 0 2 1 0 0 0 1 0 2 0 0 0 0 3 3 0 0
Do/Th  0 0 2 0 0 0 1 0 0 0 2 1 0 0 0 0 0 0 0 0 0 0 1 0 1 0
Fr/Fr  0 0 1 0 1 0 0 0 0 1 2 0 0 1 0 1 1 0 0 0 0 0 0 0 0 0
Sa/Sa  0 1 0 0 0 0 0 2 0 0 0 0 1 0 0 0 0 2 0 0 0 0 3 2 1 0
```

```text
Wochen / Weeks 27..52 | 2026-02-01..2026-08-01
So/Su  0 0 0 0 1 0 0 2 1 0 4 2 1 0 0 1 1 2 0 4 0 0 0 1 4 3
Mo/Mo  0 0 0 0 0 0 0 1 0 0 1 4 0 0 0 0 2 0 0 0 1 0 1 4 4 0
Di/Tu  0 0 0 0 0 4 0 0 4 0 0 0 1 0 0 1 2 0 0 0 0 0 0 3 4 4
Mi/We  0 0 0 0 0 3 1 0 0 0 0 3 0 2 3 0 0 2 2 0 0 0 0 0 2 -
Do/Th  0 1 0 0 1 2 0 3 2 0 0 0 4 0 0 0 4 0 3 0 0 4 0 1 4 -
Fr/Fr  1 0 0 0 0 3 0 0 4 0 2 4 0 1 0 2 2 0 1 0 0 2 4 4 4 -
Sa/Sa  0 0 0 0 0 0 2 2 0 0 0 0 0 0 0 0 0 0 0 2 0 4 4 0 4 -
```

DE: 0 = keine Aenderung; 1 = 1..79; 2 = 80..399; 3 = 400..1599; 4 = 1600+ geaenderte Textzeilen; - = noch nicht abgelaufen.

*EN: 0 = no change; 1 = 1..79; 2 = 80..399; 3 = 400..1599; 4 = 1600+ changed text lines; - = not elapsed.*

### Wochenvolumen / Weekly Volume

```text
Wochen / Weeks 01..26 | 2025-08-03..2026-01-31
    cap 5000 | . . . . . . . . . . . . . . . . . . . . . . . . . .
        4167 | . . . . . . . . . . . . . . . . . . . . . . . . . .
        3333 | . . . . . . . . . . . . . . . . . . . . . . . # . .
        2500 | . . . . . . . . . . . . . . . . . . . . . . . # . .
        1667 | . . . . . . . . . . . . . . . . . . . . . . # # . .
         833 | . . . . . . . . . . . . # . . . . . . . . . # # . .
           0 +-----------------------------------------------------
```

```text
Wochen / Weeks 27..52 | 2026-02-01..2026-08-01
   cap 50000 | . . . . . . . . . . . . . . . . . . . . . . . . . .
       41667 | . . . . . . . . . . . . . . . . . . . . . . . . . .
       33333 | . . . . . . . . . . . . . . . . . . . . . # . . . .
       25000 | . . . . . . . . . . . . . . . . . . . . . # . . # .
       16667 | . . . . . . . . . . . . . . . . . . . . . # . . # .
        8333 | . . . . . . . . # . # # . . . . # . . . . # # # # .
           0 +-----------------------------------------------------
```

Das Wochenvolumen zeigt Additionen plus Loeschungen. Es ist Aenderungsaktivitaet, nicht die aktuelle Groesse des Repositories.

*Weekly volume shows additions plus deletions. It represents change activity, not the current repository size.*

### Kumulative Entwicklung / Cumulative Development

```text
Wochen / Weeks 01..26 | 2025-08-03..2026-01-31
   cap 10000 | . . . . . . . . . . . . . . . . . . . . . . . . . .
        8333 | . . . . . . . . . . . . . . . . . . . . . . . # # #
        6667 | . . . . . . . . . . . . . . . . . . . . . . . # # #
        5000 | . . . . . . . . . . . . . . . . . . . . . . # # # #
        3333 | . . . . . . . . . . . . . . . . . . . . . . # # # #
        1667 | . . . . . . . . . . . . # # # # # # # # # # # # # #
           0 +-----------------------------------------------------
```

```text
Wochen / Weeks 27..52 | 2026-02-01..2026-08-01
  cap 200000 | . . . . . . . . . . . . . . . . . . . . . . . . . .
      166667 | . . . . . . . . . . . . . . . . . . . . . . . . . .
      133333 | . . . . . . . . . . . . . . . . . . . . . . . . # #
      100000 | . . . . . . . . . . . . . . . . . . . . . # # # # #
       66667 | . . . . . . . . . . . . . . . . . . . # # # # # # #
       33333 | . . . . . . . . . . # # # # # # # # # # # # # # # #
           0 +-----------------------------------------------------
```

Die kumulative Kurve summiert nur das Brutto-Aenderungsvolumen im Fenster. Sie darf nicht als aktuelle Codebasis gelesen werden.

*The cumulative curve sums gross change volume within the window only. It must not be read as the current code base.*

### Monatsvolumen / Monthly Volume

```text
Last 12 calendar months
  cap 100000 | . . . . . . . . . . . .
       83333 | . . . . . . . . . . . #
       66667 | . . . . . . . . . . . #
       50000 | . . . . . . . . . . . #
       33333 | . . . . . . . . . . . #
       16667 | . . . . . . . # # . . #
           0 +-------------------------
```

Es liegen keine belastbaren Phasendaten vor. Deshalb zeigt dieses Diagramm Monate und erfindet keine Projektphasen.

*No reliable phase series is available. This chart therefore shows months and does not invent project phases.*

### Beschleunigungsfaktoren / Acceleration Factors

```text
Scale: 0..100x
80 lines/day       [###############.....] 75.0x
100 lines/day      [############........] 60.0x
```

Die Faktoren vergleichen sichtbare Lieferdichte mit den dokumentierten manuellen Referenzen. Sie messen keine Arbeitszeit.

*The factors compare visible delivery density with documented manual references. They do not measure working time.*

### Durchsatzvergleich / Throughput Comparison

```text
Scale: 0..10000 lines/day
Experienced manual [#...................] 80
Thorsten solo      [#...................] 100
Visible repository [############........] 6002.7
```

Die gemeinsame Skala vergleicht Referenzen und sichtbare Lieferdichte. Sie schreibt die Git-Aktivitaet keiner Person oder KI pauschal zu.

*The common scale compares references with visible delivery density. It does not attribute Git activity to a person or AI by default.*

### Textalternative / Text Alternative

DE: Das Fenster beginnt am 2025-08-03 und endet am 2026-07-28. Es enthaelt 115 aktive und 245 inaktive vergangene Tage. Peak-Tag: 2026-07-02 / 29374. Peak-Woche: 2026-06-28 / 33755. Laengste Serie: 8 Tage (2026-07-19..2026-07-26).

*EN: The window starts on 2025-08-03 and ends on 2026-07-28. It contains 115 active and 245 inactive elapsed days. Peak day: 2026-07-02 / 29374. Peak week: 2026-06-28 / 33755. Longest streak: 8 days (2026-07-19..2026-07-26).*

| Monat / Month | Geaenderte Textzeilen / Changed text lines |
|---|---:|
| 2025-08 | 583 |
| 2025-09 | 475 |
| 2025-10 | 1338 |
| 2025-11 | 349 |
| 2025-12 | 298 |
| 2026-01 | 6764 |
| 2026-02 | 29 |
| 2026-03 | 19022 |
| 2026-04 | 25347 |
| 2026-05 | 10351 |
| 2026-06 | 4664 |
| 2026-07 | 95800 |

<!-- project-statistics-v2:end -->
