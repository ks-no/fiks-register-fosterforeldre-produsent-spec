# Fiks Folkeregister – API for omsorgsansvar for fosterforeldre

Dette API-et brukes av leverandører av fagsystem for barnevernstjenestene for å sende meldinger om omsorgsansvar til Folkeregisteret via Fiks.

API-et er asynkront:
1. Klienten sender inn en melding.
2. API-et kvitterer med at meldingen er mottatt.
3. Klienten henter videre status og resultat via tilbakemeldingsendepunktene.

## Base-URL-er

- Test: `https://api.test.fiks.ks.no/folkeregister/produsent`
- Produksjon: `https://api.fiks.ks.no/folkeregister/produsent`

Alle endepunkter krever Fiks integrasjon innlogging med maskinporten.

## Hva klienten sender inn

Det finnes ett endepunkt per operasjon:

KOMMENTAR: Skal vi versjonere på dette nivået i urlen???

| Operasjon | Endepunkt | Brukes når |
|---|---|---|
| Endre | `POST /api/v1/omsorgsansvar/endre` | Registrere nytt omsorgsansvar |
| Korrigere | `POST /api/v1/omsorgsansvar/korrigere` | Rette eksisterende registrering |
| Opphøre | `POST /api/v1/omsorgsansvar/opphoere` | Avslutte omsorgsansvar |
| Annullere | `POST /api/v1/omsorgsansvar/annullere` | Fjerne en registrering som aldri skulle vært gyldig |
| Overføre | `POST /api/v1/omsorgsansvar/overfoere` | Overføre omsorgsansvar til annen barnevernstjeneste |
| Hente startsekvens | `GET /api/v1/tilbakemeldinger/start` | Hente startpunkt for polling av tilbakemeldinger |
| Hente tilbakemeldinger | `GET /api/v1/tilbakemeldinger` | Polling av nye tilbakemeldinger |
| Slå opp melding | `GET /api/v1/tilbakemeldinger/meldinger/{avsendersMeldingsidentifikator}` | Hente tilbakemelding for en bestemt melding |
| Slå opp sak | `GET /api/v1/tilbakemeldinger/saker/{saksnummer}` | Hente siste kjente status for en sak |

## Hva klienten henter

Klienten kan hente status og resultat på to måter:

- **Polling:** Kall `/tilbakemeldinger/start` én gang ved oppstart, og bruk deretter `fraSekvensnummer` og `nesteSekvensnummer` for å hente nye tilbakemeldinger fortløpende.
- **Direkte oppslag:** Hent tilbakemelding for en bestemt melding med `avsendersMeldingsidentifikator`, eller siste kjente status for en sak med `saksnummer`.

Alle GET-endepunktene returnerer kun data for den autentiserte klienten.

Alle fem operasjoner bruker samme offentlige JSON-struktur:

- `avsendersMeldingsidentifikator`
- `avsendersSaksreferanse`
- `kildesystem`
- `gyldighetsdato`
- `innsender[]` TODO: blir kun en 
- `barn.foedselsEllerDNummer`
- `forelder.foedselsEllerDNummer`
- `barnevernstjeneste.ansvarligBarnevernstjeneste`

### Viktige regler

- `avsendersMeldingsidentifikator` er klientens idempotensnøkkel og må være unik, bruk gjerne en UUID.
- `kildesystem` - navn på fagsystem, fritekst. "Visma flyt barnevern", "Netcompany modulus barn"
- `avsendersSaksreferanse` er obligatorisk og returneres i tilbakemeldinger. KS Digital prefikser med en klientid.
- `foedselsEllerDNummer` må være 11 siffer.
- `Organisasjonsnummer` må være 9 siffer.
- `gyldighetsdato` skal være ISO 8601 dato, for eksempel `2026-09-01`.

### Felter som ikke skal sendes av klienten

Følgende felter finnes i Skatteetatens bakgrunnsformat, men inngår ikke i det offentlige API-et:

- `forespoerseltype` - utledes fra url
- `innsender[].innsendertype`
- `mottak`
- `avsendersInnsendingstidspunkt`

Disse feltene settes internt av løsningen:

