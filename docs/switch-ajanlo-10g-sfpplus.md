# Switch és optikai hálózat ajánló – 10G SFP+, 100 m uplink

> **Kontextus:** Két helyszín között ~100 m uplink, jelenleg CAT6 réz, mellé optikát kell behúzni.  
> Switch-ek: 24 portos és 48 portos, managed, rack, non-PoE, L2, 2×10G SFP+ uplink, új eszközök.

---

## 1. Uplink technológia – réz vs. optika 100 m-en

### 1.1 10GBASE-T (CAT6 réz) – határeset 100 m-en

A 10GBASE-T szabvány elméletileg CAT6A-ig és **100 m-en** teljes sebességgel működik, de **CAT6 (nem augmented)** esetén a helyzet árnyaltabb:

| Szempont | CAT6 + 10GBASE-T |
|---|---|
| Max. certifikált távolság | **55 m** (10GBASE-T, CAT6) |
| 100 m esetén | Függ a kábel minőségétől, zajtól, hőmérséklettől |
| Alien crosstalk (AXT) | Kritikus probléma kötegelt futásnál |
| Meglévő réz megbízhatósága | Nem garantált 10G-on |

**Fontos:** 100 m-en CAT6 + 10GBASE-T elvileg „működhet", de **nem certifikált konfiguráció** – különösen ha a kábel kötegben fut, régebbi vagy nem szimmetrikusan tesztelt. Környezetfüggő hibákat, link instabilitást okozhat.

**SFP+ RJ45 modulok problémái:**
- Fogyasztás: **2,5–3 W/modul** (optikai SR modul: ~0,8–1 W)
- Hőtermelés: A switchek SFP+ kártyái melegednek, ventilátor zajt növel
- Kompatibilitás: Nem minden switch fogad be minden gyártó RJ45 SFP+ modulját
- Ár: A jó minőségű RJ45 SFP+ modul (pl. Finisar, Cisco, HPE) drágább, mint egy SR optikai modul

**Következtetés:** A CAT6 + 10GBASE-T RJ45 SFP+ kombináció **ne legyen a végleges megoldás** – legyen csak **ideiglenes backup** amíg az optika nem kész.

---

### 1.2 Multimode optika – OM3/OM4 + 10G SR modulok

| Jellemző | OM3 | OM4 |
|---|---|---|
| Hullámhossz | 850 nm (VCSEL lézer) | 850 nm (VCSEL lézer) |
| 10GBASE-SR hatótáv | **300 m** | **400 m** |
| Tipikus kábel szín | Aqua/türkiz | Aqua/türkiz (lila is előfordul) |
| Kábel ár/m | ~200–350 Ft/m (outdoor) | ~250–450 Ft/m (outdoor) |
| SFP+ SR modul ár (párban) | **~4 000–12 000 Ft/db** | ugyanaz |
| Összekötő típus | LC duplex | LC duplex |

**Előnyök 100 m-en:**
- Bőséges tartalék a hatótávban (300 m / 400 m >> 100 m)
- Olcsóbb SFP+ modulok, mint LR
- Kisebb fogyasztás (~0,8–1 W/modul)
- A 850 nm-es VCSEL lézer biztonságos, olcsó, megbízható

**Hátrányok:**
- Ha egyszer kibővítik a hálózatot és 300–400 m-nél hosszabb link kellene, nem lesz elegendő (OS2 viszont igen)
- Multimode szálat nem lehet összekötni singlemode-dal adapter nélkül

---

### 1.3 Singlemode optika – OS2 + 10G LR modulok

| Jellemző | OS2 singlemode |
|---|---|
| Hullámhossz | 1310 nm (Fabry-Perot / DFB lézer) |
| 10GBASE-LR hatótáv | **10 km** |
| Kábel ár/m | ~200–400 Ft/m (outdoor) – hasonló az OM4-hez |
| SFP+ LR modul ár (párban) | **~8 000–25 000 Ft/db** – drágább, mint SR |
| Összekötő típus | LC duplex |

