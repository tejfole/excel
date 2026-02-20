Attribute VB_Name = "SzamitRangot2"
Function SzamitRangot(Pontszam As Double, Pontok As Range, Hatranyos As Range, Lakcim As Range, Testver As Range, szobeli As Range, matek As Range, magyar As Range, Fogalmazas As Range) As Integer
    Dim cell As Range
    Dim rang As Integer
    Dim prioritasEmeles As Integer
    Dim pozicio As Variant
    Dim azonosPontszamuak As Integer
    Dim korrigaltRang As Double
    Dim extraPrioritas As Double

    rang = 1
    prioritasEmeles = 0
    azonosPontszamuak = 0
    extraPrioritas = 0

    ' Alap rangsor meghatározása
    For Each cell In Pontok
        If IsNumeric(cell.value) Then
            If cell.value > Pontszam Then
                rang = rang + 1
            ElseIf cell.value = Pontszam Then
                azonosPontszamuak = azonosPontszamuak + 1
            End If
        End If
    Next cell

    ' Ha nincs pontegyezés, visszatérünk az alapranggal
    If azonosPontszamuak = 1 Then
        SzamitRangot = rang
        Exit Function
    End If

    ' Megkeressük a pontos pozíciót
    On Error Resume Next
    pozicio = Application.Match(Pontszam, Pontok, 0)
    On Error GoTo 0

    If IsError(pozicio) Then
        SzamitRangot = rang
        Exit Function
    End If

    ' Prioritások figyelembevétele
    If LCase(Trim(CStr(Hatranyos.Cells(pozicio, 1).value))) = "x" Then prioritasEmeles = prioritasEmeles - 1
    If LCase(Trim(CStr(Lakcim.Cells(pozicio, 1).value))) = "x" Then prioritasEmeles = prioritasEmeles - 1
    If LCase(Trim(CStr(Testver.Cells(pozicio, 1).value))) = "x" Then prioritasEmeles = prioritasEmeles - 1

    ' Plusz pontok finomhangoláshoz
    If IsNumeric(szobeli.Cells(pozicio, 1).value) Then extraPrioritas = extraPrioritas + szobeli.Cells(pozicio, 1).value / 1000
    If IsNumeric(matek.Cells(pozicio, 1).value) Then extraPrioritas = extraPrioritas + matek.Cells(pozicio, 1).value / 1000
    If IsNumeric(magyar.Cells(pozicio, 1).value) Then extraPrioritas = extraPrioritas + magyar.Cells(pozicio, 1).value / 1000
    If IsNumeric(Fogalmazas.Cells(pozicio, 1).value) Then extraPrioritas = extraPrioritas + Fogalmazas.Cells(pozicio, 1).value / 1000

    ' Korrigált rang visszaadása (egészre kerekítve)
    korrigaltRang = rang + prioritasEmeles - extraPrioritas
    SzamitRangot = Round(korrigaltRang)
End Function

