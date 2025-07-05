# DLSS-Enabler Installer Restoration Summary

## Changes Made

### ✅ Restored Original Installer Logic
- **Removed backup/restore system** - Back to simple, straightforward installer behavior
- **Removed `[Code]` section** - No more complex Pascal scripts for backup management  
- **Removed `[UninstallDelete]` section** - Using standard Inno Setup uninstallation
- **Removed `[UninstallRun]` section** - Simplified cleanup

### ✅ Kept Dynamic Version Assignment
The GitHub Actions workflow still dynamically updates:
- **Version**: `#define MyAppVersion "3.00.000.0"` → `#define MyAppVersion "3.01.YYYYMMDD.HHMMSS"`
- **Output filename**: `OutputBaseFilename=dlss-enabler-setup-3.00.000.0a` → `OutputBaseFilename=dlss-enabler-setup_v0.7.7-pre12_20250630`
- **Icon removal**: `SetupIconFile=FSR3.ico` → `; SetupIconFile removed - no icon`

### ✅ Updated File Structure to Use OptiScaler Layout

#### OptiScaler Files (from extracted archive):
```
OptiScaler.dll                    → dlss-enabler-upscaler.dll
OptiScaler.ini                    → nvngx.ini 
libxess.dll                       → libxess.dll
amd_fidelityfx_dx12.dll          → amd_fidelityfx_dx12.dll
amd_fidelityfx_vk.dll            → amd_fidelityfx_vk.dll
DlssOverrides/DisableSignatureOverride.reg → DisableNvidiaSignatureChecks.reg
DlssOverrides/EnableSignatureOverride.reg  → RestoreNvidiaSignatureChecks.reg
Licenses/XeSS_LICENSE.txt        → XESS LICENSE.txt
Licenses/FidelityFX_LICENSE.md   → FidelityFX_LICENSE.md
Licenses/DirectX_LICENSE.txt     → DirectX_LICENSE.txt
```

#### Static Files (from existing directories):
```
Dll version/dlss-enabler.asi     → version.dll/winmm.dll/dlss-enabler.dll
DLLSG mod/dlssg_to_fsr3_amd_is_better.dll
DLLSG mod/nvngx.dll              → nvngx-wrapper.dll
NVIDIA Environment/dxgi.dll
NVIDIA Environment/dlss-finder.bin → dlss-finder.exe
NVIDIA Environment/nvapi64-proxy.dll
```

### ✅ Preserved Original Installer Behavior
- **Simple file copying** - No backup/restore complexity
- **Standard uninstallation** - Uses Inno Setup's built-in uninstall mechanism
- **User confirmations** - `confirmoverwrite` flags still present for critical DLLs
- **Component-based installation** - All original installation types preserved
- **Original file flags** - `uninsneveruninstall` for libxess.dll restored

### ✅ Benefits of This Approach
1. **Simplicity** - Much easier to maintain and debug
2. **Reliability** - Less complex logic means fewer edge cases
3. **Dynamic dependencies** - Still gets latest OptiScaler files automatically
4. **Version tracking** - Output filenames still match OptiScaler versions
5. **User control** - Users can still manually backup files if needed

## Files Now Supported from OptiScaler

The installer now dynamically sources these files from OptiScaler releases:
- ✅ **OptiScaler.dll** (main upscaling engine)
- ✅ **OptiScaler.ini** (configuration)
- ✅ **libxess.dll** (Intel XeSS)
- ✅ **amd_fidelityfx_dx12.dll** (AMD FSR DX12)
- ✅ **amd_fidelityfx_vk.dll** (AMD FSR Vulkan) 
- ✅ **Registry overrides** (signature checks)
- ✅ **License files** (XeSS, FidelityFX, DirectX)

## Result

The installer is now back to its original simple and reliable behavior while still:
- Automatically getting the latest OptiScaler components
- Using proper versioned naming based on OptiScaler releases  
- Maintaining all installation options and compatibility modes
- Being built automatically by GitHub Actions when new OptiScaler versions are released

This provides the best of both worlds: reliability and automation.
