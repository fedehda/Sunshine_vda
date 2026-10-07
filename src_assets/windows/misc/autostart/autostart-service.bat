@echo off

rem Set the service to auto-start
sc config SunshineVDAService start= auto >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    sc config ApolloService start= auto >nul 2>&1
)
