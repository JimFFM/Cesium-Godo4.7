param(
    [Parameter(Mandatory = $true)]
    [string]$SourceVcpkgDir,

    [Parameter(Mandatory = $true)]
    [string]$TargetVcpkgDir
)

if (-not (Test-Path $SourceVcpkgDir)) {
    throw "Pinned vcpkg checkout not found at expected path: $SourceVcpkgDir"
}

$targetRoot = Split-Path -Parent $TargetVcpkgDir
New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null

if (Test-Path $TargetVcpkgDir) {
    Remove-Item -Recurse -Force $TargetVcpkgDir
}

New-Item -ItemType Directory -Force -Path $TargetVcpkgDir | Out-Null

Get-ChildItem -LiteralPath $SourceVcpkgDir -Force | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $TargetVcpkgDir -Recurse -Force
}

if (-not (Test-Path (Join-Path $TargetVcpkgDir "ports/fmt/portfile.cmake"))) {
    throw "Failed to stage vcpkg tree at expected path: $TargetVcpkgDir"
}

& "$PSScriptRoot\disable-vcpkg-fixup-pkgconfig.ps1" -VcpkgDir $TargetVcpkgDir