**Előnyök:**
- Elméletileg jövőbiztos: ha hosszabb link kell, nincs kábelcsere
- Alacsony attenuáció, kiváló jelminőség

**Hátrányok 100 m-en:**
- Az LR modul **drágább**, mint SR (kb. 2–3× árkülönbség)
- 100 m-en az LR modul **optikai teljesítménye (optikai power) esetleg túl magas** – a vevőoldal saturálódhat; ilyenkor attenuátorra lehet szükség (extra alkatrész, extra hibalehetőség)
- A 100 m távolságra **nincs praktikus előnye** az OS2-nek az OM4-hez képest

---

### 1.4 Melyiket válasszuk? – Javaslat

> **Új behúzásnál 100 m-en: OM4 multimode + 10GBASE-SR SFP+ modulok. Ez a racionális választás.**

| Szempont | OM4 + SR | OS2 + LR |
|---|---|---|
| Ár (kábel + modul) | ✅ Olcsóbb | ❌ Drágább |
| 100 m-en teljesítmény | ✅ Tökéletes | ✅ Tökéletes (de over-engineered) |
| Fogyasztás/hő | ✅ Alacsony | ✅ Alacsony |
| Jövőbiztosság 100–400 m-ig | ✅ Elegendő | ✅ 10 km-ig |
| Saturáció kockázata | ✅ Nincs | ❌ Lehetséges, attenuátor kell |
| Komplexitás | ✅ Egyszerű | ➡ Kicsit összetettebb |

**Ha biztosan nem lesz 400 m-nél hosszabb link a jövőben:** OM4 + SR a nyerő.  
**Ha egyszer lesz campusbővítés, épületek közötti link 400 m+:** akkor érdemes OS2-t behúzni, de modul olcsóbban cserélhető, kábelt nehezebb utólag.

---

## 2. Elsődleges/backup stratégia

```
OPTIKA (OM4 + SR) → PRIMARY, végleges uplink
CAT6 réz (RJ45 SFP+ vagy natív RJ45) → BACKUP/TRANSITION, csak ideiglenesen
```

- Az optikát helyezd üzembe **elsőként**, és teszteld
- A meglévő CAT6-ot hagyd bekötve a switchbe **backup portként** (ha a switch engedi: link aggregation fallback, vagy manuálisan átkapcsolható)
- Ha az optika stabil és certifikált, a réz maradhat passzív tartalékként – de **ne terheld rendszeresen**

---

## 3. Bevásárlólista – optikai 10G link, 100 m, új behúzás

### 3.1 Optikai kábel

| Tétel | Leírás | Mennyiség |
|---|---|---|
| **OM4 outdoor/indoor kábel** | 2×LC vagy 4 szál (duplex), LSZH (beltéri) vagy PE (kültéri) köpeny, aqua | **4 szál / 100 m + 10% tartalék → ~110–120 m** |

**2 szál vs. 4 szál:**
- 10G duplex optika **2 szálat** használ (TX + RX)
- Ajánlott **4 szál** behúzni: 2 aktív + 2 tartalék
- Ha valamelyik szál sérül, azonnal van csere – nem kell újra húzni
- Az ár különbség minimális (kábel + munka amortizálva)

**Kábeltípus pontosítása:**
- Épületek között, kültéri szakasz van → **outdoor HDPE/PE köpeny**, rodent-protected (rágásálló acélköpeny opcionálisan)
- Teljes beltéri futás → **LSZH (Low Smoke Zero Halogen)** köpeny, tűzbiztonság miatt

### 3.2 Patch panel / keystone

| Tétel | Leírás | Mennyiség |
|---|---|---|
| **LC duplex patch panel** | 1U vagy 2U, 12/24 portos, SC/LC | 1 db mindkét helyszínen |
| **LC-APC pigtail** (fusion splice) | Ha a kábel nem pre-connectorized | 4 db / helyszín |

**Alternatíva:** Pre-connectorized kábel (gyári LC véggel) – drágább, de nem kell fusion splicing.

