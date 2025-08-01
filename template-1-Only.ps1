$scriptBlock = {
    
    # GitHub API URL for the app manifest.
    $apiUrl = "https://api.github.com/repos/microsoft/winget-pkgs/contents/manifests/v/VideoLAN/VLC"

    # Fetch version folders then filter only version folders.
    $versions = Invoke-RestMethod -Uri $apiUrl -Headers @{ 'User-Agent' = 'PowerShell' }
    $versionFolders = $versions | Where-Object { $_.type -eq "dir" }

    # Extract and sort version numbers to get the latest version.
    $sortedVersions = $versionFolders | ForEach-Object { $_.name } | Sort-Object {[version]$_} -Descending -ErrorAction SilentlyContinue
    $latestVersion = $sortedVersions[0]

    # Get contents of the latest version folder to find the .installer.yaml file.
    $latestApiUrl = "$apiUrl/$latestVersion"
    $latestFiles = Invoke-RestMethod -Uri $latestApiUrl -Headers @{ 'User-Agent' = 'PowerShell' }
    $installerFile = $latestFiles | Where-Object { $_.name -like "*.installer.yaml" }

    # Download and parse YAML content to get the Url of the latest installer file.
    $yamlUrl = $installerFile.download_url
    $yamlContent = Invoke-RestMethod -Uri $yamlUrl -Headers @{ 'User-Agent' = 'PowerShell' }
    $null = ($yamlContent -join "`n") -match "InstallerUrl:\s+(http.*)"
    $installerUrl = $Matches[1]


    # Check the installed version number of the app and store it to the $installedVersion variable.
    $regPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($regPath in $regPaths) {
        $apps = Get-ChildItem $regPath -ErrorAction SilentlyContinue
        foreach ($app in $apps) {
            $props = Get-ItemProperty $app.PSPath
            if ($props.DisplayName -like "*vlc*") {
                $installedVersion = $($props.DisplayVersion)
            }
        }
    }

    # Download the latest installer then starting install or update the app if:
    # - The installed version is older than the latest version.
    # - The app is not installed ( $installedVersion = $null ).

    if ($installedVersion -lt $latestVersion) {
        $webClient = [System.Net.WebClient]::new()
        $webClient.DownloadFile($installerUrl, "$env:TEMP\vlc-latest.exe")

        # If the app is running, stop it before processing the update.
        $process = Get-Process -ProcessName 'vlc' -ErrorAction SilentlyContinue
        if ($process) {
            $process | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }

        # Start the install or update process.
        Start-Process -FilePath "$env:TEMP\vlc-latest.exe" -ArgumentList '/S' -Wait

        # Cleanup.
        Remove-Item -Path "$env:TEMP\vlc-latest.exe" -Force -ErrorAction SilentlyContinue
    }
    
}

# Create the C:\IntuneScripts folder if it not exist.
if (-Not (Test-Path -Path 'C:\IntuneScripts')) {
    New-Item -Path 'C:\IntuneScripts' -ItemType Directory
}

# Create a PowerShell from the $scriptBlock in the C:\IntuneScripts folder.
$scriptBlock.ToString() | Out-File -FilePath 'C:\IntuneScripts\vlc-update.ps1' -Encoding UTF8 -Force

# Create a schedule task. The task will execute the PowerShell script "C:\IntuneScripts\vlc-update.ps1" every day at 12AM.
$trigger = New-ScheduledTaskTrigger -Daily -At 12AM -RandomDelay (New-TimeSpan -Minutes 10)
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy ByPass -WindowStyle Hidden -File "C:\IntuneScripts\vlc-update.ps1"'
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -RestartCount 3
$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$splat = @{
    TaskName = 'VLC Update'
    Trigger = $trigger
    Action = $action
    Settings = $settings
    Principal = $principal
    TaskPath = '\IntuneTasks\'
}
Register-ScheduledTask @splat
