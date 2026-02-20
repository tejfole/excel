Attribute VB_Name = "DiakokBiziImport"
Option Explicit

Private Const MATRIX_SHEET As String = "bizonyitvany_matrix"
Private Const DIRTY_COL As Long = 26 ' Z oszlop

' ============ A) Mátrix felépítése forrásból ============
Public Sub BiziMatrix_Build(Optional control As IRibbonControl)
    Dim srcPath As String
    srcPath = PickExcelFile("Válaszd ki a FORRÁS Excelt (ugyanaz a típus, mint a pontszámoknál)")
    If srcPath = "" Then Exit Sub

    Application.ScreenUpdating = False
    Application.EnableEvents = False
    On Error GoTo EH

    Dim wbD As Workbook: Set wbD = ThisWorkbook
    Dim wsM As Worksheet: Set wsM = EnsureSheet(wbD, MATRIX_SHEET)

    Dim wbS As Workbook, wsS As Worksheet
    Set wbS = Workbooks.Open(srcPath, ReadOnly:=True)
    On Error Resume Next
    Set wsS = wbS.Worksheets("Export")
    On Error GoTo EH
    If wsS Is Nothing Then Set wsS = wbS.Worksheets(1)

    Dim headerRowSubject As Long: headerRowSubject = 1
    Dim headerRowYear As Long: headerRowYear = 2

    Dim srcKeyHeader As String
    srcKeyHeader = InputBox("Forrás kulcs fejléce (2. sor):", "Kulcs", "Oktatási azonosító")
    If Trim$(srcKeyHeader) = "" Then GoTo CleanExit

    Dim srcNameHeader As String
    srcNameHeader = InputBox("Forrás név fejléce (2. sor):", "Név", "Név")
    If Trim$(srcNameHeader) = "" Then srcNameHeader = "Név"

    Dim colKeyS As Long: colKeyS = FindHeaderCol(wsS, headerRowYear, srcKeyHeader)
    If colKeyS = 0 Then Err.Raise 2001, , "Nem találom a kulcs oszlopot (2. sor): " & srcKeyHeader

    Dim colNameS As Long: colNameS = FindHeaderCol(wsS, headerRowYear, srcNameHeader) ' lehet 0

    ' Tantárgy -> 4 évf oszlop index
    Dim lastCol As Long: lastCol = wsS.Cells(headerRowYear, wsS.Columns.count).End(xlToLeft).Column
    Dim subjCols As Object: Set subjCols = CreateObject("Scripting.Dictionary")

    Dim c As Long
    For c = 1 To lastCol
        If IsYear4Header(NKey(CStr(wsS.Cells(headerRowYear, c).value))) Then
            Dim subj As String
            subj = Trim$(GroupHeaderText(wsS, headerRowSubject, c))
            If subj <> "" Then
                If Not IsBlacklistedGroup(subj) Then
                    If Not subjCols.Exists(subj) Then subjCols.Add subj, c
                End If
            End If
        End If
    Next c

    If subjCols.count = 0 Then Err.Raise 2002, , "Nem találtam tantárgy alatti '4 évf.' oszlopokat."

    ' Fejléc: A oktazon, B név, C.. tantárgyak
    wsM.Cells.Clear
    wsM.Cells(1, 1).value = "oktazon"
    wsM.Cells(1, 2).value = "nev"

    Dim subjects() As String: subjects = DictKeysSorted(subjCols)
    Dim j As Long
    For j = LBound(subjects) To UBound(subjects)
        wsM.Cells(1, 3 + j).value = subjects(j)
    Next j

    ' Dirty oszlop (Z) fejléce
    wsM.Cells(1, DIRTY_COL).value = "dirty"

    ' Adatok
    Dim lastRow As Long: lastRow = wsS.Cells(wsS.rows.count, colKeyS).End(xlUp).Row
    Dim outRow As Long: outRow = 2

    Dim seen As Object: Set seen = CreateObject("Scripting.Dictionary")
    Dim dup As Long: dup = 0
    Dim dupReport As String: dupReport = ""

    Dim r As Long
    For r = headerRowYear + 1 To lastRow
        Dim k As String: k = Trim$(CStr(wsS.Cells(r, colKeyS).value))
        If k = "" Then GoTo NextR

        If seen.Exists(k) Then
            dup = dup + 1
            If dup <= 30 Then dupReport = dupReport & "• " & k & " (sor " & r & ", már volt: " & seen(k) & ")" & vbCrLf
            GoTo NextR
        Else
            seen(k) = r
        End If

        Dim nev As String
        If colNameS > 0 Then nev = CStr(wsS.Cells(r, colNameS).value) Else nev = ""

        wsM.Cells(outRow, 1).value = k
        wsM.Cells(outRow, 2).value = nev

        For j = LBound(subjects) To UBound(subjects)
            Dim colG As Long: colG = CLng(subjCols(subjects(j)))
            wsM.Cells(outRow, 3 + j).value = wsS.Cells(r, colG).value   ' RAW jegy
        Next j

        wsM.Cells(outRow, DIRTY_COL).value = 0 ' tiszta

        outRow = outRow + 1
