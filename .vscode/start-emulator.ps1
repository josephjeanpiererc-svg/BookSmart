$emulatorPath = Join-Path $env:LOCALAPPDATA 'Android\Sdk\emulator\emulator.exe'

Start-Process -FilePath $emulatorPath -ArgumentList @(
  '-avd', 'Pixel_9_Pro',
  '-gpu', 'host',
  '-no-snapshot'
)

Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class WindowTools {
  [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr handle, int command);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr handle);
}
'@

for ($attempt = 0; $attempt -lt 60; $attempt++) {
  $window = Get-Process qemu-system-x86_64 -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowTitle -like '*Pixel_9_Pro*' -and $_.MainWindowHandle -ne 0 } |
    Select-Object -First 1

  if ($window) {
    [WindowTools]::ShowWindowAsync($window.MainWindowHandle, 3)
    [WindowTools]::SetForegroundWindow($window.MainWindowHandle)
    break
  }

  Start-Sleep -Milliseconds 500
}