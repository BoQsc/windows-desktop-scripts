@echo off & call :RequestAdminElevation "%~dpfs0" %* || goto:eof
CD "%~dp0"

SETLOCAL EnableExtensions enabledelayedexpansion
::set "cmd=echo list disk | diskpart"
::call :listCmd


:repeatScan
CLS
ECHO Scanning HDD array...
for /l %%x in (0, 1, 10) do (

	call :listPar "(echo select disk %%x & echo uniqueid disk) | diskpart" 
	IF "!results!"=="Please move the focus to a disk and try again." goto :repeatScan
echo Disk ID: !results! %%x
	IF "!results!"=="02535E6D" CALL :detectPartitionType %%x !results!
)


:detectPartitionType
cls
	call :listPard "(echo select disk %1 & echo select partition 1 & echo detail partition) | diskpart" 
	IF "!result2!"=="07" GOTO :changePartitionTypeToHidden
	IF "!result2!"=="17" GOTO :changePartitionTypeToNTFSPublic

	pause

GOTO :detectPartitionType


EXIT
:changePartitionTypeToHidden

	call :listPar "(echo select disk %1 & echo select partition 1 & echo set id ^= 17 override) | diskpart" 
EXIT

:changePartitionTypeToNTFSPublic
	call :listPar "(echo select disk %1 & echo select partition 1 & echo set id ^= 07 override) | diskpart" 
EXIT

::call :listPar "echo list part| diskpart" 
::call :listPar "(echo select disk 1 & echo list partition) | diskpart" 
pause
ENDLOCAL
goto :eof

:listCmd
::echo %~0 %*
for /F "skip=7 usebackq delims=" %%? in (`"%cmd%"`) do (
  if "%%?" NEQ "DISKPART> " echo(=%%?=
)
goto :eof

:listPar
::echo %~0 %*
for /F "skip=7 usebackq delims=" %%? in (`"%~1"`) do (
  ::if "%%?" NEQ "DISKPART> " echo(=%%?=
  if "%%?" NEQ "DISKPART> " set "results=%%?"
)
set "results2=%results:: =" & set "results=%"
goto :eof

:listPard                        
for /F "usebackq delims=" %%? in (`"%~1|findstr "^^Type""`) do (
   set "result=%%~?"
)
set "result2=%result:*:=%"
set "result2=%result2: =%"

:: debug output:
::set result

goto :eof





EXIT
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RequestAdminElevation FilePath %* || goto:eof
:: 
:: By:   Cyberponk,     v1.5 - 10/06/2016 - Changed the admin rights test method from cacls to fltmc
::          v1.4 - 17/05/2016 - Added instructions for arguments with ! char
::          v1.3 - 01/08/2015 - Fixed not returning to original folder after elevation successful
::          v1.2 - 30/07/2015 - Added error message when running from mapped drive
::          v1.1 - 01/06/2015
:: 
:: Func: opens an admin elevation prompt. If elevated, runs everything after the function call, with elevated rights.
:: Returns: -1 if elevation was requested
::           0 if elevation was successful
::           1 if an error occured
:: 
:: USAGE:
:: If function is copied to a batch file:
::     call :RequestAdminElevation "%~dpf0" %* || goto:eof
::
:: If called as an external library (from a separate batch file):
::     set "_DeleteOnExit=0" on Options
::     (call :RequestAdminElevation "%~dpf0" %* || goto:eof) && CD /D %CD%
::
:: If called from inside another CALL, you must set "_ThisFile=%~dpf0" at the beginning of the file
::     call :RequestAdminElevation "%_ThisFile%" %* || goto:eof
::
:: If you need to use the ! char in the arguments, the calling must be done like this, and afterwards you must use %args% to get the correct arguments:
::      set "args=%* "
::      call :RequestAdminElevation .....   use one of the above but replace the %* with %args:!={a)%
::      set "args=%args:{a)=!%" 
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
setlocal ENABLEDELAYEDEXPANSION & set "_FilePath=%~1"
  if NOT EXIST "!_FilePath!" (echo/Read RequestAdminElevation usage information)
  :: UAC.ShellExecute only works with 8.3 filename, so use %~s1
  set "_FN=_%~ns1" & echo/%TEMP%| findstr /C:"(" >nul && (echo/ERROR: %%TEMP%% path can not contain parenthesis &pause &endlocal &fc;: 2>nul & goto:eof)
  :: Remove parenthesis from the temp filename
  set _FN=%_FN:(=%
  set _vbspath="%temp:~%\%_FN:)=%.vbs" & set "_batpath=%temp:~%\%_FN:)=%.bat"

  :: Test if we gave admin rights
  fltmc >nul 2>&1 || goto :_getElevation

  :: Elevation successful
  (if exist %_vbspath% ( del %_vbspath% )) & (if exist %_batpath% ( del %_batpath% )) 
  :: Set ERRORLEVEL 0, set original folder and exit
  endlocal & CD /D "%~dp1" & ver >nul & goto:eof

  :_getElevation
  echo/Requesting elevation...
  :: Try to create %_vbspath% file. If failed, exit with ERRORLEVEL 1
  echo/Set UAC = CreateObject^("Shell.Application"^) > %_vbspath% || (echo/&echo/Unable to create %_vbspath% & endlocal &md; 2>nul &goto:eof) 
  echo/UAC.ShellExecute "%_batpath%", "", "", "runas", 1 >> %_vbspath% & echo/wscript.Quit(1)>> %_vbspath%
  :: Try to create %_batpath% file. If failed, exit with ERRORLEVEL 1
  echo/@%* > "%_batpath%" || (echo/&echo/Unable to create %_batpath% & endlocal &md; 2>nul &goto:eof)
  echo/@if %%errorlevel%%==9009 (echo/^&echo/Admin user could not read the batch file. If running from a mapped drive or UNC path, check if Admin user can read it.)^&echo/^& @if %%errorlevel%% NEQ 0 pause >> "%_batpath%"

  :: Run %_vbspath%, that calls %_batpath%, that calls the original file
  %_vbspath% && (echo/&echo/Failed to run VBscript %_vbspath% &endlocal &md; 2>nul & goto:eof)

  :: Vbscript has been run, exit with ERRORLEVEL -1
  echo/&echo/Elevation was requested on a new CMD window &endlocal &fc;: 2>nul & goto:eof
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::