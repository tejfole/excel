Attribute VB_Name = "IktszSzamFeltoltese"
Sub KitoltIktsz_TablaAutomatikusan(Optional control As IRibbonControl)
    If FillIktsz("lista", "oktazon", "iktsz", 1, Empty, False, True, True) Then
        MsgBox "Az iktsz oszlop sikeresen feltöltve az 'oktazon' alapján!", vbInformation
    End If
End Sub

