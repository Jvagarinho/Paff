@echo off
echo ============================================
echo CORRIGIR PROJETO WINDOWS - Sticky Notes
echo ============================================
echo.

REM Limpar cache do Flutter
echo A limpar cache...
call flutter clean

REM Remover pasta build
echo A remover pasta build...
if exist build rmdir /s /q build

REM Rember configuracoes windows
flutter config --enable-windows-desktop

REM Recriar projeto Windows do zero
echo.
echo A recriar projeto Windows...
call flutter create --platforms=windows --overwrite .

REM Instalar dependencias
echo.
echo A instalar dependencias...
call flutter pub get

echo.
echo ============================================
echo Concluido! Agora pode executar:
echo.
echo    flutter run -d windows
echo.
echo ============================================
pause