Attribute VB_Name = "modIktsz"
Option Explicit

' Central iktsz workflows:
' 1) lista institutional notification: grouped by isk_nev
' 2) lista hatarozat: unique sequential per eligible row (keep existing values)
' 3) diakadat oral notification: conditional sequential (keep existing values)

Public Sub FillIktsz_ListaIntezmenyiErtesites(Optional control As IRibbonControl)
    Dim lo As ListObject
    Set lo = FindTableByName("lista")
    If lo Is Nothing Then
        MsgBox "Nem talalhato 'lista' nevu tabla.", vbCritical
        Exit Sub
    End If

    Dim keyCol As Long
    Dim iktszCol As Long

    keyCol = GetColumnIndex(lo, "isk_nev")
    iktszCol = GetColumnIndex(lo, "iktsz")

    If keyCol = 0 Or iktszCol = 0 Then
        MsgBox "Hianyzik az 'isk_nev' vagy 'iktsz' oszlop a 'lista' tablaban.", vbCritical
        Exit Sub
    End If

    Dim startNum As Long
    startNum = PromptStartNumber("Kezdo iktsz", 1, False, 0)
    If startNum = 0 Then Exit Sub

    AssignGroupedIktsz lo, keyCol, iktszCol, startNum

    MsgBox "Kesz: iktsz kitoltve intezmenyi ertesiteshez (isk_nev alapjan).", vbInformation
End Sub

Public Sub FillIktsz_ListaHatarozatok(Optional control As IRibbonControl)
    Dim lo As ListObject
    Set lo = FindTableByName("lista")
    If lo Is Nothing Then
        MsgBox "Nem talalhato 'lista' nevu tabla.", vbCritical
        Exit Sub
    End If

    Dim iktszCol As Long
    iktszCol = GetColumnIndex(lo, "iktsz")
    If iktszCol = 0 Then
        MsgBox "Hianyzik az 'iktsz' oszlop a 'lista' tablaban.", vbCritical
        Exit Sub
    End If

    Dim continueFrom As Long
    continueFrom = GetMaxExistingIktsz(lo, iktszCol) + 1
    If continueFrom < 1 Then continueFrom = 1

    Dim startNum As Long
    startNum = PromptStartNumber("Hatarozat iktsz", continueFrom, True, continueFrom)
    If startNum = 0 Then Exit Sub

    Dim i As Long
    For i = 1 To lo.ListRows.Count
        If IsEmptyValue(lo.DataBodyRange.Cells(i, iktszCol).Value) Then
            If IsListaHatarozatEligible(lo, i) Then
                lo.DataBodyRange.Cells(i, iktszCol).Value = startNum
                startNum = startNum + 1
            End If
        End If
    Next i

    MsgBox "Kesz: hatarozat iktsz kitoltve (soronkent egyedi).", vbInformation
End Sub

Public Sub FillIktszColumn(Optional control As IRibbonControl)
    Dim lo As ListObject
    Set lo = FindTableByName("diakadat")
    If lo Is Nothing Then
        MsgBox "Nem talalhato 'diakadat' nevu tabla.", vbCritical
        Exit Sub
    End If

    Dim iktszCol As Long
    Dim bizottsagCol As Long
    Dim datumCol As Long
    Dim mailCol As Long
    Dim kiadvaCol As Long

    iktszCol = GetColumnIndex(lo, "iktsz")
    bizottsagCol = GetColumnIndex(lo, "bizottsag")
    datumCol = GetColumnIndex(lo, "datum_nap")
    mailCol = GetColumnIndex(lo, "mail")
    kiadvaCol = GetColumnIndex(lo, "idopont_kiadva")

    If iktszCol = 0 Or bizottsagCol = 0 Or datumCol = 0 Or mailCol = 0 Or kiadvaCol = 0 Then
        MsgBox "Hianyzik egy szukseges oszlop: iktsz, bizottsag, datum_nap, mail, idopont_kiadva.", vbCritical
        Exit Sub
    End If

    Dim continueFrom As Long
    continueFrom = GetMaxExistingIktsz(lo, iktszCol) + 1
    If continueFrom < 1 Then continueFrom = 1

    Dim startNum As Long
    startNum = PromptStartNumber("Szobeli iktsz", continueFrom, True, continueFrom)
    If startNum = 0 Then Exit Sub

    Dim i As Long
    For i = 1 To lo.ListRows.Count
        If IsEmptyValue(lo.DataBodyRange.Cells(i, iktszCol).Value) Then
            If IsDiakadatEligible(lo, i, bizottsagCol, datumCol, mailCol, kiadvaCol) Then
                lo.DataBodyRange.Cells(i, iktszCol).Value = startNum
                startNum = startNum + 1
            End If
        End If
    Next i

    MsgBox "Kesz: szobeli idopont kiertesiteshez iktsz kitoltve.", vbInformation
End Sub

Private Sub AssignGroupedIktsz(ByVal lo As ListObject, ByVal keyCol As Long, ByVal iktszCol As Long, ByVal startNum As Long)
    Dim dict As Object
    Set dict = CreateObject("Scripting.Dictionary")

    Dim i As Long
    Dim key As String

    For i = 1 To lo.ListRows.Count
        key = Trim$(CStr(lo.DataBodyRange.Cells(i, keyCol).Value))

        If key <> "" Then
            If Not dict.Exists(key) Then
                dict.Add key, startNum
                startNum = startNum + 1
            End If
            lo.DataBodyRange.Cells(i, iktszCol).Value = dict(key)
        Else
            lo.DataBodyRange.Cells(i, iktszCol).Value = ""
        End If
    Next i
