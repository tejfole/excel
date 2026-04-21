Attribute VB_Name = "modIktsz"
Option Explicit

Private Const MAX_LONG_VALUE As Long = 2147483647

' Központi iktsz kiosztó modul.
' Módok:
' 1) lista / intézményi értesítés: group-by isk_nev -> iktsz
' 2) lista / határozat (felvettek-elutasítottak): group-by oktazon -> iktsz
' 3) diakadat / szóbeli időpont kiértesítés: feltételes szekvenciális iktsz

Public Sub Iktsz_Lista_IntezmenyiErtesites()
    FillIktszByKey "lista", "isk_nev", "iktsz", "Intézményi értesítés", 1
End Sub

Public Sub Iktsz_Lista_HatarozatSzobeli(Optional control As IRibbonControl)
    FillIktszByKey "lista", "oktazon", "iktsz", "Határozat (felvettek/elutasítottak)", 1
End Sub

Public Sub Iktsz_Diakadat_SzobeliIdopont(Optional control As IRibbonControl)
    FillIktszConditionalSequential "diakadat", "iktsz", "bizottsag", Array("datum_nap", "idopont_nap"), Array("mail", "email"), "idopont_kiadva", "x"
End Sub

Private Sub FillIktszByKey(ByVal tableName As String, ByVal keyColName As String, ByVal iktszColName As String, ByVal modeLabel As String, ByVal defaultStart As Long)
    Dim lo As ListObject
    Set lo = FindTable(tableName)
    If lo Is Nothing Then
        MsgBox "Nem található a(z) '" & tableName & "' tábla.", vbCritical
        Exit Sub
    End If

    Dim keyCol As Long, iktszCol As Long
    keyCol = FindColumnIndex(lo, keyColName)
    iktszCol = FindColumnIndex(lo, iktszColName)

    If keyCol = 0 Or iktszCol = 0 Then
        MsgBox "Hiányzik a(z) '" & keyColName & "' vagy '" & iktszColName & "' oszlop.", vbCritical
        Exit Sub
    End If

    Dim nextIktsz As Long
    If Not AskStartNumber("Kezdő iktsz", "Add meg a kezdő iktsz számot (" & modeLabel & "):", defaultStart, nextIktsz) Then Exit Sub

    Dim dict As Object
    Set dict = CreateObject("Scripting.Dictionary")

    Dim r As ListRow
    Dim keyValue As String

    For Each r In lo.ListRows
        keyValue = Trim$(CStr(r.Range(1, keyCol).Value))
        If keyValue <> "" Then
            If Not dict.Exists(keyValue) Then
                dict.Add keyValue, nextIktsz
                nextIktsz = nextIktsz + 1
            End If
            r.Range(1, iktszCol).Value = dict(keyValue)
        Else
            r.Range(1, iktszCol).Value = vbNullString
        End If
    Next r

    MsgBox "Kész: iktsz kitöltve (" & modeLabel & ").", vbInformation
End Sub

Private Sub FillIktszConditionalSequential(ByVal tableName As String, ByVal iktszColName As String, ByVal bizottsagColName As String, ByVal dateColumnCandidates As Variant, ByVal mailColumnCandidates As Variant, ByVal issuedColName As String, ByVal issuedFlag As String)
    Dim lo As ListObject
    Set lo = FindTable(tableName)
    If lo Is Nothing Then
        MsgBox "Nem található a(z) '" & tableName & "' tábla.", vbCritical
        Exit Sub
    End If

    Dim iktszCol As Long, bizCol As Long, dateCol As Long, mailCol As Long, issuedCol As Long
    iktszCol = FindColumnIndex(lo, iktszColName)
    bizCol = FindColumnIndex(lo, bizottsagColName)
    dateCol = FindFirstColumnIndex(lo, dateColumnCandidates)
    mailCol = FindFirstColumnIndex(lo, mailColumnCandidates)
    issuedCol = FindColumnIndex(lo, issuedColName)

    If iktszCol = 0 Or bizCol = 0 Or dateCol = 0 Or mailCol = 0 Or issuedCol = 0 Then
        MsgBox "Hiányzik valamelyik szükséges oszlop: '" & iktszColName & "', '" & bizottsagColName & "', " & CandidatesToText(dateColumnCandidates) & ", " & CandidatesToText(mailColumnCandidates) & ", '" & issuedColName & "'.", vbCritical
        Exit Sub
    End If

    Dim maxExisting As Long
    maxExisting = MaxNumericColumnValue(lo, iktszCol)

    ' A következő értékhez +1 kell, ezért MAX_LONG esetén már nem folytatható.
    If maxExisting >= MAX_LONG_VALUE Then
        MsgBox "Az iktsz oszlopban elérted a Long típus maximumát (" & CStr(MAX_LONG_VALUE) & ").", vbCritical
        Exit Sub
    End If

    Dim defaultStart As Long
    defaultStart = maxExisting + 1
    If defaultStart < 1 Then defaultStart = 1

    Dim nextIktsz As Long
    If Not AskStartNumber("Kezdő iktsz", "Add meg a kezdő iktsz számot (szóbeli időpont kiértesítés).", defaultStart, nextIktsz) Then Exit Sub

    Dim r As ListRow
    Dim iktszText As String

    For Each r In lo.ListRows
        If IsRowEligibleForSzobeli(r, bizCol, dateCol, mailCol, issuedCol, issuedFlag) Then
            iktszText = Trim$(CStr(r.Range(1, iktszCol).Value))
            If iktszText = vbNullString Then
                r.Range(1, iktszCol).Value = nextIktsz
                nextIktsz = nextIktsz + 1
            End If
        End If
    Next r

    MsgBox "Kész: iktsz feltöltve (szóbeli időpont kiértesítés).", vbInformation
