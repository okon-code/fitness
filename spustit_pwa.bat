@echo off
title Silovy Trenink PWA Server
cd /d "%~dp0\pwa"
echo ===================================================
echo   Spoustim server pro PWA Silovy Trenink...
echo ===================================================
echo.
echo Na svem iPhonu ve Firefoxu otevrete adresu:
echo   http://172.20.10.5:8080
echo   (nebo http://localhost:8080 na tomto PC)
echo.
echo Pro ukonceni stisknete Ctrl+C
echo ===================================================
echo.
python -m http.server 8080
pause
