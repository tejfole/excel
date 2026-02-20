Attribute VB_Name = "SzuressNev2"
Function SzuressNev(Optional Valasztas As String = "", Optional SorIndex As Integer = 0, Optional KeresettErtek As Variant = "x") As Variant
    Dim eredmenyek As Variant

    If Valasztas = "" Then
        On Error Resume Next
        Valasztas = Trim(LCase(CStr(ActiveSheet.Range("B1").value)))
        On Error GoTo 0
    End If

    Select Case LCase(Valasztas)
        Case "elut"
            eredmenyek = SzuresElut(True)
        Case "elutkevespont"
            eredmenyek = SzuresElut(False)
        Case "felvesz", "mastvalaszt"
            eredmenyek = SzuresAltalanos(Valasztas, KeresettErtek)
        Case "kevespont"
            eredmenyek = SzuresKevesPont()
        Case "visszalep"
            eredmenyek = SzuresVisszalepett()
        Case Else
            SzuressNev = CVErr(xlErrValue)
        
         Exit Function
    End Select

    On Error GoTo Hibakezeles

    If IsEmpty(eredmenyek) Then
        SzuressNev = ""
    ElseIf IsArray(eredmenyek) Then
        If Not IsNumeric(LBound(eredmenyek)) Or Not IsNumeric(UBound(eredmenyek)) Then
            SzuressNev = ""
        ElseIf UBound(eredmenyek) = 0 Then
            SzuressNev = ""
        ElseIf SorIndex = 0 Then
            SzuressNev = Application.Transpose(eredmenyek)
        ElseIf SorIndex > 0 And SorIndex <= UBound(eredmenyek) Then
            SzuressNev = eredmenyek(SorIndex)
        Else
            SzuressNev = ""
        End If
    Else
        SzuressNev = eredmenyek
    End If

    Exit Function

Hibakezeles:
    SzuressNev = ""
End Function

Private Function SzuresElut(ByVal duplikalhat As Boolean) As Variant
    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim i As Long, j As Integer
    Dim matchCount As Long
    Dim elutOszlopok As Variant
    Dim matches() As String
    Dim elutIndex As Integer, nevIndex As Integer, jelenIndex As Integer, irasbeliIndex As Integer
    Dim irasbeliValue As Variant
    Dim nev As String
    Dim addedDict As Object
    Dim dataArr As Variant
    Dim visszalepettIndex As Integer

    Set ws = ThisWorkbook.Sheets("rangsor")
    Set tbl = ws.ListObjects("rangsor")

    Set addedDict = CreateObject("Scripting.Dictionary")
    elutOszlopok = Array("j_1000", "j_2000", "j_3000", "j_4000")
    elutIndex = GetColIndexByName(tbl, "elut")
    nevIndex = GetColIndexByName(tbl, "nev")
    irasbeliIndex = GetColIndexByName(tbl, "irasbeliossz")
    visszalepettIndex = GetColIndexByName(tbl, "visszalepett")
    dataArr = tbl.DataBodyRange.value

    ReDim matches(1 To UBound(dataArr, 1) * UBound(elutOszlopok))
    matchCount = 0

    For i = 1 To UBound(dataArr, 1)
        If LCase(Trim(CStr(dataArr(i, visszalepettIndex)))) = "x" Then GoTo KovetkezoSor

        nev = Trim(CStr(dataArr(i, nevIndex)))
        irasbeliValue = dataArr(i, irasbeliIndex)

        If IsNumeric(irasbeliValue) And irasbeliValue < 70 Then
            If Not addedDict.Exists(nev) Then
                matchCount = matchCount + 1
                matches(matchCount) = nev
                addedDict.Add nev, True
            End If
        ElseIf LCase(Trim(CStr(dataArr(i, elutIndex)))) = "x" Then
            For j = LBound(elutOszlopok) To UBound(elutOszlopok)
                jelenIndex = GetColIndexByName(tbl, elutOszlopok(j))
                If LCase(Trim(CStr(dataArr(i, jelenIndex)))) = "x" Then
                    If duplikalhat Then
                        matchCount = matchCount + 1
                        matches(matchCount) = nev
                    ElseIf Not addedDict.Exists(nev) Then
                        matchCount = matchCount + 1
                        matches(matchCount) = nev
                        addedDict.Add nev, True
                        Exit For
                    End If
                End If
            Next j
        End If
KovetkezoSor:
    Next i

    If matchCount > 0 Then
        ReDim Preserve matches(1 To matchCount)
        SzuresElut = matches
    Else
        SzuresElut = Array("")
    End If
End Function

