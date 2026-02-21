Attribute VB_Name = "modImportDiakadat"
Option Explicit

' =============================================================================
' modImportDiakadat – Diakadat import az Export munkalapról a diakadat táblába
' =============================================================================

Private Const KEY_ALIAS_DEFAULT As String = "Oktatási azonosító"
Private Const DST_TABLE_NAME    As String = "diakadat"
Private Const SRC_SHEET_DEFAULT As String = "Export"

' ---------------------------------------------------------------------------
' ImportDiakadat – fő makró (Ribbon-ból hívható)
' ---------------------------------------------------------------------------
Public Sub ImportDiakadat(Optional control As IRibbonControl)
    ' 1) Forrásfájl kiválasztása
    Dim srcPath As String
    srcPath = modDialogs.PickExcelFile("Válaszd ki a FORRÁS Excel fájlt")
    If srcPath = "" Then Exit Sub

    ' 2) Kulcs alias bekérése (Cancel → KEY_ALIAS_DEFAULT)
    Dim keyAlias As String
    keyAlias = InputBox("Forrás kulcs oszlop fejléce:", "Kulcs kiválasztás", KEY_ALIAS_DEFAULT)
    If StrPtr(keyAlias) = 0 Or Trim$(keyAlias) = "" Then
        keyAlias = KEY_ALIAS_DEFAULT
    End If

    modApp.AppBegin True, True, True
    On Error GoTo EH

    ' 3) Céltábla megnyitása
    Dim loD As ListObject
    Set loD = modTableUtils.FindTableByName(ThisWorkbook, DST_TABLE_NAME)
    If loD Is Nothing Then
        MsgBox "Nem található '" & DST_TABLE_NAME & "' tábla a munkafüzetben.", vbExclamation
        GoTo Cleanup
    End If

    ' 4) Forrásmunkafüzet megnyitása
    Dim wbS As Workbook
    Set wbS = Workbooks.Open(srcPath, ReadOnly:=True)

    ' 5) Forrásmunkalap keresése
    Dim wsS As Worksheet
    Set wsS = modImportCore.GetSheetByNameOrPrompt(wbS, SRC_SHEET_DEFAULT)
    If wsS Is Nothing Then GoTo CloseSource

    ' 6) Fejléc térképek felépítése
    Dim mapS As Object
    Set mapS = modImportCore.BuildHeaderMapNorm(wsS, 1)
    Dim mapD As Object
    Set mapD = modImportCore.BuildListObjectColMap(loD)

    ' 7) Kulcs oszlopok meghatározása
    Dim nkKeyAlias As String: nkKeyAlias = modTextNorm.NKey(keyAlias)
    If Not mapS.Exists(nkKeyAlias) Then
        MsgBox "A forrásban nem találom ezt a kulcs fejlécet: " & keyAlias, vbExclamation
        GoTo CloseSource
    End If
    Dim colKeyS As Long: colKeyS = mapS(nkKeyAlias)

    Dim colKeyD As Long: colKeyD = modTableUtils.ColIndex(loD, "oktazon", True)
    If colKeyD = -1 Then GoTo CloseSource

    ' 8) Forrás→Cél mezőleképezés felépítése
    '    NKey(forrás fejléc) → cél oszlopnév
    Dim m As Object: Set m = CreateObject("Scripting.Dictionary")
    m(modTextNorm.NKey("Oktatási azonosító"))     = "oktazon"
    m(modTextNorm.NKey("Név"))                    = "f_nev"
    m(modTextNorm.NKey("Születési hely"))          = "f_szul_hely"
    m(modTextNorm.NKey("Születési dátum"))         = "f_szul_ido"
    m(modTextNorm.NKey("Anyja születéskori neve")) = "f_a_nev"
    m(modTextNorm.NKey("Állandó lakcím"))          = "a_cim"
    m(modTextNorm.NKey("Értesítési név"))           = "ert_nev"
    m(modTextNorm.NKey("Értesítési cím"))           = "ert_cim"
    m(modTextNorm.NKey("Általános iskola neve"))    = "isknev"
    m(modTextNorm.NKey("Általános iskola"))         = "isknev"
    m(modTextNorm.NKey("Iskola neve"))              = "isknev"
    m(modTextNorm.NKey("Értesítési e-mail címek"))  = "mail"
    m(modTextNorm.NKey("Értesítési e-mail cím"))    = "mail"
    m(modTextNorm.NKey("Értesítési e-mail"))        = "mail"
    m(modTextNorm.NKey("Értesítési email címek"))   = "mail"
    m(modTextNorm.NKey("Értesítési email cím"))     = "mail"
    m(modTextNorm.NKey("Értesítési email"))         = "mail"
    m(modTextNorm.NKey("E-mail"))                   = "mail"
    m(modTextNorm.NKey("Email"))                    = "mail"
    m(modTextNorm.NKey("Kapcsolattartó e-mail"))    = "mail"
    m(modTextNorm.NKey("Kapcsolattartó email"))     = "mail"
    m(modTextNorm.NKey("Értesítési telefonszámok")) = "tel"
    m(modTextNorm.NKey("Telefonszám"))              = "tel"
    m(modTextNorm.NKey("Telefon"))                  = "tel"
    m(modTextNorm.NKey("Mobilszám"))                = "tel"
    m(modTextNorm.NKey("Mobil"))                    = "tel"
    m(modTextNorm.NKey("Kapcsolattartó telefonszám")) = "tel"
    m(modTextNorm.NKey("Kapcsolattartó telefon"))   = "tel"
    m(modTextNorm.NKey("SNI"))                      = "f_SNI2"
    m(modTextNorm.NKey("BTMN"))                     = "f_BTNN"
    m(modTextNorm.NKey("Megjegyzés"))               = "megjegyzes"
    m(modTextNorm.NKey("Jelige"))                   = "f_jelige"
    m(modTextNorm.NKey("001/1000"))                 = "j_1000"
    m(modTextNorm.NKey("001/2000"))                 = "j_2000"
    m(modTextNorm.NKey("001/3000"))                 = "j_3000"
    m(modTextNorm.NKey("001/4000"))                 = "j_4000"

    ' 9) Céltábla sor-index felépítése
    Dim idxD As Object: Set idxD = CreateObject("Scripting.Dictionary")
    modImportCore.BuildDestIndex loD, colKeyD, idxD

    ' 10) Opcionális oszlopok: szul_ev, szul_ho, I_ker_irsz
    Dim colSzulEv  As Long: colSzulEv  = modTableUtils.ColIndex(loD, "szul_ev",    False)
    Dim colSzulHo  As Long: colSzulHo  = modTableUtils.ColIndex(loD, "szul_ho",    False)
    Dim colIKer    As Long: colIKer    = modTableUtils.ColIndex(loD, "I_ker_irsz", False)
    Dim colACim    As Long: colACim    = modTableUtils.ColIndex(loD, "a_cim",       False)
    Dim colSzulIdo As Long: colSzulIdo = modTableUtils.ColIndex(loD, "f_szul_ido", False)

    ' 11) Feldolgozás
    Dim lastRow As Long
    lastRow = wsS.Cells(wsS.Rows.Count, colKeyS).End(xlUp).Row
    Dim readCount As Long, newCount As Long, filledCount As Long, skippedCount As Long

    Dim r As Long
    For r = 2 To lastRow
        Dim k As String
        k = Trim$(CStr(wsS.Cells(r, colKeyS).Value))
        If k = "" Then GoTo NextRow
        readCount = readCount + 1

        ' Céltábla sor meghatározása / létrehozása
        Dim lr As ListRow
        Dim isNew As Boolean: isNew = False
        If idxD.Exists(k) Then
            Set lr = loD.ListRows(CLng(idxD(k)))
        Else
            Set lr = loD.ListRows.Add
            lr.Range.Cells(1, colKeyD).Value = k
            idxD(k) = lr.Index
            isNew = True
            newCount = newCount + 1
        End If

        ' Forrásmezők másolása
        Dim srcH As Variant, dstColName As String
        Dim wroteMail As Boolean: wroteMail = False
        Dim wroteTel  As Boolean: wroteTel  = False

        For Each srcH In m.Keys
            dstColName = m(srcH)
            ' oktazon-t nem írjuk felül (már beállítottuk)
            If modTextNorm.NKey(dstColName) = "oktazon" Then GoTo ContinueField

            ' Forrásban van-e ez az oszlop?
            If Not mapS.Exists(srcH) Then GoTo ContinueField
            ' Célban van-e ez az oszlop?
            If Not mapD.Exists(modTextNorm.NKey(dstColName)) Then GoTo ContinueField

            Dim cS As Long: cS = mapS(srcH)
            Dim cD As Long: cD = mapD(modTextNorm.NKey(dstColName))
            Dim v As Variant: v = wsS.Cells(r, cS).Value

            ' --- mail ---
            If modTextNorm.NKey(dstColName) = "mail" Then
                If Not wroteMail Then
                    Dim em As String: em = EmailFirstValid(CStr(v))
                    If em <> "" Then
                        Dim celMail As Range: Set celMail = lr.Range.Cells(1, cD)
                        Dim prevMailV As Variant: prevMailV = celMail.Value
                        modImportCore.WriteIfEmpty celMail, em
                        If IsError(prevMailV) Or IsNull(prevMailV) Or _
                           IsEmpty(prevMailV) Or Trim$(CStr(prevMailV)) = "" Then
                            filledCount = filledCount + 1
                        Else
                            skippedCount = skippedCount + 1
                        End If
                        wroteMail = True
                    End If
                End If
                GoTo ContinueField
            End If

            ' --- tel ---
            If modTextNorm.NKey(dstColName) = "tel" Then
                If Not wroteTel Then
                    Dim ph As String: ph = PhoneFirstValid(CStr(v))
                    If ph <> "" Then
                        Dim celTel As Range: Set celTel = lr.Range.Cells(1, cD)
                        Dim prevTelV As Variant: prevTelV = celTel.Value
                        modImportCore.WriteIfEmpty celTel, ph
                        If IsError(prevTelV) Or IsNull(prevTelV) Or _
                           IsEmpty(prevTelV) Or Trim$(CStr(prevTelV)) = "" Then
                            filledCount = filledCount + 1
                        Else
                            skippedCount = skippedCount + 1
                        End If
                        wroteTel = True
                    End If
                End If
                GoTo ContinueField
            End If

            ' --- dátum ---
            If modTextNorm.NKey(dstColName) = modTextNorm.NKey("f_szul_ido") Then
                v = CoerceToDateOrKeep(v)
            End If

            ' --- SNI / BTMN: igen → x ---
            If modTextNorm.NKey(dstColName) = modTextNorm.NKey("f_SNI2") Or _
               modTextNorm.NKey(dstColName) = modTextNorm.NKey("f_BTNN") Then
                v = YesToX(v)
            End If

            ' --- általános írás (csak üres cellába) ---
            Dim celD As Range: Set celD = lr.Range.Cells(1, cD)
            Dim prevVal As Variant: prevVal = celD.Value
            Dim srcEmpty As Boolean
            srcEmpty = (IsError(v) Or IsEmpty(v) Or IsNull(v) Or Trim$(CStr(v)) = "")
            If Not srcEmpty Then
                If IsError(prevVal) Or IsNull(prevVal) Or _
                   IsEmpty(prevVal) Or Trim$(CStr(prevVal)) = "" Then
                    modImportCore.WriteIfEmpty celD, v
                    filledCount = filledCount + 1
                Else
                    skippedCount = skippedCount + 1
                End If
            End If

