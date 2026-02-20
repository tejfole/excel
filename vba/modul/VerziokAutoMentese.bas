Attribute VB_Name = "VerziokAutoMentese"
Option Explicit

Public Sub SaveVersionedCopy(Optional control As IRibbonControl)
    Dim wb As Workbook
    Dim folderPath As String
    Dim versionFolder As String
    Dim baseName As String
    Dim fileName As String
    Dim versionNum As Long
    Dim todayDate As String
    Dim fullPath As String
    Dim fso As Object
    Dim dotPos As Integer

    Set wb = ThisWorkbook
    Set fso = CreateObject("Scripting.FileSystemObject")

    ' Alapesetben: a workbook mappája
    folderPath = wb.Path

    ' Ha SharePoint/OneDrive URL, próbáljuk átalakítani helyi útvonalra
    If InStr(1, folderPath, "http", vbTextCompare) = 1 Then
        folderPath = ConvertSharePointToLocalPath(folderPath)
        
        If folderPath = "" Then
            MsgBox "?? A fájl SharePoint-on van, de nincs szinkronizálva!" & vbCrLf & vbCrLf & _
                   "Kérlek:" & vbCrLf & _
                   "1. Szinkronizáld le a OneDrive mappát" & vbCrLf & _
                   "2. Nyisd meg a fájlt a helyi OneDrive mappából" & vbCrLf & _
                   "3. Futtasd újra a makrót", vbExclamation
            Exit Sub
        End If
    End If

    ' Ha még mindig nincs érvényes útvonal
    If folderPath = "" Then
        MsgBox "?? A fájlt elõször el kell menteni!", vbCritical
        Exit Sub
    End If

    ' Verziók almappa a munkakönyvtárban
    versionFolder = folderPath & "\Verziok"
    
    ' Almappa létrehozása
    If Not fso.FolderExists(versionFolder) Then
        On Error Resume Next
        fso.CreateFolder versionFolder
        If Err.Number <> 0 Then
            MsgBox "? Nem sikerült létrehozni a Verziok mappát!" & vbCrLf & Err.Description, vbCritical
            Exit Sub
        End If
        On Error GoTo 0
    End If

    ' Fájlnév és kiterjesztés kezelése
    dotPos = InStrRev(wb.Name, ".")
    If dotPos > 0 Then
        baseName = Left(wb.Name, dotPos - 1)
    Else
        baseName = wb.Name
    End If

    ' Dátum
    todayDate = Format(Date, "yyyymmdd")

    ' Verziószám: v01, v02...
    versionNum = 1
    Do
        fileName = baseName & "_" & todayDate & "_v" & Format(versionNum, "00") & ".xlsm"
        fullPath = versionFolder & "\" & fileName
        If Not fso.FileExists(fullPath) Then Exit Do
        versionNum = versionNum + 1
        If versionNum > 99 Then
            MsgBox "?? Túl sok verzió van már a mai napra (99+)!", vbExclamation
            Exit Sub
        End If
    Loop

    ' Mentés
    On Error Resume Next
    wb.SaveCopyAs fullPath
    If Err.Number <> 0 Then
        MsgBox "? Mentés sikertelen!" & vbCrLf & Err.Description, vbCritical
        Exit Sub
    End If
    On Error GoTo 0

    MsgBox "? Verzió mentve:" & vbCrLf & fullPath, vbInformation
    
    Set fso = Nothing
End Sub

Private Function ConvertSharePointToLocalPath(ByVal webPath As String) As String
    ' SharePoint URL › helyi OneDrive útvonal konvertálása
    Dim localPath As String
    Dim oneDriveRoot As String
    Dim relativePath As String
    Dim fso As Object
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    ' OneDrive gyökér meghatározása
    oneDriveRoot = GetOneDriveRoot()
    If oneDriveRoot = "" Then
        ConvertSharePointToLocalPath = ""
        Exit Function
    End If
    
    ' SharePoint URL › relatív útvonal
    ' Példa: https://szegbp-my.sharepoint.com/personal/.../Documents/Szeg/felveteli2026
    ' › Szeg/felveteli2026
    
    If InStr(webPath, "/Documents/") > 0 Then
        relativePath = Mid(webPath, InStr(webPath, "/Documents/") + Len("/Documents/"))
        relativePath = Replace(relativePath, "/", "\")
        
        ' Teljes helyi útvonal összeállítása
        localPath = oneDriveRoot & "\" & relativePath
        
        ' Ellenõrizzük, hogy létezik-e
        If fso.FolderExists(localPath) Then
            ConvertSharePointToLocalPath = localPath
        Else
            ConvertSharePointToLocalPath = ""
        End If
    Else
        ConvertSharePointToLocalPath = ""
    End If
    
    Set fso = Nothing
End Function

Private Function GetOneDriveRoot() As String
    ' Business / School account (ez a te esetedben)
    GetOneDriveRoot = Environ$("OneDriveCommercial")
    If GetOneDriveRoot <> "" Then Exit Function

    ' Personal account
    GetOneDriveRoot = Environ$("OneDrive")
    If GetOneDriveRoot <> "" Then Exit Function

    ' Ritkább elnevezés
    GetOneDriveRoot = Environ$("OneDriveConsumer")
End Function
