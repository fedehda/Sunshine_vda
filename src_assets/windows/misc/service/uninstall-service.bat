@echo off
setlocal enabledelayedexpansion

set "SERVICE_CONFIG_DIR=%LOCALAPPDATA%\SunshineVDA"
set "SERVICE_CONFIG_FILE=%SERVICE_CONFIG_DIR%\service_start_type.txt"

rem Save the current service start type to a file if the service exists
set TARGET_SVC=SunshineVDAService
sc qc %TARGET_SVC% >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    set TARGET_SVC=ApolloService
    sc qc %TARGET_SVC% >nul 2>&1
)

if %ERRORLEVEL%==0 (
    if not exist "%SERVICE_CONFIG_DIR%\" mkdir "%SERVICE_CONFIG_DIR%\"

    rem Get the start type
    for /f "tokens=3" %%i in ('sc qc %TARGET_SVC% ^| findstr /C:"START_TYPE"') do (
        set "CURRENT_START_TYPE=%%i"
    )

    rem Set the content to write
    if "!CURRENT_START_TYPE!"=="2" (
        sc qc %TARGET_SVC% | findstr /C:"(DELAYED)" >nul
        if !ERRORLEVEL!==0 (
            set "CONTENT=2-delayed"
        ) else (
            set "CONTENT=2"
        )
    ) else if "!CURRENT_START_TYPE!" NEQ "" (
        set "CONTENT=!CURRENT_START_TYPE!"
    ) else (
        set "CONTENT=unknown"
    )

    rem Write content to file
    echo !CONTENT!> "%SERVICE_CONFIG_FILE%"
)

rem Stop and delete legacy services
net stop sunshinesvc >nul 2>&1
sc delete sunshinesvc >nul 2>&1

rem Stop and delete ApolloService service
net stop ApolloService >nul 2>&1
sc delete ApolloService >nul 2>&1

rem Stop and delete SunshineVDAService service
net stop SunshineVDAService >nul 2>&1
sc delete SunshineVDAService >nul 2>&1
