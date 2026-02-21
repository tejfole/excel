Attribute VB_Name = "modImportDiakadat"
Option Explicit

' =============================================================================
' modImportDiakadat – Diákadat import belépési pont (clean)
' =============================================================================
' Belépési pont: ImportDiakadat_Clean
'
' Folyamat:
'   1. Forrás Excel fájl kiválasztása (PickExcelFile)
'   2. Forrás megnyitása read-only (OpenReadOnly)
'   3. Forrás munkalap: "Export" (vagy InputBox)
'   4. Kulcs alias bekérése (InputBox), forrás kulcs oszlop megkeresése
'   5. Cél tábla: "diakadat" ListObject
'   6. Non-destructive upgrade + új sor logika
'   7. MsgBox összegzés
' =============================================================================

' Default kulcs alias lista
Private Const KEY_ALIAS_DEFAULT As String = _
    "Oktatási azonosító;oktazon;oktatasi azonosito;oktatasi_azonosito"

' Default forrás munkalap neve
Private Const SRC_SHEET_DEFAULT As String = "Export"

' Cél tábla neve
Private Const DST_TABLE_NAME As String = "diakadat"

' Cél kulcs oszlop neve
Private Const DST_KEY_COL As String = "oktazon"

' =============================================================================
' ImportDiakadat_Clean – publikus belépési pont
' =============================================================================
Public Sub ImportDiakadat_Clean()
    ' --- Forrás fájl kiválasztása ---
    Dim srcPath As String
    srcPath = PickExcelFile("Válaszd ki a FORRÁS Excel fájlt")
    If srcPath = "" Then Exit Sub

    AppBegin True, True, False

    Dim wbS As Workbook
    Dim wsS As Worksheet
    Dim loD As ListObject

    On Error GoTo EH

    ' --- Cél tábla keresése ---
    Set loD = FindTableByName(ThisWorkbook, DST_TABLE_NAME)
    If loD Is Nothing Then
        MsgBox "Nem található a(z) """ & DST_TABLE_NAME & """ nevű tábla a munkafüzetben.", vbExclamation
        GoTo Cleanup
    End If

    ' --- Forrás megnyitása ---
    Set wbS = OpenReadOnly(srcPath)
    If wbS Is Nothing Then GoTo Cleanup

    ' --- Forrás munkalap ---
    Set wsS = GetSheetByNameOrPrompt(wbS, SRC_SHEET_DEFAULT)
    If wsS Is Nothing Then GoTo Cleanup

    ' --- Fejléc-térképek ---
    Dim mapS As Object
    Set mapS = BuildHeaderMap(wsS, 1)

    ' --- Kulcs alias bekérése ---
    Dim keyAliases As String
    keyAliases = InputBox("Forrás kulcs fejléc alias-ok (pontosvesszővel elválasztva):", _
                          "Kulcs alias", KEY_ALIAS_DEFAULT)
    keyAliases = Trim$(keyAliases)
    If keyAliases = "" Then GoTo Cleanup

    ' --- Forrás kulcs oszlop ---
    Dim colKeyS As Long
    colKeyS = FirstMatchingHeaderCol(mapS, keyAliases)
    If colKeyS = -1 Then
        MsgBox "Nem található kulcs fejléc a forrásban." & vbCrLf & _
               "Alias-ok: " & keyAliases, vbExclamation
        GoTo Cleanup
    End If

    ' --- Cél kulcs oszlop ---
    Dim colKeyD As Long
    colKeyD = ColIndex(loD, DST_KEY_COL, required:=True)
    If colKeyD = -1 Then GoTo Cleanup

    ' --- Cél index felépítése ---
    Dim idxD As Object
    Set idxD = CreateObject("Scripting.Dictionary")
    BuildDestIndex loD, colKeyD, idxD

    ' --- Opcionális mezők: alias lista → cél oszlopnév ---
    '   Minden mezőhöz: alias lista (pontosvesszővel elválasztva)
    Dim optFields(0 To 3) As String   ' alias listák
    Dim optDstCols(0 To 3) As String  ' cél oszlopnevek

    optFields(0) = "Név;Tanuló neve;nev;tanulo neve"
    optDstCols(0) = "nev"

    optFields(1) = "Értesítési e-mail;Értesítési e-mail cím;E-mail;Email;email;mail"
    optDstCols(1) = "email"

    optFields(2) = "Általános iskola neve;Általános iskola;Iskola neve;isk_nev;isknev"
    optDstCols(2) = "isk_nev"

    optFields(3) = "Bizottság;bizottsag;Bizottsag"
    optDstCols(3) = "bizottsag"

    ' Cél oszlopindexek előre meghatározása (-1 = nem létezik a cél táblában)
    Dim optColS(0 To 3) As Long  ' forrás oszlop index
    Dim optColD(0 To 3) As Long  ' cél oszlop index
    Dim f As Long
    For f = 0 To UBound(optFields)
        optColS(f) = FirstMatchingHeaderCol(mapS, optFields(f))
        If optColS(f) > 0 Then
            optColD(f) = ColIndex(loD, optDstCols(f), required:=False)
        Else
            optColD(f) = -1
        End If
    Next f

    ' --- Import ciklus ---
    Dim lastRowS As Long
    lastRowS = wsS.Cells(wsS.Rows.Count, colKeyS).End(xlUp).Row

    Dim newCount As Long, filledCount As Long, skippedCount As Long, totalCount As Long
    newCount = 0
    filledCount = 0
    skippedCount = 0
    totalCount = 0

    Dim r As Long
    For r = 2 To lastRowS   ' fejléc az 1. sorban
        Dim keyVal As String
        keyVal = Trim$(CStr(wsS.Cells(r, colKeyS).Value))
        If keyVal = "" Then
            skippedCount = skippedCount + 1
            GoTo NextRow
        End If

        totalCount = totalCount + 1

        Dim lr As ListRow
        If idxD.Exists(keyVal) Then
            Set lr = loD.ListRows(CLng(idxD(keyVal)))
        Else
            Set lr = loD.ListRows.Add
            lr.Range.Cells(1, colKeyD).Value = keyVal
            idxD(keyVal) = lr.Index
            newCount = newCount + 1
        End If

        ' Opcionális mezők kitöltése (csak üres cellába)
        For f = 0 To UBound(optFields)
            If optColS(f) > 0 And optColD(f) > 0 Then
                Dim srcVal As Variant
                srcVal = wsS.Cells(r, optColS(f)).Value
                If Not IsEmpty(srcVal) And Trim$(CStr(srcVal)) <> "" Then
                    If WriteIfEmpty(lr.Range.Cells(1, optColD(f)), srcVal) Then
                        filledCount = filledCount + 1
                    End If
                End If
            End If
        Next f

NextRow:
    Next r

    MsgBox "Import kész." & vbCrLf & vbCrLf & _
           "Beolvasott sorok: " & totalCount & vbCrLf & _
           "Új rekordok: " & newCount & vbCrLf & _
           "Kitöltött cellák: " & filledCount & vbCrLf & _
           "Kihagyott sorok (hiányzó kulcs): " & skippedCount, vbInformation

    GoTo Cleanup

EH:
    MsgBox "Hiba: " & Err.Number & vbCrLf & Err.Description, vbCritical

Cleanup:
    CloseReadOnly wbS
    AppEnd
End Sub