End Sub

Private Function IsListaHatarozatEligible(ByVal lo As ListObject, ByVal rowIndex As Long) As Boolean
    Dim felveszCol As Long
    Dim elutCol As Long
    Dim mastValasztCol As Long
    Dim hatarozatCol As Long

    felveszCol = GetColumnIndex(lo, "felvesz", False)
    elutCol = GetColumnIndex(lo, "elut", False)
    mastValasztCol = GetColumnIndex(lo, "mastvalaszt", False)
    hatarozatCol = GetColumnIndex(lo, "hatarozat", False)

    If felveszCol > 0 Then
        If IsXFlag(lo.DataBodyRange.Cells(rowIndex, felveszCol).Value) Then IsListaHatarozatEligible = True: Exit Function
    End If

    If elutCol > 0 Then
        If IsXFlag(lo.DataBodyRange.Cells(rowIndex, elutCol).Value) Then IsListaHatarozatEligible = True: Exit Function
    End If

    If mastValasztCol > 0 Then
        If IsXFlag(lo.DataBodyRange.Cells(rowIndex, mastValasztCol).Value) Then IsListaHatarozatEligible = True: Exit Function
    End If

    If hatarozatCol > 0 Then
        If Not IsEmptyValue(lo.DataBodyRange.Cells(rowIndex, hatarozatCol).Value) Then IsListaHatarozatEligible = True: Exit Function
    End If

    If felveszCol = 0 And elutCol = 0 And mastValasztCol = 0 And hatarozatCol = 0 Then
        IsListaHatarozatEligible = True
    End If
End Function

Private Function IsDiakadatEligible(ByVal lo As ListObject, ByVal rowIndex As Long, ByVal bizottsagCol As Long, ByVal datumCol As Long, ByVal mailCol As Long, ByVal kiadvaCol As Long) As Boolean
    If IsEmptyValue(lo.DataBodyRange.Cells(rowIndex, bizottsagCol).Value) Then Exit Function
    If IsEmptyValue(lo.DataBodyRange.Cells(rowIndex, datumCol).Value) Then Exit Function
    If IsEmptyValue(lo.DataBodyRange.Cells(rowIndex, mailCol).Value) Then Exit Function
    If IsXFlag(lo.DataBodyRange.Cells(rowIndex, kiadvaCol).Value) Then Exit Function

    IsDiakadatEligible = True
End Function

Private Function PromptStartNumber(ByVal title As String, ByVal defaultValue As Long, ByVal allowContinue As Boolean, ByVal continueValue As Long) As Long
    Dim msg As String
    Dim userInput As String

    If allowContinue Then
        msg = "Add meg a kezdo iktsz szamot." & vbCrLf & _
              "Ha uresen hagyod, folytatas a meglevo max utan: " & CStr(continueValue)
    Else
        msg = "Add meg a kezdo iktsz szamot."
    End If

    userInput = InputBox(msg, title, CStr(defaultValue))

    If StrPtr(userInput) = 0 Then
        PromptStartNumber = 0
        Exit Function
    End If

    userInput = Trim$(userInput)
    If allowContinue And userInput = "" Then
        PromptStartNumber = continueValue
        Exit Function
    End If

    If Not IsNumeric(userInput) Then
        MsgBox "A megadott ertek nem szam.", vbExclamation
        PromptStartNumber = 0
        Exit Function
    End If

    PromptStartNumber = CLng(userInput)
    If PromptStartNumber < 1 Then
        MsgBox "A kezdo iktsz legalabb 1 legyen.", vbExclamation
        PromptStartNumber = 0
    End If
End Function

Private Function GetMaxExistingIktsz(ByVal lo As ListObject, ByVal iktszCol As Long) As Long
    Dim i As Long
    Dim v As Variant
    Dim n As Long

    For i = 1 To lo.ListRows.Count
        v = lo.DataBodyRange.Cells(i, iktszCol).Value
        If IsNumeric(v) Then
            n = CLng(v)
            If n > GetMaxExistingIktsz Then
                GetMaxExistingIktsz = n
            End If
        End If
    Next i
End Function

Private Function FindTableByName(ByVal tableName As String) As ListObject
    Dim ws As Worksheet
    Dim lo As ListObject

    For Each ws In ThisWorkbook.Worksheets
        For Each lo In ws.ListObjects
            If LCase$(Trim$(lo.Name)) = LCase$(Trim$(tableName)) Then
                Set FindTableByName = lo
                Exit Function
            End If
        Next lo
    Next ws
End Function

Private Function GetColumnIndex(ByVal lo As ListObject, ByVal columnName As String, Optional ByVal required As Boolean = True) As Long
    Dim col As ListColumn

    For Each col In lo.ListColumns
        If LCase$(Trim$(col.Name)) = LCase$(Trim$(columnName)) Then
            GetColumnIndex = col.Index
            Exit Function
        End If
    Next col

    If required Then
        GetColumnIndex = 0
    End If
End Function

Private Function IsXFlag(ByVal v As Variant) As Boolean
    IsXFlag = (LCase$(Trim$(CStr(v))) = "x")
End Function

Private Function IsEmptyValue(ByVal v As Variant) As Boolean
    If IsError(v) Then
        IsEmptyValue = True
    Else
        IsEmptyValue = (Trim$(CStr(v)) = "")
    End If
End Function
