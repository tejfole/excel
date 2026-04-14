# Hálózati switch ajánló – 24–48 × 1GbE RJ45 + SFP bővítőhely

> **Kontextus:** A felhasználó 24–48 darab gigabites RJ45-portot és legalább néhány SFP/SFP+ uplink/bővítőhelyet igénylő switch-et keres.

---

## 1. Döntési szempontok

| Szempont | Mit jelent? | Mikor fontos? |
|---|---|---|
| **Managed vs. Unmanaged** | Managed: VLAN, QoS, port-mirroring, SNMP, webes GUI / CLI. Unmanaged: plug-and-play, nincs konfiguráció. | Ha kell VLAN, forgalomszabályozás, monitoring → managed |
| **PoE / PoE+** | 802.3af (15,4 W/port) vagy 802.3at PoE+ (30 W/port). Kell IP kamerákhoz, VoIP-hoz, WiFi AP-hoz. | Ha hálózati eszközöket táplál a switch |
| **SFP vs. SFP+** | SFP = 1 Gbps uplink; SFP+ = 10 Gbps uplink. | Ha a core switch / NAS / szerver 10G képes, érdemes SFP+ |
| **L2 vs. L3** | L2: csak switching (VLAN, STP, RSTP). L3: routing képesség (statikus route, OSPF, RIP) a switch-en belül. | Multi-VLAN routing nélküli esetben elég L2 |
| **Stacking** | Több switch fizikailag egyként kezelhető, közös felügyelet, magasabb rendelkezésre állás. | Nagyobb, skálázódó környezetben |
| **Zaj / hűtés** | Rack-eszközök ventillátorral zajosak lehetnek. Desktop/fanless modellek csendesebbek. | Irodai, nyitott térben kritikus |
| **Rack vs. Desktop** | 1U rack: standard adatközponti formátum. Desktop: kisebb irodákhoz, nincs rack. | Rack szekrény megléte szerint |
| **Gyártói garancia / support** | Cisco: Lifetime Limited Warranty (egyes modellek). TP-Link / Netgear: 2–5 év. | Vállalati SLA-igény esetén fontos |

---

## 2. Modelljavaslatok árkategóriánként

### 🟢 Budget (< 150–300 EUR) – kis iroda, otthoni labor

#### TP-Link TL-SG3428X (28-port, L2+)
- **Portok:** 24 × 1GbE RJ45 + 4 × SFP+ (10G)
- **Managed:** igen (web GUI, CLI, SNMP)
- **PoE:** nincs (külön PoE verziók: TL-SG3428XMP)
- **Stacking:** nincs
- **Ár:** ~130–160 EUR
- **Mikor jó:** kis irodai VLAN-kezelés, 10G uplink kell, PoE nem kell

#### TP-Link TL-SG3452X (52-port, L2+)
- **Portok:** 48 × 1GbE RJ45 + 4 × SFP+ (10G)
- **Managed:** igen
- **PoE:** nincs (PoE verzió: TL-SG3452XP, 768 W PoE budget)
- **Stacking:** nincs
- **Ár:** ~220–280 EUR
- **Mikor jó:** 48 port kell, 10G uplink, budget-barát

#### Netgear GS724Tv4 (24-port, L2)
- **Portok:** 24 × 1GbE RJ45 + 2 × SFP (1G)
- **Managed:** igen (Smart Managed Plus)
- **PoE:** nincs
- **Stacking:** nincs
- **Ár:** ~100–130 EUR
- **Mikor jó:** egyszerű VLAN-kezelés, alacsony budget, 1G uplink elég

---

### 🟡 SMB / középkategória (300–800 EUR)

#### Cisco CBS350-24T-4G (28-port, L2/L3)
- **Portok:** 24 × 1GbE RJ45 + 4 × SFP (1G)
- **Managed:** igen (webes GUI, CLI, SNMP, RMON)
- **PoE:** nincs (PoE verzió: CBS350-24P-4G, 195 W)
- **Stacking:** nem (CBS350-hez nincs natív stacking)
- **L3 képesség:** statikus routing, VLAN routing
- **Ár:** ~300–400 EUR
- **Mikor jó:** Cisco-preferencia, megbízhatóság, L3 routing kell

#### Cisco CBS350-48T-4G (52-port, L2/L3)
- **Portok:** 48 × 1GbE RJ45 + 4 × SFP (1G)
- **Managed:** igen
- **PoE:** nincs (PoE verziók: CBS350-48P-4G 370 W, CBS350-48FP-4G 740 W)
- **Ár:** ~450–550 EUR
- **Mikor jó:** 48 port + Cisco megbízhatóság, L3, mérsékelt budget