### 3.3 LC-LC patch kábelek

| Tétel | Leírás | Mennyiség |
|---|---|---|
| **OM4 LC-LC duplex patch kábel** | 1–3 m, aqua, mindkét helyszínre (patch paneltől switchig) | 2 db / helyszín (összesen 4 db) |

- Mindig **gyártói certifikált patch kábelt** vegyél (ne DIY)
- Ellenőrizd: LC duplex – duplex, UPC polishing (nem APC, mivel 850 nm SR-nél APC felesleges)

### 3.4 SFP+ transceiver modulok

| Tétel | Leírás | Mennyiség |
|---|---|---|
| **10GBASE-SR SFP+ modul** | OM3/OM4 kompatibilis, 850 nm, LC duplex, DDM (Digital Diagnostics) | **2 pár (4 db összesen)** – 1 pár aktív + 1 pár tartalék |

**Modulválasztás szempontjai:**
- Switch-kompatibilitás: Ellenőrizd a switch kompatibilitási listáját (OEM vs. 3rd party)
- DDM (Digital Diagnostics Monitoring): Hőmérséklet, optikai teljesítmény, feszültség monitorozható
- Ajánlott gyártók: Finisar/II-VI, Cisco (OEM), FS.com (harmadik féltől), Ubiquiti (saját switchhez)
- **Kerüld:** ismeretlen gyártmányú, nagyon olcsó, DDM nélküli modulokat

**Megjegyzés:** Ha a switch gyártója csak saját modulokat fogad be (pl. Cisco CBS önmagában): vegyél kompatibilis, tesztelt 3rd party modult vagy gyári modult.

### 3.5 Mérés és tanúsítás

| Tétel | Leírás | Megjegyzés |
|---|---|---|
| **OTDR mérés** | Optikai reflektometria – törések, fröccsök, tükörreflexiók kimutatása | Behúzás után kötelező |
| **Insertion loss mérés** | Összesített csillapítás (dB) mérése, tanúsítványos | Certifikált mérőfelszerelés kell |
| **Tanúsítvány** | Mérési protokoll, minden szálhoz | Archivált dokumentáció |

**Mérési határértékek (10GBASE-SR, OM4):**
- Max. insertion loss link budget: **2,6 dB** (teljes link)
- Ha a mérés ezt alulteljesíti: garantált a 10G összeköttetés

> **Ha nem rendelkeztek mérőeszközzel:** Kérjetek be mérési-tanúsítási szolgáltatást a szerelőtől, vagy béreltek OTDR-t. Tanúsítvány nélkül garanciális vita esetén nincs bizonyíték.

---

## 4. Switch ajánló – 24 és 48 portos modellek

**Feltételek:** Managed, rack, non-PoE, L2, min. 2×10G SFP+ uplink, új eszköz.

---

### 4.1 Belépő szint (~50 000 – 100 000 Ft)

#### 24 portos
| Modell | Portok | SFP+ | Megjegyzés |
|---|---|---|---|
| **TP-Link TL-SG3428X** | 24×1GbE | 4×10G SFP+ | Jó alapfelszereltség, webGUI + CLI, L2+ |
| **Zyxel GS1920-24HP** helyett → **XGS1210-12** | – | – | Zyxel 10G belépő inkább 2,5G; SFP+-hoz XGS1930 |
| **MikroTik CRS326-24G-2S+RM** | 24×1GbE | 2×10G SFP+ | SwOS + RouterOS, nagyon rugalmas, olcsó; CLI-t igényel |

#### 48 portos
| Modell | Portok | SFP+ | Megjegyzés |
|---|---|---|---|
| **TP-Link TL-SG3452X** | 48×1GbE | 4×10G SFP+ | A TL-SG3428X nagytestvére |
| **MikroTik CRS354-48G-4S+2Q+RM** | 48×1GbE | 4×10G SFP+ + 2×40G QSFP+ | Igen sok port és uplink, extrém ár/érték |

---

