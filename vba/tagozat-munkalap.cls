VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Munka3"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Private Sub Worksheet_Change(ByVal Target As Range)
    If Not Intersect(Target, Me.Range("B1")) Is Nothing Then
        If Trim(CStr(Target.value)) <> "" Then
            Application.EnableEvents = False
            Call TagozatSzures_SzamitottRangsorral
            Application.EnableEvents = True
        End If
    End If
End Sub

