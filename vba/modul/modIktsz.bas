Attribute VB_Name = "modIktsz"
Option Explicit

' ============================================================================
' Iktsz közös kitöltő
' ----------------------------------------------------------------------------
' A repository-ben 3 iktsz-kiosztási minta támogatott:
' 1) isk_nev alapú (lista.iktsz)
' 2) oktazon alapú (lista.iktsz)
' 3) feltételes kiosztás (pl. bizottsag+datum_nap kulcs; csak megadott
'    feltételek teljesülésekor; meglévő iktsz-ek folytatásával)
'
' Belépési pontok (wrapper makrók):
' - IktszIskolaErthez.KitoltIktsz_TablaAutomatikusan
' - IktszSzamFeltoltese.KitoltIktsz_TablaAutomatikusan
' - SendMailSzobeliMeghivo.FillIktszColumn
' ============================================================================

Public Function FillIktsz(ByVal tableName As String, _
                          ByVal keyCols As Variant, _
                          ByVal iktszColName As String, _
                          Optional ByVal defaultStart As Long = 1, _
                          Optional ByVal requiredNonEmptyCols As Variant = Empty, _
                          Optional ByVal continueFromExisting As Boolean = False, _
                          Optional ByVal askStart As Boolean = True, _
                          Optional ByVal clearWhenConditionFails As Boolean = True) As Boolean

    Dim tbl As ListObject
    Set tbl = FindListObjectInWorkbook(tableName)
    If tbl Is Nothing Then
        MsgBox "Nem található '" & tableName & "' nevű tábla egyik munkalapon sem!", vbCritical
        Exit Function
    End If

    Dim iktszCol As ListColumn
    Set iktszCol = FindColumnByName(tbl, iktszColName)
    If iktszCol Is Nothing Then
        MsgBox "Hiányzik az '" & iktszColName & "' oszlop a táblában!", vbCritical
        Exit Function
    End If

    Dim keyIndexes As Variant
    keyIndexes = ResolveColumnIndexes(tbl, keyCols)
    If IsEmpty(keyIndexes) Then
        MsgBox "Hiányzik legalább egy kulcs oszlop.", vbCritical
        Exit Function
    End If

    Dim requiredIndexes As Variant
    requiredIndexes = ResolveColumnIndexes(tbl, requiredNonEmptyCols)
    If IsArray(requiredNonEmptyCols) And IsEmpty(requiredIndexes) Then
        MsgBox "Hiányzik legalább egy feltétel oszlop.", vbCritical
        Exit Function
    End If

    Dim dict As Object
    Set dict = CreateObject("Scripting.Dictionary")

    Dim i As Long
    Dim key As String
    Dim curr As Variant
    Dim maxExisting As Long
    maxExisting = defaultStart - 1

    If continueFromExisting Then
        For i = 1 To tbl.ListRows.count
            key = BuildKeyFromRow(tbl, i, keyIndexes)
            curr = tbl.DataBodyRange.Cells(i, iktszCol.Index).value

            If key <> "" And IsNumeric(curr) Then
                If CLng(curr) > maxExisting Then maxExisting = CLng(curr)
                If Not dict.Exists(key) Then
                    dict.Add key, CLng(curr)
                End If
            End If
        Next i
    End If

    Dim nextNum As Long
    nextNum = defaultStart
    If continueFromExisting And maxExisting >= nextNum Then
        nextNum = maxExisting + 1
    End If

    If askStart Then
        nextNum = AskForStart(nextNum)
        If nextNum = 0 Then Exit Function
    End If

    For i = 1 To tbl.ListRows.count
        key = BuildKeyFromRow(tbl, i, keyIndexes)
        curr = tbl.DataBodyRange.Cells(i, iktszCol.Index).value

        If key <> "" And IsRowEligible(tbl, i, requiredIndexes) Then
            If IsNumeric(curr) And continueFromExisting Then
                If Not dict.Exists(key) Then dict.Add key, CLng(curr)
                tbl.DataBodyRange.Cells(i, iktszCol.Index).value = CLng(curr)
            Else
                If Not dict.Exists(key) Then
                    dict.Add key, nextNum
                    nextNum = nextNum + 1
                End If
                tbl.DataBodyRange.Cells(i, iktszCol.Index).value = dict(key)
            End If
        ElseIf clearWhenConditionFails Then
            tbl.DataBodyRange.Cells(i, iktszCol.Index).value = ""
        End If
    Next i
    FillIktsz = True
