# Switch ajánló – 24/48×1GbE, L2, rack, 2×10G SFP+ uplink (PoE nélkül)

> **Kontextus:** épületen belüli hálózatbővítés, ~100 m-es 10G uplink, rack szekrénybe kerülő, menedzselhető L2 switchek.  
> Frissítve: 2026-04

---

## 1. Ajánlott switchek

Az alábbi modellek **újonnan beszerezhetők**, rackes kivitelűek, legalább **2×10G SFP+ uplink** porttal rendelkeznek, PoE nélküliek, és teljes L2 menedzsmentet (VLAN, RSTP, LACP, ACL, SNMP) kínálnak.

### 24 portos (24×1GbE RJ45 + 2–4×10G SFP+)

| Gyártó / Modell | Access portok | 10G SFP+ | Megjegyzés |
|---|---|---|---|
| **MikroTik CRS326-24G-2S+RM** | 24×1GbE | 2×SFP+ | Olcsó, SwOS/RouterOS, fanless opció |
| **TP-Link JetStream TL-SG3428X** | 24×1GbE | 4×SFP+ | Jó ár-érték, Omada menedzsment |
| **Ubiquiti USW-Pro-24** | 24×1GbE | 2×SFP+ | UniFi ökoszisztéma, letisztult UI |
| **Cisco Business CBS350-24T-4X** | 24×1GbE | 4×SFP+ | Vállalati szintű L2+/L3-lite, jó garancia |
| **Netgear M4250-26G4XF** | 24×1GbE | 4×SFP+ | AV over IP / SMB enterprise, csendes |

### 48 portos (48×1GbE RJ45 + 2–4×10G SFP+)

| Gyártó / Modell | Access portok | 10G SFP+ | Megjegyzés |
|---|---|---|---|
| **MikroTik CRS354-48G-4S+2Q+RM** | 48×1GbE | 4×SFP+ + 2×QSFP+ | Nagy kapacitás, olcsó |
| **TP-Link JetStream TL-SG3452X** | 48×1GbE | 4×SFP+ | Omada, megbízható, elérhető ár |
| **Ubiquiti USW-Pro-48** | 48×1GbE | 2×SFP+ | UniFi, kompakt, menedzselt |
| **Cisco Business CBS350-48T-4X** | 48×1GbE | 4×SFP+ | Hosszú termékciklus, stabil FW |
| **Netgear M4350-36x4C** | 48×1GbE | 4×SFP+ | Enterprise, részletes QoS |

> **Tipp:** Ha MikroTik-ot választasz, a **SwOS** az egyszerűbb L2 menedzsmenthez bőven elég; a RouterOS teljesebb kontrollt ad, de konfigurációs ismeretet igényel.

---

## 2. Optikai uplink (~100 m, épületen belül, 10G)

### 2.1 Ajánlott: OM4 multimode + 10G SR SFP+ (LC)

Az épületen belüli ~100 m-es 10G uplinkhez **OM4 multimode optika + 10GBASE-SR SFP+ modulok** a legjobb ár-érték arányú megoldás:

- **OM4 multimode szálkábel** (LC végzésű vagy pigtail + patch panel): névleges hatótáv 10GBASE-SR-rel **400 m**, tehát 100 m-en bőséges tartalék.
- **10GBASE-SR SFP+ modulok** (850 nm, LC, mindkét oldalra): széles körben elérhető, olcsó, kompatibilis minden nagyobb gyártóval (Cisco, TP-Link, Ubiquiti, MikroTik stb.). Érdemes **generic/MSA kompatibilis** modult venni, ha a switch firmware megengedi.
- **OM3** is elegendő 100 m-en (hatótáv OM3+SR: 300 m), de ha most húzunk be kábelt, OM4 az ésszerű választás hosszabb élettartam és tartalék miatt.

**Összefoglalva:**  
`OM4 LC-LC trunk (4–8 szál) + 10GBASE-SR SFP+ modulpár = 10G uplink 100 m-en, megbízhatóan`

### 2.2 Alternatíva: OS2 singlemode + 10G LR SFP+ – jövőállóbb, de most nem szükséges

