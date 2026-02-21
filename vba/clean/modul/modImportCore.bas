Attribute VB_Name = "modImportCore"
Option Explicit

' =============================================================================
' modImportCore – Közös import utility függvények
' =============================================================================

' ---------------------------------------------------------------------------
' BuildDestIndex – céltábla kulcs → ListRow.Index szótár felépítése
'   Hardened: üres tábla esetén csöndesen kilép.
'   idx: key (String) → ListRow.Index (Long), első előfordulás nyer, üres kulcs kihagyva.
' ---------------------------------------------------------------------------
Public Sub BuildDestIndex(ByVal lo As ListObject, _
                          ByVal keyColIndex As Long, _
                          ByRef idx As Object)
    idx.RemoveAll
    If lo Is Nothing Then Exit Sub
    If lo.DataBodyRange Is Nothing Then Exit Sub
    If lo.ListRows.Count = 0 Then Exit Sub

    Dim i As Long, k As String
    For i = 1 To lo.ListRows.Count
        k = Trim$(CStr(lo.DataBodyRange.Cells(i, keyColIndex).Value))
        If k <> "" Then
            If Not idx.Exists(k) Then idx(k) = i
        End If
    Next i
End Sub

' ---------------------------------------------------------------------------
' BuildHeaderMapNorm – munkalap fejléc sor → NKey(fejléc) : oszlopszám szótár
' ---------------------------------------------------------------------------
Public Function BuildHeaderMapNorm(ByVal ws As Worksheet, _
                                   ByVal headerRow As Long) As Object
    Dim d As Object: Set d = CreateObject("Scripting.Dictionary")
    Dim lastCol As Long
    lastCol = ws.Cells(headerRow, ws.Columns.Count).End(xlToLeft).Column
    Dim c As Long, h As String, nk As String
    For c = 1 To lastCol
        h = Trim$(CStr(ws.Cells(headerRow, c).Value))
        If h <> "" Then
            nk = modTextNorm.NKey(h)
            If Not d.Exists(nk) Then d(nk) = c
        End If
    Next c
    Set BuildHeaderMapNorm = d
End Function

' ---------------------------------------------------------------------------
' BuildListObjectColMap – ListObject oszlopai → NKey(oszlopnév) : oszlopindex szótár
' ---------------------------------------------------------------------------
Public Function BuildListObjectColMap(ByVal lo As ListObject) As Object
    Dim d As Object: Set d = CreateObject("Scripting.Dictionary")
    Dim i As Long
    For i = 1 To lo.ListColumns.Count
        d(modTextNorm.NKey(lo.ListColumns(i).Name)) = i
    Next i
    Set BuildListObjectColMap = d
End Function

' ---------------------------------------------------------------------------
' WriteIfEmpty – csak akkor ír a cellába, ha az üres/null/error
' ---------------------------------------------------------------------------
Public Sub WriteIfEmpty(ByVal cel As Range, ByVal v As Variant)
    Dim cur As Variant
    cur = cel.Value
    If IsError(cur) Then
        cel.Value = v
    ElseIf IsNull(cur) Or IsEmpty(cur) Or Trim$(CStr(cur)) = "" Then
        cel.Value = v
    End If
End Sub

' ---------------------------------------------------------------------------
' GetSheetByNameOrPrompt – munkalap keresése névvel; ha nem találja, kérdez
'   Ha a felhasználó mégis visszamond (Cancel/üres), visszatér Nothing.
' ---------------------------------------------------------------------------
Public Function GetSheetByNameOrPrompt(ByVal wb As Workbook, _
                                       ByVal sheetName As String) As Worksheet
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = wb.Worksheets(sheetName)
    On Error GoTo 0
    If Not ws Is Nothing Then
        Set GetSheetByNameOrPrompt = ws
        Exit Function
    End If

    ' Nem találta – kérdezzük meg a felhasználót
    Dim ans As String
    ans = InputBox("Nem található '" & sheetName & "' nevű munkalap." & vbCrLf & _
                   "Add meg a pontos lapnevet (vagy hagyd üresen az első laphoz):", _
                   "Munkalap kiválasztása", sheetName)
    If ans = "" And StrPtr(ans) = 0 Then   ' Cancel
        Set GetSheetByNameOrPrompt = Nothing
        Exit Function
    End If
    If Trim$(ans) = "" Then
        Set GetSheetByNameOrPrompt = wb.Worksheets(1)
        Exit Function
    End If
    On Error Resume Next
    Set ws = wb.Worksheets(Trim$(ans))
    On Error GoTo 0
    Set GetSheetByNameOrPrompt = ws   ' Nothing, ha még mindig nem találja
End Function