- `forespoerseltype` utledes av valgt endepunkt.
- `innsender[].innsendertype` settes til `barnevernstjenesten`.
- `mottak.informasjonskanal` settes til `elektroniskMelding`.
- `avsendersInnsendingstidspunkt` settes til tidspunktet meldingen sendes fra Fiks til Skatteetaten.
- `mottak.mottakstidspunktFraOpprinneligKanal` settes til tidspunktet Fiks mottar requesten fra klienten.

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
  "saksnummer": "2026-000123",
  "folkeregisterReferanse": "47956f5b-fa1e-447d-a62d-b6714bc1f120",
  "avsendersMeldingsidentifikator": "MSG-2026-ENDRE-0001",
  "status": "MOTTATT",
  "mottattTidspunkt": "2026-09-09T09:12:31Z"
}
```

`202 Accepted` betyr bare at meldingen er mottatt for videre behandling. `status` her er Fiks-mottakets egen kvitteringsstatus (alltid `MOTTATT`) og er ikke det samme som den endelige beslutningen fra Folkeregisteret – se avsnittet om `status` i tilbakemeldinger under.

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
      "saksnummer": "2026-000123",
      "folkeregisterReferanse": "47956f5b-fa1e-447d-a62d-b6714bc1f120",
      "avsendersMeldingsidentifikator": "MSG-2026-ENDRE-0001",
      "avsendersSaksreferanse": "SAK-2026-0001",
      "status": "REGISTRERT",
      "resultatkode": "skalEndre",
      "resultatbeskrivelse": "Omsorgsansvar skal endres",
      "opprettetTidspunkt": "2026-09-09T09:12:45Z",
      "beslutningstidspunkt": "2026-09-09T09:13:05Z"
    }
  ]
}
```

Bruk alltid returnert `nesteSekvensnummer` i neste kall. Ikke beregn neste verdi selv.

### Betydningen av `status`, `resultatkode` og `begrunnelser`

`status` i en tilbakemelding tilsvarer feltet `Beslutning` fra Folkeregisteret, og har følgende mulige verdier. Per nåværende dokumentasjon er kun `AVVIST` og `REGISTRERT` i aktiv bruk:

| Verdi | Betydning |
|---|---|
| `GODKJENT` | Godkjent |
| `AVSLAATT` | Avslått |
| `AVVIST` | Avvist |
| `AVBRUTT` | Avbrutt |
| `REGISTRERT` | Registrert |

`resultatkode` er en maskinlesbar kode fra Folkeregisteret. Kjente verdier per nåværende dokumentasjon:

| Kode | Betydning |
|---|---|
| `skalEndre` | Omsorgsansvar skal endres |
| `skalIkkeEndre` | Omsorgsansvar skal ikke endres |
| `skalKorrigere` | Omsorgsansvar skal korrigeres |
| `skalIkkeKorrigere` | Omsorgsansvar skal ikke korrigeres |
| `skalOpphøre` | Omsorgsansvar skal opphøre |
| `skalIkkeOpphøre` | Omsorgsansvar skal ikke opphøre |
| `skalAnnullere` | Omsorgsansvar skal annulleres |
| `SkalIkkeAnnullere` | Omsorgsansvar skal ikke annulleres (casing som dokumentert av Skatteetaten) |
| `skalOverføres` | Omsorgsansvar skal overføres |
| `skalIkkeOverføres` | Omsorgsansvar skal ikke overføres |

`begrunnelser` er en liste som beskriver hvorfor en sak er avvist eller har en merknad. Hver oppføring har `begrunnelseskode` (maskinlesbar), `begrunnelsesnavn` (lesbar forklaring) og en valgfri `begrunnelsesmerknad`. Kjente koder per nåværende dokumentasjon (listen er under arbeid hos Skatteetaten og kan utvides):