End Function

Private Function AskForStart(ByVal defaultStart As Long) As Long
    Dim raw As String
    raw = Trim$(InputBox("Add meg a kezdő iktsz számot:", "Kezdő iktsz", CStr(defaultStart)))

    If raw = "" Then
        AskForStart = 0
        Exit Function
    End If

    If Not IsNumeric(raw) Then
        MsgBox "A kezdő iktsz csak szám lehet.", vbExclamation
        AskForStart = 0
        Exit Function
    End If

    AskForStart = CLng(raw)
End Function

Private Function FindListObjectInWorkbook(ByVal tableName As String) As ListObject
    Dim ws As Worksheet
    Dim lo As ListObject

    For Each ws In ThisWorkbook.Worksheets
        For Each lo In ws.ListObjects
            If LCase$(Trim$(lo.Name)) = LCase$(Trim$(tableName)) Then
                Set FindListObjectInWorkbook = lo
                Exit Function
            End If
        Next lo
    Next ws
End Function

Private Function FindColumnByName(ByVal tbl As ListObject, ByVal colName As String) As ListColumn
    Dim col As ListColumn
    For Each col In tbl.ListColumns
        If LCase$(Trim$(col.Name)) = LCase$(Trim$(colName)) Then
            Set FindColumnByName = col
            Exit Function
        End If
    Next col
End Function

Private Function ResolveColumnIndexes(ByVal tbl As ListObject, ByVal colNames As Variant) As Variant
    Dim arrNames() As Variant
    arrNames = NormalizeToArray(colNames)

    If (Not IsArray(arrNames)) Then Exit Function

    Dim idx() As Long
    ReDim idx(LBound(arrNames) To UBound(arrNames))

    Dim i As Long
    Dim col As ListColumn

    For i = LBound(arrNames) To UBound(arrNames)
        Set col = FindColumnByName(tbl, CStr(arrNames(i)))
        If col Is Nothing Then Exit Function
        idx(i) = col.Index
    Next i

    ResolveColumnIndexes = idx
End Function

Private Function NormalizeToArray(ByVal v As Variant) As Variant
    Dim a() As Variant

    If IsEmpty(v) Then Exit Function

    If IsArray(v) Then
        NormalizeToArray = v
        Exit Function
    End If

    ReDim a(0 To 0)
    a(0) = v
    NormalizeToArray = a
End Function

Private Function BuildKeyFromRow(ByVal tbl As ListObject, ByVal rowIdx As Long, ByVal keyIndexes As Variant) As String
    Dim i As Long
    Dim part As String
    Dim key As String

    For i = LBound(keyIndexes) To UBound(keyIndexes)
        part = Trim$(CStr(tbl.DataBodyRange.Cells(rowIdx, CLng(keyIndexes(i))).value))
        If part = "" Then
            BuildKeyFromRow = ""
            Exit Function
        End If
        key = key & "|" & part
    Next i

    BuildKeyFromRow = key
End Function

Private Function IsRowEligible(ByVal tbl As ListObject, ByVal rowIdx As Long, ByVal requiredIndexes As Variant) As Boolean
    Dim i As Long
    Dim v As String

    If IsEmpty(requiredIndexes) Then
        IsRowEligible = True
        Exit Function
    End If

    For i = LBound(requiredIndexes) To UBound(requiredIndexes)
        v = Trim$(CStr(tbl.DataBodyRange.Cells(rowIdx, CLng(requiredIndexes(i))).value))
        If v = "" Then Exit Function
    Next i

    IsRowEligible = True
End Function
