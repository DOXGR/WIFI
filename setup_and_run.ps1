param (
    [switch]$force
)

$flutterPath = "C:\src\flutter\bin"
$wifRemotePath = "C:\Users\Redal\wifREMOTE"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "wifREMOTE Automated Setup Script" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Check if Git is installed
try {
    git --version | Out-Null
} catch {
    Write-Host "Git is not installed! Please install Git for Windows first: https://git-scm.com/download/win" -ForegroundColor Red
    exit
}

# 2. Check/Install Flutter
if (-Not (Test-Path $flutterPath)) {
    Write-Host "Flutter not found. Downloading the Flutter SDK (This might take a while, go grab a coffee!)..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path "C:\src" | Out-Null
    git clone https://github.com/flutter/flutter.git -b stable C:\src\flutter
} else {
    Write-Host "Flutter SDK found at C:\src\flutter!" -ForegroundColor Green
}

# 3. Add to PATH for this session
$env:Path += ";$flutterPath"

Write-Host "Initializing Flutter SDK (Downloading Dart, etc.)..." -ForegroundColor Yellow
flutter precache

Write-Host "Setting up the wifREMOTE project files..." -ForegroundColor Yellow
Set-Location -Path $wifRemotePath

# Run flutter create to generate Android/iOS folders
flutter create .

# 4. Inject Android Permissions
$manifestPath = "$wifRemotePath\android\app\src\main\AndroidManifest.xml"
if (Test-Path $manifestPath) {
    Write-Host "Adding required network permissions to AndroidManifest.xml..." -ForegroundColor Yellow
    $manifestContent = Get-Content $manifestPath -Raw
    
    $permissions = @"
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
"@

    if (-not $manifestContent.Contains("android.permission.ACCESS_WIFI_STATE")) {
        $manifestContent = $manifestContent -replace '<application', "$permissions`n    <application"
        Set-Content -Path $manifestPath -Value $manifestContent
        Write-Host "Permissions injected successfully." -ForegroundColor Green
    } else {
        Write-Host "Permissions already exist." -ForegroundColor Green
    }
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "You can now connect your Android device or start an emulator, and run:" -ForegroundColor Cyan
Write-Host "    flutter run" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan
