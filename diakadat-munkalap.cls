VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Munka5"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

Private Sub Worksheet_Change(ByVal Target As Range)
    On Error GoTo Vege

    ' Biztonság: ne fusson tömbmódosításnál
    If Application.EnableEvents = False Then Exit Sub
    If Target.Cells.CountLarge > 1 Then Exit Sub

    Dim lo As ListObject
    Set lo = Me.ListObjects("diakadat")
    If lo Is Nothing Then Exit Sub
    If lo.DataBodyRange Is Nothing Then Exit Sub

    ' Csak a bizottsag oszlop érdekes
    Dim rngBiz As Range
    Set rngBiz = lo.ListColumns("bizottsag").DataBodyRange

    If Intersect(Target, rngBiz) Is Nothing Then Exit Sub

    Dim v As String
    v = Trim$(CStr(Target.value))

    ' Ha üres vagy nem szám › kilép
    If v = "" Then Exit Sub
    If Not IsNumeric(v) Then Exit Sub

    Dim biz As Long
    biz = CLng(v)

    ' Csak 1–10 bizottság
    If biz < 1 Or biz > 10 Then
        MsgBox "A bizottság csak 1 és 10 közötti szám lehet.", vbExclamation
        Exit Sub
    End If

    ' Sor index a táblán belül
    Dim rowIdx As Long
    rowIdx = Target.Row - lo.DataBodyRange.Row + 1

    ' Ha már van idõpont, ne írja felül
    Dim colDt As Long
    colDt = lo.ListColumns("idopont_nap").Index

    If Trim$(CStr(lo.DataBodyRange.Cells(rowIdx, colDt).value)) <> "" Then Exit Sub

    ' --- ITT hívjuk a kiosztót ---
    Application.EnableEvents = False
    AssignDatumNap_FromIdopontTabla lo, rowIdx, biz, 4
    Application.EnableEvents = True

Vege:
    Application.EnableEvents = True
End Sub
