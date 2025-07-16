if (Get-ScheduledTask -TaskName ' Update') {
    Write-Host "Detected."
    exit 0
} else {
    Write-Host "Not Detected."    
    exit 1
}