ContinueField:
        Next srcH

        ' --- Levezetett mezők: szul_ev, szul_ho ---
        If colSzulIdo > 0 Then
            Dim dtV As Variant: dtV = lr.Range.Cells(1, colSzulIdo).Value
            If IsDate(dtV) Then
                Dim dtD As Date: dtD = CDate(dtV)
                If colSzulEv > 0 Then
                    modImportCore.WriteIfEmpty lr.Range.Cells(1, colSzulEv), Year(dtD)
                End If
                If colSzulHo > 0 Then
                    modImportCore.WriteIfEmpty lr.Range.Cells(1, colSzulHo), Month(dtD)
                End If
            End If
        End If

        ' --- I_ker_irsz: Budapest 1010–1019 ---
        If colIKer > 0 Then
            Dim addrVal As String: addrVal = ""
            If colACim > 0 Then
                addrVal = CStr(lr.Range.Cells(1, colACim).Value)
            Else
                ' Keressük a forrásban
                Dim nkACim As String: nkACim = modTextNorm.NKey("Állandó lakcím")
                If mapS.Exists(nkACim) Then
                    addrVal = CStr(wsS.Cells(r, mapS(nkACim)).Value)
                End If
            End If
            Dim celIKer As Range: Set celIKer = lr.Range.Cells(1, colIKer)
            If Trim$(CStr(celIKer.Value)) = "" Then
                If IsBudapest101x(addrVal) Then
                    celIKer.Value = "x"
                End If
            End If
        End If

