'EXAMPLE: wscript.exe "Desktop/paleisti_nematoma_patikra.vbs" "Prat�sti Windows 7 aktyvacija dar 30 dien�.cmd"
CreateObject("Wscript.Shell").Run """" & WScript.Arguments(0) & """", 0, False