if (Get-ScheduledTask -TaskName 'WinRAR Update') {
    Write-Host "Detected."
    exit 0
} else {
    Write-Host "Not Detected."    
    exit 1
}