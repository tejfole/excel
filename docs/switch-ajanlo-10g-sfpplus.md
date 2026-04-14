# Switch ajánló – menedzselhető, rackes, non-PoE, 10G SFP+ uplinkkel

**Célcsoport:** iskolai / SMB környezet, ahol kell legalább 24 és 48×1GbE access port,  
legalább 2×10G SFP+ uplink, rack kivitel, L2 menedzsment (VLAN, LACP, STP), **PoE nem szükséges**.

---

## Igények összefoglalása

| Szempont | Elvárás |
|---|---|
| Port szám | 24-es és 48-as is kell |
| Access portok | 1GbE RJ45 |
| Uplink | legalább 2×10G SFP+ |
| Réteg | L2 (VLAN, LACP, RSTP/MSTP, IGMP snooping) |
| PoE | **nem kell** |
| Kivitel | rack |
| Menedzsment | nincs erős preferencia (eddig Linksys) |
| Optikai uplink | épületen belüli ~100 m, OM4 + 10G SR (elsődleges) |
| Réz tartalék | CAT6 (1G backup / vész) |

---

## HP Aruba Instant On 1960 24G 2XGT 2SFP+ Switch – értékelés

### Modell leírása

| Jellemző | Adat |
|---|---|
| Gyártó | HPE / Aruba Networks |
| Termékvonal | Instant On 1960 sorozat |
| Access portok | 24× 1GbE RJ45 |
| Multi-gig portok | **2× "XGT"** – 1/2.5/5/10GBase-T (RJ45, réz) |
| Uplink portok | **2× SFP+** (10G) |
| PoE | nincs (ez a változat) |
| Réteg | L2+ |
| Kivitel | rack (1U) |
| Menedzsment | Aruba Instant On (felhő/app + helyi webes felület) |

#### A "2XGT" portok magyarázata

A **2XGT** jelölés **2 db multi-gig RJ45 portot** jelent, amelyek az alábbi sebességeken működhetnek:  
**1 / 2.5 / 5 / 10 GBase-T** (rézkábelen, jellemzően CAT6A-val 10G-n jól megy, CAT6-tal 10G ~55 m-ig).

Ezek a portok *nem* az SFP+ uplink helyett vannak, hanem mellette – extra flexibilitást adnak, pl.:
- Egy szerverhez vagy NAS-hoz 5G/10G réz összeköttetésre,
- Egy Wi-Fi 6/6E AP-hoz (amik képesek 2.5/5G-t kihasználni),
- Vagy akár réz "félmegoldásként" uplink irányba, ha átmenetileg kell.

> **A te esetedben:** az XGT portok jó "bónusz", de az elsődleges 10G optikai uplinkhez az SFP+ portok kellenek (és azok megvannak).

#### Menedzsment: Aruba Instant On – hogyan működik?

Az **Instant On** platform SMB-re tervezett, egyszerűsített menedzsment:

- **Helyi webes felület** (böngészőből elérhető az eszköz IP-jén – nincs internetfüggőség),
- **Felhős app** (Aruba Instant On mobil- és webes app – opcionális, de kényelmes),
- **Nem** az enterprise "ArubaOS-CX" vagy "AOS-S" platform (az bonyolultabb, prémium),
- VLAN, LACP, RSTP, IGMP snooping, QoS mind elérhető L2-szinten.

> Iskolai / SMB környezetben az Instant On platform **teljesen megfelelő** – nem kell hozzá szerver, controller vagy licenc.

---

### Megfelel-e az igényeknek?

| Igény | Teljesül? | Megjegyzés |
|---|---|---|
| 24×1GbE access | ✅ | 24 db RJ45 1G port |
| 2×10G SFP+ uplink | ✅ | 2 db SFP+ (10G) – optikával és DAC-kal is működik |
| Rack kivitel | ✅ | 1U rack |
| Non-PoE | ✅ | ez a változat nem PoE |
| L2 menedzsment | ✅ | VLAN, LACP, RSTP/MSTP, IGMP snooping |
| Épületen belüli ~100 m optikai uplink | ✅ | SFP+ SR modullal (OM4 + LC) problémamentes |
| Réz tartalék (CAT6) | ⚠️ | Az XGT portok rézen is adnak lehetőséget; CAT6-on 10G ~55 m-ig, 1G-re bőven elég |
| Nincs preferencia / egyszerű menedzsment | ✅ | Instant On app + helyi webes UI, Linksys mellől könnyen átszokható |

---

### Előnyök