- **OS2 singlemode** kábel + **10GBASE-LR SFP+** (1310 nm, hatótáv 10 km): drágább modul, de az infrastruktúra évtizedekig marad, és később magasabb sebesség (pl. 25G/100G) vagy nagyobb távolság esetén sem kell újrakábelezni.
- **Ha most döntünk:** OM4+SR is teljesen megfelel 100 m-en, az OS2+LR inkább akkor éri meg, ha már most tudni, hogy a gerinc 25G+ lesz, vagy több épületet is össze kell majd kötni.

---

## 3. Réz tartalék – CAT6 és 10GBASE-T

### CAT6 maradjon 1G backupnak

A meglévő **CAT6 infrastruktúra** ajánlott szerepe:
- **1 Gbps vészhelyzeti/backup link** – ha az optika meghibásodik, rövid ideig 1G rézen lehet fenntartani a kapcsolatot.
- Nem szükséges eltávolítani; érdemes megtartani és dokumentálni.

### 10GBASE-T rézen (100 m) – miért óvakodjunk tőle uplinkként

| Szempont | Részlet |
|---|---|
| **Szabvány hatótáv** | 10GBASE-T: max. 100 m Cat6A-n; Cat6-on általában csak 55 m garantált 10G-n |
| **Zaj / áthallás** | Sűrű rack környezetben érzékenyebb, kábelfegyelmet igényel |
| **SFP+ RJ45 modul hő/fogyasztás** | Egy 10GBASE-T SFP+ modul tipikusan **3–5 W** (vs. SR: ~1 W); melegszik, feszültséget tesz a switch portjára |
| **Javaslat** | Ha mindenképpen réz kell 10G-hoz: Cat6A újrafektetés + 10GBASE-T modul; de elsődleges uplinkként az optika megbízhatóbb és gazdaságosabb |

---

## 4. Beszerzési checklist

Az alábbi lista segít, hogy ne maradjon ki semmi a kivitelezés előtt:

### Kábelezés
- [ ] **Optikai trunk kábel** – OM4 multimode, LC végzésű vagy pigtail; **minimum 4 szál** (2 aktív + 2 tartalék), ajánlott **8 szál** (tartalék szálak aranyat érnek)
- [ ] **LC-LC patch kábelek** (OM4, duplex) – rackben, mindkét oldalon (switch ↔ patch panel)
- [ ] **CAT6 réz patch kábelek** – backup link(ek)hez, ha szükséges

### Passzív elemek
- [ ] **Optikai patch panel vagy kazetta** (LC, mindkét végre) – rendezett rackbe szereléshez
- [ ] **Pigtail szett** (ha helyszínen kell fúziós hegesztéssel befejezni a kábelt)
- [ ] **Kábelcímkék / dokumentáció sablon** – minden szál azonosítása

### Aktív elemek
- [ ] **10GBASE-SR SFP+ modul** – **páronként** (mindkét switch/végpont oldalra), gyártó-kompatibilis vagy MSA generic
- [ ] **Switch(ek)** – 24 vagy 48 portos, a fenti táblázatból

### Mérés és átadás
- [ ] **Optikai mérés (OTDR vagy insertion loss)** – kivitelezés után kötelező; jegyőkönyv legyen minden szálról
- [ ] **Link-teszt** (10G-n valós adatátvitellel, pl. `iperf3`) – hogy éles üzem előtt biztosan stabil legyen
- [ ] **Dokumentáció frissítése** – hálózati térkép, szálszám, végpontok, patchelési táblázat

---

## 5. Rövid összefoglalás

| Kérdés | Ajánlás |
|---|---|
| 24 vs. 48 port | Igény szerint; érdemes eggyel nagyobbat venni, mint a jelenlegi portszükséglet |
| Gyártó | MikroTik (budget), TP-Link Omada (SMB), Ubiquiti UniFi (ha már UniFi van), Cisco CBS (enterprise SLA) |
| 10G uplink optika | **OM4 + 10GBASE-SR SFP+ (LC)** – 100 m-re tökéletes, egyszerű, olcsó |
| Jövőállóság | OS2+LR modul ha később >100 m vagy 25G+ is szóba jön; most nem szükséges |
| Réz backup | CAT6 maradhat 1G vészhelyzeti linknek; 10GBASE-T 100 m-en körülményes, mellőzhető |
| Mérés | OTDR/insertion loss mérés + 10G iperf teszt, átadáskor mindenképpen |
