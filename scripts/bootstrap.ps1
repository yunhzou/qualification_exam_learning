[CmdletBinding()]
param(
    [string]$Python,
    [string]$TectonicVersion = "0.16.9"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

if (-not $Python) {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Python\Python312\python.exe"),
        "python3",
        "python"
    )
    foreach ($candidate in $candidates) {
        if ((Test-Path $candidate) -or (Get-Command $candidate -ErrorAction SilentlyContinue)) {
            $Python = $candidate
            break
        }
    }
}

if (-not $Python) {
    throw "Python 3.12 was not found. Install Python or pass -Python C:\path\to\python.exe."
}

$version = & $Python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"
if ($LASTEXITCODE -ne 0 -or [version]$version -lt [version]"3.12") {
    throw "Python 3.12 or newer is required; found $version."
}

$venv = Join-Path $root ".venv"
if (-not (Test-Path $venv)) {
    & $Python -m venv $venv
    if ($LASTEXITCODE -ne 0) { throw "Failed to create the Python virtual environment." }
}

$tectonicDir = Join-Path $root ".tools\tectonic"
$tectonic = Join-Path $tectonicDir "tectonic.exe"
if (-not (Test-Path $tectonic)) {
    New-Item -ItemType Directory -Force -Path $tectonicDir | Out-Null
    $archive = Join-Path $env:TEMP "tectonic-$TectonicVersion.zip"
    $tag = "tectonic@$TectonicVersion"
    $asset = "tectonic-$TectonicVersion-x86_64-pc-windows-msvc.zip"
    $url = "https://github.com/tectonic-typesetting/tectonic/releases/download/$tag/$asset"
    Write-Host "Downloading Tectonic $TectonicVersion..."
    $curl = Get-Command "curl.exe" -ErrorAction SilentlyContinue
    if ($curl) {
        & $curl.Source --fail --location --retry 3 --continue-at - --silent --show-error --output $archive $url
        if ($LASTEXITCODE -ne 0) { throw "Failed to download Tectonic from $url." }
    } else {
        Invoke-WebRequest -Uri $url -OutFile $archive
    }
    Expand-Archive -Path $archive -DestinationPath $tectonicDir -Force
    Remove-Item -LiteralPath $archive -Force
}

Write-Host "Python environment: $venv"
& $tectonic --version
if ($LASTEXITCODE -ne 0) { throw "Tectonic was installed but could not be executed." }
Write-Host "Setup complete. Run: .\.venv\Scripts\python.exe scripts\build.py all"
