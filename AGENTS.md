# AGENTS.md

Dette dokumentet beskriver etablerte regler og praksis for API-spesifikasjonen i dette repoet.

## Canonical filer

- Canonical OpenAPI: `register-fosterforeldre-innsending-openapi.yaml`
- XSD kildegrunnlag: `meldinger/MeldingOmEndringAvOmsorgsansvar_v1.0.xsd`
- Faglig beskrivelse: `meldinger/Melding om endring av omsorgsansvar august 2026.pdf`
- Eksempler: `examples/*.xml`

## Sprak og navngivning

- Bruk norske feltnavn og verdier i payload der XSD/PDF bruker norsk.
- Behold XSD-navn i API der det er relevant (f.eks. `avsendersMeldingsidentifikator`, `forespoerseltype`, `innsender`, `barnevernstjeneste`).
- Response-komponentnavn i OpenAPI kan vaere pa engelsk (`Accepted`, `BadRequest`, osv.).
- Unnga blanding av engelske feltnavn i eksempelverdier for request payload.

## API-design (etablert)

- Eget endepunkt per forespoerseltype:
  - `POST /api/v1/omsorgsansvar/endre`
  - `POST /api/v1/omsorgsansvar/korrigere`
  - `POST /api/v1/omsorgsansvar/opphoere`
  - `POST /api/v1/omsorgsansvar/annullere`
  - `POST /api/v1/omsorgsansvar/overfoere`
- Payload er JSON (ikke XML).
- Vedlegg stoettes som `vedlegg` (base64) i API-kontrakten.
- `mottak` eksponeres ikke i det offentlige API-et; dette settes internt av mottakslosningen for videreformidling til backend.

## Polling og oppslag

- Polling er klient-skopet (ikke globalt):
  - `GET /api/v1/tilbakemeldinger/start`
  - `GET /api/v1/tilbakemeldinger?fraSekvensnummer=...&antall=...`
- Direkte oppslag:
  - `GET /api/v1/tilbakemeldinger/meldinger/{avsendersMeldingsidentifikator}`
  - `GET /api/v1/tilbakemeldinger/saker/{saksnummer}`

## ID-prinsipper

- `avsendersMeldingsidentifikator` er klientens idempotensnokkel og skal vaere unik per klient/tenant.
- `sakId` er intern teknisk identifikator (UUID) i tilbakemeldinger.
- `saksnummer` er saksreferansen for oppslag i status-endepunkt.

## XSD/PDF-konsistens som skal holdes

- `avsendersSaksreferanse` er obligatorisk.
- `forespoerseltype` er obligatorisk, og operasjonsspesifikke request-skjema skal laase korrekt verdi.
- `mottak` finnes i XSD og settes internt mot backend, men skal ikke vaere del av den offentlige request-payloaden i API-specen.
- XSD-verdier for enum brukes uendret:
  - `forespoerseltype`: `endre|korrigere|opphoere|annullere|overfoere`
  - `innsendertype`: `barnevernstjenesten`
  - `informasjonskanal`: `elektroniskMelding`
- Format/regler:
  - `foedselsEllerDNummer`: 11 sifre
  - organisasjonsnummer: 9 sifre
  - dato/datetime i ISO-format

## OpenAPI metadata

- Ikke legg inn `info.license` med mindre det blir eksplisitt bedt om.

## Endringsrutine

1. Oppdater `register-fosterforeldre-innsending-openapi.yaml`.
2. Kjor lint lokalt:

```bash
npx -y @redocly/cli lint register-fosterforeldre-innsending-openapi.yaml
```

3. Verifiser i Swagger-preview i IntelliJ.
4. Ved tvil: prioriter navnebruk og regler fra XSD/PDF.


