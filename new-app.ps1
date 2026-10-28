<#
.SYNOPSIS
  Starts a new Android app on the kit: android\ in a repo, with the kit as
  its android\kit submodule.

.DESCRIPTION
  Copies template\ into <Repo>\android, filling in the name, package and log
  tag, and - when <Repo> is a git repo - adds this kit as the submodule
  android\kit. The result builds as it is: one activity that shows the
  app's name and logs "started".

  Run it from any checkout of the kit; the submodule is added from -KitUrl,
  not from this folder.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File new-app.ps1 -Repo ..\Tides -Name Tides -AppId works.tides
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Repo,
    # Shown under the launcher icon.
    [Parameter(Mandatory)][string]$Name,
    # Package and applicationId, e.g. works.tides.
    [Parameter(Mandatory)][ValidatePattern('^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$')][string]$AppId,
    # The logcat tag the app logs under and deploy.cmd follows.
    [string]$LogTag = (($Name -replace '[^A-Za-z0-9]', '') -replace '^$', 'App'),
    [string]$KitUrl = 'https://github.com/Volv-G/android-kit.git'
)

$ErrorActionPreference = 'Stop'

New-Item -ItemType Directory -Force -Path $Repo | Out-Null
$Repo = (Resolve-Path $Repo).Path
$android = Join-Path $Repo 'android'
if ((Test-Path $android) -and (Get-ChildItem $android -Force | Select-Object -First 1)) {
    throw "$android already exists and is not empty"
}

$fill = @{
    '__APP_NAME__' = $Name
    '__APP_ID__'   = $AppId
    '__PROJECT__'  = ($Name.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
    '__LOG_TAG__'  = $LogTag
}

$template = Join-Path $PSScriptRoot 'template'
Get-ChildItem $template -Recurse -File -Force | ForEach-Object {
    $rel = $_.FullName.Substring($template.Length + 1)
    # The activity goes in its package's folder.
    if ($rel -eq 'app\src\main\java\MainActivity.kt') {
        $rel = "app\src\main\java\$($AppId.Replace('.', '\'))\MainActivity.kt"
    }
    $dest = Join-Path $android $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
    # ReadAllText/WriteAllText keep each file's line endings - the .cmd
    # files need their CRLF - and write UTF-8 without a BOM.
    $text = [IO.File]::ReadAllText($_.FullName)
    foreach ($k in $fill.Keys) { $text = $text.Replace($k, $fill[$k]) }
    [IO.File]::WriteAllText($dest, $text)
}
Write-Host "  wrote $android"

$isRepo = $false
Push-Location $Repo
try {
    # Through cmd.exe: with ErrorActionPreference Stop, Windows PowerShell
    # turns git's "fatal: not a git repository" on stderr into a
    # terminating error, and that answer is the expected one here.
    & cmd.exe /c "git rev-parse --is-inside-work-tree >nul 2>&1"
    $isRepo = $LASTEXITCODE -eq 0
    if ($isRepo) {
        & git submodule add $KitUrl android/kit
        if ($LASTEXITCODE -ne 0) { throw "git submodule add failed" }
        Write-Host "  added the kit as android\kit"
    }
} finally { Pop-Location }

if (-not $isRepo) {
    Write-Host @"

  $Repo is not a git repo yet, so the kit is not in android\kit. Then:
    cd "$Repo"
    git init
    git submodule add $KitUrl android/kit
"@ -ForegroundColor Yellow
}

Write-Host @"

Next, from $Repo :
  powershell -NoProfile -ExecutionPolicy Bypass -File android\kit\bootstrap.ps1
  android\build.cmd
  android\deploy.cmd
"@ -ForegroundColor Green
