# excel

## Struktúra

- **`workbook/`** – Az Excel munkafüzet (`szuresnev.xlsm`) helye.
- **`vba/`** – Az exportált VBA forrásfájlok, almappákba rendezve:
  - **`vba/modul/`** – Standard VBA modulok (`*.bas`).
  - **`vba/munkalap/`** – Munkalap- és dokumentum-exportok (`*.cls`, pl. `*-munkalap.cls`, `Munka*.cls`).
  - **`vba/osztaly/`** – Osztálymodulok (`*.cls`), jelenleg üres.

## VBA modulok importálása

A `vba/modul/` mappában található `*.bas` fájlokat a fejlesztő **manuálisan importálja** az Excel VBA Editorba:

1. Nyisd meg az Excel VBA Editort (`Alt+F11`).
2. A Project Explorerben jobb klikk → **Import File…**
3. Válaszd ki a kívánt `.bas` fájlt a `vba/modul/` mappából.

A munkalaphoz tartozó `.cls` fájlokat (`vba/munkalap/`) szintén manuálisan kell importálni, vagy a meglévő munkalapmodulba kell bemásolni.

## Clean rewrite plan

Az újraírt, tiszta VBA kódbázis fokozatosan kerül bevezetésre:

### 1. kör – Core utils (jelen PR)
| Modul | Tartalom |
|---|---|
| `modApp.bas` | `AppBegin` / `AppEnd` / `AppReset` – Application state (ScreenUpdating, Calculation, EnableEvents) |
| `modTextNorm.bas` | `NKey`, `NormalizeSpaces`, `StripHungarianAccents` – szövegnormalizálás |
| `modDialogs.bas` | `PickExcelFile`, `PickWordFile`, `PickFolder`, `AskLong` – UI dialógusok |
| `modTableUtils.bas` | `FindTableByName`, `ColIndex`, `SafeValD`, `IsFlagX` – ListObject segédfüggvények |

### Következő körök
- **Import modulok** – Diakadat, Kozponti, Bizi import logikájának átvezetése a core utilokra.
- **Pontszámítás** – `PontSzamitas` és `BiziPontok` logika tisztán, core utilokkal.
- **Rangsor** – Rangsorolas és prioritásos rangsor újraírása.
- **Export** – PDF/Word export (`modWordPdfExport`) integrálása a core utilokkal.