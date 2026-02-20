Attribute VB_Name = "TagozatSzures"
Sub TagozatSzures_SzamitottRangsorral()

    Dim loInput As ListObject, loOutput As ListObject, loRangsor As ListObject
    Dim tbl As ListObject, ws As Worksheet
    Dim wb As Workbook: Set wb = ThisWorkbook
    Dim i As Long
    Dim tagozatKod As String, szuresOszlopNev As String
    Dim nevCol As Long, oktazonCol As Long, pontCol As Long, szuresCol As Long
    Dim rFelveszCol As Long, rMasikCol As Long, rVisszaCol As Long, rOktazonCol As Long
    Dim oktazonRangsorDict As Object: Set oktazonRangsorDict = CreateObject("Scripting.Dictionary")
    Dim ertek As String, aktuOktazon As String
    Dim outRow As ListRow

    ' Tábla beazonosítás
    For Each ws In wb.Sheets
        For Each tbl In ws.ListObjects
            If tbl.Name = "diakadat" Then Set loInput = tbl
            If tbl.Name = "rangsor" Then Set loRangsor = tbl
            If tbl.Name = "tagozatokszures" Then Set loOutput = tbl
        Next tbl
    Next ws

    If loInput Is Nothing Or loRangsor Is Nothing Or loOutput Is Nothing Then
        MsgBox "Hiányzik valamelyik tábla: diakadat, rangsor vagy tagozatokszures", vbCritical
        Exit Sub
    End If

    ' B1 cella beolvasása
    tagozatKod = LCase(Trim(CStr(ThisWorkbook.Sheets("tagozat").Range("B1").value)))
    If tagozatKod = "" Then
        MsgBox "A tagozat B1 cellája üres.", vbExclamation
        Exit Sub
    End If
    szuresOszlopNev = "j_" & tagozatKod

    ' Oszlop indexek
    On Error Resume Next
    nevCol = loInput.ListColumns("f_nev").Index
    oktazonCol = loInput.ListColumns("oktazon").Index
    pontCol = loInput.ListColumns("p_mindossz").Index
    szuresCol = loInput.ListColumns(szuresOszlopNev).Index
    rOktazonCol = loRangsor.ListColumns("oktazon").Index
    rFelveszCol = loRangsor.ListColumns("felvesz").Index
    rMasikCol = loRangsor.ListColumns("mastvalaszt").Index
    rVisszaCol = loRangsor.ListColumns("visszalepett").Index
    On Error GoTo 0

    If nevCol = 0 Or oktazonCol = 0 Or pontCol = 0 Or szuresCol = 0 Then
        MsgBox "Hiányzik valamelyik szükséges oszlop!", vbCritical
        Exit Sub
    End If

    ' Elõszûrés: kizárt oktazonok
    For i = 1 To loRangsor.ListRows.count
        aktuOktazon = Trim(CStr(loRangsor.DataBodyRange(i, rOktazonCol).value))
        If aktuOktazon <> "" Then
            If LCase(loRangsor.DataBodyRange(i, rFelveszCol).value) = "x" _
            Or LCase(loRangsor.DataBodyRange(i, rMasikCol).value) = "x" _
            Or LCase(loRangsor.DataBodyRange(i, rVisszaCol).value) = "x" Then
                oktazonRangsorDict(aktuOktazon) = True
            End If
        End If
    Next i

    ' Kiürítés cél táblából
    Do While loOutput.ListRows.count > 0
        loOutput.ListRows(1).Delete
    Loop

    ' Rangsor mezõk beállítása
    Dim Pontok As Range, Hatranyos As Range, Lakcim As Range, Testver As Range
    Dim szobeli As Range, matek As Range, magyar As Range, Fogalmazas As Range

    Set Pontok = loInput.ListColumns("p_mindossz").DataBodyRange
    Set Hatranyos = loInput.ListColumns("f_hatranyos").DataBodyRange
    Set Lakcim = loInput.ListColumns("I_ker_irsz").DataBodyRange
    Set Testver = loInput.ListColumns("f_testver").DataBodyRange
    Set szobeli = loInput.ListColumns("szobeli").DataBodyRange
    Set matek = loInput.ListColumns("p_matek").DataBodyRange
    Set magyar = loInput.ListColumns("p_magyar").DataBodyRange
    Set Fogalmazas = loInput.ListColumns("p_bemutatkozas").DataBodyRange

    ' Adatok másolása
    For i = 1 To loInput.ListRows.count
        aktuOktazon = Trim(CStr(loInput.DataBodyRange(i, oktazonCol).value))
        ertek = LCase(Trim(loInput.DataBodyRange(i, szuresCol).value))

        If ertek = "x" And Not oktazonRangsorDict.Exists(aktuOktazon) Then
            Set outRow = loOutput.ListRows.Add
            outRow.Range(1, 1).value = loInput.DataBodyRange(i, nevCol).value
            outRow.Range(1, 2).value = aktuOktazon
            outRow.Range(1, 3).value = loInput.DataBodyRange(i, pontCol).value
            outRow.Range(1, 4).value = SzamitRangot(loInput.DataBodyRange(i, pontCol).value, _
                Pontok, Hatranyos, Lakcim, Testver, szobeli, matek, magyar, Fogalmazas)
        End If
    Next i

    ' ?? Színezés külön ciklusban
    Dim oktazonOutCol As Long, outSzam As Long
    Dim irszIndex As Long, testverIndex As Long
    Dim keresettOktazon As String
    oktazonOutCol = loOutput.ListColumns("oktazon").Index
    irszIndex = loInput.ListColumns("I_ker_irsz").Index
    testverIndex = loInput.ListColumns("f_testver").Index

    For outSzam = 1 To loOutput.ListRows.count
        keresettOktazon = Trim(CStr(loOutput.DataBodyRange(outSzam, oktazonOutCol).value))
        For i = 1 To loInput.ListRows.count
            If Trim(CStr(loInput.DataBodyRange(i, oktazonCol).value)) = keresettOktazon Then
                Dim irszX As Boolean, testverX As Boolean
                irszX = (LCase(Trim(CStr(loInput.DataBodyRange(i, irszIndex).value))) = "x")
                testverX = (LCase(Trim(CStr(loInput.DataBodyRange(i, testverIndex).value))) = "x")

                If irszX And testverX Then
                    loOutput.ListRows(outSzam).Range.Interior.color = RGB(180, 220, 255) ' világoskék
                ElseIf testverX Then
                    loOutput.ListRows(outSzam).Range.Interior.color = RGB(200, 255, 200) ' világoszöld
                ElseIf irszX Then
                    loOutput.ListRows(outSzam).Range.Interior.color = RGB(255, 255, 150) ' világossárga
                End If
                Exit For
            End If
        Next i
    Next outSzam

    ' Rendezés
    On Error Resume Next
    loOutput.Sort.SortFields.Clear
    loOutput.Sort.SortFields.Add key:=loOutput.ListColumns("p_mindossz").DataBodyRange, _
        SortOn:=xlSortOnValues, Order:=xlDescending
    loOutput.Sort.SortFields.Add key:=loOutput.ListColumns("szamitott_rang").DataBodyRange, _
        SortOn:=xlSortOnValues, Order:=xlAscending
    With loOutput.Sort
        .Header = xlYes
        .Apply
    End With
    On Error GoTo 0

    MsgBox "Rangsorolás és színezés kész: tagozat = " & tagozatKod, vbInformation

End Sub


