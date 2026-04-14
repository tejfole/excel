# Switch ajánló – menedzselhető, rack, 10G SFP+ uplink (PoE nélkül)

> **Igény összefoglalása:**  
> - 24 portos **és** 48 portos kivitel  
> - Menedzselhető (managed), rack-be szerelhető (1U)  
> - PoE **nem kell**  
> - Legalább **2 db 10G SFP+** uplink port  
> - L2 funkciók elegendők  
> - Nincs gyártói preferencia; korábbi eszközök: **Linksys**

---

## Tartalomjegyzék

1. [SMB / budget kategória](#1-smb--budget-kategória)
2. [Jobb / enterprise-ebb kategória](#2-jobb--enterprise-ebb-kategória)
3. [Cisco Business – Linksys-rokon vonal](#3-cisco-business--linksys-rokon-vonal)
4. [Döntési szempontok](#4-döntési-szempontok)
5. [Javasolt alap topológia](#5-javasolt-alap-topológia)
6. [Beszerzési checklist](#6-beszerzési-checklist)

---

## 1. SMB / budget kategória

### 24 portos

| Modell | Portok | 10G SFP+ | Menedzsment | Megjegyzés |
|---|---|---|---|---|
| **TP-Link TL-SG3428XMP** (non-PoE testvér: **TL-SG3428X**) | 24×1GbE | 4×SFP+ | Web + CLI (Omada) | Olcsó, stabil, Omada szoftverből kezelhető |
| **Zyxel XGS1930-28** | 24×1GbE | 4×SFP+ | Web + CLI | Smart managed, csendes, nem ventilátor-intenzív |
| **Netgear GS724TPv2** | 24×1GbE | 2×SFP+ (1G) – **GS728TX**: 4×SFP+10G | Web | Ha 10G kell, a **GS728TX** (28 portos) modell az ajánlott |
| **MikroTik CRS326-24G-2S+RM** | 24×1GbE | **2×SFP+** | Web (CRS/RouterOS) + CLI | Nagyon jó ár, de CLI-hez érteni kell; pontosan 2×10G SFP+ |

> **Kiemelés SMB 24P:** A **MikroTik CRS326-24G-2S+RM** pontosan teljesíti a kritériumot (24×1GbE + 2×10G SFP+, rack, PoE nélkül), és az egyik legjobb ár-érték arányú megoldás ebben a kategóriában.

### 48 portos

| Modell | Portok | 10G SFP+ | Menedzsment | Megjegyzés |
|---|---|---|---|---|
| **TP-Link TL-SG3452X** | 48×1GbE | 4×SFP+ | Web + CLI (Omada) | Omada ökoszisztéma, megfizethető |
| **Zyxel XGS1930-52** | 48×1GbE | 4×SFP+ | Web + CLI | Smart managed, irodai zaj szint |
| **MikroTik CRS354-48G-4S+2Q+RM** | 48×1GbE | 4×SFP+ (+2×QSFP+) | Web + CLI | Sokat tud, de RouterOS/SwOS kettős kezelési logika |

---

## 2. Jobb / enterprise-ebb kategória

### 24 portos

| Modell | Portok | 10G SFP+ | Menedzsment | Megjegyzés |
|---|---|---|---|---|
| **Ubiquiti UniFi USW-Pro-24** | 24×1GbE | 2×SFP+ | UniFi Controller / Web | Egységes UniFi menedzsment, jó L2 |
| **Cisco Business CBS350-24T-4X** | 24×1GbE | 4×SFP+ | Web + CLI (IOS-like) | Cisco minőség SMB áron, kiváló support |
| **HPE Aruba Instant On 1960 24G 2XGT 2SFP+** | 24×1GbE | 2×SFP+ | Web + Instant On app | Egyszerű menedzsment, megbízható hardver |
| **Juniper EX2300-24T** | 24×1GbE | 4×SFP+ | Web + Junos CLI | Enterprise minőség, hosszú életciklus |

### 48 portos

| Modell | Portok | 10G SFP+ | Menedzsment | Megjegyzés |
|---|---|---|---|---|
| **Ubiquiti UniFi USW-Pro-48** | 48×1GbE | 2×SFP+ | UniFi Controller / Web | Egységes UniFi menedzsment |
| **Cisco Business CBS350-48T-4X** | 48×1GbE | 4×SFP+ | Web + CLI (IOS-like) | Legjobb "volt-Linksys" utód, erős support |
| **HPE Aruba Instant On 1960 48G 2XGT 2SFP+** | 48×1GbE | 2×SFP+ | Web + Instant On app | Egyszerű adminisztráció |
| **Juniper EX2300-48T** | 48×1GbE | 4×SFP+ | Web + Junos CLI | Enterprise életciklus, stacking támogatás |

---

## 3. Cisco Business – Linksys-rokon vonal

A **Cisco Business (CBS) sorozat** a Linksys üzleti termékcsalád közvetlen utódja: a Cisco 2019-ben megvásárolta, majd beolvasztotta a Linksys üzleti switchvonalat ebbe a termékcsaládba. Ha korábban Linksys SRW/SFx sorozatot használtatok, a CBS350 közvetlenül ismert lesz a kezelőfelület és a feature-set szempontjából.

| Ajánlott modell | Portok | 10G SFP+ | Ár jelleg |
|---|---|---|---|
| **Cisco CBS350-24T-4X** | 24×1GbE | 4×SFP+ | Közepes–magas SMB |
| **Cisco CBS350-48T-4X** | 48×1GbE | 4×SFP+ | Közepes–magas SMB |

**Előnyök Linksys után:**
- Azonos menedzsment "logika" (webgui stílus, VLAN setup)
- Cisco TAC support és SmartNet (ha enterprise support kell)
- Firmware frissítések, hosszú EOL dátumok
- Magyar forgalmazóktól elérhető, garanciával

---

## 4. Döntési szempontok

### Ventilátor / zaj
- **Aktívan hűtött (ventilátoros):** szinte minden 48 portos rack switch; a 24 portosok egy részénél opcionális passzív mód van.
- **Zajszint:** rack szekrénybe (zárt szerver szoba) kerülnek? → nem probléma. Nyílt irodai rack esetén nézzétek a dB(A) értékeket.
- Tipikusan **csendesebb** opciók: Zyxel XGS1930, Aruba Instant On 1960, Ubiquiti USW-Pro.

### Tápegység redundancia
- **SMB kategóriában** általában **nincs** redundáns PSU – single PSU, belső.
- **Enterprise kategóriában** (pl. CBS350, Juniper EX2300) általában **opcionális** külső redundáns RPS (Redundant Power Supply) megoldás létezik.
- Ha kritikus az üzemidő: kérdezd a forgalmazótól az RPS lehetőséget, vagy UPS-t tegyél a rack-be.

### Garancia / support
| Gyártó | Garancia (alap) | Kiterjesztett support |
|---|---|---|
| TP-Link | 3 év limited | Fizetős csere program |
| Zyxel | 2+1 év (regisztrációval 3 év) | Gold Care csere |
| MikroTik | 1 év | Közösségi forum, limitált |
| Ubiquiti | 1 év | Közösségi support |
| Cisco CBS350 | Korlátlan ideig hardver, 5 év szoftver | SmartNet (fizetős) |
| HPE Aruba | 3 év | Aruba Care csomag |
| Juniper | 1 év | Juniper Care (fizetős) |

### Menedzsment (web / CLI)
- Minden ajánlott modell rendelkezik **webes GUI-val** és **SSH/CLI** eléréssel.
- **SNMP v2/v3** mindegyiknél elérhető (monitorozás, NMS integráció).
- **Omada (TP-Link)** és **UniFi (Ubiquiti)** ökoszisztéma-alapú, centralizált vezérlést ad – akkor éri meg, ha más eszközökhöz (AP, router) is ugyanezt a gyártót használod.

### L2 feature lista (mind az ajánlott modelleknél elérhető)
| Feature | Támogatás |
|---|---|
| IEEE 802.1Q VLAN | ✅ |
| LACP (802.3ad port channel) | ✅ |
| RSTP (802.1w) / MSTP (802.1s) | ✅ |
| IGMP Snooping (v1/v2/v3) | ✅ |
| Port mirroring | ✅ |
| QoS (802.1p, DSCP) | ✅ |
| ACL | ✅ (a legtöbbnél) |
| DHCP Snooping | ✅ |
| Dynamic ARP Inspection | ✅ (CBS350, Juniper, Aruba; MikroTik-nél korlátosabb) |

### 10G SFP+ modul kompatibilitás (DAC vs optika)
- **DAC kábel (Direct Attach Copper):** 1–3 méterig tökéletes, olcsó, passzív; nem kell SFP+ modul.
- **AOC (Active Optical Cable):** 5–30 méter, ha a két eszköz messzebb van egymástól a rack-en belül.
- **SR optics (MMF, 850 nm):** max ~300 m multimode szállal; tipikusan épületen belüli hosszabb futáshoz.
- **LR optics (SMF, 1310 nm):** km léptékű, ha külső szálra kell.
- **Gyártói kompatibilitás:** A Cisco CBS350 nagyon zárt – lehetőleg Cisco SFP+ modult vegyetek, vagy megbízható harmadik fél (pl. FS.com, Axiom) kompatibilis modulokat. MikroTik és Ubiquiti általában nyíltabb, elfogadja a harmadik feles modulokat.
- **Ajánlás alap topológiához:** ha a core switch és az access switch egy rack-ben van → **DAC kábel** (pl. 1m, 10G SFP+ DAC); ha más rack-ben → SR optics + multimode patch kábel.

### Stacking / MLAG
> **Nem prioritás a jelenlegi igénynél**, de érdemes tudni:
> - **MikroTik CRS sorozat** – nincs klasszikus stacking, de RSTP/MSTP alapú redundancia lehetséges.
> - **Juniper EX2300** – Virtual Chassis (stacking) támogatott.
> - **Ubiquiti USW-Pro** – nincs natív stacking.
> - **Cisco CBS350** – CBS350 nem támogat stackinget (ez CBS250/350-specifikus korlát); CBS220/350X modelleknél van.
>
> Ha jövőben merül fel a stacking igény: Juniper EX2300 vagy Cisco Catalyst 1000 sorozat felé érdemes tekinteni.

---

## 5. Javasolt alap topológia

```
Internet / Tűzfal / Router
         │
         │ (WAN uplink)
    ┌────┴────────────────────────────────────────┐
    │          Core switch / L3 router            │
    │  (vagy tűzfal rendelkezik L3 funkcióval)    │
    └────┬───────────────────────┬────────────────┘
         │ 10G SFP+ DAC          │ 10G SFP+ DAC
    ┌────┴──────┐           ┌────┴──────┐
    │  Access   │           │  Access   │
    │ switch 1  │           │ switch 2  │
    │ (24 port) │           │ (48 port) │
    └─────┬─────┘           └─────┬─────┘
          │ 1GbE RJ45             │ 1GbE RJ45
     végponti eszközök       végponti eszközök
  (PC, laptop, IP kamera,   (PC, laptop, szerver,
      VoIP, stb.)                stb.)
```

**Magyarázat:**
- Az access switchek **10G SFP+ uplinken** csatlakoznak a core eszközhöz (router/tűzfal/core switch).
- Az access switchek **1GbE RJ45 portjain** lógnak a végponti eszközök.
- Redundáns uplink esetén (LACP vagy RSTP): mindkét SFP+ portot használd (2 fizikai link = LACP bundle vagy STP backup).
- VLAN-ok kiosztása az access switcheken; inter-VLAN routing a core eszközön (vagy tűzfalon) történik.

---

## 6. Beszerzési checklist

Amit kérdezz a beszállítótól mielőtt megrendeled:

- [ ] **Rack fülek (rack ears / rack kit):** beletartozik-e a dobozba, vagy külön kell rendelni? (pl. Ubiquiti USW-Pro-nál nem mindig mellékelt)
- [ ] **Tápkábel:** CEE 7/4 (Schuko) csatlakozó, hossz, biztosítva-e? (rack-nél általában IEC C13/C14 belső, de az PDU oldalát ellenőrizd)
- [ ] **SFP+ modulok / DAC kábelek:** ki szállítja, kompatibilitás garantált-e a kiválasztott switchhez? (különösen Cisco CBS esetén!)
- [ ] **Garancia részletei:** hány év, helyszíni csere van-e, vagy beks RMA? Mennyi a várható cserehatáridő?
- [ ] **Szállítás és szállítási idő:** raktárról megy, vagy rendelésre? (MikroTik / Juniper egyes modellek import-függők, 2–4 hét is lehet)
- [ ] **Magyar forgalmazói support:** van-e helyi (HU) support elérhetőség, vagy csak gyártói angliai helpdesk?
- [ ] **Firmware verzió:** a dobozban lévő firmware naprakész-e, vagy szükséges frissítés beüzemelés előtt?

---

*Dokumentum készítve: 2026-04-14 | Igény alapja: 24+48 portos, rack, menedzselhető, PoE nélkül, 2×10G SFP+, L2, korábbi Linksys környezet*