| begrunnelseskode | begrunnelsesnavn |
|---|---|
| `identifikatorForBarnFinnesIkke` | Barnets fødsels- eller d-nummer er ikke tildelt en person |
| `identifikatorForBarnErIkkeGjeldende` | Opphørt fødsels- eller d-nummer for barn |
| `ugyldigBarn` | Barn har personstatus som ikke er forenelig med å ha fosterforelder |
| `identifikatorForForelderFinnesIkke` | Forelderens fødsels- eller d-nummer er ikke tildelt en person |
| `identifikatorForForelderErIkkeGjeldende` | Opphørt fødsels- eller d-nummer for forelderen |
| `ugyldigForelder` | Forelderen har personstatus som ikke er forenelig med å ha fosterbarn |
| `vedtaksdatoErFramtidEllerFeil` | Angitt vedtaksdato er i framtid eller feil |
| `gjeldendeOmsorgsansvarFinnesAllerede` | Forespørselstype er `endre`, men det finnes allerede et aktivt omsorgsansvar mellom barnet og fosterforelder |
| `finnerIkkeOmsorgsansvarSomKanSlettes` | Forespørselstype er `annullere`, men det finnes ikke et aktivt omsorgsansvar å annullere |
| `finnerIkkeOmsorgsansvarSomKanEndres` | Forespørselstype er `korrigere`, men det finnes ikke et aktivt omsorgsansvar å korrigere |
| `gyldighetstidspunktForTidlig` | Gyldighetstidspunktet fører til at denne registreringen blir historisk |
| `gyldighetstidspunktForSent` | Kan ikke legge inn fosterforelder-ansvar fram i tid |

### Eksempel på direkte oppslag