NextRow:
    Next r

    ' 12) Összegzés
    MsgBox "Import kész." & vbCrLf & _
           "Olvasott sorok: " & readCount & vbCrLf & _
           "Új sorok: " & newCount & vbCrLf & _
           "Kitöltött mezők: " & filledCount & vbCrLf & _
           "Kihagyott (nem üres) mezők: " & skippedCount, vbInformation

CloseSource:
    On Error Resume Next
    wbS.Close SaveChanges:=False
    On Error GoTo 0

Cleanup:
    modApp.AppEnd
    Exit Sub

EH:
    MsgBox "Hiba: " & Err.Number & vbCrLf & Err.Description, vbCritical
    Resume Cleanup
End Sub

' =============================================================================
' EMAIL FELDOLGOZÁS
' =============================================================================

Private Function EmailFirstValid(ByVal szoveg As String) As String
    Dim col As Collection: Set col = ExtractEmails(szoveg)
    If col.Count = 0 Then EmailFirstValid = "" Else EmailFirstValid = CStr(col(1))
End Function

Private Function ExtractEmails(ByVal s As String) As Collection
    Dim col As New Collection
    s = Replace(s, ChrW(160), " ")
    Dim re As Object: Set re = CreateObject("VBScript.RegExp")
    re.Global = True
    re.IgnoreCase = True
    re.Pattern = "([A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,})"
    Dim ms As Object: Set ms = re.Execute(s)
    Dim mt As Object
    For Each mt In ms
        On Error Resume Next
        col.Add LCase$(Trim$(mt.Value)), LCase$(Trim$(mt.Value))
        On Error GoTo 0
    Next mt
    Set ExtractEmails = col
