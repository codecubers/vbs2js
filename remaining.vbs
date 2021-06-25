


' ================================== Job: vbspm-build ================================== 

' ================= src : lib/core/init.vbs ================= 
Option Explicit

Dim debug: debug = (WScript.Arguments.Named("debug") = "true")
if (debug) Then WScript.Echo "Debug is enabled"
Dim VBSPM_TEST_INDEX: VBSPM_TEST_INDEX = 1
Dim vbspmDir: vbspmDir=Left(WScript.ScriptFullName,InStrRev(WScript.ScriptFullName,"\"))
Dim baseDir
With CreateObject("WScript.Shell")
    baseDir=.CurrentDirectory
End With
' Judging by the declaration and description of the startsWith Java function, 
' the "most straight forward way" to implement it in VBA would either be with Left:
' Author: Blackhawk
' Source: https://stackoverflow.com/a/20805609/1751166

Public Function startsWith(str, prefix)
    startsWith = Left(str, Len(prefix)) = prefix
End Function

Public Function endsWith(str, suffix)
    endsWith = Right(str, Len(suffix)) = suffix
End Function

Public Function contains(str, char)
    contains = (Instr(1, str, char) > 0)
End Function

Public Function argsArray()
    Dim i
    ReDim arr(WScript.Arguments.Count-1)
    For i = 0 To WScript.Arguments.Count-1
        arr(i) = """"+WScript.Arguments(i)+""""
    Next
    argsArray = arr
End Function

Public Function argsDict()
    Dim i, param, dict
    set dict = CreateObject("Scripting.Dictionary")
    dict.CompareMode = vbTextCompare
    ReDim arr(WScript.Arguments.Count-1)
    For i = 1 To WScript.Arguments.Count-1
        param = WScript.Arguments(i)
        If startsWith(param, "/") And contains(param, ":") Then
            param = mid(param, 2)
            WScript.Echo "param to be split: " & param
            dict.Add Lcase(split(param, ":")(0)), split(param, ":")(1)
        Else
            dict.Add i, param
        End If
    Next
    set argsDict = dict
End Function

' ================= src : lib/core/Console/Console.vbs ================= 

' ================= src : lib/core/init-functions.vbs ================= 
Dim oConsole                         
set oConsole = new Console
PUblic Sub printf(str, args)
    'TODO: If use use %s, %d, %f format the values according to it.
    str = Replace(str, "%s", "%x")
    str = Replace(str, "%i", "%x")
    str = Replace(str, "%f", "%x")
    str = Replace(str, "%d", "%x")
    WScript.Echo oConsole.fmt(str, args)
End Sub

Public Sub debugf(str, args)
    if (debug) Then printf str, args
End Sub

Public Sub EchoX(str, args)
    If Not IsNull(args) Then
        If IsArray(args) Then
            'WScript.Echo str & " with args " & join(args, ",")
            WScript.Echo oConsole.fmt(str, args)
        Else
            'WScript.Echo str & " with arg " & args
            WScript.Echo oConsole.fmt(str, Array(args))
        End if
    Else
        WScript.Echo str
    End If
End Sub

Public Sub Echo(str) 
    EchoX str, NULL
End Sub

Public Sub EchoDX(str, args)
    if (debug) Then EchoX str, args
End Sub

Public Sub EchoD(str) 
    EchoDX str, NULL
End Sub
' ================= src : lib/core/Collection/Collection.vbs ================= 


' Collection
' ================= src : lib/core/DictUtil.vbs ================= 

' ================= src : lib/core/ArrayUtil/ArrayUtil.vbs ================= 

' ================= inline ================= 

Dim arrUtil
set arrUtil = new ArrayUtil

' ================= src : lib/core/PathUtil/PathUtil.vbs ================= 
' PathUtil
' ================= inline ================= 

Dim putil
set putil = new PathUtil
putil.BasePath = baseDir
EchoX "Project location: %x", putil.BasePath

' ================= src : lib/core/FSO/FSO.vbs ================= 
' ==============================================================================================
' Implementation of several use cases of FileSystemObject into this
' ================= inline ================= 

Dim cFS
set cFS = new FSO

cFS.setDir(baseDir)

Public Function log(msg)
cFS.WriteFile "build.log", msg, false
End Function

'vbspmDir = cFS.GetFileDir(WScript.ScriptFullName)
log "VBSPM Directory: " & vbspmDir


' ================= src : lib/core/include-build.vbs ================= 

Public Sub Include(file)
  ' DO NOT REMOVE THIS Sub Routine
End Sub
Public Sub Import(file)
  ' DO NOT REMOVE THIS Sub Routine
End Sub


'================= File: C:\Users\nanda\git\xps.local.npm\vbs-excel-utilities\lib\parameters.vbs =================
Dim wbFile
If Wscript.Arguments.Named.Exists("workbook") Then
    wbFile = Wscript.Arguments.Named("workbook")
    EchoX "Excel workbook to be packed/unpacked: %x", wbFile
Else
    Echo "No excel workbook supplied as a parameter. Nothing to unpack."
    WScript.Quit
End If

Dim sourceDir
If Wscript.Arguments.Named.Exists("source") Then
    sourceDir = Wscript.Arguments.Named("source")
    EchoX "Excel workbook will be packed from directory: %x", sourceDir
End If

Dim destDir
If Wscript.Arguments.Named.Exists("destination") Then
    destDir = Wscript.Arguments.Named("destination")
    EchoX "Excel workbook will be unpacked to directory: %x", destDir
End If


'================= File: C:\Users\nanda\git\xps.local.npm\vbs-excel-utilities\ExcelUtil.vbs =================
' Excel


'================= File: C:\Users\nanda\git\xps.local.npm\vbs-excel-utilities\lib\export.vbs =================
Include("..\ExcelUtil.vbs")
Include(".\parameters.vbs")

Dim xl
set xl = new ExcelUtil

EchoX "Opening workbook at path: %x", wbFile
xl.OpenWorkBook(wbFile)

EchoX "Active workbook name is: %x", xl.GetActiveWorkbook.Name

xl.ExportVBAComponents(destDir)

xl.CloseWorkBook
set xl = nothing
