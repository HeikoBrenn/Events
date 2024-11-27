Dim shell,command
command = "powershell.exe -windowstyle hidden -noprofile -executionpolicy bypass -file ""C:\Test\RandomChristmasWindowsBackground.ps1"""
set objShell = CreateObject("wscript.shell")
objShell.Run command,0