Private Function SzuresAltalanos(ByVal Valasztas As String, ByVal KeresettErtek As Variant) As Variant
    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim i As Long
    Dim matchCount As Long
    Dim matches() As String
    Dim keresettColIndex As Integer, nevColIndex As Integer, visszalepettIndex As Integer
    Dim dataArr As Variant

    Set ws = ThisWorkbook.Sheets("rangsor")
    Set tbl = ws.ListObjects("rangsor")

    dataArr = tbl.DataBodyRange.value
    keresettColIndex = GetColIndexByName(tbl, Valasztas)
    nevColIndex = GetColIndexByName(tbl, "nev")
    visszalepettIndex = GetColIndexByName(tbl, "visszalepett")

    ReDim matches(1 To UBound(dataArr, 1))
    matchCount = 0

    For i = 1 To UBound(dataArr, 1)
        If LCase(Trim(CStr(dataArr(i, visszalepettIndex)))) = "x" Then GoTo KovetkezoSor

        If MatchWithCriteria(dataArr(i, keresettColIndex), KeresettErtek, True) Then
            matchCount = matchCount + 1
            matches(matchCount) = dataArr(i, nevColIndex)
        End If
KovetkezoSor:
    Next i

    If matchCount > 0 Then
        ReDim Preserve matches(1 To matchCount)
        SzuresAltalanos = matches
    Else
        SzuresAltalanos = Array("")
    End If
End Function

Private Function SzuresKevesPont() As Variant
    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim i As Long
    Dim irasbeliValue As Variant
    Dim matchCount As Long
    Dim matches() As String
    Dim nevIndex As Integer, irasbeliIndex As Integer, visszalepettIndex As Integer
    Dim dataArr As Variant

    Set ws = ThisWorkbook.Sheets("rangsor")
    Set tbl = ws.ListObjects("rangsor")

    nevIndex = GetColIndexByName(tbl, "nev")
    irasbeliIndex = GetColIndexByName(tbl, "irasbeliossz")
    visszalepettIndex = GetColIndexByName(tbl, "visszalepett")
    dataArr = tbl.DataBodyRange.value

    ReDim matches(1 To UBound(dataArr, 1))
    matchCount = 0

    For i = 1 To UBound(dataArr, 1)
        If LCase(Trim(CStr(dataArr(i, visszalepettIndex)))) = "x" Then GoTo KovetkezoSor

        irasbeliValue = dataArr(i, irasbeliIndex)
        If IsNumeric(irasbeliValue) And irasbeliValue < 70 Then
            matchCount = matchCount + 1
            matches(matchCount) = dataArr(i, nevIndex)
        End If
KovetkezoSor:
    Next i

    If matchCount > 0 Then
        ReDim Preserve matches(1 To matchCount)
        SzuresKevesPont = matches
    Else
        SzuresKevesPont = Array("")
    End If
End Function

Private Function SzuresVisszalepett() As Variant
    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim dataArr As Variant
    Dim matches() As String
    Dim i As Long
    Dim nevIndex As Integer, visszalepettIndex As Integer
    Dim matchCount As Long

    Set ws = ThisWorkbook.Sheets("rangsor")
    Set tbl = ws.ListObjects("rangsor")

    dataArr = tbl.DataBodyRange.value
    nevIndex = GetColIndexByName(tbl, "nev")
    visszalepettIndex = GetColIndexByName(tbl, "visszalepett")

    ReDim matches(1 To UBound(dataArr, 1))
    matchCount = 0

    For i = 1 To UBound(dataArr, 1)
        If LCase(Trim(CStr(dataArr(i, visszalepettIndex)))) = "x" Then
            matchCount = matchCount + 1
            matches(matchCount) = dataArr(i, nevIndex)
        End If
    Next i

    If matchCount > 0 Then
        ReDim Preserve matches(1 To matchCount)
        SzuresVisszalepett = matches
    Else
        SzuresVisszalepett = Array("")
    End If
End Function

Private Function GetColIndexByName(ByVal tbl As ListObject, ByVal colName As String) As Integer
    On Error Resume Next
    GetColIndexByName = tbl.ListColumns(colName).Index
    On Error GoTo 0
End Function

Private Function MatchWithCriteria(ByVal cellValue As Variant, ByVal criteria As Variant, Optional ByVal partialMatch As Boolean = False) As Boolean
    Dim i As Long
    Dim cellStr As String

    cellStr = LCase(Trim(CStr(cellValue)))

    If IsArray(criteria) Then
        For i = LBound(criteria) To UBound(criteria)
            If partialMatch Then
                If InStr(cellStr, LCase(Trim(CStr(criteria(i))))) > 0 Then
                    MatchWithCriteria = True
                    Exit Function
                End If
            Else
                If cellStr = LCase(Trim(CStr(criteria(i)))) Then
                    MatchWithCriteria = True
                    Exit Function
                End If
            End If
        Next i
        MatchWithCriteria = False
    Else
        If partialMatch Then
            MatchWithCriteria = InStr(cellStr, LCase(Trim(CStr(criteria)))) > 0
        Else
            MatchWithCriteria = (cellStr = LCase(Trim(CStr(criteria))))
        End If
    End If
End Function


