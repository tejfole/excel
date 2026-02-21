Attribute VB_Name = "modTextNorm"
Option Explicit

' =============================================================================
' modTextNorm – Közös szövegnormalizálás
' =============================================================================
' NKey: ékezetes → ékezet nélküli, kisbetű, whitespace/kötőjel/underscore → "_"
' NormalizeSpaces: többszörös szóköz → egy szóköz, trim
' StripHungarianAccents: csak az ékezetcsere
' =============================================================================

' ---------------------------------------------------------------------------
' NKey – normalizált kulcs összehasonlításhoz és fejléc-kereséshez
' ---------------------------------------------------------------------------
Public Function NKey(ByVal s As String) As String
    s = Trim$(s)
    s = NormalizeSpaces(s)
    s = StripHungarianAccents(s)
    s = LCase$(s)
    ' whitespace, kötőjel, underscore → _
    Dim i As Long
    Dim ch As String
    Dim result As String
    result = ""
    For i = 1 To Len(s)
        ch = Mid$(s, i, 1)
        Select Case ch
            Case " ", "-", "_"
                result = result & "_"
            Case Else
                result = result & ch
        End Select
    Next i
    ' többszörös underscore összevonása
    Do While InStr(result, "__") > 0
        result = Replace(result, "__", "_")
    Loop
    ' vezető/záró underscore eltávolítása
    result = Trim$(result)
    Do While Left$(result, 1) = "_"
        result = Mid$(result, 2)
    Loop
    Do While Right$(result, 1) = "_"
        result = Left$(result, Len(result) - 1)
    Loop
    NKey = result
End Function

' ---------------------------------------------------------------------------
' NormalizeSpaces – többszörös szóközt egy szóközre cseréli, trim
' ---------------------------------------------------------------------------
Public Function NormalizeSpaces(ByVal s As String) As String
    s = Trim$(s)
    Do While InStr(s, "  ") > 0
        s = Replace(s, "  ", " ")
    Loop
    NormalizeSpaces = s
End Function

' ---------------------------------------------------------------------------
' StripHungarianAccents – magyar ékezetes betűk → ékezet nélküli megfelelők
' ---------------------------------------------------------------------------
Public Function StripHungarianAccents(ByVal s As String) As String
    ' Nagybetűk
    s = Replace(s, Chr(193), "A")   ' Á
    s = Replace(s, Chr(201), "E")   ' É
    s = Replace(s, Chr(205), "I")   ' Í
    s = Replace(s, Chr(211), "O")   ' Ó
    s = Replace(s, Chr(214), "O")   ' Ö
    s = Replace(s, Chr(336), "O")   ' Ő
    s = Replace(s, Chr(218), "U")   ' Ú
    s = Replace(s, Chr(220), "U")   ' Ü
    s = Replace(s, Chr(368), "U")   ' Ű
    ' Kisbetűk
    s = Replace(s, Chr(225), "a")   ' á
    s = Replace(s, Chr(233), "e")   ' é
    s = Replace(s, Chr(237), "i")   ' í
    s = Replace(s, Chr(243), "o")   ' ó
    s = Replace(s, Chr(246), "o")   ' ö
    s = Replace(s, Chr(337), "o")   ' ő
    s = Replace(s, Chr(250), "u")   ' ú
    s = Replace(s, Chr(252), "u")   ' ü
    s = Replace(s, Chr(369), "u")   ' ű
    StripHungarianAccents = s
End Function
