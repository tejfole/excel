Attribute VB_Name = "modImportCore"
Option Explicit

' =============================================================================
' modImportCore – Diákadat import alap-utilok (clean)
' =============================================================================
' Tartalom:
'   OpenReadOnly          – forrás munkafüzet megnyitása csak olvasásra
'   CloseReadOnly         – forrás munkafüzet biztonságos bezárása
'   BuildHeaderMap        – fejléc → oszlopindex Dictionary (NKey kulccsal)
'   GetSheetByNameOrPrompt – munkalap neve alapján vagy InputBox-szal
'   FirstMatchingHeaderCol – alias lista alapján első egyező fejléc-oszlop
'   BuildDestIndex        – cél ListObject kulcs → sorindex Dictionary
'   WriteIfEmpty          – cellát csak akkor ír, ha üres
' =============================================================================

' ---------------------------------------------------------------------------
' OpenReadOnly – megnyit egy Excel fájlt csak olvasásra
'   Visszatér Nothing, ha a path üres vagy megnyitás sikertelen.
' ---------------------------------------------------------------------------
Public Function OpenReadOnly(ByVal filePath As String) As Workbook
    If filePath = "" Then
        Set OpenReadOnly = Nothing
        Exit Function
    End If
    On Error GoTo OpenFail
    Set OpenReadOnly = Workbooks.Open(filePath, ReadOnly:=True)
    Exit Function
OpenFail:
    MsgBox "Nem sikerült megnyitni a fájlt: " & vbCrLf & filePath & vbCrLf & vbCrLf & _
           Err.Description, vbExclamation
    Set OpenReadOnly = Nothing
End Function

' ---------------------------------------------------------------------------
' CloseReadOnly – biztonságosan bezár egy munkafüzetet mentés nélkül
'   Nothing esetén csendesen kilép.
' ---------------------------------------------------------------------------
Public Sub CloseReadOnly(ByRef wb As Workbook)
    If wb Is Nothing Then Exit Sub
    On Error Resume Next
    wb.Close SaveChanges:=False
    On Error GoTo 0
    Set wb = Nothing
End Sub

' ---------------------------------------------------------------------------
' BuildHeaderMap – Dictionary: NKey(fejléc) → oszlopindex
'   Első egyező kulcs tárolódik (duplikált fejléc esetén az első nyer).
' ---------------------------------------------------------------------------
Public Function BuildHeaderMap(ByVal ws As Worksheet, _
                                Optional ByVal headerRow As Long = 1) As Object
    Dim d As Object
    Set d = CreateObject("Scripting.Dictionary")
    Dim lastCol As Long
    lastCol = ws.Cells(headerRow, ws.Columns.Count).End(xlToLeft).Column
    Dim c As Long, h As String, nk As String
    For c = 1 To lastCol
        h = Trim$(CStr(ws.Cells(headerRow, c).Value))
        If h <> "" Then
            nk = NKey(h)
            If Not d.Exists(nk) Then d(nk) = c
        End If
    Next c
    Set BuildHeaderMap = d
End Function

' ---------------------------------------------------------------------------
' GetSheetByNameOrPrompt – visszaadja a kért nevű munkalapot;
'   ha nincs, InputBox kér be új nevet (üres / Cancel → Nothing)
' ---------------------------------------------------------------------------
Public Function GetSheetByNameOrPrompt(ByVal wb As Workbook, _
                                        ByVal defaultName As String) As Worksheet
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = wb.Worksheets(defaultName)
    On Error GoTo 0

    If ws Is Nothing Then
        Dim shName As String
        shName = InputBox("Nem található '" & defaultName & "' nevű munkalap." & vbCrLf & _
                          "Adja meg a forrás munkalap nevét:", "Munkalap kiválasztás", defaultName)
        shName = Trim$(shName)
        If shName = "" Then
            Set GetSheetByNameOrPrompt = Nothing
            Exit Function
        End If
        On Error Resume Next
        Set ws = wb.Worksheets(shName)
        On Error GoTo 0
        If ws Is Nothing Then
            MsgBox "Nem találom ezt a munkalapot: """ & shName & """", vbExclamation
            Set GetSheetByNameOrPrompt = Nothing
            Exit Function
        End If
    End If

    Set GetSheetByNameOrPrompt = ws
End Function

' ---------------------------------------------------------------------------
' FirstMatchingHeaderCol – alias lista (pontosvesszővel elválasztva) alapján
'   megkeresi az első egyező fejléc oszlopindexét a headerMap-ben.
'   Visszatér -1, ha egyik alias sem található.
' ---------------------------------------------------------------------------
Public Function FirstMatchingHeaderCol(ByVal headerMap As Object, _
                                        ByVal aliasList As String) As Long
    Dim aliases As Variant
    aliases = Split(aliasList, ";")
    Dim i As Long
    For i = LBound(aliases) To UBound(aliases)
        Dim nk As String
        nk = NKey(Trim$(CStr(aliases(i))))
        If nk <> "" And headerMap.Exists(nk) Then
            FirstMatchingHeaderCol = CLng(headerMap(nk))
            Exit Function
        End If
    Next i
    FirstMatchingHeaderCol = -1
End Function

' ---------------------------------------------------------------------------
' BuildDestIndex – cél ListObject kulcsoszlop → sorindex Dictionary építés
'   idx: kulcs (String) → ListRow.Index (Long)
' ---------------------------------------------------------------------------
Public Sub BuildDestIndex(ByVal lo As ListObject, _
                           ByVal keyColIndex As Long, _
                           ByRef idx As Object)
    idx.RemoveAll
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
' WriteIfEmpty – cellát csak akkor írja, ha jelenleg üres
'   Visszatér True, ha valóban írt.
' ---------------------------------------------------------------------------
Public Function WriteIfEmpty(ByVal cell As Range, ByVal val As Variant) As Boolean
    If IsEmpty(cell.Value) Or Trim$(CStr(cell.Value)) = "" Then
        cell.Value = val
        WriteIfEmpty = True
    Else
        WriteIfEmpty = False
    End If
End Function
