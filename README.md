# Fiks Folkeregister – API for omsorgsansvar for fosterforeldre

Dette API-et brukes av leverandører av fagsystem for barnevernstjenestene for å sende meldinger om omsorgsansvar til Folkeregisteret via Fiks.

API-et er asynkront:
1. Klienten sender inn en melding.
2. API-et kvitterer med at meldingen er mottatt.
3. Klienten henter videre status og resultat via tilbakemeldingsendepunktene.

## Base-URL-er

- Test: `https://api.test.fiks.ks.no`
- Produksjon: `https://api.fiks.ks.no`

Alle endepunkter krever `Authorization: Bearer <token>`.

## Hva klienten sender inn

Det finnes ett endepunkt per operasjon:

| Operasjon | Endepunkt | Brukes når |
|---|---|---|
| Endre | `POST /api/v1/omsorgsansvar/endre` | Registrere nytt omsorgsansvar |
| Korrigere | `POST /api/v1/omsorgsansvar/korrigere` | Rette eksisterende registrering |
| Opphøre | `POST /api/v1/omsorgsansvar/opphoere` | Avslutte omsorgsansvar |
| Annullere | `POST /api/v1/omsorgsansvar/annullere` | Fjerne en registrering som aldri skulle vært gyldig |
| Overføre | `POST /api/v1/omsorgsansvar/overfoere` | Overføre omsorgsansvar til annen barnevernstjeneste |

Alle fem operasjoner bruker samme offentlige JSON-struktur:

- `avsendersMeldingsidentifikator`
- `avsendersSaksreferanse`
- `kildesystem`
- `avsendersInnsendingstidspunkt`
- `gyldighetsdato`
- `innsender[]`
- `barn.foedselsEllerDNummer`
- `forelder.foedselsEllerDNummer`
- `barnevernstjeneste.ansvarligBarnevernstjeneste`
- `vedlegg[]` (valgfritt)

### Viktige regler

- `avsendersMeldingsidentifikator` er klientens idempotensnøkkel og må være unik per klient.
- `avsendersSaksreferanse` er obligatorisk og returneres i tilbakemeldinger.
- `foedselsEllerDNummer` må være 11 siffer.
- `Organisasjonsnummer` må være 9 siffer.
- `avsendersInnsendingstidspunkt` skal være ISO 8601 dato-tid, for eksempel `2026-09-07T11:30:00+02:00` eller `2026-09-09T09:12:31Z`.
- `gyldighetsdato` skal være ISO 8601 dato, for eksempel `2026-09-01`.
- `vedlegg` støtter `application/pdf`, `image/png` og `image/jpeg`.

### Felter som ikke skal sendes av klienten

Følgende felter finnes i Skatteetatens bakgrunnsformat, men inngår ikke i det offentlige API-et:

- `forespoerseltype`
- `innsender[].innsendertype`
- `mottak`

Disse feltene settes internt av løsningen:

- `forespoerseltype` utledes av valgt endepunkt.
- `innsender[].innsendertype` settes til `barnevernstjenesten`.
- `mottak.informasjonskanal` settes til `elektroniskMelding`.
- `mottak.mottakstidspunktFraOpprinneligKanal` settes til tidspunktet Fiks mottar requesten.

## Betydningen av `gyldighetsdato`

Samme felt brukes i alle operasjoner, men med ulik betydning:

| Endepunkt | Betydning |
|---|---|
| `/omsorgsansvar/endre` | Dato omsorgsansvaret er gyldig fra |
| `/omsorgsansvar/korrigere` | Korrigert gyldig-fra-dato |
| `/omsorgsansvar/opphoere` | Dato omsorgsansvaret opphører |
| `/omsorgsansvar/annullere` | Må sendes, men har ingen praktisk betydning |
| `/omsorgsansvar/overfoere` | Dato overføringen trer i kraft |

## Typisk flyt

### 1. Send inn melding

Eksempel: registrere nytt omsorgsansvar.

```bash
curl -X POST 'https://api.test.fiks.ks.no/api/v1/omsorgsansvar/endre' \
  -H 'Authorization: Bearer <token>' \
  -H 'Content-Type: application/json' \
  -d '{
    "avsendersMeldingsidentifikator": "MSG-2026-ENDRE-0001",
    "avsendersSaksreferanse": "SAK-2026-0001",
    "kildesystem": "Visma Flyt Barnevern",
    "avsendersInnsendingstidspunkt": "2026-09-07T11:30:00+02:00",
    "gyldighetsdato": "2026-09-01",
    "innsender": [
      {
        "navnPaaBarnevernstjenesten": "Oslo barnevernstjeneste",
        "barnevernstjeneste": "123456789"
      }
    ],
    "barn": {
      "foedselsEllerDNummer": "01010112345"
    },
    "forelder": {
      "foedselsEllerDNummer": "02020223456"
    },
    "barnevernstjeneste": {
      "ansvarligBarnevernstjeneste": "111222333"
    }
  }'
```

