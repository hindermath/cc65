# Lastenheft-Abarbeitungsreihenfolge

- **Dokumenttyp / Document type:** Lesbare Reihenfolge fuer spaetere
  Spec-Kit-Laeufe / Readable order for later Spec Kit runs
- **Status:** aktiv / active
- **Stand / Updated:** 2026-08-30
- **Zielgruppe / Audience:** Projektverantwortliche, Reviewer und Agenten /
  project owners, reviewers, and agents
- **Vorkenntnisse / Prior knowledge:** Keine Spec-Kit-Vorkenntnisse
  erforderlich / no prior Spec Kit knowledge required

## Zweck / Purpose

Diese Datei erklaert die verbindliche Reihenfolge der aktiven Intakes in
menschenlesbarer Form. Sie startet keinen Intake und keinen Spec-Kit-Lauf.
Branch-spezifische Lastenhefte, die bereits einem Lauf zugeordnet sind, werden
nicht erneut einsortiert.

*This file explains the binding order of active intakes in human-readable form.
It starts neither an intake nor a Spec Kit run. Branch-specific requirements
that already belong to a run are not scheduled again.*

## Begriffe / Terms

- **Intake:** Ein Lastenheft, das einen spaeteren Feature-Lauf vorbereitet.
- **Serie:** Die geordnete Menge der aktiven Intakes.
- **Root:** Ein Intake ohne eingehende Abhaengigkeit.
- **Bindende Kante:** Der Vorgaenger muss abgeschlossen sein, bevor der
  Nachfolger ausgewaehlt werden darf.
- **Eligible:** Der Intake ist laut Reihenfolge auswaehlbar; dies erteilt keine
  Ausfuehrungs- oder Lieferberechtigung.
- **Blocked:** Mindestens ein bindender Vorgaenger ist nicht abgeschlossen.

*An **intake** is a requirements document that prepares a later feature run. A
**series** is the ordered set of active intakes. A **root** has no incoming
dependency. A **binding edge** requires its predecessor to be completed before
the successor may be selected. **Eligible** is ordering evidence only and does
not grant execution or delivery authority. **Blocked** means that at least one
binding predecessor is incomplete.*

<!-- secure-development-hardening-order:start -->
## Verbindliche Reihenfolge / Binding Order

| Rang / Rank | Intake | Rolle / Role | Status |
|---:|---|---|---|
| 1 | `Lastenheft_Secure-Development-Hardening.md` | Root, Primaer / primary | Eligible |
| 2 | `Lastenheft_RL-SE-Checklist-Selbstpruefung.md` | Geordnetes Mitglied / ordered member | Blocked |
| 3 | `Lastenheft_GSDB-Spec-Kit-Intensivpruefung.md` | Geordnetes Mitglied / ordered member | Blocked |

### Abhaengigkeiten und Blocker / Dependencies and Blockers

1. `Lastenheft_Secure-Development-Hardening.md` ist der Root und hat keinen
   Vorgaenger.
2. `Lastenheft_RL-SE-Checklist-Selbstpruefung.md` benoetigt den Abschluss von
   `Lastenheft_Secure-Development-Hardening.md` als `AssessmentBaseline`.
3. `Lastenheft_GSDB-Spec-Kit-Intensivpruefung.md` benoetigt den Abschluss von
   `Lastenheft_RL-SE-Checklist-Selbstpruefung.md` als `FinalAuditInput`.

*The Secure Development intake is the root. The RL-SE intake is blocked by the
Secure Development `AssessmentBaseline`. The GSDB intake is blocked by the
RL-SE `FinalAuditInput`. Both dependencies are binding.*

### Entscheidungen / Decisions

- Das Serienmanifest ist gemaess Schema-2-Konfiguration die autoritative
  maschinenlesbare Quelle.
- Diese Datei verwendet dieselben drei Pfade, dieselbe Reihenfolge, denselben
  Root und dieselben zwei bindenden Kanten.
- Die Inhalte der drei Intakes bleiben unveraendert.
- `Eligible` startet keine Arbeit und erteilt keine Remote-, Merge- oder
  Bypass-Berechtigung.

*The series manifest is the authoritative machine-readable source under the
schema-2 configuration. This document uses the same paths, order, root, and two
binding edges. Intake content is unchanged. Eligibility starts no work and
grants no remote, merge, or bypass authority.*

### Naechste Aktion / Next Action

`$speckit-intake-series-status`

Die Aktion prueft nur den Status und startet keinen nachgelagerten Lauf.

*The action only checks status and starts no downstream run.*
<!-- secure-development-hardening-order:end -->

## Hinweise fuer Agenten / Guidance for Agents

- Vor einem Lauf aktuellen Repository-Stand, Branch und offene Diffs pruefen.
- Erst nach ausdruecklicher Freigabe einen nachgelagerten Spec-Kit-Lauf starten.

*Before a run, check the current repository state, branch, and open diffs. Start
a downstream Spec Kit run only with explicit current approval.*
