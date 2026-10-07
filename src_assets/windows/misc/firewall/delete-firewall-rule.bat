@echo off

rem Delete the rules
netsh advfirewall firewall delete rule name="Sunshine + VDA fork" >nul 2>&1
netsh advfirewall firewall delete rule name=Apollo >nul 2>&1
