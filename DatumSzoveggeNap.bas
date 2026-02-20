Attribute VB_Name = "DatumSzoveggeNap"
Function DatumSzovegge4(ByVal datum As Date) As String
    Dim honapok As Variant
    honapok = Array("", "január", "február", "március", "április", "május", "június", _
                        "július", "augusztus", "szeptember", "október", "november", "december")

    DatumSzovegge4 = Day(datum) & "."
End Function

