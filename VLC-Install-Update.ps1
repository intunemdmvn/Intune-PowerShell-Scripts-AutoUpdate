
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
$installerUrl = ($yamlContent -join "`n") -match "InstallerUrl:\s+(http.*)" | ForEach-Object { $Matches[1] }

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

# Download the latest installer then starting update process if:
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

    # Start update process.
    Start-Process -FilePath "$env:TEMP\vlc-latest.exe" -ArgumentList '/S' -Wait

    # Cleanup.
    Remove-Item -Path "$env:TEMP\vlc-latest.exe" -Force -ErrorAction SilentlyContinue
}