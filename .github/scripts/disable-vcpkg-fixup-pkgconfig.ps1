param(
    [Parameter(Mandatory = $true)]
    [string]$VcpkgDir
)

$fmtPortfile = Join-Path $VcpkgDir "ports/fmt/portfile.cmake"

if (-not (Test-Path $fmtPortfile)) {
    throw "fmt portfile not found at expected path: $fmtPortfile"
}

Write-Host "Patching fmt portfile to skip vcpkg_fixup_pkgconfig(): $fmtPortfile"

$portfileContent = Get-Content -Path $fmtPortfile -Raw
$updatedContent = $portfileContent -replace '(?m)^(\s*)vcpkg_fixup_pkgconfig\(\)\s*$', '$1# Disabled in CI to avoid MSYS2 pkgconfig acquisition'

if ($updatedContent -eq $portfileContent) {
    throw "Failed to locate vcpkg_fixup_pkgconfig() in $fmtPortfile"
}

Set-Content -Path $fmtPortfile -Value $updatedContent -Encoding utf8

Write-Host "Successfully patched fmt portfile."
