@ECHO OFF & Title Aktyvacijos atnaujinimo programa [slmgr /dlv]
::Source: http://www.daniel-mitchell.com/blog/reset-windows-7-rearm-count/
::Update to 360 days rearm https://www.gohacking.com/use-windows-7-without-activation/
::Busting Research on update to 360 days rearms http://www.thewindowsclub.com/legally-use-windows-without-activating
::2017.04.14 fixed notification bug which stopped rearms
::2017.04.14 Detected need for administration privilegies



ECHO                       [Tikrinama Windows licenzija] 
ECHO             ^(licenzijos atnaujinimu galima pasinaudoti tik 3 kartus^)
ECHO   Po licenzijos atnaujinimo, jusu operacine sistema vel bus aktyvuota 30 dienu.
 echo             ---------------------------------------------------
::Storing commands' (Where slmgr) output into variable
FOR /F "tokens=* USEBACKQ" %%F IN (`Where slmgr`) DO (
SET "slmgrScriptLocation=%%F"
)


SETLOCAL EnableDelayedExpansion
FOR /F "tokens=* USEBACKQ" %%A IN (`cscript //Nologo %slmgrScriptLocation% /dli`) DO ( SET "line=%%A"
	call :splitOutput "!line!"

)


 echo             ---------------------------------------------------
 
 
 IF [%daysnum%]==[] set "daysnum=0"
 If %daysnum% GEQ 3 (
 echo               Kol kas licenzija vis dar aktyvi. (liko !daysnum! dienu^)
 echo               Aktyvacijos vis dar nebutina atnaujinti.
 echo.
 echo               ____________________________________________
 echo               [Paspauskite bet kuri mygtuka norint Iseiti]
 echo             -------------------------------------------------

	) else ( 
		slmgr /rearm
		ECHO Licenzijos aktyvacija buvo atnaujinta.
	)


pause >nul


:splitOutput
SET "string=%1"

::DEQUOTE
Set string=%string:"=%

::SplitOutput
set "var1=%string::=" & set "var2=%"


::http://stackoverflow.com/questions/7105433/windows-batch-echo-without-new-line
If "%var1%" == "Name" ( echo|set /p="|            Operacines sistema:%var2%" & echo.)
::If "%var1%" == "Partial Product Key" ( echo|set /p="_Dalinis produkto kodas: %var2%" & echo.)
::If "%var1%" == "License Status" ( echo |set /p="_Licenzijos busena: %var2%" & echo.)

If "%var1%" == "Time remaining" ( CALL :SeperateTimeAndDays & echo|set /p="            Liko laiko: licenzija galios dar !daysnum! dienu" & echo. 
	)






GOTO :EOF


:SeperateTimeAndDays

SETLOCAL EnableDelayedExpansion
	FOR /f "tokens=*" %%a IN ('^(echo ^| set /p "=%var2%"^)') do ( 
	set "sanitizedOutput=%%a"
	) 
	
ENDLOCAL & ( 
	set "sanitizedOutput=%sanitizedOutput%"
	)

	
	
::extracting minutes left
set "minutes=%sanitizedOutput:minute=" & set "days=%"

::parsing days/extracting number of days left
set "days=%sanitizedOutput:) (=" & set "days=%"
set "daysnum=%days: day=" & set "days=%"

GOTO :EOF



::slmgr /dlv
