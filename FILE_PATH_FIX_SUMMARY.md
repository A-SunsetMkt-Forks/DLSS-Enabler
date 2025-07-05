# DLSS-Enabler File Path Fix Summary

## Issue Identified
The installer script was trying to reference files in their original OptiScaler directory structure:
- `DlssOverrides\DisableSignatureOverride.reg`
- `DlssOverrides\EnableSignatureOverride.reg`
- `OptiScaler.dll`
- `OptiScaler.ini`
- `libxess.dll`
- `amd_fidelityfx_dx12.dll`
- `amd_fidelityfx_vk.dll`
- `Licenses\XeSS_LICENSE.txt`
- `Licenses\FidelityFX_LICENSE.md`
- `Licenses\DirectX_LICENSE.txt`

But the GitHub Actions workflow was copying these files to different locations in the existing directory structure.

## Fix Applied

### ✅ Updated Installer Script Paths
Changed the installer script to reference files where the workflow actually places them:

**Registry Files:**
- `DlssOverrides\DisableSignatureOverride.reg` → `DLLSG mod\DisableNvidiaSignatureChecks.reg`
- `DlssOverrides\EnableSignatureOverride.reg` → `DLLSG mod\RestoreNvidiaSignatureChecks.reg`

**OptiScaler Files:**
- `OptiScaler.dll` → `Dll version\dlss-enabler-upscaler.dll`
- `OptiScaler.ini` → `Dll version\OptiScaler.ini`
- `libxess.dll` → `Dll version\libxess.dll`
- `amd_fidelityfx_dx12.dll` → `Dll version\amd_fidelityfx_dx12.dll`
- `amd_fidelityfx_vk.dll` → `Dll version\amd_fidelityfx_vk.dll`

**License Files:**
- `Licenses\XeSS_LICENSE.txt` → `Dll version\XeSS_LICENSE.txt`
- `Licenses\FidelityFX_LICENSE.md` → `Dll version\FidelityFX_LICENSE.md`
- `Licenses\DirectX_LICENSE.txt` → `Dll version\DirectX_LICENSE.txt`

### ✅ Enhanced GitHub Actions Workflow
Added license file copying to the workflow:

```powershell
# Copy license files from OptiScaler
$xessLicenseFile = Get-ChildItem -Path $extractDir -Filter "XeSS_LICENSE.txt" -Recurse | Select-Object -First 1
if ($xessLicenseFile) {
    $targetXessPath = "Dll version\XeSS_LICENSE.txt"
    Copy-Item -Path $xessLicenseFile.FullName -Destination $targetXessPath -Force
    Write-Host "Copied XeSS_LICENSE.txt to: $targetXessPath"
}

$fidelityFxLicenseFile = Get-ChildItem -Path $extractDir -Filter "FidelityFX_LICENSE.md" -Recurse | Select-Object -First 1
if ($fidelityFxLicenseFile) {
    $targetFidelityFxPath = "Dll version\FidelityFX_LICENSE.md"
    Copy-Item -Path $fidelityFxLicenseFile.FullName -Destination $targetFidelityFxPath -Force
    Write-Host "Copied FidelityFX_LICENSE.md to: $targetFidelityFxPath"
}

$directXLicenseFile = Get-ChildItem -Path $extractDir -Filter "DirectX_LICENSE.txt" -Recurse | Select-Object -First 1
if ($directXLicenseFile) {
    $targetDirectXPath = "Dll version\DirectX_LICENSE.txt"
    Copy-Item -Path $directXLicenseFile.FullName -Destination $targetDirectXPath -Force
    Write-Host "Copied DirectX_LICENSE.txt to: $targetDirectXPath"
}
```

### ✅ Enhanced Verification
Updated the workflow verification to check all copied files including license files and registry files.

## Result

The installer script now correctly references files in the locations where the GitHub Actions workflow places them. This ensures:

1. **Build Success**: The Inno Setup compiler will find all required source files
2. **Dynamic Content**: Files are still sourced from the latest OptiScaler releases
3. **Complete Licensing**: All OptiScaler license files are included in the installer
4. **Consistent Structure**: Uses the existing DLSS-Enabler directory structure while incorporating new OptiScaler content

## Files Now Handled Correctly

### From OptiScaler (via workflow):
- ✅ **OptiScaler.dll** → `Dll version\dlss-enabler-upscaler.dll`
- ✅ **OptiScaler.ini** → `Dll version\OptiScaler.ini` 
- ✅ **libxess.dll** → `Dll version\libxess.dll`
- ✅ **AMD FSR DLLs** → `Dll version\amd_fidelityfx_*.dll`
- ✅ **Registry files** → `DLLSG mod\*SignatureChecks.reg`
- ✅ **License files** → `Dll version\*_LICENSE.*`

### Static DLSS-Enabler files:
- ✅ **Main mod DLL** → `Dll version\dlss-enabler.asi`
- ✅ **DLSSG mod** → `DLLSG mod\dlssg_to_fsr3_amd_is_better.dll`
- ✅ **NVIDIA Environment** → `NVIDIA Environment\*.dll`

The build should now complete successfully with all files in their expected locations.
