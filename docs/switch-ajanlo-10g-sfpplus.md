# Switch ajánló – 10G SFP+ uplink, L2, rack, non-PoE

> **Igények összefoglalója:** menedzselhető L2-es switch, rackbe szerelhető, PoE nem kell, legalább 2× 10G SFP+ uplink, elsődlegesen optika (~100 m épületen belül), réz tartaléknak.

---

## Kiválasztott modellpár

### 24 portos: Aruba Instant On 1960 24G 2XGT 2SFP+

| Jellemző | Érték |
|---|---|
| Access portok | 24× 1GbE RJ45 |
| 10G réz portok | 2× 10GBase-T RJ45 („2XGT") |
| Uplink portok | 2× SFP+ (10G) |
| PoE | Nem (ez a változat) |
| Kivitel | Rack, 1U |
| Menedzsment | Aruba Instant On (felhős/appos + helyi web) |
| L2 funkciók | 802.1Q VLAN, LACP, RSTP/MSTP, IGMP snooping |

**„2XGT" mit jelent?** Ez 2 darab **multigig RJ45** portot jelent (jellemzően 1/2,5/5/10GBase-T). Hasznos lehet pl. szerver, NAS vagy AP felé réz linken – de az SFP+ uplinktől független, külön portok.

---

### 48 portos: HP Aruba Instant On 1960 48xGbE 2x10GbE 2xSFP+

| Jellemző | Érték |
|---|---|
| Access portok | 48× 1GbE RJ45 |
| 10G réz portok | 2× 10GBase-T RJ45 („2x10GbE") |
| Uplink portok | 2× SFP+ (10G) |
| PoE | Nem (ez a változat) |
| Kivitel | Rack, 1U |
| Menedzsment | Aruba Instant On (felhős/appos + helyi web) |
| L2 funkciók | 802.1Q VLAN, LACP, RSTP/MSTP, IGMP snooping |

**„2x10GbE" mit jelent?** A névben szereplő **2x10GbE** a 24-es modell „2XGT"-jéhez hasonlóan **2 darab 10GBase-T (RJ45) portot** jelent – ezek réz portok, nem optikai uplinkok. Kiegészítik a 2× SFP+ portot: a réz 10G portokra lehet pl. szervert, NAS-t vagy más eszközt rákötni, míg az SFP+ portokat az optikai (vagy DAC) uplinkhez célszerű használni.

**Megfelel-e a „2 SFP+" követelménynek?** ✅ **Igen.** A modell rendelkezik 2× SFP+ (10G) porttal, ami teljesíti az igényt.

---

## Értékelés a követelmények alapján

| Követelmény | Teljesül? | Megjegyzés |
|---|---|---|
| Menedzselhető, L2 | ✅ | Aruba Instant On app + helyi web UI, VLAN/LACP/STP/IGMP |
| Rack kivitel | ✅ | 1U rack |
| Non-PoE | ✅ | Ennél a változatnál nincs PoE |
| Legalább 2× SFP+ (10G) | ✅ | Pontosan 2× SFP+ van |
| Elsődlegesen optika (~100 m) | ✅ | SFP+ portba optikai modul tehető |
| Réz tartalék lehetséges | ✅ | 2× 10GBase-T RJ45 port rendelkezésre áll |

---

## Előnyök és hátrányok

### Előnyök
- **Egységes platform:** a 24-es és 48-as ugyanabból a vonalból való → közös menedzsment, azonos firmware, ismerős felület.
- **L2 funkciók:** VLAN, LACP, RSTP/MSTP, IGMP snooping – minden szükséges alapfunkció megvan.
- **Kompakt, rack:** 1U, rackbe kész kialakítás.
- **Réz 10G portok (2× 10GBase-T) extra értéket adnak:** szerver/NAS réz linken elérhető anélkül, hogy az SFP+ uplinket feláldoznád.
- **Instant On menedzsment:** egyszerű, app-alapú (iOS/Android) és böngészőből is elérhető – iskolai/SMB környezethez megfelelő.

### Hátrányok / mérlegelési pontok
- **Csak 2× SFP+ uplink:** Ez épp teljesíti a minimumot, de ha a jövőben kell pl. redundáns optikai uplink **és** egy külön 10G link valami más irányba, akkor a 2 port szűk lehet. Ilyenkor egy 4× SFP+-os modell (pl. Aruba Instant On 1930 48G 4SFP+) rugalmasabb lenne.
- **Nincs LACP a redundanciához és sávszélhez egyszerre:** Ha mindkét SFP+ portot LACP-re (2×10G aggregált) használod, nem marad szabad uplink port egy harmadik irányhoz.
- **Instant On menedzsment:** Alapvetően felhős/appos modell. Ha **offline/teljesen helyi** menedzsmentet kell (internet nélküli környezet), ellenőrizd, hogy a helyi web UI minden szükséges funkciót ad-e (VLAN, STP stb.). Enterprise ArubaOS-CX vonal (pl. Aruba 6000 sorozat) jobban testreszabható, de drágább.
- **10GBase-T RJ45 modulok melegednek/fogyasztanak:** Ha a réz 10G portokba SFP+ 10GBASE-T modult tennél, ezek jellemzően több hőt termelnek. A beépített 10GBase-T portok ezt kiküszöbölik – inkább ezeket használd réz 10G-hez.

---

## Optika-javaslat (100 m, épületen belül)

### Elsődleges uplink: OM4 + 10G SFP+ SR

| Elem | Részlet |
|---|---|
| Szál | **OM4 multimode duplex** (LC csatlakozó) |
| Modul | **10G SFP+ SR** (mindkét végre ugyanaz, LC csatlakozó) |
| Max. távolság | ~300–400 m (SR szabványnál), 100 m-re bőven elég |
| Megjegyzés | Olcsóbb, mint LR/singlemode; beltéri 100 m-re a legjobb ár/érték arány |

**Kivitelezési tipp:**
- Ne csak 2 szálat húzz be – **legalább 4 vagy 8 szálat** érdemes, a tartalék szálak később felbecsülhetetlen értékűek.
- Az összeköttetés mindkét végén **LC-LC patch kábel** és rendező/kazetta szükséges.
- Kivitelezés után **mérés/dokumentáció** kötelező (100 m-nél is sokszor meglepetés jön elő, ha nincsenek jó szerelési pontok).

---

## Réz tartalék stratégia

### Mi van a dobozon?
- A 48-as modell **2× 10GBase-T RJ45 portja** (a „2x10GbE") kiváló **réz backup** lehetőséget ad, különösebb többletköltség nélkül (nincs külön modul).
- Ha az optika meghibásodik, a 10GBase-T réz portba átdugva a szerver/NAS-kapcsolatot akár manuálisan átemelhető, illetve a switchek egymás felé réz 10G-n is kommunikálhatnak (ha mindkét switchnek van szabad 10GBase-T portja).

### CAT6 a meglévő infrastruktúrából
- A meglévő **CAT6** kábel **1G backup uplinknek** rendben van (pl. ha az optika teljesen meghibásodik, ideiglenesen 1G-n menjen a forgalom).
- **10G-t CAT6-on 100 m-en** körültekintéssel lehet megcsinálni (10GBASE-T), de ez környezetfüggő (toldások, patch panelek minősége, elektromágneses zaj) – inkább vész-opciónak kezeld, ne tervezett, állandó megoldásnak.
- **SFP+ 10GBASE-T RJ45 modul** (ha az SFP+ portba réz modult tennél): működhet, de ezek a modulok jellemzően melegszenek és több áramot vesznek. Inkább a beépített 10GBase-T portokat (a „2x10GbE" portokat) használd réz összeköttetésre.

### Összefoglalt javasolt topológia

```
[24-es switch] ──── OM4 optika, SFP+ SR ────> [48-as switch]
                 (elsődleges, 10G)

[24-es switch] ──── CAT6 RJ45 (1G backup) ──> [48-as switch]
                 (tartalék/vész, 1G)
```

Vagy ha mindkét switchnek van szabad 10GBase-T portja:
```
[24-es switch, 10GBase-T] ── CAT6 ──> [48-as switch, 10GBase-T]
                 (réz backup, 10G – ha a kábel/útvonal megbízható)
```

---

## Rövid ajánlás

A **HP Aruba Instant On 1960 48xGbE 2x10GbE 2xSFP+** megfelel a megadott követelményeknek (L2, rack, non-PoE, 2× SFP+). Jó pár a 24-es **Aruba Instant On 1960 24G 2XGT 2SFP+** mellé – azonos platform, közös menedzsment.

**Ha biztosan elég a 2× SFP+** (pl. 1 optikai uplink + 1 tartalék, vagy LACP-ben kettő), ez a modell a helyes választás.

**Ha a jövőben több 10G irányra számítasz** (pl. redundáns uplink + külön 10G szerver irány + esetleg inter-switch 10G link is kell), fontolja meg a **4× SFP+** uplinkkel rendelkező modellt (pl. Aruba Instant On 1930 48G 4SFP+) – ez rugalmasabb terjeszkedéshez.

**Azonnali bevásárlólista:**
- 2× Aruba Instant On 1960 SFP+ SR modul (vagy kompatibilis 10G SR, LC, multimode)
- OM4 duplex patch kábel (a rackekhez, LC-LC)
- OM4 törzs (legalább 4 szál, ha most húzzátok be)
- LC-LC patch kábelek a rackekbe (rendezőhöz)
- Rack fülek (általában a csomag része, de ellenőrizd)
