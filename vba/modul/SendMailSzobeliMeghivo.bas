Attribute VB_Name = "SendMailSzobeliMeghivo"
Option Explicit

' ============================================================================
' Visszafelé kompatibilis wrapper a feltételes iktsz-kiosztáshoz.
' Kulcs: bizottsag + datum_nap
' Feltétel: bizottsag, datum_nap, mail, idopont_kiadva nem üres
' Kiosztás: meglévő iktsz-ek megtartása és a legnagyobbtól folytatás
' ============================================================================
Public Sub FillIktszColumn(Optional control As IRibbonControl)
    FillIktsz "diakadat", _
              Array("bizottsag", "datum_nap"), _
              "iktsz", _
              1, _
              Array("bizottsag", "datum_nap", "mail", "idopont_kiadva"), _
              True, _
              False, _
              False
End Sub
