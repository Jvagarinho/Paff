@echo off
echo ============================================
echo Sticky Notes App
echo ============================================
echo.
echo A iniciar a aplicacao...
echo.

REM Verificar se o Flutter esta instalado
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ERRO: Flutter nao encontrado!
    echo.
    echo Por favor instale o Flutter em:
    echo https://docs.flutter.dev/get-started/install
    echo.
    pause
    exit /b 1
)

REM Navegar para a pasta do projeto
cd /d "%~dp0"

REM Executar a aplicacao
flutter run -d windows --hot

pause