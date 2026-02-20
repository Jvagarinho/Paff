@echo off
echo ============================================
echo Criar Atalho - Sticky Notes App
echo ============================================
echo.

set "EXECUTAVEL=%~dp0build\windows\x64\runner\Release\sticky_notes_app.exe"
set "DESKTOP=%USERPROFILE%\Desktop"
set "NOME_ATALHO=Sticky Notes.lnk"

REM Verificar se o executável existe
if not exist "%EXECUTAVEL%" (
    echo ERRO: Executavel nao encontrado!
    echo Por favor execute build_release.bat primeiro.
    pause
    exit /b 1
)

REM Criar atalho na área de trabalho usando PowerShell
echo A criar atalho na area de trabalho...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP%\%NOME_ATALHO%'); $Shortcut.TargetPath = '%EXECUTAVEL%'; $Shortcut.WorkingDirectory = '%~dp0build\windows\x64\runner\Release'; $Shortcut.IconLocation = '%EXECUTAVEL%'; $Shortcut.Save()"

if %errorlevel% equ 0 (
    echo.
    echo ============================================
    echo ATALHO CRIADO COM SUCESSO!
    echo ============================================
    echo.
    echo O atalho foi criado na sua area de trabalho.
    echo Pode executar a aplicacao clicando duas vezes em:
    echo "Sticky Notes"
    echo.
    echo Ou executar diretamente:
    echo %EXECUTAVEL%
) else (
    echo.
    echo ERRO ao criar atalho!
    echo Pode criar manualmente apontando para:
    echo %EXECUTAVEL%
)

echo.
pause