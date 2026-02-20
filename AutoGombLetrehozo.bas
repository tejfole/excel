Attribute VB_Name = "AutoGombLetrehozo"
Sub CreateShapeButton()
    Dim ws As Worksheet
    Dim shp As Shape
    Dim buttonText As String
    Dim macroName As String
    Dim cellAddress As String
    Dim topLeftCell As Range
    Dim tryRow As Long
    Dim foundEmptyCell As Boolean

    Set ws = ActiveSheet

    ' Gomb szöveg bekérése
    buttonText = InputBox("Írd be a gomb szövegét:", "Gomb szöveg")
    If buttonText = "" Then
        buttonText = "Új gomb"
    End If

    ' Makró neve bekérése (opcionális)
    macroName = InputBox("Add meg a makró nevét, amit a gomb indítson:", "Makró hozzárendelés")
    If macroName = "" Then
        macroName = ""
    End If

    ' Cella bekérése
    cellAddress = InputBox("Melyik cellába helyezzük a gombot? (pl. B2)", "Cella kiválasztása")
    If cellAddress = "" Then
        MsgBox "? Cella megadása kötelezõ!", vbCritical
        Exit Sub
    End If

    ' Ellenõrizzük a cellát
    On Error Resume Next
    Set topLeftCell = ws.Range(cellAddress)
    On Error GoTo 0
    If topLeftCell Is Nothing Then
        MsgBox "? Hibás cellahivatkozás!", vbCritical
        Exit Sub
    End If

    ' Ha foglalt, 5 sorral lejjebb megy
    foundEmptyCell = False
    tryRow = topLeftCell.Row

    Do While Not foundEmptyCell
        Dim existingBtn As Shape
        foundEmptyCell = True
        
        For Each existingBtn In ws.Shapes
            If existingBtn.Type = msoShapeRectangle Then
                If existingBtn.topLeftCell.Address = ws.Cells(tryRow, topLeftCell.Column).Address Then
                    foundEmptyCell = False
                    tryRow = tryRow + 5
                    Exit For
                End If
            End If
        Next existingBtn
    Loop

    Set topLeftCell = ws.Cells(tryRow, topLeftCell.Column)

    ' Új gomb alakzat (Rectangle)
    Set shp = ws.Shapes.AddShape(msoShapeRoundedRectangle, topLeftCell.Left, topLeftCell.Top, 200, 50)

    ' Gomb formázása
    With shp
        .TextFrame2.TextRange.Text = buttonText
        .TextFrame2.VerticalAnchor = msoAnchorMiddle
        With .TextFrame2.TextRange.Font
            .Name = "Arial"
            .Size = 14
            .Bold = msoTrue
            .Fill.ForeColor.RGB = RGB(255, 255, 255) ' Fehér betû
        End With

        ' Háttérszín
        .Fill.ForeColor.RGB = RGB(0, 153, 255) ' Világoskék
        .Line.Visible = msoFalse ' Keret eltüntetése

        ' Makró hozzárendelése, ha megadott
        If macroName <> "" Then
            .OnAction = macroName
        End If
    End With

    MsgBox "? Szép alakzat-gomb létrehozva a(z) " & topLeftCell.Address(False, False) & " cellába!" & vbNewLine & _
           "? Ha nem rendeltél hozzá makrót, jobb gombbal még megteheted.", vbInformation
End Sub