NextR:
    Next r

    ' formázás
    wsM.rows(1).Font.Bold = True
    wsM.Columns.AutoFit
    wsM.Columns(DIRTY_COL).Hidden = True

    If dup > 0 Then
        MsgBox "Mátrix készen, de duplák voltak a forrásban (elsõt vettük):" & vbCrLf & vbCrLf & dupReport, vbExclamation
    Else
        MsgBox "Mátrix elkészült: " & MATRIX_SHEET & vbCrLf & "Most már kézzel is szerkeszthetõ.", vbInformation
    End If

CleanExit:
    On Error Resume Next
    wbS.Close SaveChanges:=False
    Application.EnableEvents = True
    Application.ScreenUpdating = True
    Exit Sub

EH:
    MsgBox "Hiba: " & Err.Number & vbCrLf & Err.Description, vbExclamation
    Resume CleanExit
End Sub

' ============ B) p_bizonyitvany frissítése CSAK a módosított sorokra ============
Public Sub BiziMatrix_UpdateTarget_ChangedOnly()
    Application.ScreenUpdating = False
    Application.EnableEvents = False
    On Error GoTo EH

    Dim wbD As Workbook: Set wbD = ThisWorkbook
    Dim wsM As Worksheet: Set wsM = wbD.Worksheets(MATRIX_SHEET)

    Dim wsD As Worksheet: Set wsD = wbD.Worksheets("diakadat")
    Dim loD As ListObject: Set loD = wsD.ListObjects("diakadat")

    Dim mapD As Object: Set mapD = BuildListObjectHeaderMapNorm(loD)
    If Not mapD.Exists(NKey("oktazon")) Then Err.Raise 3001, , "A cél táblában nincs: oktazon"
    If Not mapD.Exists(NKey("p_bizonyitvany")) Then Err.Raise 3002, , "A cél táblában nincs: p_bizonyitvany"

    Dim colKeyD As Long: colKeyD = mapD(NKey("oktazon"))
    Dim colPBizi As Long: colPBizi = mapD(NKey("p_bizonyitvany"))

    Dim idxD As Object: Set idxD = CreateObject("Scripting.Dictionary")
    BuildDestIndex loD, colKeyD, idxD

    Dim lastRow As Long: lastRow = wsM.Cells(wsM.rows.count, 1).End(xlUp).Row
    Dim lastCol As Long: lastCol = wsM.Cells(1, wsM.Columns.count).End(xlToLeft).Column
    If lastRow < 2 Or lastCol < 3 Then Err.Raise 3003, , "A bizonyitvany_matrix üres."

    Dim upd As Long, miss As Long, clean As Long
    Dim missRep As String, changeRep As String
    missRep = "": changeRep = ""

    Dim r As Long
    For r = 2 To lastRow
        If NzLong(wsM.Cells(r, DIRTY_COL).value) <> 1 Then
            clean = clean + 1
            GoTo NextR
        End If

        Dim k As String: k = Trim$(CStr(wsM.Cells(r, 1).value))
        If k = "" Then GoTo NextR

        Dim sumK As Long: sumK = 0
        Dim c As Long
        For c = 3 To lastCol
            If c = DIRTY_COL Then GoTo NextC
            sumK = sumK + GradeToNum(wsM.Cells(r, c).value)
