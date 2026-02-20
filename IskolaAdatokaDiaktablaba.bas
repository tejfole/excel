Attribute VB_Name = "IskolaAdatokaDiaktablaba"
Sub ToltsdIskolaAdatokatPirosHibaval(Optional control As IRibbonControl)

    Dim ws As Worksheet
    Dim diakTbl As ListObject, iskolaTbl As ListObject
    Dim dictOM As Object, dictCim As Object, dictMail As Object
    Dim r As ListRow
    Dim isknev As String
    Dim isknevCol As ListColumn, iskomCol As ListColumn
    Dim icimCol As ListColumn, imailCol As ListColumn
    Dim i As Long

    ' Táblák keresése
    For Each ws In ThisWorkbook.Worksheets
        For Each t In ws.ListObjects
            If t.Name = "diakadat" Then Set diakTbl = t
            If t.Name = "iskola" Then Set iskolaTbl = t
        Next t
    Next ws

    If diakTbl Is Nothing Or iskolaTbl Is Nothing Then
        MsgBox "Nem található 'diakadat' vagy 'iskola' nevû tábla!", vbCritical
        Exit Sub
    End If

    ' Iskola tábla szótárakba
    Set dictOM = CreateObject("Scripting.Dictionary")
    Set dictCim = CreateObject("Scripting.Dictionary")
    Set dictMail = CreateObject("Scripting.Dictionary")

    With iskolaTbl
        Dim isknevIndex As Long, iskolaomIndex As Long, cimIndex As Long, mailIndex As Long
        For i = 1 To .ListColumns.count
            Select Case LCase(.ListColumns(i).Name)
                Case "isknev": isknevIndex = i
                Case "iskolaom": iskolaomIndex = i
                Case "cim_ossze": cimIndex = i
                Case "mail": mailIndex = i
            End Select
        Next i

        If isknevIndex = 0 Or iskolaomIndex = 0 Or cimIndex = 0 Or mailIndex = 0 Then
            MsgBox "Az 'iskola' táblában hiányzik egy szükséges oszlop (iskolaom, isknev, cim_ossze, mail)!", vbCritical
            Exit Sub
        End If

        For Each r In .ListRows
            Dim nev As String
            nev = Trim(r.Range(1, isknevIndex).value)
            If nev <> "" Then
                dictOM(nev) = r.Range(1, iskolaomIndex).value
                dictCim(nev) = r.Range(1, cimIndex).value
                dictMail(nev) = r.Range(1, mailIndex).value
            End If
        Next r
    End With

    ' diakadat oszlopok beazonosítása
    For Each col In diakTbl.ListColumns
        Select Case LCase(col.Name)
            Case "isknev": Set isknevCol = col
            Case "iskom": Set iskomCol = col
            Case "i_cim": Set icimCol = col
            Case "i_mail": Set imailCol = col
        End Select
    Next col

    If isknevCol Is Nothing Or iskomCol Is Nothing Or icimCol Is Nothing Or imailCol Is Nothing Then
        MsgBox "A 'diakadat' táblában hiányzik egy szükséges oszlop!", vbCritical
        Exit Sub
    End If

    ' Cellák kitöltése
    For Each r In diakTbl.ListRows
        isknev = Trim(r.Range(1, isknevCol.Index).value)

        ' Alaphelyzet: háttér visszaállítása
        r.Range(1, iskomCol.Index).Resize(1, 3).Interior.ColorIndex = xlNone

        If isknev <> "" Then
            If dictOM.Exists(isknev) Then
                r.Range(1, iskomCol.Index).value = dictOM(isknev)
                r.Range(1, icimCol.Index).value = dictCim(isknev)
                r.Range(1, imailCol.Index).value = dictMail(isknev)
            Else
                ' Nincs találat: törlés + piros szín
                r.Range(1, iskomCol.Index).value = ""
                r.Range(1, icimCol.Index).value = ""
                r.Range(1, imailCol.Index).value = ""
                r.Range(1, iskomCol.Index).Resize(1, 3).Interior.color = RGB(255, 200, 200)
            End If
        End If
    Next r

    MsgBox "Az iskolaadatok kitöltése kész! A hiányzó iskolákat pirossal jelöltem.", vbInformation

End Sub

