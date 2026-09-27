param(
    [Parameter(Mandatory = $true)]
    [string]$VcpkgDir
)

$pkgConfigScript = Join-Path $VcpkgDir "scripts/cmake/vcpkg_fixup_pkgconfig.cmake"

if (-not (Test-Path $pkgConfigScript)) {
    throw "vcpkg_fixup_pkgconfig.cmake not found at expected path: $pkgConfigScript"
}

Write-Host "Globally bypassing vcpkg_fixup_pkgconfig in $pkgConfigScript..."

$overrideFunction = @'
function(vcpkg_fixup_pkgconfig)
endfunction()
'@

Set-Content -Path $pkgConfigScript -Value $overrideFunction -Encoding utf8

Write-Host "Successfully disabled pkgconfig fixup globally!"