End Function

' =============================================================================
' TELEFON FELDOLGOZÁS
' =============================================================================

Private Function PhoneFirstValid(ByVal szoveg As String) As String
    Dim col As Collection: Set col = ExtractPhones(szoveg)
    If col.Count = 0 Then PhoneFirstValid = "" Else PhoneFirstValid = CStr(col(1))
End Function

Private Function ExtractPhones(ByVal s As String) As Collection
    Dim col As New Collection
    s = Replace(s, ChrW(160), " ")
    Dim parts As Variant
    parts = Split(MultiReplace(s, Array(vbCrLf, vbCr, vbLf, ";"), ","), ",")
    Dim p As Variant
    For Each p In parts
        Dim cleaned As String
        cleaned = CanonicalHuPhone(NormalizePhoneToken(CStr(p)))
        If cleaned <> "" Then
            On Error Resume Next
            col.Add cleaned, cleaned
            On Error GoTo 0
        End If
    Next p
    Set ExtractPhones = col
End Function

Private Function NormalizePhoneToken(ByVal t As String) As String
    t = Trim$(t)
    If t = "" Then NormalizePhoneToken = "": Exit Function
    If InStr(t, ":") > 0 Then t = Trim$(Mid$(t, InStrRev(t, ":") + 1))
    Dim i As Long, ch As String, out As String
    For i = 1 To Len(t)
        ch = Mid$(t, i, 1)
        If ch Like "#" Then
            out = out & ch
        ElseIf ch = "+" Then
            If out = "" Then out = "+"
        End If
    Next i
    NormalizePhoneToken = out
End Function

Private Function CanonicalHuPhone(ByVal t As String) As String
    If t = "" Then CanonicalHuPhone = "": Exit Function
    Dim digits As String: digits = t
    If Left$(digits, 1) = "+" Then digits = Mid$(digits, 2)
    Dim i As Long, ch As String, d As String
    For i = 1 To Len(digits)
        ch = Mid$(digits, i, 1)
        If ch Like "#" Then d = d & ch
    Next i
    If Left$(d, 2) = "06" Then d = "36" & Mid$(d, 3)
    If Len(d) = 9 Then d = "36" & d
    If Len(d) <> 11 Then
        CanonicalHuPhone = ""
    ElseIf Left$(d, 2) <> "36" Then
        CanonicalHuPhone = ""
    Else
        CanonicalHuPhone = "+" & d
    End If
End Function

Private Function MultiReplace(ByVal s As String, ByVal findArr As Variant, ByVal repl As String) As String
    Dim i As Long
    For i = LBound(findArr) To UBound(findArr)
        s = Replace(s, CStr(findArr(i)), repl)
    Next i
    MultiReplace = s
End Function

' =============================================================================
' EGYÉB SZABÁLYOK
' =============================================================================

Private Function CoerceToDateOrKeep(ByVal v As Variant) As Variant
    On Error GoTo Fail
    If IsDate(v) Then CoerceToDateOrKeep = CDate(v): Exit Function
    If IsNumeric(v) Then CoerceToDateOrKeep = DateSerial(1899, 12, 30) + CDbl(v): Exit Function
Fail:
    CoerceToDateOrKeep = v
End Function

Private Function IsBudapest101x(ByVal addressText As String) As Boolean
    Dim re As Object: Set re = CreateObject("VBScript.RegExp")
    re.Pattern = "(^|[^0-9])(101[0-9])([^0-9]|$)"
    re.Global = False
    re.IgnoreCase = True
    IsBudapest101x = re.Test(CStr(addressText))
End Function

Private Function YesToX(ByVal v As Variant) As Variant
    Dim s As String
    s = LCase$(Trim$(CStr(v)))
    If s = "" Then
        YesToX = vbNullString
    ElseIf s = "igen" Or s = "i" Or s = "x" Or s = "1" Or s = "true" Or s = "yes" Then
        YesToX = "x"
    Else
        YesToX = vbNullString
    End If
End Function
