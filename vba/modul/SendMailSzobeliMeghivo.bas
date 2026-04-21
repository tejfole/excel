Attribute VB_Name = "SendMailSzobeliMeghivo"
Option Explicit

' Visszafelé kompatibilis belépési pont:
' a tényleges iktsz logika a modIktsz modulban van.
Public Sub FillIktszColumn(Optional control As IRibbonControl)
    Iktsz_Diakadat_SzobeliIdopont control
End Sub