Typisk respons:

```json
{
  "sakId": "2d7f86de-4d3c-4e93-a9fc-3f65a54f5c4a",
  "saksnummer": "2026-000123",
  "folkeregisterReferanse": "47956f5b-fa1e-447d-a62d-b6714bc1f120",
  "avsendersMeldingsidentifikator": "MSG-2026-ENDRE-0001",
  "status": "MOTTATT",
  "mottattTidspunkt": "2026-09-09T09:12:31Z"
}
```

`202 Accepted` betyr bare at meldingen er mottatt for videre behandling.

### 2. Hent startsekvens for polling

```bash
curl -H 'Authorization: Bearer <token>' \
  'https://api.test.fiks.ks.no/api/v1/tilbakemeldinger/start'
```

Eksempelrespons:

```json
{
  "sekvensnummer": 182734
}
```

### 3. Poll tilbakemeldinger

```bash
curl -H 'Authorization: Bearer <token>' \
  'https://api.test.fiks.ks.no/api/v1/tilbakemeldinger?fraSekvensnummer=182734&antall=100'
```

`antall` er valgfri, har standardverdi `100` og kan settes opptil `1000`.

Eksempelrespons:

```json
{
  "fraSekvensnummer": 182734,
  "nesteSekvensnummer": 182740,
  "tilbakemeldinger": [
    {
      "sekvensnummer": 182734,
      "sakId": "2d7f86de-4d3c-4e93-a9fc-3f65a54f5c4a",
      "saksnummer": "2026-000123",
      "folkeregisterReferanse": "47956f5b-fa1e-447d-a62d-b6714bc1f120",
      "avsendersMeldingsidentifikator": "MSG-2026-ENDRE-0001",
      "avsendersSaksreferanse": "SAK-2026-0001",
      "status": "FERDIGBEHANDLET",
      "resultatkode": "FREG-OK",
      "resultatbeskrivelse": "Meldingen er ferdig behandlet.",
      "oppdatertTidspunkt": "2026-09-09T09:13:05Z"
    }
  ]
}
```

Bruk alltid returnert `nesteSekvensnummer` i neste kall. Ikke beregn neste verdi selv.

## Oppslag ved behov

Klienten kan også gjøre direkte oppslag:

- `GET /api/v1/tilbakemeldinger/meldinger/{avsendersMeldingsidentifikator}`
- `GET /api/v1/tilbakemeldinger/saker/{saksnummer}`

Dette er nyttig ved retry, feilsøking og gjenfinning av tidligere innsendinger.

Eksempel:

```bash
curl -H 'Authorization: Bearer <token>' \
  'https://api.test.fiks.ks.no/api/v1/tilbakemeldinger/meldinger/MSG-2026-ENDRE-0001'
```

## Fornuftige brukseksempler

### Korrigere
Bruk `korrigere` når en tidligere innsending er registrert på feil grunnlag, for eksempel feil forelder eller feil gyldig-fra-dato.

### Opphøre
Bruk `opphoere` når omsorgsansvaret skal avsluttes fra en gitt dato.

Eksempel: samme struktur som over, men send til `POST /api/v1/omsorgsansvar/opphoere` og sett `gyldighetsdato` til opphørsdatoen.

### Annullere
Bruk `annullere` når en registrering ikke skulle eksistert. `gyldighetsdato` må fortsatt sendes, men har ingen praktisk betydning i denne operasjonen.

### Overføre
Bruk `overfoere` når ansvaret for fosterbarnet skal overtas av en annen barnevernstjeneste fra en bestemt dato.

Eksempel: send til `POST /api/v1/omsorgsansvar/overfoere` og sett `gyldighetsdato` til datoen overføringen gjelder fra.

## Feilhåndtering

Vanlige responser:

- `202 Accepted` – meldingen er mottatt
- `400 Bad Request` – payload eller feltverdier er ugyldige
- `401 Unauthorized` – manglende eller ugyldig token
- `403 Forbidden` – klienten har ikke tilgang
- `404 Not Found` – sak eller melding finnes ikke
- `409 Conflict` – `avsendersMeldingsidentifikator` er allerede brukt

Eksempel på idempotenskonflikt:

```json
{
  "kode": "idempotent_konflikt",
  "melding": "avsendersMeldingsidentifikator finnes allerede for denne klienten.",
  "avsendersMeldingsidentifikator": "MSG-2026-ENDRE-0001",
  "sakId": "2d7f86de-4d3c-4e93-a9fc-3f65a54f5c4a",
  "saksnummer": "2026-000123"
}
```

## Kilde for kontrakten

Gjeldende API-kontrakt finnes i `register-fosterforeldre-produsent.json`.




