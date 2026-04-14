# Menedzselhető rack switch ajánló – 10G SFP+ uplink, PoE nélkül

## Követelmények összefoglalása

- 24 vagy 48 × 1GbE RJ45 access port
- Legalább 2–4 × 10G SFP+ uplink
- Menedzselt (managed): VLAN, LACP, STP/RSTP/MSTP, IGMP snooping, ACL alapok
- Rack mount (1U)
- **PoE nem szükséges**
- Új eszköz (nem használt)

---

## 1. Döntési útmutató – mire figyelj

### Uplink portok száma és sebessége
Minimum **2 × 10G SFP+** ajánlott; ha szerverek, NAS vagy más switchek felé is megy a gerinc, érdemes **4 × SFP+**-os modellt választani. Fontos: az 1G SFP uplink nem elegendő, ha a céleszköz 10G képességű.

### Switching capacity (belső sávszélesség)
48 × 1GbE + 4 × 10G SFP+ esetén a teljes non-blocking kapacitás ~136 Gbit/s legyen. Ez a mai budget switcheknél általában teljesül – ellenőrizd a gyártói adatlapon.

### Buffer méret
Fontos burst-forgalomnál (pl. sok egyidejű fájlmásolás NAS-ra). A jobb enterprise modellek nagyobb puffert adnak; budget kategóriában ez kompromisszum.

### Zaj / ventilátor
Az irodai rack-be általában csendeset érdemes: egyes modellek front-to-back légáramlásra tervezettek (szerver-szobába), mások csendesebb, változó fordulatú ventit kapnak. Ha nyitott irodában áll a rack, érdemes ezt mérlegelni.

### Garancia és support
- Budget kategória: tipikusan 1–3 év, csere mail-in alapon.
- Enterprise kategória: lifetime limited hardware warranty (pl. Cisco, HPE), next-business-day csere opcióval.

### Firmware / szoftver életciklus
Fontos biztonsági szempontból. Cisco Business, HPE/Aruba, Juniper hosszabb ideig kap biztonsági frissítést. MikroTik és TP-Link is rendszeresen frissül.

### Stacking / MLAG igény
Ha több switchből álló, redundáns architektúrát tervezel, érdemes olyan modellt választani, ami támogatja a proprietäre stacking-et (pl. Cisco StackWise) vagy MLAG-ot (pl. MikroTik MLAG CRS3xx sorozaton). Egyetlen standalone switchnél ez irreleváns.

### L2 vs L3 lite
Lásd bővebben a 3. fejezetben.

---

## 2. Konkrét modelljavaslatok

### Budget / SMB kategória

| Modell | Access portok | 10G uplink | Megjegyzés |
|---|---|---|---|
| **TP-Link JetStream TL-SG3428X** | 24 × 1GbE | 4 × 10G SFP+ | Jó ár-érték arány, Omada menedzsment, L2+ |
| **TP-Link JetStream TL-SG3452X** | 48 × 1GbE | 4 × 10G SFP+ | 48 portos változat, ugyanaz a platform |
| **MikroTik CRS326-24G-2S+RM** | 24 × 1GbE | 2 × 10G SFP+ | RouterOS + SwOS, nagyon rugalmas, de tanulási görbe van; olcsó, csendes |

> **TP-Link TL-SG3428X / TL-SG3452X** – kiemelkedő ár-érték; az Omada SDN ökoszisztémával (ha van UniFi-hoz hasonló menedzsment igény) együtt is jól működik. VLAN, LACP, RSTP, IGMP snooping, ACL mind elérhető.

> **MikroTik CRS326** – ha van hálózatos tapasztalat, ez a legolcsóbb megbízható 10G SFP+ opcó a piacon. Közvetlen CLI-n vagy SwOS webes felületen menedzselhető.

---

### Jobb / enterprise-ebb kategória

| Modell | Access portok | 10G uplink | Megjegyzés |
|---|---|---|---|
| **Cisco Business CBS350-24T-4X** | 24 × 1GbE | 4 × 10G SFP+ | Lifetime warranty, L3 lite, jó GUI és CLI |
| **Cisco Business CBS350-48T-4X** | 48 × 1GbE | 4 × 10G SFP+ | 48 portos változat, azonos platform |
| **Ubiquiti UniFi USW-Pro-24 / USW-Pro-48** | 24 vagy 48 × 1GbE | 2 × 10G SFP+ | UniFi ökoszisztémába illeszkedik, kiváló GUI, L2+L3 lite |

> **Cisco CBS350** – az SMB és enterprise határ klasszikus képviselője. Lifetime limited hardware warranty, rendszeres firmware frissítések, részletes CLI és webes menedzsment. L3 lite (statikus routing, inter-VLAN routing).

> **Ubiquiti USW-Pro-24/48** – ha a hálózatban már van vagy tervben van UniFi AP, gateway stb., akkor a UniFi Controller / Network Application alatt egy egységes, kiváló menedzsment felületet kapsz. 2 × 10G SFP+ uplink (ha 4 kell, érdemes UniFi USW-Aggregation vagy Cisco felé nézni).

---

## 3. L2 vs L3 lite – kell-e inter-VLAN routing?

### Csak L2 switch kell, ha:
- A VLAN-ok között a routing-ot **a router vagy firewall** végzi (pl. UniFi Dream Machine, pfSense, Cisco ISR).
- Az egyes VLAN-ok le vannak választva egymástól, és csak a default gateway-en keresztül kommunikálnak.
- Egyszerűbb, olcsóbb eszköz is elegendő.

### L3 lite (vagy L3 managed switch) kell, ha:
- Több VLAN között **gyors, alacsony késleltetésű inter-VLAN routing** kell, és ezt a switchben szeretnéd megoldani (nem dedikált routerben).
- Statikus routing szükséges (pl. szerver VLAN ↔ felhasználói VLAN gyors forgalomhoz).
- A tervezett modellek közül: Cisco CBS350, Ubiquiti USW-Pro – mindkét kategóriában elérhető L3 lite.

**Javaslatom:** ha van router/firewall a hálózatban, kezdj L2 switchsel; ha belső VLAN-ok között nagy forgalom várható (pl. NAS + szerver egy VLAN, kliensek másik VLAN-ban), akkor L3 lite switch érdemesebb.

---

## 4. Pontosító kérdések a végleges shortlisthez

A tökéletes ajánláshoz az alábbi kérdéseket érdemes megválaszolni:

1. **24 vagy 48 portos modell kell?** (Mennyi végpont csatlakozik most, és mennyi várható 3–5 éven belül?)
2. **Hány 10G SFP+ uplink szükséges?** (2 elég, ha 1 szerver/NAS + 1 gerinc; 4 kell, ha több szerver vagy redundáns uplink tervezett.)
3. **Kell-e redundáns tápegység?** (Ha igen, csak az enterprise kategória (pl. Cisco CBS350-hez külső RPS, vagy HPE Aruba CX sorozat) ad erre lehetőséget budget áron; MikroTik és TP-Link Budget modellek általában single PSU-val érkeznek.)
4. **Van-e meglévő menedzsment platform preferencia?** (UniFi / Omada / Cisco Business Dashboard / standalone webes GUI / CLI? Ha már van Ubiquiti vagy TP-Link infrastruktúra, érdemes abban maradni.)
5. **Hány VLAN-t tervezel, és kell-e inter-VLAN routing a switchben?** (Ez eldönti, hogy L2 vagy L3 lite modell szükséges-e.)

---

*Dokumentum létrehozva: 2026-04-14*
