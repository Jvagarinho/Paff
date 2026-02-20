@echo off
echo ============================================
echo Testar Nota Flutuante - Sticky Notes
echo ============================================
echo.

set "EXE_PATH=C:\Users\Comerciais\Desktop\Apps\Paff\build\windows\x64\runner\Release\sticky_notes_app.exe"
set "TEMP_FILE=%TEMP%\test_note.json"

REM Criar ficheiro de teste
echo {"noteId":"test123","title":"Nota de Teste","content":"Conteudo teste","color":4294967040} > "%TEMP_FILE%"

echo Ficheiro criado: %TEMP_FILE%
echo Conteudo:
type "%TEMP_FILE%"
echo.
echo A executar: %EXE_PATH% --note-file=%TEMP_FILE%
echo.

REM Executar
"%EXE_PATH%" --note-file=%TEMP_FILE%

echo.
echo ============================================
echo Verifique se abriu uma janela flutuante!
echo ============================================
pause