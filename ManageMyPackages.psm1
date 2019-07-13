###
# Author: shskwmt
###

Set-Variable -Name WindowsPackageListFile -Value "WindowsPackageList.txt" -Option Constant

Function Install-PackageProviders {
  <#
  .SYNOPSIS
    Install package providers
  #>
  Param (
    [Parameter(Position=0)][String[]]$ProviderList = @(
      'NuGet',
      'ChocolateyGet',
      'PowerShellGet',
      'Chocolatey'
    )
  )
  $ProviderList | Get-Unique | ForEach-Object {Install-PackageProvider -Force $_}
}

Function Install-MyPackages {
  <#
  .SYNOPSIS
    Install packages that are listed in gist.
  #>
  Param(
    [Parameter(Mandatory,Position=0)][String]$PackageListGistId,
    [Parameter(Position=1)][String]$FileName = $WindowsPackageListFile
  )
  [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11
  $gistUri = "https://api.github.com/gists/" + $PackageListGistId
  $packageList = (Invoke-WebRequest -Uri $gistUri | ConvertFrom-Json).files.$fileName.content -split "\n"
  $packageList | ForEach-Object {Install-Package -Force -Provider ChocolateyGet $_}
}

Function Out-PackageListFile {
  <#
  .SYNOPSIS
    Output package list file that you have already installed.
  #>
  Param(
    [Parameter(Position=0)][String]$PackageListPath = $WindowsPackageListFile,
    [Parameter(Position=1)][String]$Provider = "ChocolateyGet"
  )
  Get-Package -Provider $Provider | ForEach-Object {$_.Name} | Out-File $PackageListPath
}