@echo off
setlocal enabledelayedexpansion

echo ============================================
echo Paff. And it's noted. - Arranque Automatico
echo ============================================
echo.
echo Opcoes:
echo   1 - Adicionar ao arranque do Windows
echo   2 - Remover do arranque do Windows
echo   3 - Verificar estado atual
echo   0 - Sair
echo.
set /p opcao="Escolha uma opcao: "

if "%opcao%"=="1" (
    powershell -ExecutionPolicy Bypass -File "%~dp0arranque_automatico.ps1"
)
if "%opcao%"=="2" (
    powershell -ExecutionPolicy Bypass -File "%~dp0arranque_automatico.ps1" -Remove
)
if "%opcao%"=="3" (
    echo.
    powershell -Command "if (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Paff. And it''s noted.' -ErrorAction SilentlyContinue) { Write-Host 'A app ESTA configurada para arrancar automaticamente.' -ForegroundColor Green } else { Write-Host 'A app NAO esta configurada para arrancar automaticamente.' -ForegroundColor Yellow }"
    pause
)
if "%opcao%"=="0" exit
