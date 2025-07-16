if (Get-ScheduledTask -TaskName '7zip Update') {
    Write-Host "Detected."
    exit 0
} else {
    Write-Host "Not Detected."    
    exit 1
}