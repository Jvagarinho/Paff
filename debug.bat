@echo off
echo ============================================
echo Sticky Notes - Modo Debug
echo ============================================
echo.
echo A executar em modo debug para ver logs...
echo.

cd /d "%~dp0"

REM Executar e mostrar logs
flutter run -d windows --verbose 2>&1 | findstr "Ficheiro Executável Argumentos Erro"

echo.
echo ============================================
pause