### 4.2 Középkategória (~100 000 – 200 000 Ft)

#### 24 portos
| Modell | Portok | SFP+ | Megjegyzés |
|---|---|---|---|
| **Zyxel XGS1930-28** | 24×1GbE | 4×10G SFP+ | Jó GUI, auto-topo, VLAN, könnyű üzemeltetés |
| **Netgear GS724TPv2** (nem PoE ver.) → **GS728TX** | 24×1GbE | 4×10G SFP+ | Smart managed, egyszerű webes felület |
| **Ubiquiti USW-Pro-24** | 24×1GbE | 2×10G SFP+ | UniFi ökoszisztéma, szép dashboard; 2 db SFP+ |

#### 48 portos
| Modell | Portok | SFP+ | Megjegyzés |
|---|---|---|---|
| **Zyxel XGS1930-52** | 48×1GbE | 4×10G SFP+ | XGS1930-28 nagytestvére |
| **Netgear GS748T / GS752TX** | 48×1GbE | 4×10G SFP+ | Bevált, megbízható SMB switch |
| **Ubiquiti USW-Pro-48** | 48×1GbE | 2×10G SFP+ | UniFi, központi menedzsment; 2 db SFP+ |

---

### 4.3 Magasabb kategória / enterprise-közel (~200 000 – 400 000 Ft+)

#### 24 portos
| Modell | Portok | SFP+ | Megjegyzés |
|---|---|---|---|
| **Cisco CBS350-24T-4X** | 24×1GbE | 4×10G SFP+ | Cisco minőség, hosszú életciklus, L2+ |
| **HPE Aruba 1930 24G 4SFP+** (JL680A) | 24×1GbE | 4×10G SFP+ | Aruba Central kezelhető, jó firmware |
| **Juniper EX2300-24T** | 24×1GbE | 4×10G SFP+ | Junos, valódi enterprise; csillogóbb ár |

#### 48 portos
| Modell | Portok | SFP+ | Megjegyzés |
|---|---|---|---|
| **Cisco CBS350-48T-4X** | 48×1GbE | 4×10G SFP+ | Cisco SMB sor, könnyen kezelhető GUI |
| **HPE Aruba 1930 48G 4SFP+** (JL682A) | 48×1GbE | 4×10G SFP+ | HPE minőség, arányos ár |
| **Juniper EX2300-48T** | 48×1GbE | 4×10G SFP+ | Enterprise, Junos CLI + webGUI |

---

### 4.4 Rövid összehasonlítás – melyik kategóriába mi illik

| Kategória | Ajánlott, ha… |
|---|---|
| **Belépő (MikroTik, TP-Link)** | Ár a döntő, van hálózathoz értő ember a karbantartáshoz |
| **Közép (Zyxel, Ubiquiti, Netgear)** | Egyszerűbb üzemeltetés kell, GUI-barát; jó ár/érték arány |
| **Enterprise (Cisco, HPE, Juniper)** | Hosszú (5–10 év+) életciklus, garancia, professzionális szupport kell |

---

## 5. Összefoglaló ajánlás

```
Helyszín A <----100 m OM4 (4 szál)----> Helyszín B
Switch A: SFP+ slot 1 (SR modul)         Switch B: SFP+ slot 1 (SR modul)
Switch A: SFP+ slot 2 (RJ45 backup)      Switch B: SFP+ slot 2 (RJ45 backup)
```

1. **Optika PRIMARY:** OM4, 4 szál, LC konnektorok, 10GBASE-SR SFP+ modulok  
2. **Réz BACKUP (ideiglenes):** CAT6 + RJ45 SFP+ modul (vagy natív 10GBASE-T port ha van); stabil link esetén eltávolítható  
3. **Switch:** TP-Link / Zyxel ha ár fontos; Cisco / HPE ha hosszú élettartam és szupport az elvárás  
4. **Mérés:** OTDR + insertion loss tanúsítvány behúzás után – ne kerüljük meg!

---

*Dokumentum utolsó frissítése: 2026-04-14*
