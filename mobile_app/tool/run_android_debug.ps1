param(
    [string]$DeviceId = "R8YYA0WNSGK"
)

$adbPath = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'

if (-not (Test-Path -LiteralPath $adbPath)) {
    throw "Android Debug Bridge was not found at $adbPath. Install the Android SDK platform tools first."
}

# Maps the phone's localhost:8080 to the backend running on this computer.
# This avoids relying on a changing Wi-Fi IP address.
& $adbPath -s $DeviceId reverse tcp:8080 tcp:8080
if ($LASTEXITCODE -ne 0) {
    throw "Could not create the USB backend tunnel. Confirm that $DeviceId is connected with USB debugging enabled."
}

flutter run -d $DeviceId --dart-define=API_BASE_URL=http://127.0.0.1:8080/api
