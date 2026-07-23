<!-- intake-authoring:begin -->
# Lastenheft: Secure-Development-Hardening fuer cc65

**Dokumenttyp:** Spec-Kit Intake / Lastenheft
**Status:** vorbereitet fuer separaten Spec-Kit-Lauf
**Stand:** 2026-06-20
**Zielgruppe:** Fachinformatiker*innen in Ausbildung, Entwickler*innen, Reviewer und KI-Agenten

## 1. Zweck

Dieses Lastenheft beschreibt einen spaeteren Spec-Kit-Lauf zur
Sicherheits-Haertung des `cc65`-Forks. Der Lauf soll pruefen, ob die
Nicht-MSL-Entscheidung fuer C89 und 6502-Assembly sauber begruendet ist und ob
die passenden Kompensationskontrollen in Code, Build, Tests, Artefakten und
Dokumentation sichtbar sind.

Der Lauf startet keine Implementierung. Er erzeugt zuerst eine belastbare
Spezifikation fuer eine spaetere Haertungsphase.

*This requirements document describes a later Spec Kit run for security
hardening of the `cc65` fork. The run checks whether the non-MSL decision for
C89 and 6502 assembly is documented and whether compensating controls are
visible in code, build, tests, artifacts, and documentation. It does not start
implementation; it first creates a reliable specification for a later hardening
phase.*

## 2. Ausgangslage

`cc65` ist eine Cross-Development-Toolchain fuer 6502/65C02-Zielsysteme. Die
Primaersprachen C89 und 6502-Assembly sind wegen Zielplattform, historischer
Kompatibilitaet und Toolchain-Zweck erforderlich. Damit ist `cc65` bewusst kein
MSL-Repository.

Die Sicherheit muss deshalb ueber Kompensationskontrollen hergestellt und
nachgewiesen werden:

- sichere C/C89-Regeln und CERT-C-nahe Review-Punkte,
- vorsichtiger Umgang mit Puffern, Laengen, Zeigern und Formatstrings,
- Makefile-Kettenpruefung vor Build-Aenderungen,
- klare Trennung von Quellen und generierten Artefakten,
- Target- und Sample-Validierung fuer erzeugte Programme,
- Secret-Scan und Hook-Infrastruktur in `.dev-tools/`,
- Security-Evidenz in `docs/security/`,
- SBOM/VEX/SLSA-Entscheidungen fuer verteilbare Artefakte.

## 3. Zielbild

Nach dem spaeteren Spec-Kit-Lauf soll klar sein:

- warum C89/6502-Assembly in diesem Repository weiterhin erforderlich ist,
- welche Nicht-MSL-Risiken daraus entstehen,
- welche Kompensationskontrollen `Applicable`, `N/A` oder `Open` sind,
- welche Makefile-, Test- und Artefaktpfade geprueft werden muessen,
- welche Security-Evidenz in `docs/security/` entsteht oder bewusst `N/A` ist,
- wie Auszubildende die Gruende und Grenzen in CEFR-B2-Sprache verstehen.

## 4. Scope

In Scope:

- C/C89- und 6502-Assembly-Sicherheitsregeln,
- Bounds-Checks, Formatstrings, Pointer-Lebensdauer und Fehlerpfade,
- `make`-/Makefile-Ketten fuer Hosttools, Libraries, Tests und Samples,
- generierte Artefakte wie `bin/`, `wrk/`, `lib/`, `libwrk/` und `html/`,
- Target-/Sample-Validierung, inklusive `.d64`- oder Emulator-nahe Artefakte,
- `.dev-tools/`-Hook- und Secret-Scan-Infrastruktur,
- `docs/security/` als Evidenzpfad,
- SBOM, VEX, SLSA/Provenance und OpenSSF-Scorecard-Anwendbarkeit,
- AI-SBOM nur als `N/A`, solange keine KI-Runtime- oder Produktkomponente
  ausgeliefert oder betrieben wird.

Out of Scope:

- sofortige Code-Aenderungen,
- Toolchain-Refactoring ohne eigene Freigabe,
- Migration auf eine MSL,
- produktive Cloud-Architektur,
- automatische Release-Erzeugung.

## 5. Governance- und Compliance-Bezug

- `security-governance`: C/C89-Secure-Coding, Dependency-Audit,
  Supply-Chain-Evidenz, AI-SBOM-`N/A` und regulatorische Anwendbarkeit.
- `architecture-governance`: Architekturentscheidungen fuer Toolchain,
  Build-Grenzen, Artefaktfluesse und C3A/C5-`N/A` bei fehlendem Cloud-Betrieb.
- `a11y-governance`: textfreundliche, ausbildungsgeeignete Dokumentation.
- `cross-platform-governance`: macOS/Linux/Windows- und Shell-Paritaet fuer
  Build, Tests und Hilfsskripte.
- `agent-parity-governance`: konsistente Agenten-Guidance fuer Codex, Claude,
  Gemini und Copilot.
- `isaqb-architecture-governance`: nachvollziehbare Architekturentscheidungen
  und Qualitaetsszenarien fuer Toolchain- und Artefaktfluesse.

Private Ausbildungsnutzung, reine Entwicklungswerkzeug-KI und fehlender
Cloud-Betrieb sind fuer NIS2, CRA, EU AI Act, DORA, C3A und C5 typischerweise
`N/A`. Diese Nichtanwendbarkeit muss kurz begruendet werden.

## 6. Mindestanforderungen an den spaeteren Lauf

1. Nicht-MSL-Entscheidung fuer C89/6502-Assembly dokumentieren.
2. Kompensationskontrollen als `Applicable`, `N/A` oder `Open` klassifizieren.
3. Makefile-Kette vor Build- oder Artefaktaenderungen sichtbar machen.
4. Kritische C/C89-Regeln fuer Buffer, Pointer, Formatstrings und Fehlerpfade
   in Review- und Task-Kontext aufnehmen.
