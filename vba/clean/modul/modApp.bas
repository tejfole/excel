Attribute VB_Name = "modApp"
Option Explicit

' =============================================================================
' modApp – Application state helpers
' =============================================================================
' Biztonságos Begin/End minta:
'
'   Private Sub DoSomething()
'       AppBegin True, True, True          ' letiltja events, screen, manual calc
'       On Error GoTo EH
'       ' ... munkavégzés ...
'       GoTo Cleanup
'   EH:
'       MsgBox "Hiba: " & Err.Number & vbCrLf & Err.Description, vbCritical
'   Cleanup:
'       AppEnd                             ' MINDIG visszaállít
'   End Sub
'
' =============================================================================

Private m_ScreenUpdating  As Boolean
Private m_EnableEvents    As Boolean
Private m_Calculation     As Long       ' xlCalculationAutomatic / xlCalculationManual
Private m_DisplayAlerts   As Boolean
Private m_StateActive     As Boolean

' ---------------------------------------------------------------------------
' AppBegin – menti az állapotot és letilt mindent, amit kért
' ---------------------------------------------------------------------------
Public Sub AppBegin(Optional ByVal disableEvents As Boolean = True, _
                    Optional ByVal disableScreen As Boolean = True, _
                    Optional ByVal manualCalc As Boolean = True)

    m_ScreenUpdating = Application.ScreenUpdating
    m_EnableEvents   = Application.EnableEvents
    m_Calculation    = Application.Calculation
    m_DisplayAlerts  = Application.DisplayAlerts
    m_StateActive    = True

    If disableScreen Then Application.ScreenUpdating = False
    If disableEvents Then Application.EnableEvents   = False
    If manualCalc    Then Application.Calculation    = xlCalculationManual
End Sub

' ---------------------------------------------------------------------------
' AppEnd – visszaállítja az eredeti állapotot (mindig hívandó, EH/Cleanup-ban)
' ---------------------------------------------------------------------------
Public Sub AppEnd()
    If Not m_StateActive Then Exit Sub
    Application.ScreenUpdating = m_ScreenUpdating
    Application.EnableEvents   = m_EnableEvents
    Application.Calculation    = m_Calculation
    Application.DisplayAlerts  = m_DisplayAlerts
    m_StateActive = False
End Sub

' ---------------------------------------------------------------------------
' AppReset – kényszeres visszaállítás ismert alapállapotba (pl. vészhelyzet)
' ---------------------------------------------------------------------------
Public Sub AppReset()
    Application.ScreenUpdating = True
    Application.EnableEvents   = True
    Application.Calculation    = xlCalculationAutomatic
    Application.DisplayAlerts  = True
    m_StateActive = False
End Sub
