# -------- Imports --------
$signature = @"
using System;
using System.Runtime.InteropServices;

public static class Win32
{
  public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
  public const uint MOUSEEVENTF_LEFTUP   = 0x0004;
  public const int VK_RETURN = 0x0D;
  public const int VK_Z = 0x5A;
  public const int VK_K = 0x4B;
  public const uint KEYEVENTF_KEYDOWN = 0x0000;
  public const uint KEYEVENTF_KEYUP = 0x0002;

  [StructLayout(LayoutKind.Sequential)]
  public struct RECT
  {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
  }

  [DllImport("user32.dll")]
  [return: MarshalAs(UnmanagedType.Bool)]
  public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

  [DllImport("user32.dll")]
  public static extern bool SetForegroundWindow(IntPtr hWnd);

  [DllImport("user32.dll")]
  public static extern bool SetCursorPos(int X, int Y);

  [DllImport("user32.dll")]
  public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, UIntPtr dwExtraInfo);

  [DllImport("user32.dll")]
  [return: MarshalAs(UnmanagedType.Bool)]
  public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);

  [DllImport("user32.dll")]
  public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

  [DllImport("user32.dll")]
  public static extern uint MapVirtualKey(uint uCode, uint uMapType);
}
"@

Add-Type -TypeDefinition $signature
Add-Type -AssemblyName System.Windows.Forms

# -------- Utilities --------

function Get-Process-Handle
{
  param
  (
    [string]$Name
  )
  $proc = Get-Process | Where-Object { $_.ProcessName -like "*$Name*" } | Select-Object -First 1
  if ($proc -eq $null)
  {
    Write-Error "Launch: No process found with name containing '$Name'."
    return $null
  }

  $handle = $proc.MainWindowHandle
  if ($handle -eq 0)
  {
    Write-Error "Launch: Process found, but window handle is 0."
    return $null
  }

  $rect = New-Object Win32+RECT
  $success = [Win32]::GetWindowRect($handle, [ref] $rect)
  if (-not $success)
  {
    Write-Error "Launch: Failed to get window rectangle via GetWindowRect."
    return $null
  }

  return $handle
}

function Get-Window-Rect
{
  param
  (
    [IntPtr]$Handle
  )
  $rect = New-Object Win32+RECT
  $success = [Win32]::GetWindowRect($Handle, [ref] $rect)
  if (-not $success)
  {
    Write-Error "Launch: Failed to get window rectangle via GetWindowRect."
    return $null
  }

  return $rect
}

function Minimize-Window
{
  param
  (
    [IntPtr]$Handle
  )
  [Win32]::ShowWindowAsync($Handle, 6) | Out-Null
  Start-Sleep -Milliseconds 25
}

function Restere-Window
{
  param
  (
    [IntPtr]$Handle
  )
  [Win32]::ShowWindowAsync($Handle, 9) | Out-Null
  Start-Sleep -Milliseconds 25
}

function Focus-Window
{
  param
  (
    [IntPtr] $Handle
  )
  [Win32]::SetForegroundWindow($Handle) | Out-Null
}

function Click-In-Window
{
  param
  (
    [IntPtr] $Handle,
    [Win32+RECT] $Rect,
    [int] $X, # relative to left
    [int] $Y # relative to bottom
  )
  Focus-Window -Handle $Handle

  # Move cursor
  $absX = $Rect.Left + $X
  $windowHeight = $Rect.Bottom - $Rect.Top
  $absY = $Rect.Top + ($windowHeight - $Y)

  [Win32]::SetCursorPos($absX, $absY) | Out-Null
  Start-Sleep -Milliseconds 25

  # Simulate mouse click
  [Win32]::mouse_event([Win32]::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, [UIntPtr]::Zero)
  Start-Sleep -Milliseconds 25
  [Win32]::mouse_event([Win32]::MOUSEEVENTF_LEFTUP, 0, 0, 0, [UIntPtr]::Zero)
  Start-Sleep -Milliseconds 25
}

function Send-Key
{
  param
  (
    [IntPtr]$Handle,
    [int]$Key,
    [int]$Delay = 200
  )
  Start-Sleep -Milliseconds $Delay
  $scanCode = [Win32]::MapVirtualKey($Key, 0)
  [Win32]::keybd_event($Key, $scanCode, [Win32]::KEYEVENTF_KEYDOWN, [UIntPtr]::Zero)
  Start-Sleep -Milliseconds 25
  [Win32]::keybd_event($Key, $scanCode, [Win32]::KEYEVENTF_KEYUP, [UIntPtr]::Zero)
  Start-Sleep -Milliseconds 25
}

# -------- Logic --------

$handle = Get-Process-Handle -Name "modlunky2"
if ($handle -eq $null)
{
  Exit
}
Restere-Window -Handle $handle
$rect = Get-Window-Rect -Handle $handle
Click-In-Window -Handle $handle -Rect $rect -X 110 -Y 180
Minimize-Window -Handle $handle

Start-Sleep -Milliseconds 1000
$handle = Get-Process-Handle -Name "Spel2"
if ($handle -eq $null)
{
  Exit
}

Start-Sleep -Milliseconds 3500
Focus-Window -Handle $handle

# skip logos
Send-Key -HANDLE $handle -Key ([Win32]::VK_RETURN) # Mossmouth
Send-Key -HANDLE $handle -Key ([Win32]::VK_RETURN) # Blitworks
Send-Key -HANDLE $handle -Key ([Win32]::VK_RETURN) # Fmod
Send-Key -HANDLE $handle -Key ([Win32]::VK_RETURN) # Cinematic

# navigate to co-op
Send-Key -HANDLE $handle -Key ([Win32]::VK_RETURN) -Delay 1000 # Intro
Send-Key -HANDLE $handle -Key ([Win32]::VK_RETURN) -Delay 500 # Animation
Send-Key -HANDLE $handle -Key ([Win32]::VK_RETURN) -Delay 500 # Play
Send-Key -HANDLE $handle -Key ([Win32]::VK_RETURN) -Delay 500 # Adventure

# select players
Send-Key -HANDLE $handle -Key ([Win32]::VK_Z) -Delay 2000 # Player 1 select
Send-Key -HANDLE $handle -Key ([Win32]::VK_K) # Player 2 select
Send-Key -HANDLE $handle -Key ([Win32]::VK_Z) -Delay 300 # Player 1 confirm
Send-Key -HANDLE $handle -Key ([Win32]::VK_K) # Player 2 confirm
Send-Key -HANDLE $handle -Key ([Win32]::VK_RETURN) -Delay 500 # Start
Send-Key -HANDLE $handle -Key ([Win32]::VK_RETURN) # Animation