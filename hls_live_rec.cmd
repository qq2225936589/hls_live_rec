@echo off
setlocal enabledelayedexpansion
set url="%~1"
set name=%~2
set m3u8=_index.m3u8

call :getBaseURL %url%
echo %BaseURL%

set t=%time::=%
set t=%t: =0%
set dir=!name!_%date:-=%-%t:~0,6%
md !dir!
set m3u8=!dir!\!m3u8!
::=================================================================================================
echo Press Q to quit
type NUL>!m3u8!
set /a dc=0
set /a tsc=0
:loop
set line=
FOR /F "usebackq tokens=1,2,3* delims=" %%i IN (`curl -ks %url%`) DO (
  set line=%%i
  if "!dc!"=="0" (
    if "!line:~0,1!" NEQ "#" (
      if "!line:~-3!" NEQ ".ts" (
	    call :getFNts "!line!"
	    set line=!getFNts!
	  )
	)
    echo !line:/=_!>>!m3u8!
	echo !line!
  )
  if "!line:~0,7!"=="#EXTINF" (
	if "!dc!"=="1" set EXTINF=!line!
  )
  if "!line:~0,1!" NEQ "#" (
    if "!line:~-3!" NEQ ".ts" (
	  call :getFNts "!line!"
	  set line=!getFNts!
	)
	set outfn=!dir!\!line:/=_!
	IF NOT EXIST "!outfn!" (
      set tsurl=!BaseURL!!line!
	  if "!dc!"=="1" (
	    echo !EXTINF!
	    echo !line!
	    echo !EXTINF!>>!m3u8!
	    echo !line:/=_!>>!m3u8!
	  )
	  type NUL>"!outfn!"
	  set /a tsc=!tsc!+1
	  set t=!time::=!
      set t=!t: =0!
	  title !tsc! !dir! !t:~0,6!
	  start /b curl -ks "!tsurl!" -o "!outfn!"
	)
  )
  if "!line!"=="#EXT-X-ENDLIST" (
    if "!dc!"=="1" echo !line!>>!m3u8!
    goto end
  )
)

IF NOT DEFINED line (
  if "!dc!"=="1" echo #EXT-X-ENDLIST>>!m3u8!
  goto end
)
::timeout 1 1>nul 2>nul
choice.exe /c qc /n /t 1 /d c /m "Press Q to quit" 1>nul 2>nul
if %errorlevel%==1 (
  if "!dc!"=="1" echo #EXT-X-ENDLIST>>!m3u8!
  goto end
)

set /a dc=1
goto loop
:end
exit /b
::=================================================================================================
:getBaseURL
set DP=%cd%\
set BaseURL=%~dp1
set BaseURL=!BaseURL:%DP%=!
set BaseURL=!BaseURL:\=/!
set BaseURL=!BaseURL::/=://!
exit /b
::=================================================================================================
:getFNts
FOR /F "usebackq delims=" %%i IN (`echo "%~n1"^|grep -Eo "(.*)\.ts"`) DO (
  set getFNts=%%i
)
set getFNts=!getFNts:"=!
exit /b
