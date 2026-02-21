Attribute VB_Name = "modImportDiakadat"
Option Explicit

' =============================================================================
' modImportDiakadat – Clean Diákadat import
' =============================================================================
' Belépési pont: ImportDiakadat_Clean
'
' Forrás : felhasználó által kiválasztott Excel fájl, "Export" sheet (default)
' Cél    : ThisWorkbook "diakadat" tábla, kulcs: oktazon
' Stratégia: non-destructive – meglévő sorok csak üres mezőit tölti;
'            ismeretlen kulcsnál új sort hoz létre.
' =============================================================================

Private Const SRC_DEFAULT_SHEET As String = "Export"
Private Const DST_TABLE_NAME    As String = "diakadat"
Private Const DST_KEY_COL       As String = "oktazon"
Private Const KEY_ALIAS_DEFAULT As String = "Oktatási azonosító;oktazon;oktatasi azonosito;oktatasi_azonosito"

' ---------------------------------------------------------------------------
' ImportDiakadat_Clean – fő belépési pont
' ---------------------------------------------------------------------------
Public Sub ImportDiakadat_Clean()

    ' 1) Forrás fájl kiválasztása
    Dim srcPath As String
    srcPath = PickExcelFile("Válaszd ki a forrás Excel fájlt")
    If srcPath = "" Then Exit Sub

    ' 2) Kulcs alias-lista bekérése
    Dim aliasRaw As String
    aliasRaw = InputBox("Forrás kulcs oszlop fejléc aliasai (pontosvesszővel elválasztva):", _
                        "Forrás kulcs aliasok", KEY_ALIAS_DEFAULT)
    If Trim$(aliasRaw) = "" Then Exit Sub

    Dim keyAliases() As String
    keyAliases = Split(aliasRaw, ";")

    ' 3) Cél tábla keresése
    Dim loD As ListObject
    Set loD = FindTableByName(ThisWorkbook, DST_TABLE_NAME)
    If loD Is Nothing Then
        MsgBox "Nem található a """ & DST_TABLE_NAME & """ tábla a munkafüzetben.", vbExclamation
        Exit Sub
    End If

    ' 4) Cél kulcsoszlop indexe
    Dim colKeyD As Long
    colKeyD = ColIndex(loD, DST_KEY_COL, required:=True)
    If colKeyD = -1 Then Exit Sub

    ' AppBegin – képernyőfrissítés, events, calc letiltása
    AppBegin True, True, True
    On Error GoTo EH

    ' 5) Forrásmunkakönyv megnyitása
    Dim wbS As Workbook
    Set wbS = OpenSourceWb(srcPath)
    If wbS Is Nothing Then
        MsgBox "Nem sikerült megnyitni: " & srcPath, vbExclamation
        GoTo Cleanup
    End If

    ' 6) Forrás munkalap
    Dim wsS As Worksheet
    Set wsS = GetSheetByNameOrPrompt(wbS, SRC_DEFAULT_SHEET)
    If wsS Is Nothing Then
        MsgBox "Nem található a forrás munkalap. Az import megszakítva.", vbExclamation
        GoTo Cleanup
    End If

    ' 7) Fejléc térképek
    Dim mapS As Object
    Set mapS = BuildHeaderMap(wsS, 1)
    Dim mapD As Object
    Set mapD = BuildDestHeaderMap(loD)

    ' 8) Forrás kulcsoszlop keresése alias-lista alapján
    Dim colKeyS As Long
    colKeyS = FirstMatchingHeaderCol(mapS, keyAliases)
    If colKeyS = 0 Then
        MsgBox "A forrásban nem találom a kulcs oszlopot." & vbCrLf & _
               "Keresett aliasok: " & aliasRaw, vbExclamation
        GoTo Cleanup
    End If

    ' 9) Cél index oktazon alapján
    Dim idxD As Object
    Set idxD = BuildDestIndex(loD, colKeyD)

    ' 10) Mezőhozzárendelések
    Dim fieldDefs As Object
    Set fieldDefs = BuildFieldDefs()

    ' 11) Sorok feldolgozása
    Dim lastRow As Long
    lastRow = wsS.Cells(wsS.Rows.Count, colKeyS).End(xlUp).Row

    Dim newCount   As Long
    Dim updCells   As Long
    Dim skipCount  As Long
    Dim srcRows    As Long
    Dim r          As Long
    Dim k          As String
    Dim lr         As ListRow
    Dim isNew      As Boolean
    Dim fldKey     As Variant
    Dim fldAliases As Variant
    Dim cS         As Long
    Dim dstNk      As String
    Dim cD         As Long
    Dim val        As Variant
    Dim nkDstKey   As String
    nkDstKey = NKey(DST_KEY_COL)

    For r = 2 To lastRow
        k = Trim$(CStr(wsS.Cells(r, colKeyS).Value))
        If k = "" Then
            skipCount = skipCount + 1
        Else
            srcRows = srcRows + 1
            isNew = False
            If idxD.Exists(k) Then
                Set lr = loD.ListRows(CLng(idxD(k)))
            Else
                Set lr = loD.ListRows.Add
                isNew = True
                lr.Range.Cells(1, colKeyD).Value = k
                idxD(k) = lr.Index
                newCount = newCount + 1
            End If

            For Each fldKey In fieldDefs.Keys
                fldAliases = fieldDefs(fldKey)
                cS = FirstMatchingHeaderCol(mapS, fldAliases)
                If cS > 0 Then
                    dstNk = NKey(CStr(fldKey))
                    If mapD.Exists(dstNk) And dstNk <> nkDstKey Then
                        cD = CLng(mapD(dstNk))
                        val = wsS.Cells(r, cS).Value
                        If Trim$(CStr(val)) <> "" Then
                            If isNew Then
                                lr.Range.Cells(1, cD).Value = val
                                updCells = updCells + 1
                            Else
                                If WriteIfEmpty(lr, cD, val) Then
                                    updCells = updCells + 1
                                End If
                            End If
                        End If
                    End If
                End If
            Next fldKey
        End If
    Next r

    ' 12) Összefoglaló
    MsgBox "Import kész." & vbCrLf & vbCrLf & _
           "Beolvasott forrás sorok: " & srcRows & vbCrLf & _
           "Új rekordok: " & newCount & vbCrLf & _
           "Kitöltött cellák: " & updCells & vbCrLf & _
           "Kihagyott sorok (hiányzó kulcs): " & skipCount, vbInformation

Cleanup:
    SafeCloseWb wbS
    AppEnd
    Exit Sub

EH:
    MsgBox "Hiba: " & Err.Number & vbCrLf & Err.Description, vbExclamation
    Resume Cleanup
End Sub

' ---------------------------------------------------------------------------
' BuildDestHeaderMap – cél ListObject NKey → colIdx térképe
' ---------------------------------------------------------------------------
Private Function BuildDestHeaderMap(ByVal lo As ListObject) As Object
    Dim d As Object
    Set d = CreateObject("Scripting.Dictionary")
    Dim i As Long
    For i = 1 To lo.ListColumns.Count
        d(NKey(lo.ListColumns(i).Name)) = i
    Next i
    Set BuildDestHeaderMap = d
End Function

' ---------------------------------------------------------------------------
' BuildFieldDefs – mezőhozzárendelési tábla
'   Kulcs: cél oszlopnév (String)
'   Érték: Variant tömb – forrás fejléc aliasok (NKey-vel keresve)
' ---------------------------------------------------------------------------
Private Function BuildFieldDefs() As Object
    Dim d As Object
    Set d = CreateObject("Scripting.Dictionary")

    ' nev
    d("nev") = Array("Név", "nev", "Tanuló neve", "Teljes név")

    ' email
    d("email") = Array("Értesítési e-mail", "Értesítési e-mail cím", _
                        "Értesítési email", "Értesítési email cím", _
                        "E-mail", "Email", "email")

    ' isk_nev
    d("isk_nev") = Array("Általános iskola neve", "Általános iskola", _
                          "Iskola neve", "isk_nev")

    ' bizottsag
    d("bizottsag") = Array("Bizottság", "bizottsag", "Verseny bizottság")

    Set BuildFieldDefs = d
End Function
