Attribute VB_Name = "modDialogs"
Option Explicit

' =============================================================================
' modDialogs – Közös file/folder picker és prompt utilok
' =============================================================================

' ---------------------------------------------------------------------------
' PickExcelFile – Excel fájl kiválasztása (xls, xlsx, xlsm, xlsb)
' ---------------------------------------------------------------------------
Public Function PickExcelFile(Optional ByVal title As String = "") As String
    Dim fd As FileDialog
    Set fd = Application.FileDialog(msoFileDialogFilePicker)
    With fd
        If title <> "" Then .Title = title
        .Filters.Clear
        .Filters.Add "Excel fájlok", "*.xls;*.xlsx;*.xlsm;*.xlsb"
        .AllowMultiSelect = False
        If .Show <> -1 Then
            PickExcelFile = ""
        Else
            PickExcelFile = .SelectedItems(1)
        End If
    End With
End Function

' ---------------------------------------------------------------------------
' PickWordFile – Word fájl kiválasztása (doc, docx, docm)
' ---------------------------------------------------------------------------
Public Function PickWordFile(Optional ByVal title As String = "") As String
    Dim fd As FileDialog
    Set fd = Application.FileDialog(msoFileDialogFilePicker)
    With fd
        If title <> "" Then .Title = title
        .Filters.Clear
        .Filters.Add "Word dokumentumok", "*.doc;*.docx;*.docm"
        .AllowMultiSelect = False
        If .Show <> -1 Then
            PickWordFile = ""
        Else
            PickWordFile = .SelectedItems(1)
        End If
    End With
End Function

' ---------------------------------------------------------------------------
' PickFolder – Mappa kiválasztása
' ---------------------------------------------------------------------------
Public Function PickFolder(Optional ByVal title As String = "") As String
    Dim fd As FileDialog
    Set fd = Application.FileDialog(msoFileDialogFolderPicker)
    With fd
        If title <> "" Then .Title = title
        If .Show <> -1 Then
            PickFolder = ""
        Else
            PickFolder = .SelectedItems(1)
        End If
    End With
End Function

' ---------------------------------------------------------------------------
' AskLong – szám bekérése InputBox-on keresztül; érvénytelen/üres → def
' ---------------------------------------------------------------------------
Public Function AskLong(ByVal prompt As String, _
                         Optional ByVal title As String = "", _
                         Optional ByVal def As Long = 0) As Long
    Dim s As String
    s = InputBox(prompt, title, CStr(def))
    s = Trim$(s)
    If s = "" Or Not IsNumeric(s) Then
        AskLong = def
    Else
        AskLong = CLng(s)
    End If
End Function
