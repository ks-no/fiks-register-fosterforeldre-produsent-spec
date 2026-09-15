# AGENTS.md

Arbeidsregler for dette repoet. Selve API-et er dokumentert i `README.md` og
`register-fosterforeldre-produsent.json` - ikke dupliser innholdet her.

## Kilder

- Canonical OpenAPI: `register-fosterforeldre-produsent.json`
- Klientdokumentasjon: `README.md`
- XSD: `meldinger/MeldingOmEndringAvOmsorgsansvar_v1.0.xsd`
- Faglig beskrivelse: `meldinger/Melding om endring av omsorgsansvar august 2026.pdf`
- Eksempler: `examples/*.xml`
- Backend: https://skatteetaten.github.io/folkeregisteret-api-dokumentasjon/ (`mottak/` og `tilbakemelding/`)

## Regler

- Ikke oppfinn felter, enum-verdier eller endepunkter. Alt skal kunne spores til XSD, PDF eller backend-dokumentasjonen. Ved tvil: prioriter XSD/PDF, deretter backend-dokumentasjonen, og marker det som uavklart framfor a gjette.
- Enum-verdier beholder kildens skrivemate.
- Bruk norske feltnavn og verdier i payload der XSD/PDF bruker norsk. Response-komponentnavn i OpenAPI kan vaere engelske (`Accepted`, `BadRequest`).
- Ikke legg inn `info.license`.

## Endringsrutine

1. Oppdater specen og `README.md` i samme endring.
2. Lint:

```bash
npx -y @redocly/cli lint register-fosterforeldre-produsent.json
```

Forventet: «valid» med kun advarselen `info-license`.

3. Verifiser i Swagger-preview i IntelliJ.

## Uavklart

- `resultatkode`: i backend-feeden er den typespesifikke beslutningen et objekt-*navn* (f.eks. `skalTildeleDNummer`), ikke verdien av et felt. Specen modellerer den som streng.
- Om meldingstypen kan ende i `sakTilManuellBehandling`. I sa fall mangler `saksfrist`, og `status`/`beslutningstidspunkt` kan ikke vaere `required`.
- Casing pa `beslutning` fra backend (feeden bruker sma bokstaver, specen store).
- Om backend stotter `pageSize` over 100. Specen tillater `antall` opp til 1000.
- `forelder.foedselsEllerDNummer` er merket "Ja*" i PDF uten funnet fotnote.
- Hvilken backend-ressurssti mottak bruker for omsorgsansvar.
- Om `gyldighetsdato` faktisk er uten betydning ved `annullere` (pastanden er ikke verifisert mot PDF).
