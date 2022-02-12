@echo off
setlocal enableextensions enabledelayedexpansion
pushd "%~dp0"
set _selfbat=%~f0
set _logfile=C:\WIN7PATCH.LOG
title !_selfbat!
if "%1"=="" call :splash
if "%1"=="finish" call :finish

color 5f
set _cpuarch=%1
set _skipnum=%2
if "!_skipnum!"=="" (
  timeout /t 10
  call :logmsg arch is !_cpuarch!
  set _skipnum=0
) else (
  timeout /t 90
  call :logmsg continue after reboot
)
echo.
echo ============================================================================
echo.
set _linenum=0
for /f "eol=; delims=" %%i in (script.txt) do (
  for /f "tokens=1 delims=;" %%j in ("%%i") do (
    set /a _linenum=!_linenum!+1
    if !_linenum! gtr !_skipnum! (
      set _linecmd=%%j
      call :execute
    )
  )
)
exit

:execute
if "!_linecmd:~-1!"==" " (
  set _linecmd=!_linecmd:~0,-1!
  goto execute
)
if "!_linecmd:~0,1!"==" " (
  set _linecmd=!_linecmd:~1!
  goto execute
)
if "!_cpuarch!"=="x86" (
  if "!_linecmd:~0,4!"=="x64 " exit /b
  if "!_linecmd:~0,4!"=="x86 " set _linecmd=!_linecmd:~4!
)
if "!_cpuarch!"=="x64" (
  if "!_linecmd:~0,4!"=="x86 " exit /b
  if "!_linecmd:~0,4!"=="x64 " set _linecmd=!_linecmd:~4!
)
if "!_linecmd!"=="reboot" (
  call :reboot !_cpuarch! !_linenum!
)
if "!_linecmd!"=="finish" (
  call :reboot finish
)
if "!_linecmd:~0,4!"=="echo" (
  !_linecmd!
  exit /b
)
if "!_linecmd:~0,2!"=="kb" (
  for /f "tokens=1" %%i in ("!_linecmd!") do (
    for %%j in (*%%i-*!_cpuarch!*) do (
      echo %%j
      if /i "%%~xj"==".exe" (
        call :seterr -1
        start /wait %%j !_linecmd:* =!
        call :logmsg package '%%j !_linecmd:* =!' returned !errorlevel!
      ) else (
        call :seterr -1
        start /wait wusa %%j /quiet /norestart
        call :logmsg package '%%j' returned !errorlevel!
      )
    )
    echo.
  )
  exit /b
)
if "!_linecmd:~0,4!"=="run " (
  set _linecmd=!_linecmd:~4!
  for /f "tokens=1" %%i in ("!_linecmd!") do echo %%i
  call :seterr -1
  start /wait !_linecmd!
  call :logmsg run '!_linecmd!' returned !errorlevel!
  echo.
  exit /b
)
if "!_linecmd:~0,6!"=="quiet " (
  set _linecmd=!_linecmd:~6!
  call :seterr -1
  !_linecmd! > NUL 2> NUL
) else (
  call :seterr -1
  !_linecmd!
  echo.
)
call :logmsg command '!_linecmd!' returned !errorlevel!
exit /b

:seterr
exit /b %1

:logmsg
rem XXX: below is locale dependent
set _datestr=!date:~0,10! !time: =0!
set _datestr=[!_datestr:~0,19!]
(echo !_datestr! %*) >> !_logfile!
exit /b

:reboot
echo ============================================================================
schtasks /create /sc ONLOGON /rl HIGHEST /tn WIN7PATCH /tr "'!_selfbat!' %*" /it /f > NUL
timeout /t 90
shutdown /r /f /t 0
exit

:splash
color 3f
echo.
echo ============================================================================
echo.
echo     WIN7PATCH by ZBY (2022.02)
echo.
echo ============================================================================
echo.
if /i "%PROCESSOR_ARCHITECTURE%"=="x86" (
  powershell -command start -verb runas '!_selfbat!' x86
) else (
  powershell -command start -verb runas '!_selfbat!' x64
)
exit

:finish
color 2f
schtasks /delete /tn WIN7PATCH /f > NUL
call :logmsg finished
echo.
echo ============================================================================
echo.
echo     WIN7PATCH FINISHED
echo.
echo ============================================================================
echo.
start /wait notepad !_logfile!
del /p !_logfile!
exit
