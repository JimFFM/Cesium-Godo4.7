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

if ($portfileContent.Contains("# Disabled in CI to avoid MSYS2 pkgconfig acquisition") -and -not $portfileContent.Contains("vcpkg_fixup_pkgconfig()")) {
    Write-Host "fmt portfile already patched."
    return
}

$updatedContent = [System.Text.RegularExpressions.Regex]::Replace(
    $portfileContent,
    '(?m)^(\s*)vcpkg_fixup_pkgconfig\(\)(\r?\n?)',
    '$1# Disabled in CI to avoid MSYS2 pkgconfig acquisition$2',
    1
)

if ($updatedContent -eq $portfileContent) {
    throw "Failed to locate vcpkg_fixup_pkgconfig() in $fmtPortfile"
}

[System.IO.File]::WriteAllText($fmtPortfile, $updatedContent, $encoding)

Write-Host "Successfully patched fmt portfile."
