@echo off
echo ============================================
echo Sticky Notes App - Build para Windows
echo ============================================
echo.

REM Verificar se o Flutter esta instalado
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ERRO: Flutter nao encontrado!
    echo Por favor instale o Flutter primeiro.
    pause
    exit /b 1
)

cd /d "%~dp0"

echo A compilar a aplicacao...
echo Isto pode demorar alguns minutos...
echo.

flutter build windows --release

if %errorlevel% equ 0 (
    echo.
    echo ============================================
    echo BUILD CONCLUIDO COM SUCESSO!
    echo ============================================
    echo.
    echo O executavel esta em:
    echo build\windows\x64\runner\Release\sticky_notes_app.exe
    echo.
    echo Pode copiar esta pasta para qualquer PC Windows
echo e executar diretamente sem precisar do Flutter!
    echo.
    
    REM Perguntar se deseja abrir a pasta
    set /p abrir="Deseja abrir a pasta do executavel? (S/N): "
    if /i "%abrir%"=="S" (
        start "" "build\windows\x64\runner\Release"
    )
) else (
    echo.
    echo ERRO na compilacao!
    echo Verifique se ha erros acima.
)

pause