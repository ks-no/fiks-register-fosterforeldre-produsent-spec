### Beskrivelse
Dette er en oversikt over eksempler, case beskrivelse, xml meldinger, resulterende tilbakemelding og tilstand i registeret. Merk at det kan komme endringer. 

### Changelog
MeldingOmOmsorgsansvar_v0.3.xsd
 
Endringer fra v0.2 til v0.3
- Fjernet navnPaaBarnevernstjenesten
- Endret til å bare bruke en innsender
- Endret navn på meldingen fra meldingomendringavomsorgsansvar til meldingomomsorgsansvar og tilsvarende endring i typer


### Datoer

Meldingen inneholder _gyldighetsdato_

I Folkeregisteret er relasjonen mellom barn, fosterforelder og ansvarlig barnevernstjeneste angitt med en "gyldig fra dato" og ""gyldig til dato"

- "gyldig fra dato" er obligatorisk (eks. på andre begrep som brukes om denne datoen: _gyldighetsdato, startdato, fra-dato_)
- "gyldig til dato" er frivillig ( eks. på andre begrep som brukes om denne datoen: _sluttdato, opphørsdato, til-dato_)  

Relasjoner som har både "gyldig fra dato" og ""gyldig til dato" er HISTORISKE oppføringer.

Relasjoner som  kun har "gyldig fra dato" er GJELDENDE oppføringer. Det er disse opplysningene som deles med samfunnet.


### Forespørselstype og dato

Vi bruker forespørselstype i meldingen til å avgjøre om datoen i meldingen skal oppdatere "gyldig fra dato" eller "gyldig til dato"


- forespørselstype = endre → oppdaterer "gyldig fra dato". En ny GJELDENDE relasjon mellom barn, fosterforelder og ansvarlig barnevernstjeneste blir registrert i registeret
- forespørselstype = opphøre → oppdaterer "gyldig til dato": En eksisterende relasjon mellom barn, fosterforelder og ansvarlig barnevernstjeneste blir HISTORISK
- forespørselstype = korrigere → oppdaterer "gyldig fra dato": En eksisterende relasjon mellom barn, fosterforelder og ansvarlig barnevernstjeneste blir oppdatert
- forespørselstype = annullere → ingen oppdatering av dato:  En eksisterende relasjon mellom barn, fosterforelder og ansvarlig barnevernstjeneste blir slettet/fjernet fra registeret
- forespørselstype = overføre → oppdaterer "gyldig til dato" til relasjonen knyttet til den "gamle" barnevernstjenesten og "gyldig fra dato" til relasjonen knyttet til den "nye" barnevernstjenesten:  En eksisterende relasjon mellom barn, fosterforelder og ansvarlig barnevernstjeneste blir HISTORISK, og en ny GJELDENDE relasjon mellom barn, fosterforelder og ny ansvarlig barnevernstjeneste blir registrert i registeret



## Eksempler

### Endre 
#### Beskrivelse

Melding om en ny oppføring av relasjon mellom barn og fosterforelder i Folkeregisteret. 

- Med ny oppføring mener vi at barnet og fosterforelder som er oppgitt i meldingen ikke allerede har en GJELDENDE relasjon i folkeregisteret.
- Dato i meldingen blir gyldig fra-dato for relasjonen i registeret
- Barn og fosterforelder som er oppgitt i meldingen kan ha en HISTORISK oppføring (samme barn og samme fosterforelder) i folkeregisteret, d.v.s. at oppføringen i registeret har en både gyldig fra- og til dato. Da må dato i meldingen være senere enn gyldig til-dato i den HISTORISKE oppføringen.
- Barnet må ha personstatus _bosatt_ eller _midlertidig_ (d-nr) NB personstatus = død er uavklart
- Fosterforelder må ha personstatus _bosatt_ eller _midlertidig_ (d-nr)


Merk at det kreves to meldinger med forespørselstype = endre  til FREG, en for hver av fosterforeldrene. I eksemplet under viser vi bare en av fosterforeldrene. 


#### Melding 

