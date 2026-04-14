# Menedzselhető rack-switch ajánló – 1GbE access + 10GbE SFP+ uplink (PoE nélkül)

> **Összefoglalás:** Két különálló helyszínre (nem egymás mellé) szükséges egy **24 portos** és egy **48 portos**, rack-be szerelhető, L2 menedzselhető, PoE nélküli switch, legalább **2 × 10GbE SFP+** uplink porttal. Az uplink média elsődlegesen optika (fiber), réz tartalékként (SFP+ DAC, esetleg 10GBASE-T RJ45 SFP+ modul).

---

## Tartalomjegyzék

1. [24 portos modelljavaslatok](#1-24-portos-modelljavaslatok)
2. [48 portos modelljavaslatok](#2-48-portos-modelljavaslatok)
3. [SFP+ transceiver és DAC választási útmutató](#3-sfp-transceiver-és-dac-választási-útmutató)
4. [Topológiai javaslat](#4-topológiai-javaslat)
5. [Beszerzési checklist](#5-beszerzési-checklist)

---

## 1. 24 portos modelljavaslatok

Az alábbi modellek mindegyike megfelel a követelményeknek: **24 × 1GbE RJ45** + legalább **2 × 10GbE SFP+** uplink, rack-kompatibilis (1U), L2 menedzselt, PoE nélkül.

### 1.1 SMB / jó ár-érték kategória

#### MikroTik CRS326-24G-2S+RM
| Tulajdonság | Érték |
|---|---|
| Access portok | 24 × 1GbE RJ45 |
| Uplink portok | 2 × 10GbE SFP+ |
| Forma faktor | 1U rack |
| L2 funkciók | VLAN 802.1Q, RSTP, LACP 802.3ad, ACL, QoS, port mirroring |
| OS | RouterOS/SwOS (dual-boot) |
| Menedzsment | Web GUI, Winbox, SSH, SNMP |
| Hűtés | Ventilátor (kissé hallható) |
| Tipikus ár (2025) | ~60 000–75 000 Ft |

**Előnyök:** Kiváló ár-érték, aktív közösség, részletes dokumentáció, SwOS-ban egyszerű GUI.  
**Hátrány:** RouterOS tanulási görbe; MikroTik-specifikus terminológia.

---

#### TP-Link TL-SG3428X (JetStream)
| Tulajdonság | Érték |
|---|---|
| Access portok | 24 × 1GbE RJ45 |
| Uplink portok | 4 × 10GbE SFP+ |
| Forma faktor | 1U rack |
| L2 funkciók | VLAN, RSTP/MSTP, LACP, QoS, ACL, IGMP Snooping |
| Menedzsment | Web GUI, CLI, SNMP, Omada SDN (opcionális) |
| Hűtés | Ventilátor |
| Tipikus ár (2025) | ~90 000–110 000 Ft |

**Előnyök:** 4 × SFP+ (rugalmasabb uplink), Omada vezérlővel egységes WiFi+switch menedzsment lehetséges, széles SFP+ kompatibilitási lista, több éves gyártói garancia.  
**Hátrány:** Vendorlock-in az Omada ökoszisztémára, ha teljes SDN-t alkalmazol.

---

### 1.2 Enterprise / hosszabb életciklus, jobb szoftver

#### Ubiquiti UniFi USW-Pro-24
| Tulajdonság | Érték |
|---|---|
| Access portok | 24 × 1GbE RJ45 |
| Uplink portok | 2 × 10GbE SFP+ |
| Forma faktor | 1U rack |
| L2 funkciók | VLAN, RSTP, LACP, ACL, QoS, port isoláció |
| Menedzsment | UniFi Network Controller (helyi vagy Ubiquiti Cloud), REST API |
| Hűtés | Passzív (csendes!) |
| Tipikus ár (2025) | ~130 000–160 000 Ft |

**Előnyök:** Kiváló GUI, egységes menedzsment UniFi AP-kkal és routerekkel, passzív hűtés (irodai/iskolai közegbe ideális), aktívan fejlesztett szoftver.  
**Hátrány:** UniFi Controller kötelező (helyi vagy cloud), zárt ökoszisztéma; controllerrel való kötöttség.

---

## 2. 48 portos modelljavaslatok

Az alábbi modellek mindegyike: **48 × 1GbE RJ45** + legalább **2 × 10GbE SFP+** uplink, rack-kompatibilis (1U), L2 menedzselt, PoE nélkül.

### 2.1 SMB / jó ár-érték kategória

#### MikroTik CRS354-48G-4S+2Q+RM
| Tulajdonság | Érték |
|---|---|
| Access portok | 48 × 1GbE RJ45 |
| Uplink portok | 4 × 10GbE SFP+ + 2 × 40GbE QSFP+ |
| Forma faktor | 1U rack |
| L2 funkciók | VLAN, RSTP, LACP, ACL, QoS, IGMP Snooping |
| OS | RouterOS/SwOS (dual-boot) |
| Menedzsment | Web GUI, Winbox, SSH, SNMP |
| Hűtés | Ventilátor |
| Tipikus ár (2025) | ~130 000–160 000 Ft |

**Előnyök:** Nagyon bőséges uplink (4 × SFP+ + 2 × QSFP+), kiváló ár-érték, jövőálló.  
**Hátrány:** Nagyobb gép, RouterOS tanulási görbe.

---

#### TP-Link TL-SG3452X (JetStream)
| Tulajdonság | Érték |
|---|---|
| Access portok | 48 × 1GbE RJ45 |
| Uplink portok | 4 × 10GbE SFP+ |
| Forma faktor | 1U rack |
| L2 funkciók | VLAN, RSTP/MSTP, LACP, QoS, ACL, IGMP Snooping |
| Menedzsment | Web GUI, CLI, SNMP, Omada SDN (opcionális) |
| Hűtés | Ventilátor |
| Tipikus ár (2025) | ~140 000–175 000 Ft |

**Előnyök:** 4 × SFP+, Omada-integrálható, jó dokumentáció, széleskörű SFP+ kompatibilitás.  
**Hátrány:** Vendorlock Omada irányba.

---

### 2.2 Enterprise / hosszabb életciklus

#### Ubiquiti UniFi USW-Pro-48
| Tulajdonság | Érték |
|---|---|
| Access portok | 48 × 1GbE RJ45 |
| Uplink portok | 2 × 10GbE SFP+ |
| Forma faktor | 1U rack |
| L2 funkciók | VLAN, RSTP, LACP, ACL, QoS, port isoláció |
| Menedzsment | UniFi Network Controller, REST API |
| Hűtés | Ventilátor (halk) |
| Tipikus ár (2025) | ~200 000–240 000 Ft |

**Előnyök:** Egységes UniFi menedzsment (ha AP/gateway is UniFi), részletes forgalom-statisztika, RADIUS/802.1X támogatás.  
**Hátrány:** Controllerrel kötött, drágább, csak 2 × SFP+ uplink.

---

## 3. SFP+ transceiver és DAC választási útmutató

### 3.1 Optika (fiber) – elsődleges uplink médium

#### Multimode (MMF) – rövid/közepes távolságra

| Jelölés | Szabvány | Távolság (OM3/OM4 MMF) | Csatlakozó | Hullámhossz | Mikor használd |
|---|---|---|---|---|---|
| **10GBASE-SR** | IEEE 802.3ae | ~300 m (OM3) / ~400 m (OM4) | LC duplex | 850 nm | Géptermek, épületen belüli kábelfektetés, ahol OM3/OM4 kábel van |
| **10GBASE-LRM** | IEEE 802.3aq | ~220 m (OM1/OM2) | LC duplex | 1310 nm | Legacy multimode kábel; ritkán érdemes, SR jobb új projektben |

**Ajánlott:** Ha épületen belül vagy közel lévő gépterem között kötsz össze switcheket, és OM3 vagy OM4 kábeled van, válassz **10GBASE-SR** modult.

#### Singlemode (SMF) – hosszú távra

| Jelölés | Szabvány | Távolság (SMF) | Csatlakozó | Hullámhossz | Mikor használd |
|---|---|---|---|---|---|
| **10GBASE-LR** | IEEE 802.3ae | ~10 km | LC duplex | 1310 nm | Épületek között, campus hálózat, ha SMF kábel van fektetve |
| **10GBASE-ER** | IEEE 802.3ae | ~40 km | LC duplex | 1550 nm | Nagyon hosszú távolság; ritkán szükséges LAN-on |
| **10GBASE-ZR** | nem IEEE, gyártói | ~80 km | LC duplex | 1550 nm | Metro/WAN; nem szokásos LAN-on |

**Ajánlott:** Ha a két switchet optikán kell összekötni és a távolság > ~300 m (vagy SMF a kábel), **10GBASE-LR** a legjobb választás.

#### DDM / DOM (Digital Diagnostics Monitoring)
- Mindig kérj **DDM/DOM** támogatású modult: lehetővé teszi a hőmérséklet, optikai teljesítmény, tápfeszültség valós idejű monitorozását switch oldalon (SNMP, CLI).
- Olcsó, ismeretlen gyártójú modulok sokszor nem rendelkeznek DDM-mel.

#### Kompatibilitási kockázatok
- Az enterprise switch gyártók (Cisco, Juniper, HPE) jellemzően **vendorlock** transceiverre tesznek: nem „Cisco Original" modul esetén figyelmeztetést ad, esetleg nem aktiválja a portot.
- **MikroTik, TP-Link JetStream, Ubiquiti UniFi** ezzel szemben általában nyitott: harmadik fél (pl. FS.com, Mikrotik S+85DLC03D, Ubiquiti UF-MM-10G) modulokat is kezel, de **tesztelj egy db-t vásárlás előtt**, ha nem a gyártó saját modulját veszed.
- Ajánlott harmadik feles gyártók: **FS.com, 10Gtek, Fibertrade** – általában DDM-mel, megfelelő minőséggel.

---

### 3.2 Réz tartalék opciók

#### SFP+ DAC (Direct Attach Cable)
| Típus | Jellemző | Távolság | Hő / fogyasztás | Mikor jó |
|---|---|---|---|---|
| **Passzív DAC** | Egyszerű rézkábel, aktív elektronika nélkül | 1–3 m (tipikusan) | Alacsony (~0,5–1 W) | Switch-switch, switch-szerver közvetlen közelben (ugyanabban a rackben) |
| **Aktív DAC** | Aktív jelerősítő a csatlakozóban | 5–10 m | Közepes (~1–2 W / vég) | Ha a raktávolság megkívánja, de még nem érdemes optikát húzni |

**Fontos korlát:** A DAC szálak fizikailag közvetlen közelre korlátozódnak (max. ~10 m). Különálló helyszínek között **nem** alkalmas – ott optikát kell használni. A DAC tehát csak "tartalék" abban az értelemben, hogy ha valamelyik helyszínen belül szükség van rövid réz patch-re (pl. switch-szerver ugyanolyan rackben), ott helyettesítheti az optikát.

**Kompatibilitás:** MikroTik, TP-Link, Ubiquiti általában toleráns; mindig nézd meg a gyártó kompatibilitási listáját. Javasolt: saját gyártói DAC, vagy FS.com DAC (tesztelt kompatibilitással).

#### SFP+ 10GBASE-T (RJ45) modul
| Tulajdonság | Érték |
|---|---|
| Szabvány | 10GBASE-T (IEEE 802.3an) |
| Távolság | max. 30 m (Cat6A kábelel) |
| Hő / fogyasztás | **Magas (~2,5–4 W / modul)** |
| Ár | Drágább, mint az SR optika |
| Mikor érdemes | Ha meglévő Cat6A rézkábel van, és nem lehet optikát húzni |

**Figyelmeztetés:** Az SFP+ 10GBASE-T modulok jóval több hőt termelnek, mint az optikai modulok. Switchenként 2 ilyen modul számottevő extra hőterhelést jelent – figyelj a rack hűtésre. Használatuk inkább **átmeneti megoldás** legyen, nem végleges tervezett topológia.

---

## 4. Topológiai javaslat

### 4.1 Alaptopológia – access → core/aggregáció

```
                        [ Core / Aggregáció switch ]
                          (pl. 10G-s gerinchálózat)
                         /                          \
                10GbE SFP+ (fiber SR/LR)     10GbE SFP+ (fiber SR/LR)
               /                                           \
  [ 24p Access Switch ]                         [ 48p Access Switch ]
  (Helyszín A)                                  (Helyszín B)
  24× 1GbE → végpontok                         48× 1GbE → végpontok
```

- A két access switch **egymástól fizikailag különálló helyszínen** van.
- Mindkettő a core/aggregáció switchhez csatlakozik **10GbE SFP+ uplinken** (fiber, SR vagy LR a távolság alapján).
- Az access switchek egymással **közvetlenül nem feltétlenül kommunikálnak** – a forgalom a core-on keresztül megy.

### 4.2 Redundáns uplink – LACP (802.3ad)

Ha a switch rendelkezik **2 × SFP+** porttal (és mindkét uplink elérhető a core irányából), erősen ajánlott:

```
  [ Access Switch ]
     |          |
  SFP+ 1      SFP+ 2
     \          /
      \        /
    LACP Bond (802.3ad)
         |
  [ Core / Aggregáció switch ]
```

- **LACP (Link Aggregation Control Protocol)** összegyűjti a két 10G linket → **20 Gbps aggregált sávszélesség** (aktív/aktív) és **link-szintű redundancia**.
- Ha az egyik kábel/modul meghibásodik, a forgalom automatikusan a másik linkre kerül (failover).
- **Konfiguráció mindkét végpontan szükséges** (access switch és core switch oldalán is).
- MikroTik, TP-Link JetStream, Ubiquiti UniFi mind támogatja az LACP-t.

### 4.3 Uplink médium kiválasztása a távolság alapján

| Helyzet | Ajánlott médium |
|---|---|
| Switch és core ugyanabban a rackben / gépteremben | Passzív DAC vagy SR optika |
| Különböző helyiség, épületen belül, OM3/OM4 kábel | 10GBASE-SR multimode optika |
| Épületek között, SMF kábel, > 300 m | 10GBASE-LR singlemode optika |
| Ideiglenes réz megoldás, Cat6A, < 30 m | SFP+ 10GBASE-T modul (hőfigyeléssel) |

---

## 5. Beszerzési checklist

### Switch (mindkét helyszínre)

- [ ] Meghatározott uplink port szám: legalább **2 × 10GbE SFP+** (4 × SFP+ előnyösebb, ha LACP is kell)
- [ ] Access port szám: **24** (Helyszín A) / **48** (Helyszín B) × 1GbE RJ45
- [ ] Rack-kompatibilis (1U, tartalmaz rack füleket / rack-kit-et)
- [ ] L2 menedzselhető: VLAN 802.1Q, RSTP/MSTP, LACP 802.3ad
- [ ] PoE **nem szükséges** (PoE nélküli modell olcsóbb és kevésbé melegszik)
- [ ] Gyártói garancia (min. 2 év, ideálisan 5 év vagy lifetime hardware warranty)
- [ ] Gyártói firmware-frissítés elérhetősége (aktívan támogatott modell)
- [ ] Szükséges menedzsment módok: Web GUI, SSH/CLI, SNMP v2/v3
- [ ] Hűtés: ha zajos környezet (pl. szerverzaj) elfogadható → ventilátor; ha csendes irodai → passzív vagy halk ventilátoros modell

### SFP+ transceiver modulok

- [ ] Meghatározott fiber típus a helyszínek között: **multimode (OM3/OM4)** vagy **singlemode (SMF)**
- [ ] A távolság alapján megfelelő szabvány: **10GBASE-SR** (MMF, < 400 m) vagy **10GBASE-LR** (SMF, < 10 km)
- [ ] **DDM/DOM** támogatás a modulban (monitorozhatóság)
- [ ] LC duplex csatlakozó kompatibilitás a kábel végeivel
- [ ] Kompatibilitás a kiszemelt switch modellel: saját gyártói modul, vagy tesztelt harmadik fél (FS.com, 10Gtek)
- [ ] Redundáns uplink esetén: **min. 2 pár transceiver** (egy-egy mindkét végpontra) per link
- [ ] Tartalék/réz opció: néhány **SFP+ passzív DAC** (1–3 m) rack-en belüli összekötéshez, vagy szükség esetén **SFP+ 10GBASE-T modul** (hőgenerálás figyelembevételével)

### Fizikai / infrastruktúra

- [ ] Rack szabad hely (1U per switch): ellenőrizd az aktuális rack kapacitást mindkét helyszínen
- [ ] Fiber patch kábel: megfelelő hossz, MMF/SMF típus, LC-LC kéteres patch, polarity ellenőrzés
- [ ] Áramellátás: 230V/IEC C13 – rack PDU vagy UPS biztosított mindkét helyszínen
- [ ] Hálózati dokumentáció: IP management VLAN, SNMP community/v3 jelszavak, VLAN ID-k előre megtervezve
- [ ] Konfiguráció backup terv: switch config mentés (TFTP, SCP vagy gyártói eszköz)
- [ ] SLA / support: van-e szükség on-site szervizre, vagy NBD csere elegendő?

---

*Dokumentum utoljára frissítve: 2026-04-14*
