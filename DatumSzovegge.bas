Attribute VB_Name = "DatumSzovegge"
Function DatumSzovegge2(ByVal datum As Date) As String
    Dim honapok As Variant
    honapok = Array("", "január", "február", "március", "április", "május", "június", _
                        "július", "augusztus", "szeptember", "október", "november", "december")

    DatumSzovegge2 = Year(datum) & ". " & honapok(Month(datum)) & " " & Day(datum) & "."
End Function