```xml
<meldingOmOmsorgsansvar xmlns="folkeregisteret:melding:meldingomomsorgsansvar:v0.3">
  <innsending>
    <avsendersMeldingsidentifikator>98f00932-8dda-4470-9ad9-9e8107a3d9e7</avsendersMeldingsidentifikator>
    <avsendersInnsendingstidspunkt>2026-08-01T00:00:00+02:00</avsendersInnsendingstidspunkt>
    <kildesystem>Visma Flyt Barnevern</kildesystem>
  </innsending>
  <forespoersel>
    <avsendersSaksreferanse>SAK-1111</avsendersSaksreferanse>
    <forespoerseltype>endre</forespoerseltype>
    <gyldighetsdato>2026-08-01</gyldighetsdato>
    <innsender>
      <innsendertype>barnevernstjenesten</innsendertype>
      <barnevernstjeneste>981507320</barnevernstjeneste>
    </innsender>
    <mottak>
      <mottakstidspunktFraOpprinneligKanal>2026-08-01</mottakstidspunktFraOpprinneligKanal>
      <informasjonskanal>elektroniskMelding</informasjonskanal>
    </mottak>
    <fosterbarn>
      <foedselsEllerDNummer>06821099739</foedselsEllerDNummer>
    </fosterbarn>
    <fosterforelder>
      <foedselsEllerDNummer>17908599950</foedselsEllerDNummer>
    </fosterforelder>
    <barnevernstjeneste>
      <ansvarligBarnevernstjeneste>981507320</ansvarligBarnevernstjeneste>
    </barnevernstjeneste>
  </forespoersel>
</meldingOmOmsorgsansvar>
```

#### Tilbakemelding
```json
{
  "sakstype": "sakstype-TBD",
  "saksnummer": "FOLK/2026/111111",
  "opprettet": "2026-09-23T00:00:00+02:00",
  "avsendersSaksreferanse": "SAK-1111",
  "meldingsreferanse": {
    "avsendersMeldingsidentifikator": "98f00932-8dda-4470-9ad9-9e8107a3d9e7",
    "folkeregisterReferanse": "01a0cc8a-046d-7e76-9080-a4a4e19596fd"
  },
  "saksbeslutning": {
    "beslutning": "registrert",
    "beslutningstidspunkt": "2026-09-23T00:00:00+02:00",
    "resultatkode": "skalEndre",
    "resultatbeskrivelse": "omsorgsansvar skal endres"
  }
}
```


#### Tilstand i registeret
Før oppdatering

| Fosterbarn | Fosterforelder | Barnevernstjeneste | gyldig-fra | gyldig-til | gjeldende |
| ---------- | -------------- | ------------------ | ---------- | ---------- | --------- |
|            |                |                    |            |            |           |

Etter oppdatering

| Fosterbarn  | Fosterforelder | Barnevernstjeneste | gyldig-fra | gyldig-til | gjeldende |
| ----------- | -------------- | ------------------ | ---------- | ---------- | --------- |
| 06821099739 | 17908599950    | 981507320          | 2026-08-01 |            | true      |



#### Sak avvises
FREG avviser meldinger med forespørselstype endre hvis

- barn og fosterforelder i meldingen allerede har en GJELDENDE relasjon i registeret (med begrunnelseskode: _gjeldendeOmsorgsansvarFinnesAllerede_)
- barnet allerede har to GJELDENDE fosterforeldre i registeret (med begrunnelseskode _barnetHarFosterforeldre_)
- gyldighetsdato i meldingen er frem i tid (med begrunnelseskode: _fremtidigDato_)
- dato i meldingen fører til at det blir mer enn to gjeldende fosterbarn/fosterforelder-relasjoner i samme periode (med begrunnelseskode: _barnetHarFosterforeldre_)
- barnet har personstatus _utflyttet_, _ikke bosatt_, _fødselsregistrert_, _forsvunnet_ eller _opphørt_ på mottakstidspunkt (med begrunnelseskode: _ugyldigBarn_)
- fosterforelder har personstatus _utflyttet_, _ikke bosatt_, _fødselsregistrert_, _forsvunnet_, _opphørt_ eller _død_ på mottakstidspunkt (med begrunnelseskode:  _ugyldigForelder_)
- barn og/eller fosterforelder har adressebeskyttelse _fortrolig_ eller _strengt fortrolig_ på mottakstidspunkt (med begrunnelseskode: _adressebeskyttelse_)
- barnet har allerede en GJELDENDE oppføring i registeret, og innsender av meldingen er en annen enn ansvarlig barnevernstjeneste i registeret (med begrunnelseskode: _barnetErTilknyttetEtAnnetOrganisasjonsnummer_ )

