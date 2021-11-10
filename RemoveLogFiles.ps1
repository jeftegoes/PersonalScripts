<#
    This script search in all paths and remove all files with .log extension.
#>

$DateFormat = "dd/MM/yyyy - HH:mm:ss ->"
$Path = "D:\PowerShellPersonalScripts"

Write-Host (Get-Date -Format $DateFormat) "Cleaning .log files in the paths " $Path "..."

get-childitem $Path -recurse | Where-Object { $_.extension -eq ".log" } | % {
    $StartTime = (Get-Date -Format $DateFormat)
    Write-Host $StartTime $_.FullName
    Remove-Item -path $_.FullName
}

Write-Host (Get-Date -Format $DateFormat) "End of cleaning."