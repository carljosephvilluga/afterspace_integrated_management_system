# Launches the AIMS Flutter app on the Windows desktop target.
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$appDir = Join-Path $projectRoot 'aims'

if (-not (Test-Path -LiteralPath (Join-Path $appDir 'pubspec.yaml'))) {
  Write-Host 'Unable to find the Flutter app folder.' -ForegroundColor Red
  Read-Host 'Press Enter to close'
  exit 1
}

Set-Location -LiteralPath $appDir

Write-Host 'Starting AfterSpace Integrated Management System...' -ForegroundColor Cyan
Write-Host ''

flutter pub get
if ($LASTEXITCODE -ne 0) {
  Write-Host ''
  Write-Host 'Flutter package installation failed.' -ForegroundColor Red
  Read-Host 'Press Enter to close'
  exit $LASTEXITCODE
}

flutter run -d windows
if ($LASTEXITCODE -ne 0) {
  Write-Host ''
  Write-Host 'The app did not start successfully.' -ForegroundColor Red
  Read-Host 'Press Enter to close'
  exit $LASTEXITCODE
}