Årsaken til avvisning blir da spesifisert i tilbakemeldingen f.eks

```json
{
  "sakstype": "sakstype-TBD",
  "saksnummer": "FOLK/2026/111111",
  "opprettet": "2026-09-23T00:00:00+02:00",
  "avsendersSaksreferanse": "SAK-1111",
  "meldingsreferanse": {
    "avsendersMeldingsidentifikator": "98f00932-8dda-4470-9ad9-9e8107a3d9e7",
    "folkeregisterReferanse": "01a0cc8a-046d-7e76-9080-a4a4e19596fd"
  },
  "saksbeslutning": {
    "beslutning": "avvist",
    "beslutningstidspunkt": "2026-09-23T00:00:00+02:00",
    "resultatkode": "skalIkkeEndre",
    "resultatbeskrivelse": "omsorgsansvar skal ikke endres",
    "begrunnelse": [
      {
        "begrunnelseskode": "barnetHarFosterforeldre",
        "begrunnelsesnavn": "Barnet har allerede to fosterforeldre"
      }
    ]
  }
}
```

### Korrigere
#### Beskrivelse
Melding om at opplysninger i en oppføring av en relasjon mellom barn og fosterforelder i Folkeregisteret skal rettes. I praksis vil dette antagelig være retting av fra-dato for relasjonen. Det er ikke mulig å korrigere barn, fosterforelder eller ansvarlig barnevernstjeneste. Evt. feil i disse opplysningene må annulleres. Korrigere kan ikke brukes til å rette til-dato.

La oss anta at GRÜNERLØKKA BARNEVERNSTJENESTE (981507320) fra eksemplet over avdekker at det er feil i meldingen de har sendt. Fosterforeldrene har hatt omsorg fra 01.07.2026 (ikke 1.08.2026) Siden datoen har inntruffet, så kan feilen rettes umiddelbart.



#### Melding 

```xml
<meldingOmOmsorgsansvar xmlns="folkeregisteret:melding:meldingomomsorgsansvar:v0.3">
  <innsending>
    <avsendersMeldingsidentifikator>98f00932-8dda-4470-9ad9-9e8107a3d9e7</avsendersMeldingsidentifikator>
    <avsendersInnsendingstidspunkt>2026-08-01T00:00:00+02:00</avsendersInnsendingstidspunkt>
    <kildesystem>Visma Flyt Barnevern</kildesystem>
  </innsending>
  <forespoersel>
    <avsendersSaksreferanse>SAK-1112</avsendersSaksreferanse>
    <forespoerseltype>korrigere</forespoerseltype>
    <gyldighetsdato>2026-07-01</gyldighetsdato>
    <innsender>
      <innsendertype>barnevernstjenesten</innsendertype>
      <barnevernstjeneste>981507320</barnevernstjeneste>
    </innsender>
    <mottak>
      <mottakstidspunktFraOpprinneligKanal>2026-08-01</mottakstidspunktFraOpprinneligKanal>
      <informasjonskanal>elektroniskMelding</informasjonskanal>
    </mottak>
    <fosterbarn>
      <foedselsEllerDNummer>06821099739</foedselsEllerDNummer>
    </fosterbarn>
    <fosterforelder>
      <foedselsEllerDNummer>17908599950</foedselsEllerDNummer>
    </fosterforelder>
    <barnevernstjeneste>
      <ansvarligBarnevernstjeneste>981507320</ansvarligBarnevernstjeneste>
    </barnevernstjeneste>
  </forespoersel>
</meldingOmOmsorgsansvar>
```


#### Tilbakemelding
Identisk med endre med unntak av at resultatkode blir "skalKorrigere" og resultatbeskrivelse blir "Omsorgsansvar skal korrigeres"

#### Tilstand i registeret
Før oppdatering

| Fosterbarn  | Fosterforelder | Barnevernstjeneste | gyldig-fra | gyldig-til | gjeldende |
| ----------- | -------------- | ------------------ | ---------- | ---------- | --------- |
| 06821099739 | 17908599950    | 981507320          | 2026-08-01 |            | true      |