Direkte oppslag er nyttig ved retry, feilsøking og gjenfinning av tidligere innsendinger.

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
  "saksnummer": "2026-000123"
}
```

## Kilde for kontrakten

Gjeldende API-kontrakt finnes i `register-fosterforeldre-produsent.json`.

## Eksempler på bruk av apiet.

### 1. Ny fosterhjemsplassering
Barnet flytter til et fosterhjem, og en fosterforelder skal registreres med omsorgsansvar fra en gitt dato.

Passer til: `endre`

Eksempel: Barn flytter til fosterhjem 1. september, og fosterforelder registreres fra samme dato.

Endepunkt: `POST /api/v1/omsorgsansvar/endre`

```json
{
  "avsendersMeldingsidentifikator": "MSG-2026-ENDRE-0101",
  "avsendersSaksreferanse": "SAK-2026-1001",
  "kildesystem": "Visma Flyt Barnevern",
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
}
```

### 2. Begge fosterforeldre skal registreres
Et barn flytter inn hos to fosterforeldre, men bare en er registrert fra for. Den andre ma registreres som egen melding.

Passer til: `endre`

Eksempel: Fosterfar er registrert. Foster mor legges til som ny registrering.

Endepunkt: `POST /api/v1/omsorgsansvar/endre`

```json
{
  "avsendersMeldingsidentifikator": "MSG-2026-ENDRE-0102",
  "avsendersSaksreferanse": "SAK-2026-1001",
  "kildesystem": "Visma Flyt Barnevern",
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
    "foedselsEllerDNummer": "03030334567"
  },
  "barnevernstjeneste": {
    "ansvarligBarnevernstjeneste": "111222333"
  }
}
```

### 3. Feil person ble registrert
Barnevernstjenesten oppdager at feil fosterforelder ble meldt inn, eller at feil fodselsnummer ble brukt.

Passer til: `korrigere` eller `annullere`, avhengig av situasjon.

Typisk vurdering:
- Bruk `korrigere` hvis en eksisterende registrering skal rettes.
- Bruk `annullere` hvis registreringen aldri skulle vart der.

Eksempel A - korrigere (rette person):

Endepunkt: `POST /api/v1/omsorgsansvar/korrigere`

```json
{
  "avsendersMeldingsidentifikator": "MSG-2026-KORRIGERE-0201",
  "avsendersSaksreferanse": "SAK-2026-1002",
  "kildesystem": "Visma Flyt Barnevern",
  "gyldighetsdato": "2026-09-01",
  "innsender": [
    {
      "navnPaaBarnevernstjenesten": "Bergen barnevernstjeneste",
      "barnevernstjeneste": "234567891"
    }
  ],
  "barn": {
    "foedselsEllerDNummer": "11111112345"
  },
  "forelder": {
    "foedselsEllerDNummer": "12121223456"
  },
  "barnevernstjeneste": {
    "ansvarligBarnevernstjeneste": "234567891"
  }
}
```

Eksempel B - annullere (registreringen skulle aldri eksistert):

Endepunkt: `POST /api/v1/omsorgsansvar/annullere`

```json
{
  "avsendersMeldingsidentifikator": "MSG-2026-ANNULLERE-0301",
  "avsendersSaksreferanse": "SAK-2026-1002",
  "kildesystem": "Visma Flyt Barnevern",
  "gyldighetsdato": "2026-09-01",
  "innsender": [
    {
      "navnPaaBarnevernstjenesten": "Bergen barnevernstjeneste",
      "barnevernstjeneste": "234567891"
    }
  ],
  "barn": {
    "foedselsEllerDNummer": "11111112345"
  },
  "forelder": {
    "foedselsEllerDNummer": "99999999999"
  },
  "barnevernstjeneste": {
    "ansvarligBarnevernstjeneste": "234567891"
  }
}
```

### 4. Feil dato ble sendt inn
Omsorgsansvaret er riktig, men gyldig-fra-datoen eller opphorsdatoen ble feil.

Passer til: `korrigere`

Eksempel: Meldingen ble sendt med `2026-09-01`, men riktig dato var `2026-08-15`.

Endepunkt: `POST /api/v1/omsorgsansvar/korrigere`

```json
{
  "avsendersMeldingsidentifikator": "MSG-2026-KORRIGERE-0202",
  "avsendersSaksreferanse": "SAK-2026-1003",
  "kildesystem": "Visma Flyt Barnevern",
  "gyldighetsdato": "2026-08-15",
  "innsender": [
    {
      "navnPaaBarnevernstjenesten": "Trondheim barnevernstjeneste",
      "barnevernstjeneste": "345678912"
    }
  ],
  "barn": {
    "foedselsEllerDNummer": "13131312345"
  },
  "forelder": {
    "foedselsEllerDNummer": "14141423456"
  },
  "barnevernstjeneste": {
    "ansvarligBarnevernstjeneste": "345678912"
  }
}
```

### 5. Fosterhjemsforholdet avsluttes
Barnet flytter ut av fosterhjemmet, eller fosterforelderen har ikke lenger omsorgsansvar.

Passer til: `opphoere`

Eksempler:
- Barn flytter hjem til biologiske foreldre
- Barn flytter til institusjon
- Fosterhjemsavtalen avsluttes

Endepunkt: `POST /api/v1/omsorgsansvar/opphoere`

```json
{
  "avsendersMeldingsidentifikator": "MSG-2026-OPPHOERE-0401",
  "avsendersSaksreferanse": "SAK-2026-1004",
  "kildesystem": "Visma Flyt Barnevern",
  "gyldighetsdato": "2026-10-01",
  "innsender": [
    {
      "navnPaaBarnevernstjenesten": "Drammen barnevernstjeneste",
      "barnevernstjeneste": "456789123"
    }
  ],
  "barn": {
    "foedselsEllerDNummer": "15151512345"
  },
  "forelder": {
    "foedselsEllerDNummer": "16161623456"
  },
  "barnevernstjeneste": {
    "ansvarligBarnevernstjeneste": "456789123"
  }
}
```

### 6. Barnet flytter til nytt fosterhjem
Omsorgsansvaret i ett fosterhjem opphorer, og nytt omsorgsansvar starter i et annet fosterhjem.

Passer til: ofte en kombinasjon av `opphoere` og `endre`.

Eksempel:
- Fosterhjem A avsluttes `2026-09-30` (opphoere)
- Fosterhjem B starter `2026-10-01` (endre)

Eksempel A - avslutte eksisterende registrering:

Endepunkt: `POST /api/v1/omsorgsansvar/opphoere`

```json
{
  "avsendersMeldingsidentifikator": "MSG-2026-OPPHOERE-0402",
  "avsendersSaksreferanse": "SAK-2026-1005",
  "kildesystem": "Visma Flyt Barnevern",
  "gyldighetsdato": "2026-09-30",
  "innsender": [
    {
      "navnPaaBarnevernstjenesten": "Kristiansand barnevernstjeneste",
      "barnevernstjeneste": "567891234"
    }
  ],
  "barn": {
    "foedselsEllerDNummer": "17171712345"
  },
  "forelder": {
    "foedselsEllerDNummer": "18181823456"
  },
  "barnevernstjeneste": {
    "ansvarligBarnevernstjeneste": "567891234"
  }
}
```

Eksempel B - registrere nytt fosterhjem:

Endepunkt: `POST /api/v1/omsorgsansvar/endre`

```json
{
  "avsendersMeldingsidentifikator": "MSG-2026-ENDRE-0103",
  "avsendersSaksreferanse": "SAK-2026-1005",
  "kildesystem": "Visma Flyt Barnevern",
  "gyldighetsdato": "2026-10-01",
  "innsender": [
    {
      "navnPaaBarnevernstjenesten": "Kristiansand barnevernstjeneste",
      "barnevernstjeneste": "567891234"
    }
  ],
  "barn": {
    "foedselsEllerDNummer": "17171712345"
  },
  "forelder": {
    "foedselsEllerDNummer": "19191934567"
  },
  "barnevernstjeneste": {
    "ansvarligBarnevernstjeneste": "567891234"
  }
}
```

### 7. Omsorgsansvaret overtas av annen barnevernstjeneste
Barnet flytter til en annen kommune, eller saken overfores administrativt til en annen barnevernstjeneste.

Passer til: `overfoere`

Eksempel: Barnet bor fortsatt i fosterhjemmet, men ansvaret flyttes mellom tjenester.

Endepunkt: `POST /api/v1/omsorgsansvar/overfoere`

```json
{
  "avsendersMeldingsidentifikator": "MSG-2026-OVERFOERE-0501",
  "avsendersSaksreferanse": "SAK-2026-1006",
  "kildesystem": "Visma Flyt Barnevern",
  "gyldighetsdato": "2026-11-01",
  "innsender": [
    {
      "navnPaaBarnevernstjenesten": "Asker barnevernstjeneste",
      "barnevernstjeneste": "678912345"
    }
  ],
  "barn": {
    "foedselsEllerDNummer": "20202012345"
  },
  "forelder": {
    "foedselsEllerDNummer": "21212123456"
  },
  "barnevernstjeneste": {
    "ansvarligBarnevernstjeneste": "789123456"
  }
}
```

### 8. Registreringen skulle aldri vart opprettet
Det ble meldt inn omsorgsansvar pa feil grunnlag, eller plasseringen ble aldri gjennomfort.

Passer til: `annullere`

Eksempler:
- Vedtak ble omgjort for plassering tradte i kraft
- Barnet flyttet aldri inn
- Registreringen ble sendt pa feil sak

Endepunkt: `POST /api/v1/omsorgsansvar/annullere`

```json
{
  "avsendersMeldingsidentifikator": "MSG-2026-ANNULLERE-0302",
  "avsendersSaksreferanse": "SAK-2026-1007",
  "kildesystem": "Visma Flyt Barnevern",
  "gyldighetsdato": "2026-09-01",
  "innsender": [
    {
      "navnPaaBarnevernstjenesten": "Stavanger barnevernstjeneste",
      "barnevernstjeneste": "789123456"
    }
  ],
  "barn": {
    "foedselsEllerDNummer": "22222212345"
  },
  "forelder": {
    "foedselsEllerDNummer": "23232323456"
  },
  "barnevernstjeneste": {
    "ansvarligBarnevernstjeneste": "789123456"
  }
}
```

### 9. Tidligere korrekt registrering ma oppdateres etter ny vurdering
Det skjer intern kontroll eller revisjon, og eksisterende opplysninger ma rettes uten at omsorgsansvaret opphorer.

Passer til: `korrigere`

Eksempler:
- Feil saksreferanse
- Feil kobling mellom barn og fosterforelder
- Feil ansvarlig barnevernstjeneste i meldingen

Endepunkt: `POST /api/v1/omsorgsansvar/korrigere`

```json
{
  "avsendersMeldingsidentifikator": "MSG-2026-KORRIGERE-0203",
  "avsendersSaksreferanse": "SAK-2026-1008-KORR",
  "kildesystem": "Visma Flyt Barnevern",
  "gyldighetsdato": "2026-09-01",
  "innsender": [
    {
      "navnPaaBarnevernstjenesten": "Tromso barnevernstjeneste",
      "barnevernstjeneste": "891234567"
    }
  ],
  "barn": {
    "foedselsEllerDNummer": "24242412345"
  },
  "forelder": {
    "foedselsEllerDNummer": "25252523456"
  },
  "barnevernstjeneste": {
    "ansvarligBarnevernstjeneste": "891234567"
  }
}
```
