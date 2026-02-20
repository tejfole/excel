Attribute VB_Name = "jelszogeneralasCsvfilekeszites"
Sub GeneratePasswordsFromTableAndExportCSV_Final_UniqueWithLogClean(Optional control As IRibbonControl)

    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim r As ListRow
    Dim aNev As String
    Dim szulI As String
    Dim jelszo As String
    Dim fileNo As Integer
    Dim logNo As Integer
    Dim folderPath As String
    Dim csvFile As String
    Dim logFile As String
    Dim lineText As String
    Dim fd As FileDialog
    Dim dict As Object

    ' --- Egyediség figyelése ---
    Set dict = CreateObject("Scripting.Dictionary")

    ' Aktív munkalap
    Set ws = ActiveSheet

    ' Tábla beállítása
    If ws.ListObjects.count = 0 Then
        MsgBox "? Nincs tábla az aktív munkalapon!", vbCritical
        Exit Sub
    End If
    
    Set tbl = ws.ListObjects(1) ' Az elsõ tábla a munkalapon

    ' Ellenõrizzük, hogy megvannak-e az oszlopok
    On Error GoTo HianyzoOszlop
    Dim aNevCol As ListColumn
    Dim szulICol As ListColumn
    Dim jelszoCol As ListColumn
    Dim oktazonCol As ListColumn

    Set aNevCol = tbl.ListColumns("a_nev")
    Set szulICol = tbl.ListColumns("szul_i")
    Set jelszoCol = tbl.ListColumns("jelszo")
    Set oktazonCol = tbl.ListColumns("oktazon")
    On Error GoTo 0

    ' --- Jelszavak generálása a táblában ---
    For Each r In tbl.ListRows
        Dim oktazonValue As String
        oktazonValue = Trim(r.Range(1, oktazonCol.Index).value)

        ' Ha nincs oktazon, hagyjuk üresen a jelszó oszlopot
        If oktazonValue = "" Then
            r.Range(1, jelszoCol.Index).value = ""
        Else
            aNev = CleanName(LCase(Trim(r.Range(1, aNevCol.Index).value)))
            szulI = r.Range(1, szulICol.Index).value

            ' szul_i dátum formázása
            If IsDate(szulI) Then
                szulI = Format(szulI, "yyyymmdd")
            Else
                szulI = Trim(szulI)
            End If

            ' Jelszó készítése
            If Len(aNev) >= 3 And szulI <> "" Then
                jelszo = Left(aNev, 3) & szulI
                r.Range(1, jelszoCol.Index).value = jelszo
            Else
                r.Range(1, jelszoCol.Index).value = "HIBA"
            End If
        End If
    Next r

    ' --- Mappa választó ablak ---
    Set fd = Application.FileDialog(msoFileDialogFolderPicker)
    fd.title = "Válassz mappát a CSV és log fájl mentéséhez"
    If fd.Show = -1 Then
        folderPath = fd.SelectedItems(1)
    Else
        MsgBox "? Mappaválasztás megszakítva!", vbCritical
        Exit Sub
    End If

    ' --- CSV és Log fájl elérési útja ---
    csvFile = folderPath & "\jelszavak.csv"
    logFile = folderPath & "\hibas_sorok_log.txt"

    fileNo = FreeFile
    Open csvFile For Output As #fileNo

    logNo = FreeFile
    Open logFile For Output As #logNo

    ' --- CSV fejléc ---
    Print #fileNo, "fajlnev;jelszo"

    ' --- Tábla sorainak exportálása ---
    For Each r In tbl.ListRows
        Dim oktazonExport As String
        Dim jelszoExport As String

        oktazonExport = Trim(r.Range(1, oktazonCol.Index).value)
        jelszoExport = Trim(r.Range(1, jelszoCol.Index).value)

        ' Ha nincs oktazon, teljesen kihagyjuk (nem írjuk sehová)
        If oktazonExport = "" Then GoTo SkipNext

        ' Ha az oktazon már szerepelt, kihagyjuk
        If dict.Exists(oktazonExport) Then GoTo SkipNext

        ' Ha jelszó hibás, logoljuk és kihagyjuk
        If jelszoExport = "" Or jelszoExport = "HIBA" Then
            Print #logNo, "? Hibás sor - Oktazon: " & oktazonExport & ", Jelszó: " & jelszoExport
            GoTo SkipNext
        End If

        ' Új, egyedi oktazon - írjuk CSV-be
        lineText = oktazonExport & ";" & jelszoExport
        Print #fileNo, lineText
        dict.Add oktazonExport, True

SkipNext:
    Next r

    Close #fileNo
    Close #logNo

    MsgBox "? CSV és hibás sorok log sikeresen elkészült!", vbInformation
    Exit Sub

HianyzoOszlop:
    MsgBox "? A táblában hiányzik valamelyik szükséges oszlop: 'a_nev', 'szul_i', 'jelszo', 'oktazon'!", vbCritical

End Sub

' === Segédfüggvény: név tisztítása ===
Function CleanName(szoveg As String) As String
    ' dr. eltávolítása, ha az elején van
    If Left(szoveg, 3) = "dr." Then
        szoveg = Trim(Mid(szoveg, 4))
    End If

    ' Magyar ékezetek eltávolítása
    szoveg = Replace(szoveg, "á", "a")
    szoveg = Replace(szoveg, "é", "e")
    szoveg = Replace(szoveg, "í", "i")
    szoveg = Replace(szoveg, "ó", "o")
    szoveg = Replace(szoveg, "ö", "o")
    szoveg = Replace(szoveg, "õ", "o")
    szoveg = Replace(szoveg, "ú", "u")
    szoveg = Replace(szoveg, "ü", "u")
    szoveg = Replace(szoveg, "û", "u")

    ' Kisbetûsítés
    szoveg = LCase(szoveg)

    CleanName = szoveg
End Function

