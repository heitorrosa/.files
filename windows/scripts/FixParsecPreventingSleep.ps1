Add-Type -TypeDefinition '
using System;
using System.Runtime.InteropServices;

namespace Utilities
{
    public static class Display
    {
        [StructLayout(LayoutKind.Sequential)]
        private struct LASTINPUTINFO
        {
            public uint cbSize;
            public uint dwTime;
        }

        [DllImport("user32.dll")]
        private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

        public static uint GetIdleTime()
        {
            LASTINPUTINFO lastInput = new LASTINPUTINFO();
            lastInput.cbSize = (uint)Marshal.SizeOf(lastInput);
            GetLastInputInfo(ref lastInput);
            return (uint)Environment.TickCount - lastInput.dwTime;
        }

        public static void PowerOff()
        {
            SendMessage(
                (IntPtr)0xffff, // HWND_BROADCAST
                0x0112,         // WM_SYSCOMMAND
                (IntPtr)0xf170, // SC_MONITORPOWER
                (IntPtr)0x0002  // POWER_OFF
            );
        }
    }
}
'

powercfg /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 0
powercfg /setactive SCHEME_CURRENT

# Check for idle time every 5 seconds
$idleThreshold = 120000  # 2 minutes in milliseconds

while ($true) {
    $idleTime = [Utilities.Display]::GetIdleTime()
    if ($idleTime -ge $idleThreshold) {
        [Utilities.Display]::PowerOff()
        break
    }
    Start-Sleep -Seconds 5
}