NextC:
        Next c

        If Not idxD.Exists(k) Then
            miss = miss + 1
            If miss <= 30 Then missRep = missRep & "• " & k & " (mátrix sor " & r & ")" & vbCrLf
            GoTo NextR
        End If

        Dim cur As Variant
        cur = loD.ListRows(idxD(k)).Range.Cells(1, colPBizi).value

        If NzLong(cur) <> sumK Then
            loD.ListRows(idxD(k)).Range.Cells(1, colPBizi).value = sumK
            upd = upd + 1
            If upd <= 30 Then changeRep = changeRep & "• " & k & ": " & NzLong(cur) & " › " & sumK & vbCrLf
        End If

        wsM.Cells(r, DIRTY_COL).value = 0 ' visszatisztít
NextR:
    Next r

    ThisWorkbook.Save

    Dim msg As String
    msg = "Frissítés kész (csak módosított sorok)." & vbCrLf & _
          "Módosított p_bizonyitvany: " & upd & vbCrLf & _
          "Célból hiányzott: " & miss & vbCrLf & _
          "Nem volt dirty: " & clean

    If changeRep <> "" Then msg = msg & vbCrLf & vbCrLf & "Változások (elsõ 30):" & vbCrLf & changeRep
    If missRep <> "" Then msg = msg & vbCrLf & vbCrLf & "Hiányzók (elsõ 30):" & vbCrLf & missRep

    MsgBox msg, vbInformation

CleanExit:
    Application.EnableEvents = True
    Application.ScreenUpdating = True
    Exit Sub

EH:
    MsgBox "Hiba: " & Err.Number & vbCrLf & Err.Description, vbExclamation
    Resume CleanExit
End Sub

' ===================== Jegy -> szám (1..5), 0/-, üres = 0 =====================
Private Function GradeToNum(v As Variant) As Long
    Dim s As String
    s = LCase$(Trim$(CStr(v)))
    If s = "" Then GradeToNum = 0: Exit Function
    If s = "-" Or s = "–" Or s = "—" Or s = "0" Then GradeToNum = 0: Exit Function

    If IsNumeric(s) Then
        Dim n As Long: n = CLng(val(s))
        If n >= 1 And n <= 5 Then GradeToNum = n Else GradeToNum = 0
        Exit Function
    End If

    ' teljesítmény jellegû szöveg
    If InStr(s, "kivaloan") > 0 Or InStr(s, "kiválóan") > 0 Or InStr(s, "dics") > 0 Then GradeToNum = 5: Exit Function
    If InStr(s, "jol") > 0 Or InStr(s, "jól") > 0 Then GradeToNum = 4: Exit Function
    If InStr(s, "megfelelt") > 0 Then GradeToNum = 3: Exit Function
    If InStr(s, "nem felelt") > 0 Then GradeToNum = 1: Exit Function

    ' klasszikus osztályzat szövegek
    If InStr(s, "jeles") > 0 Or InStr(s, "kituno") > 0 Or InStr(s, "kitûnõ") > 0 Or InStr(s, "kivalo") > 0 Or InStr(s, "kiváló") > 0 Then GradeToNum = 5: Exit Function
    If InStr(s, "jo") > 0 Or InStr(s, "jó") > 0 Then GradeToNum = 4: Exit Function
    If InStr(s, "kozepes") > 0 Or InStr(s, "közepes") > 0 Then GradeToNum = 3: Exit Function
    If InStr(s, "elegseges") > 0 Or InStr(s, "elégséges") > 0 Then GradeToNum = 2: Exit Function
    If InStr(s, "elegtelen") > 0 Or InStr(s, "elégtelen") > 0 Then GradeToNum = 1: Exit Function

    GradeToNum = 0
End Function

' ===================== Fejléc/merged segédek =====================
Private Function IsYear4Header(ByVal nk As String) As Boolean
    nk = Replace(nk, ".", "")
    IsYear4Header = (nk = NKey("4 évf") Or nk = NKey("4 evf"))
End Function

Private Function IsBlacklistedGroup(ByVal groupTitle As String) As Boolean
    IsBlacklistedGroup = (NKey(groupTitle) = NKey("kozponti felveteli eredmenyek"))
End Function

Private Function FindHeaderCol(ws As Worksheet, headerRow As Long, headerText As String) As Long
    Dim lastCol As Long: lastCol = ws.Cells(headerRow, ws.Columns.count).End(xlToLeft).Column
    Dim c As Long
    For c = 1 To lastCol
        If NKey(CStr(ws.Cells(headerRow, c).value)) = NKey(headerText) Then
            FindHeaderCol = c
            Exit Function
        End If
    Next c
    FindHeaderCol = 0