5. Generated-Artifact-Policy pruefen und mit `.gitignore` abgleichen.
6. Target-/Sample-Validierung fuer relevante Beispiele planen.
7. SBOM/VEX/SLSA/OpenSSF-Entscheidungen fuer verteilbare Artefakte pruefen.
8. AI-SBOM als `N/A` dokumentieren, solange KI nur Entwicklungswerkzeug ist.
9. Alle Ergebnisse fuer Auszubildende auf DE/EN, CEFR B2 und WCAG-freundliche
   Markdown-Struktur ausrichten.

## 7. Erwartete Ergebnisartefakte

| Artefakt | Erwartung |
|---|---|
| Spec-Kit `spec.md` | Scope, Nicht-Ziele, Nicht-MSL-Begruendung, Schutzmodell |
| Spec-Kit `plan.md` | Makefile-/Artefaktpfade, Evidenzmatrix, Risiken |
| Spec-Kit `tasks.md` | Pruef-, Dokumentations- und spaetere Implementierungsaufgaben |
| Security-Evidence | Secure-C-Review, Supply Chain, AI-SBOM-`N/A`, Regulatory-`N/A` |
| README/Guide | CEFR-B2-Erklaerung fuer Auszubildende und Reviewer |

## 8. Akzeptanzkriterien

- Der spaetere Lauf startet keine Implementierung ohne eigene Freigabe.
- Jede positive Sicherheitsbehauptung verweist auf konkrete Evidenz.
- Jede Nichtanwendbarkeit ist als `N/A` begruendet.
- Die Nicht-MSL-Entscheidung ist nachvollziehbar und nicht als Ausnahme ohne
  Kompensationskontrollen dokumentiert.
- Die Makefile- und Artefaktpfade sind vor Aenderungen sichtbar.

## 9. Kopierbarer `/speckit-specify`-Prompt

```text
Ersetzter Alt-Prompt: speckit-specify Nutze Lastenheft_Secure-Development-Hardening.md als verbindliche Eingabedatei. Erstelle die Feature-Spezifikation fuer einen Sicherheits-Haertungs-Lauf im cc65-Fork.

Ziel: Aus der Secure-Development-Governance, den sechs Spec-Kit-Presets und der cc65-spezifischen Nicht-MSL-Situation soll ein belastbares Zielbild fuer C89/6502-Assembly-Sicherheit, Makefile-Kettenpruefung, Artefakt-Hygiene und Supply-Chain-Evidenz entstehen.

Pflichtpunkte:
- Nicht-MSL-Entscheidung fuer C89 und 6502-Assembly begruenden.
- Kompensationskontrollen fuer Buffer, Pointer, Formatstrings, Fehlerpfade, Makefiles, Generated Artifacts und Target-/Sample-Validierung als Applicable/N/A/Open klassifizieren.
- Makefile-Kette und relevante Artefaktpfade vor Aenderungen sichtbar machen.
- SBOM, VEX, SLSA/Provenance, OpenSSF Scorecard und Dependency-Audit fuer verteilbare Artefakte pruefen.
- AI-SBOM als N/A dokumentieren, solange KI nur Entwicklungswerkzeug ist und keine KI-Runtime-/Produktkomponente ausgeliefert oder betrieben wird.
- C3A/C5, NIS2, CRA, EU AI Act und DORA als Anwendbarkeitsmatrix pruefen; private Ausbildungs- oder Fork-Arbeit darf N/A sein, aber nur mit Begruendung.
- Inhalte muessen DE/EN, CEFR B2 und WCAG-2.2-AA-freundlich dokumentierbar sein.

Nicht-Ziele:
- Keine direkte Implementierung in diesem Lauf.
- Keine Migration auf eine Memory-Safe Language.
- Keine automatische Release-Erzeugung.
- Keine produktive Cloud-Architektur ohne eigenes Lastenheft.

Erzeuge eine Spezifikation mit Scope, Nicht-Zielen, Nicht-MSL-Begruendung, Schutzmodell, Evidenzmatrix, Anforderungen, Akzeptanzkriterien, Risiken und Teststrategie.
```
<!-- intake-authoring:prompts -->
## Kopierbare Spec-Kit-Prompts / Copy-Ready Spec Kit Prompts

Die folgenden Alternativen starten keinen Lauf automatisch. Der autonome
Prompt ist auf `LocalImplementation` begrenzt und erteilt keine Remote-,
PR-, Merge-, Bypass-, Secret- oder Provider-Berechtigung.

*The alternatives below do not start a run automatically. The autonomous
prompt is limited to `LocalImplementation` and grants no remote,
pull-request, merge, bypass, secret, or provider authority.*

### Specify

<!-- spec-kit-command-id: speckit.specify -->
```text
$speckit-specify Use Lastenheft_Secure-Development-Hardening.md as the binding intake. Preserve its scope, non-goals, ordering, governance, evidence, and acceptance criteria. Create or update only the matching feature specification. Do not implement, commit, push, create a pull request, merge, or start another feature.
```

### Autonomous

<!-- spec-kit-command-id: speckit.autonomous -->
```text
$speckit-autonomous Execute one complete autonomous Spec Kit run using Lastenheft_Secure-Development-Hardening.md as the binding intake. Delivery mode: LocalImplementation. Preserve all scope, ordering, security, accessibility, evidence, and acceptance boundaries. Do not push, create or merge a pull request, use bypass authority, expose secrets, or start a follow-up feature.
```
<!-- intake-authoring:end -->
