'EXAMPLE: wscript.exe "Desktop/paleisti_nematoma_patikra.vbs" "Pratæsti Windows 7 aktyvacija dar 30 dienø.cmd"
CreateObject("Wscript.Shell").Run """" & WScript.Arguments(0) & """", 0, False