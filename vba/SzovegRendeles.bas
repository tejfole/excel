Attribute VB_Name = "SzovegRendeles"
Sub SzovegRendelesStrukturaltTablakkal()

    Dim listaT As ListObject, rangsorT As ListObject, szovegekT As ListObject
    Dim i As Long, j As Long
    Dim nev As String, nev_kereso As String, nevRangsor As String
    Dim irasbeli As Double
    Dim kategoria As String
    Dim szoveg As String
    Dim indok As String
    Dim hatarozat As String
    Dim megszolitInput As String
    Dim orommelInput As String
    Dim gratulaInput As String
    Dim tagozat As String
    Dim nevelo As String

    Set listaT = ThisWorkbook.Sheets("lista").ListObjects("lista")
    Set rangsorT = ThisWorkbook.Sheets("rangsor").ListObjects("rangsor")
    Set szovegekT = ThisWorkbook.Sheets("adatok").ListObjects("szovegek")

    On Error Resume Next
    listaT.ListColumns("szoveg").Name = "szoveg"
    listaT.ListColumns("indok").Name = "indok"
    listaT.ListColumns("megszolit").Name = "megszolit"
    listaT.ListColumns("hatarozat").Name = "hatarozat"
    listaT.ListColumns("orommel").Name = "orommel"
    listaT.ListColumns("gratula").Name = "gratula"
    If Err.Number <> 0 Then Err.Clear
    On Error GoTo 0

    For i = 1 To listaT.ListRows.count

        nev = listaT.ListColumns("nev").DataBodyRange.Cells(i, 1).value
        nev_kereso = Trim(LCase(nev))
        kategoria = ""
        szoveg = "Nincs adat"
        indok = ""
        hatarozat = ""
        megszolitInput = ""
        orommelInput = ""
        gratulaInput = ""

        For j = 1 To rangsorT.ListRows.count
            nevRangsor = Trim(LCase(rangsorT.ListColumns("nev").DataBodyRange.Cells(j, 1).value))
            If nev_kereso = nevRangsor Then
                irasbeli = rangsorT.ListColumns("irasbeliossz").DataBodyRange.Cells(j, 1).value

                If irasbeli < 70 Then
                    kategoria = "elegtelen"
                Else
                    If LCase(rangsorT.ListColumns("felvesz").DataBodyRange.Cells(j, 1).value) = "x" Then
                        kategoria = "felvesz"
                    ElseIf LCase(rangsorT.ListColumns("mastvalaszt").DataBodyRange.Cells(j, 1).value) = "x" Then
                        kategoria = "mastvalasz"
                    ElseIf LCase(rangsorT.ListColumns("elut").DataBodyRange.Cells(j, 1).value) = "x" Then
                        kategoria = "elut"
                    End If
                End If
                Exit For
            End If
        Next j

        If kategoria <> "" Then
            If kategoria = "felvesz" Then
                Dim resz1 As String, resz2 As String, resz3 As String
                Dim indok1 As String, indok2 As String
                Dim hat1 As String, hat2 As String, hat3 As String
                Dim nyelv1 As String, nyelv2 As String, nyelvossz As String

                For j = 1 To szovegekT.ListRows.count
                    If Trim(LCase(szovegekT.ListColumns("kategoria").DataBodyRange.Cells(j, 1).value)) = "felvesz" Then
                        resz1 = szovegekT.ListColumns("resz1").DataBodyRange.Cells(j, 1).value
                        resz2 = szovegekT.ListColumns("resz2").DataBodyRange.Cells(j, 1).value
                        resz3 = szovegekT.ListColumns("resz3").DataBodyRange.Cells(j, 1).value
                        indok1 = szovegekT.ListColumns("indok1").DataBodyRange.Cells(j, 1).value
                        indok2 = szovegekT.ListColumns("indok2").DataBodyRange.Cells(j, 1).value
                        hat1 = szovegekT.ListColumns("hatarozat1").DataBodyRange.Cells(j, 1).value
                        hat2 = szovegekT.ListColumns("hatarozat2").DataBodyRange.Cells(j, 1).value
                        hat3 = szovegekT.ListColumns("hatarozat3").DataBodyRange.Cells(j, 1).value
                        megszolitInput = szovegekT.ListColumns("megszolit").DataBodyRange.Cells(j, 1).value
                        orommelInput = szovegekT.ListColumns("orommel").DataBodyRange.Cells(j, 1).value
                        gratulaInput = szovegekT.ListColumns("gratula").DataBodyRange.Cells(j, 1).value
                        Exit For
                    End If
                Next j

                tagozat = listaT.ListColumns("tagozat").DataBodyRange.Cells(i, 1).value
                nyelv1 = listaT.ListColumns("ny_1_nagy").DataBodyRange.Cells(i, 1).value
                nyelv2 = listaT.ListColumns("ny_2").DataBodyRange.Cells(i, 1).value
                nyelvossz = listaT.ListColumns("ny_osszefuz").DataBodyRange.Cells(i, 1).value

                If Trim(CStr(tagozat)) = "1000" Then
                    nevelo = "az"
                Else
                    nevelo = "a"
                End If

                szoveg = nyelv1 & " " & resz1 & " " & nyelv2 & " " & resz2
                indok = indok1 & " " & nyelvossz & " " & indok2
                hatarozat = nev & " " & hat1 & " " & nevelo & " " & tagozat & " " & hat2 & " " & nyelvossz & " " & hat3

            Else
                For j = 1 To szovegekT.ListRows.count
                    If Trim(LCase(szovegekT.ListColumns("kategoria").DataBodyRange.Cells(j, 1).value)) = kategoria Then
                        If kategoria = "elut" And irasbeli >= 70 Then
                            Dim elutResz1 As String, elutResz2 As String, elutasitasOk As String
                            elutResz1 = szovegekT.ListColumns("resz1").DataBodyRange.Cells(j, 1).value
                            elutResz2 = szovegekT.ListColumns("resz2").DataBodyRange.Cells(j, 1).value
                            elutasitasOk = listaT.ListColumns("ok").DataBodyRange.Cells(i, 1).value
                            tagozat = listaT.ListColumns("tagozat").DataBodyRange.Cells(i, 1).value

                            If InStr(elutasitasOk, "1000") > 0 Then
                                nevelo = "az"
                            Else
                                nevelo = "a"
                            End If


                            szoveg = elutResz1 & " " & nevelo & " " & elutasitasOk & " " & elutResz2
                        Else
                            szoveg = szovegekT.ListColumns("resz1").DataBodyRange.Cells(j, 1).value
                        End If
                        Exit For
                    End If
                Next j
            End If
        End If

        If kategoria <> "" And szoveg <> "Nincs adat" Then
            listaT.ListColumns("szoveg").DataBodyRange.Cells(i, 1).value = szoveg
            listaT.ListColumns("indok").DataBodyRange.Cells(i, 1).value = indok
            listaT.ListColumns("megszolit").DataBodyRange.Cells(i, 1).value = megszolitInput
            listaT.ListColumns("hatarozat").DataBodyRange.Cells(i, 1).value = hatarozat
            listaT.ListColumns("orommel").DataBodyRange.Cells(i, 1).value = orommelInput
            listaT.ListColumns("gratula").DataBodyRange.Cells(i, 1).value = gratulaInput
        Else
            listaT.ListColumns("szoveg").DataBodyRange.Cells(i, 1).value = ""
            listaT.ListColumns("indok").DataBodyRange.Cells(i, 1).value = ""
            listaT.ListColumns("megszolit").DataBodyRange.Cells(i, 1).value = ""
            listaT.ListColumns("hatarozat").DataBodyRange.Cells(i, 1).value = ""
            listaT.ListColumns("orommel").DataBodyRange.Cells(i, 1).value = ""
            listaT.ListColumns("gratula").DataBodyRange.Cells(i, 1).value = ""
        End If

    Next i

    ufrKesz.Show

End Sub

