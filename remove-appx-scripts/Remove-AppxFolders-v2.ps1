# ==== Require admin privileges ====
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {

    Write-Host "This script must be run as Administrator. Relaunching with elevated privileges..."

    $scriptPath = $MyInvocation.MyCommand.Definition
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    return
}

try {
	$rootPath = "C:\Program Files\WindowsApps"
	
	# Define the keyword to search for in folder names
	$keyword = "SAMSUNGELECTRONICSCO.LTD.SamsungCloudPlatformManag"

	# Get all matching directories in the root path
	$folders = Get-ChildItem -Path $rootPath -Directory -Force |
		Where-Object { $_.Name -like "*$keyword*" }

	foreach ($folder in $folders) {
		Write-Host "----------------------------------------------------------"
		$folderPath = "$rootPath\${folder}"
		Write-Host "Target folder to delete: $folderPath"

		if (-Not (Test-Path $folderPath)) {
			Write-Host "Folder not found: $folderPath"
			continue
		}

		# ==== Take ownership ====
		Write-Host "Taking ownership..."
		takeown /F "$folderPath" /A /R /D Y | Out-Null

		# ==== Grant full access ====
		Write-Host "Granting full access to Administrators..."
		icacls "$folderPath" /grant Administrators:F /T | Out-Null

		# ==== Delete folder ====
		Write-Host "Deleting folder..."
		Remove-Item "$folderPath" -Recurse -Force -ErrorAction Stop
		Write-Host "Folder deleted successfully."
	}
} catch {
    Write-Host "An error occurred:"
    Write-Host $_.Exception.Message
} finally {
    Write-Host "`nPress any key to exit..."
    [void][System.Console]::ReadKey($true)
}
