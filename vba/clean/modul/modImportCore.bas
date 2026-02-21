Attribute VB_Name = "modImportCore"
Option Explicit

' =============================================================================
' modImportCore – Közös import segédfüggvények
' =============================================================================
' OpenSourceWb           – forrás workbook megnyitása (ReadOnly)
' SafeCloseWb            – workbook biztonságos lezárása
' BuildHeaderMap         – NKey(fejléc) → oszlopindex Dictionary
' GetSheetByNameOrPrompt – munkalap lekérése, hiány esetén InputBox
' FirstMatchingHeaderCol – első illeszkedő alias a headerMap-ben
' BuildDestIndex         – cél index kulcsoszlop alapján
' WriteIfEmpty           – csak üres célcellába ír
' =============================================================================

' ---------------------------------------------------------------------------
' OpenSourceWb – forrás workbook megnyitása (ReadOnly)
'   Visszatér Nothing, ha hiba történik.
' ---------------------------------------------------------------------------
Public Function OpenSourceWb(ByVal filePath As String) As Workbook
    On Error GoTo Fail
    Set OpenSourceWb = Workbooks.Open(filePath, ReadOnly:=True)
    Exit Function
Fail:
    Set OpenSourceWb = Nothing
End Function

' ---------------------------------------------------------------------------
' SafeCloseWb – workbook biztonságos lezárása mentés nélkül
' ---------------------------------------------------------------------------
Public Sub SafeCloseWb(ByVal wb As Workbook)
    If wb Is Nothing Then Exit Sub
    On Error Resume Next
    wb.Close SaveChanges:=False
    On Error GoTo 0
End Sub

' ---------------------------------------------------------------------------
' BuildHeaderMap – fejléc-sor alapján NKey → oszlopindex Dictionary
'   ws        : forrás munkalap
'   headerRow : fejléc sorszáma (általában 1)
' ---------------------------------------------------------------------------
Public Function BuildHeaderMap(ByVal ws As Worksheet, _
                                ByVal headerRow As Long) As Object
    Dim d As Object
    Set d = CreateObject("Scripting.Dictionary")
    Dim lastCol As Long
    lastCol = ws.Cells(headerRow, ws.Columns.Count).End(xlToLeft).Column
    Dim c   As Long
    Dim h   As String
    Dim nk  As String
    For c = 1 To lastCol
        h = Trim$(CStr(ws.Cells(headerRow, c).Value))
        If h <> "" Then
            nk = NKey(h)
            If Not d.Exists(nk) Then d(nk) = c  ' első előfordulás nyer; duplikált (normalizált) fejlécek kihagyva
        End If
    Next c
    Set BuildHeaderMap = d
End Function

' ---------------------------------------------------------------------------
' GetSheetByNameOrPrompt – megpróbálja a defaultName-t, ha nincs, InputBox
'   Visszatér Nothing, ha a felhasználó megszakítja, vagy a megadott név sem létezik.
' ---------------------------------------------------------------------------
Public Function GetSheetByNameOrPrompt(ByVal wb As Workbook, _
                                        ByVal defaultName As String) As Worksheet
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = wb.Worksheets(defaultName)
    On Error GoTo 0
    If Not ws Is Nothing Then
        Set GetSheetByNameOrPrompt = ws
        Exit Function
    End If
    ' Nem találtuk – rákérdezünk
    Dim ans As String
    ans = InputBox("A """ & defaultName & """ munkalap nem található." & vbCrLf & _
                   "Add meg a forrás munkalap nevét:", "Forrás munkalap", defaultName)
    If Trim$(ans) = "" Then
        Set GetSheetByNameOrPrompt = Nothing
        Exit Function
    End If
    On Error Resume Next
    Set ws = wb.Worksheets(Trim$(ans))
    On Error GoTo 0
    Set GetSheetByNameOrPrompt = ws
End Function

' ---------------------------------------------------------------------------
' FirstMatchingHeaderCol – alias-listából az első egyező oszlopindex
'   headerMap : BuildHeaderMap eredménye (NKey → colIndex)
'   aliases   : Variant tömb (pl. Split(...) eredménye vagy Array(...))
'   Visszatér 0, ha egyik alias sem szerepel a headerMap-ben.
' ---------------------------------------------------------------------------
Public Function FirstMatchingHeaderCol(ByVal headerMap As Object, _
                                        ByVal aliases As Variant) As Long
    Dim i  As Long
    Dim nk As String
    For i = LBound(aliases) To UBound(aliases)
        nk = NKey(Trim$(CStr(aliases(i))))
        If nk <> "" And headerMap.Exists(nk) Then
            FirstMatchingHeaderCol = CLng(headerMap(nk))
            Exit Function
        End If
    Next i
    FirstMatchingHeaderCol = 0
End Function

' ---------------------------------------------------------------------------
' BuildDestIndex – cél ListObject indexelése kulcsoszlop alapján
'   lo        : cél tábla
'   keyColIdx : kulcsoszlop indexe (1-based, ListColumn.Index)
'   Visszatér : Dictionary  kulcsérték (String) → ListRow.Index (Long)
' ---------------------------------------------------------------------------
Public Function BuildDestIndex(ByVal lo As ListObject, _
                                ByVal keyColIdx As Long) As Object
    Dim d As Object
    Set d = CreateObject("Scripting.Dictionary")
    If lo.ListRows.Count = 0 Then
        Set BuildDestIndex = d
        Exit Function
    End If
    Dim i As Long
    Dim k As String
    For i = 1 To lo.ListRows.Count
        k = Trim$(CStr(lo.DataBodyRange.Cells(i, keyColIdx).Value))
        If k <> "" Then
            If Not d.Exists(k) Then d(k) = i
        End If
    Next i
    Set BuildDestIndex = d
End Function

' ---------------------------------------------------------------------------
' WriteIfEmpty – csak üres célcellába ír értéket
'   lr     : ListRow
'   colIdx : oszlopindex a ListRow.Range-ben (1-based)
'   val    : írandó érték
'   Visszatér True, ha ténylegesen írt (a cella üres volt)
' ---------------------------------------------------------------------------
Public Function WriteIfEmpty(ByVal lr As ListRow, _
                              ByVal colIdx As Long, _
                              ByVal val As Variant) As Boolean
    Dim cell As Range
    Set cell = lr.Range.Cells(1, colIdx)
    If Trim$(CStr(cell.Value)) = "" Then
        cell.Value = val
        WriteIfEmpty = True
    Else
        WriteIfEmpty = False
    End If
End Function
