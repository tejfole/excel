Attribute VB_Name = "modIdopontok"
Option Explicit

' ==============================
' IDÕPONT TÁBLA LEKÉRÉS
' ==============================
Public Function GetIdopontTabla_V2() As ListObject
    On Error GoTo EH
    
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets("idopontok")
    
    Set GetIdopontTabla_V2 = ws.ListObjects("tbl_idopontok")
    Exit Function
    
EH:
    MsgBox "Hiányzik az 'idopontok' munkalap vagy a 'tbl_idopontok' tábla!" & vbCrLf & _
           "Hozd létre az idõpont táblát.", vbCritical
    Set GetIdopontTabla_V2 = Nothing
End Function


' ==============================
' FÕ: IDÕPONT HOZZÁRENDELÉS
' ==============================
Public Sub AssignDatumNap_FromIdopontTabla(loD As ListObject, ByVal rowIdx As Long, ByVal biz As Long, ByVal kapacitas As Long)
    
    Dim loT As ListObject
    Set loT = GetIdopontTabla_V2()
    If loT Is Nothing Then Exit Sub
    
    If loT.ListRows.count = 0 Then
        MsgBox "Nincs idõpont az idopontok táblában!", vbExclamation
        Exit Sub
    End If
    
    Dim arrT As Variant
    arrT = loT.DataBodyRange.value
    
    Dim iDtT As Long
    Dim iAkT As Long
    
    iDtT = loT.ListColumns("datum_nap").Index
    iAkT = loT.ListColumns("aktiv").Index
    
    Dim iBizD As Long
    Dim iDtD As Long
    
    iBizD = loD.ListColumns("bizottsag").Index
    iDtD = loD.ListColumns("datum_nap").Index
    
    Dim arrD As Variant
    arrD = loD.DataBodyRange.value
    
    Dim activeDates As Collection
    Set activeDates = New Collection
    
    Dim r As Long
    Dim dtParsed As Date
    
    For r = 1 To UBound(arrT, 1)
        If CLng(val(arrT(r, iAkT))) = 1 Then
            If TryParseHuDateTime(arrT(r, iDtT), dtParsed) Then
                activeDates.Add dtParsed
            End If
        End If
    Next r
    
    If activeDates.count = 0 Then
        MsgBox "Nincs AKTÍV, felismerhetõ idõpont!", vbExclamation
        Exit Sub
    End If
    
    Dim items() As String
    Dim keys() As Double
    Dim i As Long
    
    ReDim items(1 To activeDates.count)
    ReDim keys(1 To activeDates.count)
    
    For i = 1 To activeDates.count
        Dim dt As Date
        dt = activeDates(i)
        
        Dim used As Long
        used = CountAssignedInArr(arrD, biz, dt, iBizD, iDtD)
        
        Dim free As Long
        free = kapacitas - used
        
        keys(i) = CDbl(dt)
        items(i) = Format$(dt, "yyyy.mm.dd hh:nn") & "   (szabad: " & free & ")"
    Next i
    
    Dim pick As Long
    pick = ChooseIndexFromList_Safe("Idõpont választás - Bizottság " & biz, items)
    
    If pick = 0 Then Exit Sub
    
    Dim chosenDate As Date
    chosenDate = CDate(keys(pick))
    
    If CountAssignedInArr(arrD, biz, chosenDate, iBizD, iDtD) >= kapacitas Then
        MsgBox "Ez az idõpont betelt!", vbExclamation
        Exit Sub
    End If
    
    loD.DataBodyRange.Cells(rowIdx, iDtD).value = chosenDate
    loD.DataBodyRange.Cells(rowIdx, iDtD).NumberFormat = "yyyy.mm.dd hh:mm:ss"
    
End Sub


' ==============================
' DÁTUM PARSZER (ÜTKÖZÉSMENTES)
' ==============================
Private Function TryParseHuDateTime(ByVal v As Variant, ByRef dtOut As Date) As Boolean
    On Error GoTo Fail
    
    If IsDate(v) Then
        dtOut = CDate(v)
        TryParseHuDateTime = True
        Exit Function
    End If
    
    Dim s As String
    s = Trim$(CStr(v))
    If s = "" Then GoTo Fail
    
    s = Replace(s, "-", ".")
    
    Dim parts() As String
    parts = Split(s, " ")
    
    Dim datePart As String
    Dim timePart As String
    
    datePart = parts(0)
    If UBound(parts) >= 1 Then
        timePart = parts(1)
    Else
        timePart = "00:00:00"
    End If
    
    Dim d() As String
    d = Split(datePart, ".")
    If UBound(d) <> 2 Then GoTo Fail
    
    Dim yyyy As Long, mm As Long, dd As Long
    yyyy = CLng(val(d(0)))
    mm = CLng(val(d(1)))
    dd = CLng(val(d(2)))
    
    Dim t() As String
    t = Split(timePart, ":")
    
    Dim hh As Long, nn As Long, ss As Long
    hh = 0: nn = 0: ss = 0
    
    If UBound(t) >= 0 Then hh = CLng(val(t(0)))
    If UBound(t) >= 1 Then nn = CLng(val(t(1)))
    If UBound(t) >= 2 Then ss = CLng(val(t(2)))
    
    dtOut = DateSerial(yyyy, mm, dd) + TimeSerial(hh, nn, ss)
    TryParseHuDateTime = True
    Exit Function
    
Fail:
    TryParseHuDateTime = False
End Function


' ==============================
' FOGLALTSÁG SZÁMOLÁS
' ==============================
Private Function CountAssignedInArr(arrD As Variant, biz As Long, dt As Date, iBizD As Long, iDtD As Long) As Long
    Dim r As Long
    Dim cnt As Long
    
    For r = 1 To UBound(arrD, 1)
        If CLng(val(arrD(r, iBizD))) = biz Then
            If IsDate(arrD(r, iDtD)) Then
                If CDbl(CDate(arrD(r, iDtD))) = CDbl(dt) Then
                    cnt = cnt + 1
                End If
            End If
        End If
    Next r
    
    CountAssignedInArr = cnt
End Function


' ==============================
' LISTA VÁLASZTÓ ABLAK
' ==============================
Private Function ChooseIndexFromList_Safe(ByVal title As String, ByRef items As Variant) As Long
    On Error GoTo Hibakezeles
    
    Dim msg As String
    Dim i As Long
    
    If IsEmpty(items) Then Exit Function
    
    For i = LBound(items) To UBound(items)
        msg = msg & (i - LBound(items) + 1) & ". " & CStr(items(i)) & vbCrLf
    Next i
    
    Dim ans As String
    ans = InputBox(msg, title, "1")
    
    If Trim$(ans) = "" Then Exit Function
    If Not IsNumeric(ans) Then Exit Function
    
    Dim n As Long
    n = CLng(ans)
    
    If n < 1 Or n > (UBound(items) - LBound(items) + 1) Then Exit Function
    
    ChooseIndexFromList_Safe = LBound(items) + n - 1
    Exit Function

Hibakezeles:
    MsgBox "Lista választási hiba: " & Err.Description, vbExclamation
End Function

