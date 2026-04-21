Attribute VB_Name = "IktszIskolaErthez"
Sub KitoltIktsz_TablaAutomatikusan()
    If FillIktsz("lista", "isk_nev", "iktsz", 1, Empty, False, True, True) Then
        MsgBox "Az iktsz oszlop sikeresen feltöltve az 'isk_nev' alapján!", vbInformation
    End If
End Sub

