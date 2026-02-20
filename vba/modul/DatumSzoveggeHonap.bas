Attribute VB_Name = "DatumSzoveggeHonap"
Function DatumSzovegge3(ByVal datum As Date) As String
    Dim honapok As Variant
    honapok = Array("", "január", "február", "március", "április", "május", "június", _
                        "július", "augusztus", "szeptember", "október", "november", "december")

    DatumSzovegge3 = honapok(Month(datum))
End Function


