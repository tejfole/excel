Attribute VB_Name = "DatumSzoveggeEv"
Function DatumSzovegge5(ByVal datum As Date) As String
    Dim honapok As Variant
    honapok = Array("", "január", "február", "március", "április", "május", "június", _
                        "július", "augusztus", "szeptember", "október", "november", "december")

    DatumSzovegge5 = Year(datum) & "."
End Function


