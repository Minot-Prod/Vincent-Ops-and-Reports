# Telemetry — Guide de tagging (SYNC)

## Objectif
Standardiser les debriefs pour que le scoring apprenne correctement.

## Fichier
- `telemetry/LEARN_LOG.yaml` — append par entrée.

## Schéma conseillé (YAML)
- date: "YYYY-MM-DD"
- company_slug: "acme-pharma"
- interaction: "call|email|demo|meeting"
- outcome: "meeting_booked|qualified|no_fit|no_timing|lost|won|follow_up"
- objections: ["prix","timing","technique","sécurité","inconnu"]
- triggers: ["gala","lancement","congrès","salon","webinaire","campagne"]
- notes: "phrase courte, actionnable"
- fit: 0-5
- timing: 0-5
- access: 0-5

## Exemples
- objections: ["prix","timing"]
- triggers: ["gala","congrès"]

## Bonnes pratiques
- 1 entrée par interaction significative.
- Toujours au moins 1 **outcome** + 0..n **objections** + 0..n **triggers**.
- `notes` = 1–2 phrases max, factuelles.