End Function

Private Function GroupHeaderText(ws As Worksheet, headerRowGroup As Long, col As Long) As String
    Dim cell As Range: Set cell = ws.Cells(headerRowGroup, col)
    If cell.MergeCells Then
        GroupHeaderText = CStr(cell.MergeArea.Cells(1, 1).value)
    Else
        GroupHeaderText = CStr(cell.value)
    End If
End Function

' ===================== Cél index segédek =====================
Private Function BuildListObjectHeaderMapNorm(lo As ListObject) As Object
    Dim d As Object: Set d = CreateObject("Scripting.Dictionary")
    Dim i As Long
    For i = 1 To lo.ListColumns.count
        d(NKey(lo.ListColumns(i).Name)) = i
    Next i
    Set BuildListObjectHeaderMapNorm = d
End Function

Private Sub BuildDestIndex(lo As ListObject, keyColIndex As Long, idx As Object)
    idx.RemoveAll
    If lo.ListRows.count = 0 Then Exit Sub
    Dim i As Long, k As String
    For i = 1 To lo.ListRows.count
        k = Trim$(CStr(lo.DataBodyRange.Cells(i, keyColIndex).value))
        If k <> "" Then idx(k) = i
    Next i
End Sub

' ===================== Normalizáló / util =====================
Private Function NKey(ByVal s As String) As String
    Dim t As String
    t = LCase$(Trim$(s))
    t = Replace(t, ChrW(160), " ")
    Do While InStr(t, "  ") > 0: t = Replace(t, "  ", " "): Loop
    t = Replace(t, "-", " "): t = Replace(t, "—", " "): t = Replace(t, "–", " ")

    t = Replace(t, "á", "a"): t = Replace(t, "é", "e"): t = Replace(t, "í", "i")
    t = Replace(t, "ó", "o"): t = Replace(t, "ö", "o"): t = Replace(t, "õ", "o")
    t = Replace(t, "ú", "u"): t = Replace(t, "ü", "u"): t = Replace(t, "û", "u")
    NKey = t
End Function

Private Function NzLong(v As Variant) As Long
    If IsNumeric(v) Then NzLong = CLng(v) Else NzLong = 0
End Function

Private Function EnsureSheet(wb As Workbook, sheetName As String) As Worksheet
    On Error Resume Next
    Set EnsureSheet = wb.Worksheets(sheetName)
    On Error GoTo 0
    If EnsureSheet Is Nothing Then
        Set EnsureSheet = wb.Worksheets.Add(After:=wb.Worksheets(wb.Worksheets.count))
        EnsureSheet.Name = sheetName
    End If
End Function

Private Function DictKeysSorted(d As Object) As String()
    Dim arr() As String, i As Long
    ReDim arr(0 To d.count - 1)
    i = 0
    Dim k As Variant
    For Each k In d.keys
        arr(i) = CStr(k): i = i + 1
    Next k
    QuickSortStrings arr, LBound(arr), UBound(arr)
    DictKeysSorted = arr
End Function

Private Sub QuickSortStrings(ByRef a() As String, ByVal lo As Long, ByVal hi As Long)
    Dim i As Long, j As Long, pivot As String, tmp As String
    i = lo: j = hi: pivot = a((lo + hi) \ 2)
    Do While i <= j
        Do While a(i) < pivot: i = i + 1: Loop
        Do While a(j) > pivot: j = j - 1: Loop
        If i <= j Then
            tmp = a(i): a(i) = a(j): a(j) = tmp
            i = i + 1: j = j - 1
        End If
    Loop
    If lo < j Then QuickSortStrings a, lo, j
    If i < hi Then QuickSortStrings a, i, hi
End Sub

Private Function PickExcelFile(ByVal title As String) As String
    Dim fd As FileDialog
    Set fd = Application.FileDialog(msoFileDialogFilePicker)
    With fd
        .title = title
        .Filters.Clear
        .Filters.Add "Excel fájlok", "*.xlsx;*.xlsm;*.xls"
        .AllowMultiSelect = False
        If .Show <> -1 Then PickExcelFile = "" Else PickExcelFile = .SelectedItems(1)
    End With
End Function