- **Egyszerű menedzsment:** Instant On app intuitív, nincs szükség szerverre / licencre.
- **2×SFP+ uplink:** 10G optikához (SFP+ SR modul + OM4) és DAC-hoz is ideális; elegendő 1 aktív + 1 tartalék, vagy 2×10G LACP konfigurációhoz.
- **2×XGT multi-gig port:** szerver/NAS/AP felé extra érték, amit a legtöbb L2 SMB switch nem ad.
- **Rack kész:** 1U, rack fülek tipikusan mellékelve.
- **Non-PoE változat elérhetősége:** nem kell fizetni PoE-ért, ha nem kell.
- **Aruba márka megbízhatósága:** HPE/Aruba long-term firmware támogatás, bevált SMB vonal.

### Hátrányok / figyelj rá

- **Csak 2×SFP+ uplink:** ha a jövőben egyszerre 4 db 10G uplink kell (pl. redundáns mag + NAS + egyéb), a 48-as változat `48G 4SFP+` verzióját érdemes nézni.
- **Multi-gig RJ45 (XGT) 10G-hoz CAT6 kell, CAT6A ajánlott:** ha az épületben csak CAT6 van, az XGT porton 10G csak ~55 m-ig stabil; 100 m-re az SFP+ optika biztosabb.
- **Felhős regisztráció opcionális, de ajánlott:** a teljes funkcióhoz (firmware update, remote mgmt) érdemes Instant On fiókot létrehozni, de helyi hálón internetkapcsolat nélkül is működik.
- **Nem enterprise-ArubaOS-CX:** ha később profi routing funkciók (OSPF, BGP, VRF) kellene, más vonal kell – de L2 iskolai/SMB-re ez nem hiány.

---

## 48-portos ajánlott párok

Ugyanebből a **Instant On 1960** sorozatból válassz – a 24-es és 48-as között egységes a menedzsment és firmware:

### Elsődlegesen ajánlott: Aruba Instant On 1960 48G 2XGT 2SFP+

| Jellemző | Adat |
|---|---|
| Access portok | 48× 1GbE RJ45 |
| Multi-gig portok | 2× XGT (1/2.5/5/10GBase-T RJ45) |
| Uplink portok | **2× SFP+** (10G) |
| PoE | nincs (ez a változat) |
| Réteg | L2+ |
| Kivitel | rack (1U) |

**Mikor válaszd:** ha a 2×SFP+ uplink elegendő (1 aktív optikai + 1 tartalék, vagy 2×LACP), és a 24-es mellé "ugyanolyan érzésű" eszközt szeretnél.

### Alternatíva: Aruba Instant On 1960 48G 4SFP+

| Jellemző | Adat |
|---|---|
| Access portok | 48× 1GbE RJ45 |
| Multi-gig portok | nincs (vagy kevesebb XGT) |
| Uplink portok | **4× SFP+** (10G) |
| PoE | nincs (ez a változat) |
| Réteg | L2+ |
| Kivitel | rack (1U) |

**Mikor válaszd:** ha a 48-as switch oldalán több 10G uplink kellhet (pl. 2 aktív mag felé + 2 szerver/NAS/tartalék), és a multi-gig RJ45 portok helyett inkább több SFP+ rugalmasság kell.

> **Vásárlás előtt ellenőrizd:** a konkrét típusjelölésben a `4SFP+` valóban 10G SFP+ portokat jelent-e (ne SFP 1G-t). Az Aruba Instant On 1960 vonalnál igen, de mindig érdemes a terméklapon megnézni.

---

## Optika és réz összefoglaló (ehhez a switchpárhoz)

### Elsődleges uplink: 10G optika (~100 m, épületen belül)

- **OM4 multimode** kábel (legalább 4–8 szál, LC csatlakozóval szerelve)
- **2× SFP+ SR modul** mindkét switch-be (ugyanolyan típus mindkét végre, LC)
- 100 m-re OM4+SR bőven megbízható, tipikus és költséghatékony megoldás

### Tartalék: CAT6 (réz)

- Jelenlegi CAT6 maradhat **1G backup**-nak (switch management portján vagy 1G access porton)
- 10G rézen 100 m-en 10GBASE-T kényes lehet; inkább 1G vésztartalékként kezelendő
- Az XGT porton is működhet 1G/2.5G/5G-n a CAT6, ha a végpont is tudja

---

## Gyors döntési összefoglaló

| Kérdés | Válasz |
|---|---|
| Megfelel a 24G 2XGT 2SFP+ az igényeknek? | **Igen** – minden fő elvárást teljesít |
| 48-as ajánlás | **1960 48G 2XGT 2SFP+** (ha 2 uplink elég), vagy **1960 48G 4SFP+** (ha több uplink kell) |
| Optika | OM4 + SFP+ SR (LC), mindkét végre azonos modul |
| Réz | CAT6 marad 1G tartaléknak, az XGT portok bónusz lehetőség szerver/AP felé |
| Menedzsment | Instant On app + helyi web – iskolai/SMB-re teljesen megfelelő, nem kell licenc |
