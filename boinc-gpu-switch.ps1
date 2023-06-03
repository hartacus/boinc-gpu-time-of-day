# Script to switch BOINC GPU processing on or off
# To be used via Task Scheduler
# Requires two scheduled tasks:
# - "BOINC GPU enable": runs `boinc-gpu-switch.ps1 enable` to start GPU computation, every half hour, starting as soon as possible if missed
# - "BOINC GPU disable": runs `boinc-gpu-switch.ps1 disable` to stop GPU computation, every half hour, starting as soon as possible if missed
# The enable action with stop the disable task if it's still running (waiting for a repeat), and vice versa

param (
    [string]$action
)

#$boinc_exe = "C:\Program Files\BOINC\boinccmd.exe"

# Find the BOINC binary location from the running boincmgr.exe process
if ($mgr = &get-process -name boincmgr) {
    $wd = $mgr.path | Split-Path
} else {
    Write-Output "BOINC is not running. Exiting..."
    Exit
}

$boinc_exe = $wd + "\boinccmd.exe"

if ($action -eq "") {
    Write-Output "Usage: boinc-gpu-switch.ps1 [enable|always|disable]"
    Exit
}

if ($action -eq "enable") {
    Write-Output "Enabling GPU computation"
    Stop-ScheduledTask -TaskName "BOINC GPU disable"  # to stop it getting disabled again in case of delayed start
    &$boinc_exe --set_gpu_mode auto
} elseif ($action -eq "always") {
    Write-Output "Enabling always-on GPU computation"
    Stop-ScheduledTask -TaskName "BOINC GPU disable"  # to stop it getting disabled again in case of delayed start
    &$boinc_exe --set_gpu_mode always
} elseif ($action -eq "disable") {
    Write-Output "Disabling GPU computation"
    Stop-ScheduledTask -TaskName "BOINC GPU disable"  # to stop it getting enabled again in case of delayed start
    &$boinc_exe --set_gpu_mode never
} else {
    Write-Output "Valid actions are `'enable`' or `'always`' or `'disable`'"
}