Etter oppdatering

| Fosterbarn  | Fosterforelder | Barnevernstjeneste | gyldig-fra | gyldig-til | gjeldende |
| ----------- | -------------- | ------------------ | ---------- | ---------- | --------- |
| 06821099739 | 17908599950    | 981507320          | 2026-07-01 |            | true      |


#### Sak avvises
FREG avviser meldinger med forespørselstype = korrigere hvis

- barn og fosterforelder i meldingen ikke har en GJELDENDE relasjon i registeret
- dato meldingen er frem i tid
- barn og/eller fosterforelder har adressebeskyttelse _fortrolig_ eller _strengt fortrolig_
- innsender av meldingen er en annen enn ansvarlig barnevernstjeneste i registeret
  
Årsaken til avvisning blir spesifisert i tilbakemeldingen




### Opphøre
#### Beskrivelse
Melding om at en oppføring av en relasjon mellom barn og fosterforelder i Folkeregisteret skal avsluttes. Med avslutting mener vi at barn og fosterforelder som er oppgitt i meldingen har en GJELDENDE relasjon i folkeregisteret som skal bli HISTORISK. Dato i meldingen blir gyldig til-dato for relasjonen i registeret, og relasjonen blir HISTORISK

Det er den nyeste relasjonen mellom barn og forelder i registeret som blir oppdatert med til-dato, uavhengig av om den er GJELDENDE eller HISTORISK. Det betyr at forespørselstype = opphøre kan brukes til å korrigere til-dato.

La oss anta at Fosterforelder (17908599950) ikke lenger skal ha omsorgen for Barn (06821099739). Relasjonen opphører 18.09.2026. Opphørsmeldingene skal sendes tidligst den dagen relasjonen opphører, d.v.s. 18.09.2026




#### Melding 

```xml
<meldingOmOmsorgsansvar xmlns="folkeregisteret:melding:meldingomomsorgsansvar:v0.3">
  <innsending>
    <avsendersMeldingsidentifikator>98f00932-8dda-4470-9ad9-9e8107a3d9e7</avsendersMeldingsidentifikator>
    <avsendersInnsendingstidspunkt>2026-09-18T00:00:00+02:00</avsendersInnsendingstidspunkt>
    <kildesystem>Visma Flyt Barnevern</kildesystem>
  </innsending>
  <forespoersel>
    <avsendersSaksreferanse>SAK-1113</avsendersSaksreferanse>
    <forespoerseltype>opphoere</forespoerseltype>
    <gyldighetsdato>2026-09-18</gyldighetsdato>
    <innsender>
      <innsendertype>barnevernstjenesten</innsendertype>
      <barnevernstjeneste>981507320</barnevernstjeneste>
    </innsender>
    <mottak>
      <mottakstidspunktFraOpprinneligKanal>2026-09-18</mottakstidspunktFraOpprinneligKanal>
      <informasjonskanal>elektroniskMelding</informasjonskanal>
    </mottak>
    <fosterbarn>
      <foedselsEllerDNummer>06821099739</foedselsEllerDNummer>
    </fosterbarn>
    <fosterforelder>
      <foedselsEllerDNummer>17908599950</foedselsEllerDNummer>
    </fosterforelder>
    <barnevernstjeneste>
      <ansvarligBarnevernstjeneste>981507320</ansvarligBarnevernstjeneste>
    </barnevernstjeneste>
  </forespoersel>
</meldingOmOmsorgsansvar>
```


#### Tilbakemelding
Identisk med endre med unntak av at resultatkode blir "skalOpphøre" og resultatbeskrivelse blir "Omsorgsansvar skal opphøre"



#### Tilstand i registeret etter beslutning

Før oppdatering

| Fosterbarn  | Fosterforelder | Barnevernstjeneste | gyldig-fra | gyldig-til | gjeldende |
| ----------- | -------------- | ------------------ | ---------- | ---------- | --------- |
| 06821099739 | 17908599950    | 981507320          | 2026-08-01 |            | true      |

Etter oppdatering

| Fosterbarn  | Fosterforelder | Barnevernstjeneste | gyldig-fra | gyldig-til | gjeldende |
| ----------- | -------------- | ------------------ | ---------- | ---------- | --------- |
| 06821099739 | 17908599950    | 981507320          | 2026-08-01 | 2026-09-18 | false     |




