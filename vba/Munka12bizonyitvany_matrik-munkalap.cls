VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Munka12"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

Private Const DIRTY_COL As Long = 26 ' Z

Private Sub Worksheet_Change(ByVal Target As Range)
    On Error GoTo SafeExit
    If Application.EnableEvents = False Then Exit Sub

    ' Ne jelöljük dirty-nek, ha az A:B vagy Z oszlop módosul
    If Target.Column <= 2 Then Exit Sub
    If Target.Column = DIRTY_COL Then Exit Sub
    If Target.Row < 2 Then Exit Sub

    Application.EnableEvents = False
    Me.Cells(Target.Row, DIRTY_COL).value = 1
SafeExit:
    Application.EnableEvents = True
End Sub

