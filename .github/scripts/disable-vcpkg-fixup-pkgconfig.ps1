param(
    [Parameter(Mandatory = $true)]
    [string]$VcpkgDir
)

$fmtPortfile = Join-Path $VcpkgDir "ports/fmt/portfile.cmake"

if (-not (Test-Path $fmtPortfile)) {
    throw "fmt portfile not found at expected path: $fmtPortfile"
}

Write-Host "Patching fmt portfile to skip vcpkg_fixup_pkgconfig(): $fmtPortfile"

$portfileBytes = [System.IO.File]::ReadAllBytes($fmtPortfile)
$hasUtf8Bom = $portfileBytes.Length -ge 3 -and $portfileBytes[0] -eq 0xEF -and $portfileBytes[1] -eq 0xBB -and $portfileBytes[2] -eq 0xBF
$encoding = [System.Text.UTF8Encoding]::new($hasUtf8Bom)
$portfileContent = $encoding.GetString($portfileBytes)
$updatedContent = $portfileContent -replace '(?m)^(\s*)vcpkg_fixup_pkgconfig\(\)\s*$', '$1# Disabled in CI to avoid MSYS2 pkgconfig acquisition'

if ($updatedContent -eq $portfileContent) {
    throw "Failed to locate vcpkg_fixup_pkgconfig() in $fmtPortfile"
}

[System.IO.File]::WriteAllText($fmtPortfile, $updatedContent, $encoding)

Write-Host "Successfully patched fmt portfile."
