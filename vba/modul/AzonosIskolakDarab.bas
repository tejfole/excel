Attribute VB_Name = "AzonosIskolakDarab"
Sub Szamolas_Darab_Es_Max()
    Dim tbl As ListObject
    Dim r As ListRow
    Dim dict As Object
    Dim isknevCol As ListColumn
    Dim darabCol As ListColumn
    Dim ertek As String
    Dim maxErtek As Long
    
    Set tbl = ActiveSheet.ListObjects("lista")
    Set isknevCol = tbl.ListColumns("isk_nev")
    Set darabCol = tbl.ListColumns("darab")
    Set dict = CreateObject("Scripting.Dictionary")
    
    ' Elõször összeszámoljuk hányszor szerepel az isk_nev minden értéke
    For Each r In tbl.ListRows
        ertek = Trim(CStr(r.Range(1, isknevCol.Index).value))
        If ertek <> "" Then
            If dict.Exists(ertek) Then
                dict(ertek) = dict(ertek) + 1
            Else
                dict.Add ertek, 1
            End If
        End If
    Next r
    
    ' Visszaírjuk a darabszámokat és meghatározzuk a maximumot
    maxErtek = 0
    For Each r In tbl.ListRows
        ertek = Trim(CStr(r.Range(1, isknevCol.Index).value))
        If ertek <> "" Then
            r.Range(1, darabCol.Index).value = dict(ertek)
            If dict(ertek) > maxErtek Then maxErtek = dict(ertek)
        Else
            r.Range(1, darabCol.Index).value = ""
        End If
    Next r

    MsgBox "Ok A 'darab' oszlop frissítve!" & vbNewLine & _
           "?? Legmagasabb elõfordulás: " & maxErtek, vbInformation
End Sub


