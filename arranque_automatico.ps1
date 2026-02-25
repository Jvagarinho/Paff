param(
    [switch]$Remove
)

$appName = "Paff. And it`s noted."
$exePath = Join-Path $PSScriptRoot "build\windows\x64\runner\Release\sticky_notes_app.exe"

if (-not (Test-Path $exePath)) {
    Write-Host "Erro: Executável não encontrado em: $exePath" -ForegroundColor Red
    Write-Host "Certifique-se que fez build da aplicação." -ForegroundColor Yellow
    exit 1
}

$exePath = (Resolve-Path $exePath).Path

if ($Remove) {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    if (Get-ItemProperty -Path $regPath -Name $appName -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $regPath -Name $appName
        Write-Host "App removida do arranque automático!" -ForegroundColor Green
    } else {
        Write-Host "A app não está configurada para arrancar automaticamente." -ForegroundColor Yellow
    }
} else {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    Set-ItemProperty -Path $regPath -Name $appName -Value "`"$exePath`""
    Write-Host "App adicionada ao arranque automático!" -ForegroundColor Green
    Write-Host "A app irá iniciar automaticamente com o Windows." -ForegroundColor Cyan
}