#### Sak avvises
FREG avviser meldinger med forespørselstype = opphøre hvis

- barn og fosterforelder i meldingen ikke har en relasjon i registeret  (med begrunnelseskode: finnerIkkeOmsorgsansvarSomKanOpphøres)
- dato meldingen er frem i tid  (med begrunnelseskode:  _fremtidigDato_)
- dato i meldingen fører til at perioden for relasjonen blir ulogisk (til-dato blir før fra-dato)  (med begrunnelseskode: _opphørstidspunktErTidligereEnnGyldighetstidspunkt_) 
- barn og/eller fosterforelder har adressebeskyttelse _fortrolig_ eller _strengt fortrolig_  (med begrunnelseskode: _adressebeskyttelse)_ 
- innsender av meldingen er en annen enn ansvarlig barnevernstjeneste i registeret  (med begrunnelseskode: _barnetErTilknyttetEtAnnetOrganisasjonsnummer_)

Årsaken til avvisning blir spesifisert i tilbakemeldingen


### Annullere

#### Beskrivelse

Melding om at en oppføring av en relasjon mellom barn og fosterforelder i Folkeregisteret skal slettes. Med sletting mener vi at barn og fosterforelder som er oppgitt i meldingen ikke lenger skal ha en oppføring i registeret. Den skal ikke gjøres historisk, den skal fjernes fra registeret.


#### Melding 

```xml
<meldingOmOmsorgsansvar xmlns="folkeregisteret:melding:meldingomomsorgsansvar:v0.3">
  <innsending>
    <avsendersMeldingsidentifikator>98f00932-8dda-4470-9ad9-9e8107a3d9e7</avsendersMeldingsidentifikator>
    <avsendersInnsendingstidspunkt>2026-08-01T00:00:00+02:00</avsendersInnsendingstidspunkt>
    <kildesystem>Visma Flyt Barnevern</kildesystem>
  </innsending>
  <forespoersel>
    <avsendersSaksreferanse>SAK-11116</avsendersSaksreferanse>
    <forespoerseltype>annullere</forespoerseltype>
    <gyldighetsdato>2026-08-01</gyldighetsdato>
    <innsender>
      <innsendertype>barnevernstjenesten</innsendertype>
      <barnevernstjeneste>981507320</barnevernstjeneste>
    </innsender>
    <mottak>
      <mottakstidspunktFraOpprinneligKanal>2026-08-01</mottakstidspunktFraOpprinneligKanal>
      <informasjonskanal>elektroniskMelding</informasjonskanal>
    </mottak>
    <fosterbarn>
      <foedselsEllerDNummer>06821099739</foedselsEllerDNummer>
    </fosterbarn>
    <fosterforelder>
      <foedselsEllerDNummer>17908599950</foedselsEllerDNummer>
    </fosterforelder>
    <barnevernstjeneste>
      <ansvarligBarnevernstjeneste>981507320</ansvarligBarnevernstjeneste>
    </barnevernstjeneste>
  </forespoersel>
</meldingOmOmsorgsansvar>
```

#### Tilbakemelding
Identisk med endre med unntak av at resultatkode blir "skalAnnullere" og resultatbeskrivelse blir "Omsorgsansvar skal annulleres"

#### Tilstand i registeret etter beslutning

Før oppdatering

| Fosterbarn  | Fosterforelder | Barnevernstjeneste | gyldig-fra | gyldig-til | gjeldende |
| ----------- | -------------- | ------------------ | ---------- | ---------- | --------- |
| 06821099739 | 17908599950    | 981507320          | 2026-08-01 |            | true      |


Etter oppdatering

| Fosterbarn | Fosterforelder | Barnevernstjeneste | gyldig-fra | gyldig-til | gjeldende |
| ---------- | -------------- | ------------------ | ---------- | ---------- | --------- |
|            |                |                    |            |            |           |



#### Sak avvises
FREG avviser meldinger med forespørselstype = annullere hvis

- barn og fosterforelder i meldingen ikke har en GJELDENDE
- barn og/eller fosterforelder har adressebeskyttelse _fortrolig_ eller _strengt fortrolig_
- innsender av meldingen er en annen enn ansvarlig barnevernstjeneste i registeret