#### Ubiquiti UniFi USW-48 (52-port, L2)
- **Portok:** 48 × 1GbE RJ45 + 4 × SFP (1G)
- **Managed:** igen (UniFi Controller / Cloud Key szükséges)
- **PoE:** nincs (PoE verzió: USW-48-POE, 195 W)
- **Stacking:** virtuális (UniFi Controller egységes UI)
- **Ár:** ~350–450 EUR
- **Mikor jó:** már meglévő UniFi ökoszisztéma, egységes dashboard

---

### 🔴 Enterprise (> 800 EUR)

#### Cisco CBS220-48T-4X (52-port, L2, Smart)
> *Megjegyzés: ha igazán enterprise kell, a Catalyst 1000 vagy 9000-es sorozat jön szóba.*

#### Cisco Catalyst 1000-48T-4G-L (52-port, L2)
- **Portok:** 48 × 1GbE RJ45 + 4 × SFP (1G)
- **Managed:** igen (IOS, full CLI, SNMP, NetFlow lite)
- **PoE:** nincs (PoE verzió: C1000-48P-4G-L, 370 W; C1000-48FP-4G-L, 740 W)
- **Stacking:** nincs (Catalyst 9000-es sorozatban van)
- **Ár:** ~700–1000 EUR
- **Mikor jó:** enterprise Cisco-környezet, full IOS, hosszú support lifecycle

#### HPE Aruba 2530-48G-PoE+ J9772A (52-port, L2)
- **Portok:** 48 × 1GbE RJ45 PoE+ + 4 × SFP (1G)
- **Managed:** igen (web GUI, CLI, SNMP)
- **PoE:** igen, 382 W total budget
- **Stacking:** igen (Intelligent Resilient Framework – IRF)
- **Ár:** ~600–900 EUR (refurb piacon olcsóbban)
- **Mikor jó:** PoE + stacking kell, Aruba/HPE ökoszisztéma

---

## 3. Gyors összehasonlító táblázat

| Modell | Portok (RJ45) | SFP | SFP+ | PoE | L3 | Stacking | ~Ár (EUR) |
|---|---|---|---|---|---|---|---|
| TP-Link TL-SG3428X | 24 | – | 4× 10G | – | – | – | 130–160 |
| TP-Link TL-SG3452X | 48 | – | 4× 10G | – | – | – | 220–280 |
| Netgear GS724Tv4 | 24 | 2× 1G | – | – | – | – | 100–130 |
| Cisco CBS350-24T-4G | 24 | 4× 1G | – | opcionális | ✓ | – | 300–400 |
| Cisco CBS350-48T-4G | 48 | 4× 1G | – | opcionális | ✓ | – | 450–550 |
| Ubiquiti USW-48 | 48 | 4× 1G | – | opcionális | – | virtuális | 350–450 |
| Cisco Catalyst 1000-48T | 48 | 4× 1G | – | opcionális | – | – | 700–1000 |
| HPE Aruba 2530-48G-PoE+ | 48 | 4× 1G | – | ✓ 382 W | – | ✓ IRF | 600–900 |

---

## 4. Kérdések a pontos igényfelméréshez

A legjobb ajánláshoz az alábbi kérdések megválaszolása szükséges:

1. **PoE kell-e?** IP kamerák, VoIP telefonok, WiFi AP-ok vannak a hálózaton?
   - Ha igen: hány port, és mekkora PoE budget (W) kell összesen?

2. **10G SFP+ uplink kell-e?** Van 10G-s szerver, NAS, core switch a hálózaton?
   - Ha nem, elég a 4× 1G SFP.

3. **VLAN / L3 routing kell-e?** Több alhálózat van/lesz, amelyek között routing kell?

4. **Rack szekrény van?** 1U rack-es forma kell, vagy elég egy desktop switch?

5. **Zaj-érzékeny hely?** (iroda, tanterem, tárgyaló) → fanless / csendes modell jöhet szóba.

6. **Stacking igény?** Egynél több switch lesz, és egységes kezelés kell?

7. **Gyártói preferencia / meglévő ökoszisztéma?** (Cisco, Ubiquiti/UniFi, HPE Aruba, TP-Link, Netgear)

8. **Budget (nettó)?** Kb. milyen árkategória reális (< 200 EUR / 200–500 EUR / 500 EUR+)?

9. **Garancia / support SLA?** Kell-e NBD (Next Business Day) csere vagy elegendő a standard gyártói garancia?

---

> **Megjegyzés:** Az árak tájékoztató jellegűek (2024–2025-ös EUR-árak, forgalmazótól és régiótól függően változhatnak). Refurbished (felújított) piacon a Cisco és HPE modellek 30–50%-kal olcsóbbak lehetnek.
