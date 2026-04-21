Attribute VB_Name = "IktszSzamFeltoltese"

' Backward-compatible entrypoint used by existing Ribbon callbacks/macros.
Public Sub KitoltIktsz_TablaAutomatikusan(Optional control As IRibbonControl)
    FillIktsz_ListaHatarozatok control
End Sub
