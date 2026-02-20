Attribute VB_Name = "Rangsorolas"
Sub Rangsorolas_Rangsorban_BevitelEredetiMarad(Optional control As IRibbonControl)
    Dim wsInput As Worksheet, wsOutput As Worksheet
    Dim loInput As ListObject
    Dim szuresMezo As String, celLapNev As String, alapNev As String
    Dim lastRow As Long, i As Long, destRow As Long
    Dim f_nevCol As Long, oktazonCol As Long, pontCol As Long, szuresCol As Long, jeligeCol As Long
    Dim sorszam As Long: sorszam = 1

    ' Forrás beállítás
    Set wsInput = ThisWorkbook.Sheets("diakadat")
    Set loInput = wsInput.ListObjects("diakadat")

    ' Szûrés mezõ bekérése, melyik tagozat alapján
    szuresMezo = InputBox("Melyik mezõre szeretnél szûrni?" & vbCrLf & _
                          "Írd be: j_1000, j_2000, j_3000, j_4000 vagy mind", _
                          "Szûrés kiválasztása", "mind")
    If szuresMezo = "" Then Exit Sub

    ' Javasolt munkalapnév elõkészítése
    If LCase(szuresMezo) = "mind" Then
        alapNev = "mind"
    ElseIf LCase(szuresMezo) Like "j_*" Then
        alapNev = Replace(LCase(szuresMezo), "j_", "")
    Else
        alapNev = "eredmeny"
    End If

    ' Munkalapnév bekérése
    celLapNev = InputBox("Add meg az új munkalap nevét:", "Cél munkalap neve", alapNev)
    If celLapNev = "" Then
        MsgBox "A mûvelet megszakadt – nem adtál meg munkalapot.", vbExclamation
        Exit Sub
    End If

    ' Oszlopok beazonosítása
    On Error GoTo Hibakezeles
    f_nevCol = loInput.ListColumns("f_nev").Range.Column
    oktazonCol = loInput.ListColumns("oktazon").Range.Column
    pontCol = loInput.ListColumns("p_mindossz").Range.Column
    jeligeCol = loInput.ListColumns("f_jelige").Range.Column
    If LCase(szuresMezo) <> "mind" Then
        szuresCol = loInput.ListColumns(szuresMezo).Range.Column
    End If
    On Error GoTo 0

    ' Munkalap létrehozása
    Application.DisplayAlerts = False
    On Error Resume Next: Worksheets(celLapNev).Delete: On Error GoTo 0
    Application.DisplayAlerts = True
    Set wsOutput = ThisWorkbook.Sheets.Add(After:=wsInput)
    wsOutput.Name = celLapNev

    ' Fejléc
    wsOutput.Range("A1:D1").value = Array("sorszam", "f_nev", "azonosito", "p_mindossz")

    ' Adatok gyûjtése tömbbe
    lastRow = wsInput.Cells(wsInput.rows.count, f_nevCol).End(xlUp).Row
    Dim adatLista() As Variant
    Dim count As Long: count = 0

    For i = 2 To lastRow
        Dim includeRow As Boolean: includeRow = True
        If LCase(szuresMezo) <> "mind" Then
            If LCase(Trim(wsInput.Cells(i, szuresCol).value)) <> "x" Then includeRow = False
        End If

        If includeRow Then
            count = count + 1
            ReDim Preserve adatLista(1 To 3, 1 To count)
            ' f_nev
            adatLista(1, count) = wsInput.Cells(i, f_nevCol).value
            ' azonosito = jelige ha van, egyébként oktazon
            If Trim(wsInput.Cells(i, jeligeCol).value) <> "" Then
                adatLista(2, count) = wsInput.Cells(i, jeligeCol).value
            Else
                adatLista(2, count) = wsInput.Cells(i, oktazonCol).value
            End If
            ' p_mindossz
            adatLista(3, count) = wsInput.Cells(i, pontCol).value
        End If
    Next i

    If count = 0 Then
        MsgBox "?? Nincs találat a szûrés alapján.", vbExclamation
        Exit Sub
    End If

    ' Rendezés p_mindossz szerint csökkenõ
    Dim j As Long
    For i = 1 To count - 1
        For j = i + 1 To count
            If adatLista(3, i) < adatLista(3, j) Then
                Dim temp1, temp2, temp3
                temp1 = adatLista(1, i): temp2 = adatLista(2, i): temp3 = adatLista(3, i)
                adatLista(1, i) = adatLista(1, j)
                adatLista(2, i) = adatLista(2, j)
                adatLista(3, i) = adatLista(3, j)
                adatLista(1, j) = temp1
                adatLista(2, j) = temp2
                adatLista(3, j) = temp3
            End If
        Next j
    Next i

    ' Kiírás új lapra sorszámozva
    destRow = 2
    For i = 1 To count
        wsOutput.Cells(destRow, 1).value = i                       ' sorszam
        wsOutput.Cells(destRow, 2).value = adatLista(1, i)         ' f_nev
        wsOutput.Cells(destRow, 3).value = adatLista(2, i)         ' azonosito
        wsOutput.Cells(destRow, 4).value = adatLista(3, i)         ' p_mindossz
        destRow = destRow + 1
    Next i

    MsgBox "? Rangsor elkészült '" & szuresMezo & "' alapján, lap: '" & celLapNev & "'", vbInformation
    Exit Sub

Hibakezeles:
    MsgBox "? Hiba: valamelyik oszlop hiányzik (pl. f_nev, oktazon, p_mindossz, f_jelige vagy szûrési oszlop)!", vbCritical

End Sub