End Sub

Private Function IsRowEligibleForSzobeli(ByVal rowItem As ListRow, ByVal bizCol As Long, ByVal dateCol As Long, ByVal mailCol As Long, ByVal issuedCol As Long, ByVal issuedFlag As String) As Boolean
    Dim bizText As String, dateText As String, mailText As String, issuedText As String

    bizText = Trim$(CStr(rowItem.Range(1, bizCol).Value))
    dateText = Trim$(CStr(rowItem.Range(1, dateCol).Value))
    mailText = Trim$(CStr(rowItem.Range(1, mailCol).Value))
    issuedText = LCase$(Trim$(CStr(rowItem.Range(1, issuedCol).Value)))

    IsRowEligibleForSzobeli = (bizText <> vbNullString) _
        And (dateText <> vbNullString) _
        And (mailText <> vbNullString) _
        And (issuedText <> LCase$(issuedFlag))
End Function

Private Function FindTable(ByVal tableName As String) As ListObject
    Dim ws As Worksheet
    Dim lo As ListObject

    For Each ws In ThisWorkbook.Worksheets
        For Each lo In ws.ListObjects
            If LCase$(Trim$(lo.Name)) = LCase$(Trim$(tableName)) Then
                Set FindTable = lo
                Exit Function
            End If
        Next lo
    Next ws
End Function

Private Function FindColumnIndex(ByVal lo As ListObject, ByVal colName As String) As Long
    Dim col As ListColumn
    For Each col In lo.ListColumns
        If LCase$(Trim$(col.Name)) = LCase$(Trim$(colName)) Then
            FindColumnIndex = col.Index
            Exit Function
        End If
    Next col
End Function

Private Function FindFirstColumnIndex(ByVal lo As ListObject, ByVal names As Variant) As Long
    Dim i As Long
    For i = LBound(names) To UBound(names)
        FindFirstColumnIndex = FindColumnIndex(lo, CStr(names(i)))
        If FindFirstColumnIndex <> 0 Then Exit Function
    Next i
End Function

Private Function MaxNumericColumnValue(ByVal lo As ListObject, ByVal colIndex As Long) As Long
    Dim r As ListRow
    Dim valueText As String
    Dim valueNum As Double

    For Each r In lo.ListRows
        valueText = Trim$(CStr(r.Range(1, colIndex).Value))
        If valueText <> vbNullString Then
            If IsNumeric(valueText) Then
                valueNum = CDbl(valueText)
                If valueNum > MAX_LONG_VALUE Then valueNum = MAX_LONG_VALUE
                If valueNum > MaxNumericColumnValue Then
                    MaxNumericColumnValue = CLng(valueNum)
                End If
            End If
        End If
    Next r
End Function

Private Function CandidatesToText(ByVal names As Variant) As String
    Dim i As Long
    For i = LBound(names) To UBound(names)
        If i > LBound(names) Then CandidatesToText = CandidatesToText & "/"
        CandidatesToText = CandidatesToText & CStr(names(i))
    Next i
End Function

Private Function AskStartNumber(ByVal title As String, ByVal prompt As String, ByVal defaultValue As Long, ByRef resultValue As Long) As Boolean
    Dim userInput As String
    userInput = InputBox(prompt, title, CStr(defaultValue))
    userInput = Trim$(userInput)

    If userInput = vbNullString Then Exit Function
    If Not IsNumeric(userInput) Then
        MsgBox "A megadott érték nem szám. A művelet megszakítva.", vbExclamation
        Exit Function
    End If

    Dim numericValue As Double
    numericValue = CDbl(userInput)
    If numericValue < -2147483648# Or numericValue > MAX_LONG_VALUE Then
        MsgBox "A megadott érték kívül esik a Long tartományon. A művelet megszakítva.", vbExclamation
        Exit Function
    End If

    resultValue = CLng(numericValue)
    AskStartNumber = True
End Function
