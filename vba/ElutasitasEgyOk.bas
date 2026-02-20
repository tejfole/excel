Attribute VB_Name = "ElutasitasEgyOk"
Function ElutasitasEgyOk2(nev As String, elutasitasIndex As Integer) As String
    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim i As Long, j As Integer
    Dim dataArr As Variant
    Dim elutOszlopok As Variant
    Dim nevIndex As Integer, irasbeliIndex As Integer, elutIndex As Integer, jelenIndex As Integer
    Dim irasbeliValue As Variant
    Dim cellNev As String
    Dim countTalalat As Integer

    Set ws = ThisWorkbook.Sheets("rangsor")
    Set tbl = ws.ListObjects("rangsor")
    dataArr = tbl.DataBodyRange.value

    elutOszlopok = Array("j_1000", "j_2000", "j_3000", "j_4000")
    nevIndex = GetColIndexByName(tbl, "nev")
    irasbeliIndex = GetColIndexByName(tbl, "irasbeliossz")
    elutIndex = GetColIndexByName(tbl, "elut")
    countTalalat = 0

    ' Ha valamelyik oszlop hiányzik, térjen vissza hibával
    If nevIndex = -1 Or irasbeliIndex = -1 Or elutIndex = -1 Then
        ElutasitasEgyOk2 = "hiba: hiányzó oszlop"
        Exit Function
    End If

    For i = 1 To UBound(dataArr, 1)
        cellNev = Trim(LCase(CStr(dataArr(i, nevIndex))))
        If cellNev = Trim(LCase(nev)) Then
            irasbeliValue = dataArr(i, irasbeliIndex)

            ' Kevéspont
            If IsNumeric(irasbeliValue) And irasbeliValue < 70 Then
                countTalalat = countTalalat + 1
                If countTalalat = elutasitasIndex Then
                    ElutasitasEgyOk2 = "kevéspont"
                    Exit Function
                End If
            End If

            ' j_ oszlopok
            If LCase(Trim(CStr(dataArr(i, elutIndex)))) = "x" Then
                For j = LBound(elutOszlopok) To UBound(elutOszlopok)
                    jelenIndex = GetColIndexByName(tbl, elutOszlopok(j))
                    If jelenIndex <> -1 Then
                        If LCase(Trim(CStr(dataArr(i, jelenIndex)))) = "x" Then
                            countTalalat = countTalalat + 1
                            If countTalalat = elutasitasIndex Then
                                ElutasitasEgyOk2 = Replace(elutOszlopok(j), "j_", "")
                                Exit Function
                            End If
                        End If
                    End If
                Next j
            End If
        End If
    Next i

    ElutasitasEgyOk2 = ""
End Function

Private Function GetColIndexByName(ByVal tbl As ListObject, ByVal colName As String) As Integer
    On Error Resume Next
    GetColIndexByName = tbl.ListColumns(colName).Index
    On Error GoTo 0
    If GetColIndexByName = 0 Then
        GetColIndexByName = -1
    End If
End Function

