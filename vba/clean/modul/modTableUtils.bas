Attribute VB_Name = "modTableUtils"
Option Explicit

' =============================================================================
' modTableUtils – ListObject táblakezelő utilok
' =============================================================================

' ---------------------------------------------------------------------------
' FindTableByName – munkafüzetben keres egy adott nevű ListObject-et
'   Visszatér Nothing, ha nem találja.
' ---------------------------------------------------------------------------
Public Function FindTableByName(ByVal wb As Workbook, _
                                ByVal tableName As String) As ListObject
    Dim ws As Worksheet
    Dim lo As ListObject
    For Each ws In wb.Worksheets
        For Each lo In ws.ListObjects
            If lo.Name = tableName Then
                Set FindTableByName = lo
                Exit Function
            End If
        Next lo
    Next ws
    Set FindTableByName = Nothing
End Function

' ---------------------------------------------------------------------------
' ColIndex – oszlopindex keresése ListObject-ben fejlécnév alapján
'   required=True  → ha nem találja, MsgBox + visszatér -1
'   required=False → ha nem találja, visszatér -1 (csend)
' ---------------------------------------------------------------------------
Public Function ColIndex(ByVal lo As ListObject, _
                          ByVal colName As String, _
                          Optional ByVal required As Boolean = True) As Long
    Dim lc As ListColumn
    For Each lc In lo.ListColumns
        If lc.Name = colName Then
            ColIndex = lc.Index
            Exit Function
        End If
    Next lc
    ' Nem találta
    If required Then
        MsgBox "Hiányzó oszlop: """ & colName & """ a(z) """ & lo.Name & """ táblában.", vbExclamation
    End If
    ColIndex = -1
End Function

' ---------------------------------------------------------------------------
' SafeValD – Variant → Double, hiba/Empty/Nothing esetén def
' ---------------------------------------------------------------------------
Public Function SafeValD(ByVal v As Variant, _
                          Optional ByVal def As Double = 0) As Double
    If IsEmpty(v) Or IsNull(v) Then
        SafeValD = def
        Exit Function
    End If
    If IsError(v) Then
        SafeValD = def
        Exit Function
    End If
    On Error Resume Next
    Dim d As Double
    d = CDbl(v)
    If Err.Number <> 0 Then
        d = def
        Err.Clear
    End If
    On Error GoTo 0
    SafeValD = d
End Function

' ---------------------------------------------------------------------------
' IsFlagX – True, ha a cella értéke "x" vagy "X" (jelölőnégyzet-szerű flag)
' ---------------------------------------------------------------------------
Public Function IsFlagX(ByVal v As Variant) As Boolean
    If IsEmpty(v) Or IsNull(v) Or IsError(v) Then
        IsFlagX = False
        Exit Function
    End If
    IsFlagX = (Trim$(CStr(v)) = "x" Or Trim$(CStr(v)) = "X")
End Function