Årsaken til avvisning blir spesifisert i tilbakemeldingen


### Overføre

#### Beskrivelse
Melding om at ansvaret for et fosterbarn som er registrert i registeret skal overføres til en annen barnevernstjeneste .

- Barnevernstjenesten som sender inn den første meldingen som gjelder et barn, er ansvarlig barnevernstjeneste for barnet inntil ansvaret overføres til en annen barnevernstjeneste.
- Det er kun ansvarlig barnevernstjeneste som er registrert i registeret fra før som kan overføre barnet til en annen barnevernstjeneste
- Overføring er aktuelt ved omorganisering av barnevernstjenesten. Eks. kommune sammenslåing, interkommunalt samarbeid, bydelsreform

La oss anta at GRÜNERLØKKA BARNEVERNSTJENESTE (981507320) skal legges ned. Fra 01.01.2027 er ny barnevernstjeneste 979589522 SØNDRE NORDSTRAND BARNEVERNSTJENESTE. Krever en melding for alle aktive fosterbarnrelasjonene hos GRÜNERLØKKA BARNEVERNSTJENESTE. Meldingene sendes tidligst 01.01.2027

#### Melding 

```xml
<meldingOmOmsorgsansvar xmlns="folkeregisteret:melding:meldingomomsorgsansvar:v0.3">
  <innsending>
    <avsendersMeldingsidentifikator>98f00932-8dda-4470-9ad9-9e8107a3d9e7</avsendersMeldingsidentifikator>
    <avsendersInnsendingstidspunkt>2027-01-01T00:00:00+02:00</avsendersInnsendingstidspunkt>
    <kildesystem>Visma Flyt Barnevern</kildesystem>
  </innsending>
  <forespoersel>
    <avsendersSaksreferanse>SAK-1111</avsendersSaksreferanse>
    <forespoerseltype>overfoere</forespoerseltype>
    <gyldighetsdato>2027-01-01</gyldighetsdato>
    <innsender>
      <innsendertype>barnevernstjenesten</innsendertype>
      <barnevernstjeneste>981507320</barnevernstjeneste>
    </innsender>
    <mottak>
      <mottakstidspunktFraOpprinneligKanal>2027-01-01</mottakstidspunktFraOpprinneligKanal>
      <informasjonskanal>elektroniskMelding</informasjonskanal>
    </mottak>
    <fosterbarn>
      <foedselsEllerDNummer>06821099739</foedselsEllerDNummer>
    </fosterbarn>
    <fosterforelder>
      <foedselsEllerDNummer>17908599950</foedselsEllerDNummer>
    </fosterforelder>
    <barnevernstjeneste>
      <ansvarligBarnevernstjeneste>979589522</ansvarligBarnevernstjeneste>
    </barnevernstjeneste>
  </forespoersel>
</meldingOmOmsorgsansvar>
```


#### Tilbakemelding
Identisk med endre med unntak av at resultatkode blir "skalOverføre" og resultatbeskrivelse blir "Omsorgsansvar skal overføres"


#### Tilstand i registeret etter beslutning


Før oppdatering

| Fosterbarn  | Fosterforelder | Barnevernstjeneste | gyldig-fra | gyldig-til | gjeldende |
| ----------- | -------------- | ------------------ | ---------- | ---------- | --------- |
| 06821099739 | 17908599950    | 981507320          | 2026-08-01 |            | true      |

Etter oppdatering

| Fosterbarn  | Fosterforelder | Barnevernstjeneste | gyldig-fra | gyldig-til | gjeldende |
| ----------- | -------------- | ------------------ | ---------- | ---------- | --------- |
| 06821099739 | 17908599950    | 981507320          | 2026-08-01 | 2027-01-01 | false     |
| 06821099739 | 17908599950    | 979589522          | 2027-01-01 |            |           |


#### Sak avvises

FREG avviser meldinger med forespørselstype = overføre hvis

- barnet ikke har en GJELDENDE relasjon i registeret
- barn og/eller fosterforelder har adressebeskyttelse _fortrolig_ eller _strengt fortrolig_

Årsaken til avvisning blir spesifisert i tilbakemeldingen




