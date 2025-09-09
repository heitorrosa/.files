# -----------------------------
# Global Hotkey Toggle Script (No Input Buffering)
# -----------------------------

# Configuration
$peerId = "peer_id="
$exePath = "C:\Program Files\Parsec\parsecd.exe"
$toggle = $false
$busy = $false

if (-not (Test-Path $exePath)) {
    Write-Host "Error: $exePath not found!"
    exit
}

Add-Type @"
using System;
using System.Runtime.InteropServices;

public class HotKey {
    public const int MOD_ALT = 0x1;
    public const int MOD_CONTROL = 0x2;
    public const int MOD_SHIFT = 0x4;
    public const int WM_HOTKEY = 0x0312;

    [DllImport("user32.dll")]
    public static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);

    [DllImport("user32.dll")]
    public static extern bool UnregisterHotKey(IntPtr hWnd, int id);

    [DllImport("user32.dll")]
    public static extern int GetMessage(out MSG lpMsg, IntPtr hWnd, uint wMsgFilterMin, uint wMsgFilterMax);

    [DllImport("user32.dll")]
    public static extern bool TranslateMessage(ref MSG lpMsg);

    [DllImport("user32.dll")]
    public static extern IntPtr DispatchMessage(ref MSG lpMsg);

    public struct MSG {
        public IntPtr hwnd;
        public uint message;
        public UIntPtr wParam;
        public IntPtr lParam;
        public uint time;
        public POINT pt;
    }

    public struct POINT { public int x; public int y; }
}
"@

# Register hotkey (Ctrl+Alt+Shift+P)
$hotkeyId = 1
[HotKey]::RegisterHotKey([IntPtr]::Zero, $hotkeyId, [HotKey]::MOD_CONTROL -bor [HotKey]::MOD_ALT -bor [HotKey]::MOD_SHIFT, [int][System.Windows.Forms.Keys]::P)

while ($true) {
    $msg = New-Object HotKey+MSG
    [HotKey]::GetMessage([ref]$msg, [IntPtr]::Zero, 0, 0) | Out-Null

    if ($msg.message -eq [HotKey]::WM_HOTKEY) {

        if ($busy) { continue }

        $busy = $true
        $toggle = -not $toggle

        if ($toggle) {
            & glazewm command focus --workspace parsec
            Start-Process $exePath -ArgumentList $peerId
            & usbipd bind -i 046d:c547 --force
        } else {
            & glazewm command focus --prev-active-workspace
            & usbipd unbind -i 046d:c547
        }

        $busy = $false
    }
}

[HotKey]::UnregisterHotKey([IntPtr]::Zero, $hotkeyId)
