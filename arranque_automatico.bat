@echo off
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

if "%opcao%"=="1" powershell -ExecutionPolicy Bypass -File "%~dp0arranque_automatico.ps1"
if "%opcao%"=="2" powershell -ExecutionPolicy Bypass -File "%~dp0arranque_automatico.ps1" -Remove
if "%opcao%"=="3" (
    powershell -Command "Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Paff. And it''s noted.' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'Paff. And it''s noted.''"
    if errorlevel 1 (
        echo.
        echo A app NAO está configurada para arrancar automaticamente.
    ) else (
        echo.
        echo A app ESTÁ configurada para arrancar automaticamente.
    )
    pause
)
if "%opcao%"=="0" exit
