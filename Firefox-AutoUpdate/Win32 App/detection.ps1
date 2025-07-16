if (Get-ScheduledTask -TaskName 'Firefox Update') {
    Write-Host "Detected."
    exit 0
} else {
    Write-Host "Not Detected."    
    exit 1
}