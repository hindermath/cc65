# Lastenheft_Abarbeitungsreihenfolge

**Dokumenttyp:** Reihenfolge fuer spaetere Spec-Kit-Laeufe
**Status:** aktiv
**Stand:** 2026-06-20

## Zweck

Diese Datei merkt die aktive Reihenfolge fuer spaetere Spec-Kit-Laeufe. Sie
startet selbst keinen Lauf. Feature-Branch-spezifische Lastenhefte mit einem
Branch-Namen im Dateinamen, zum Beispiel `001-workspace-homogeneity-guardian`,
gelten als bereits einem Lauf zugeordnet und werden hier nicht erneut
einsortiert.

## Aktive Reihenfolge fuer spaetere Laeufe

1. `Lastenheft_Secure-Development-Hardening.md`

## Hinweise fuer Agenten

- Nur Dateien nach dem Muster `Lastenheft*.md` pruefen.
- Bereits branch-spezifische Lastenhefte nicht erneut ausfuehren.
- Vor einem Lauf den aktuellen Repo-Stand, Branch und offene Diffs pruefen.
- Erst nach ausdruecklicher Freigabe einen Spec-Kit-Lauf starten.
