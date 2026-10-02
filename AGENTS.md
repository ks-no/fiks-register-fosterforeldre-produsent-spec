# AGENTS.md

Arbeidsregler for dette repoet. Selve API-et er dokumentert i `register-fosterforeldre-produsent.json` og i
klientdokumentasjonen på developers.fiks.ks.no - ikke dupliser innholdet her.

## Kilder

- Canonical OpenAPI: `register-fosterforeldre-produsent.json`
- Klientdokumentasjon: https://developers.fiks.ks.no/tjenester/register/fosterforeldre-omsorgsansvar/
  (kilde: `content/Tjenester/register/fosterforeldre-omsorgsansvar/` i `ks-no/ks-no.github.io`)
- XSD: `meldinger/MeldingOmOmsorgsansvar_v0.3.xsd`
- Faglig beskrivelse: `meldinger/Melding om endring av omsorgsansvar Sept. 2026.pdf`
- Eksempler: `meldinger/eksempler.md` and validated XML files in `examples/*.xml`
- Backend: https://skatteetaten.github.io/folkeregisteret-api-dokumentasjon/ (`mottak/` og `tilbakemelding/`)

## Regler

- Ikke oppfinn felter, enum-verdier eller endepunkter. Alt skal kunne spores til XSD, PDF eller backend-dokumentasjonen. Ved tvil: prioriter XSD/PDF, deretter backend-dokumentasjonen, og marker det som uavklart framfor a gjette.
- Enum-verdier beholder kildens skrivemate.
- Bruk norske feltnavn og verdier i payload der XSD/PDF bruker norsk. Response-komponentnavn i OpenAPI kan vaere engelske (`Accepted`, `BadRequest`).
- Ikke legg inn `info.license`.
- Specen er leverandørrettet: ikke nevn Skatteetaten, XSD, interne felter (f.eks. `forespoerseltype`), backend-feilkoder eller intern hendelsesstrøm i beskrivelser eller eksempler.
- Kodelister som kan utvides (`resultatkode`, `begrunnelseskode`) modelleres som `string` med `x-extensible-enum`, ikke `enum`.

## Endringsrutine

1. Oppdater specen, og oppdater klientdokumentasjonen i `ks-no.github.io` ved endringer som påvirker klienter.
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
- Hvilken backend-ressurssti mottak bruker for omsorgsansvar.
