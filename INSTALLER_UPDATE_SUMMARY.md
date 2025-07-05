# DLSS-Enabler Installer Update Summary

## Completed Tasks

### ✅ OptiScaler Integration (v0.7.7-pre12)
- **Extracted and copied latest OptiScaler files:**
  - `OptiScaler.dll` → `Dll version\dlss-enabler-upscaler.dll` (23.5 MB - latest upscaling engine)
  - `OptiScaler.ini` → `Dll version\OptiScaler.ini` (29 KB - comprehensive configuration)
  - `libxess.dll` → `Dll version\libxess.dll` (77.7 MB - Intel XeSS library)
  - `amd_fidelityfx_dx12.dll` → `Dll version\amd_fidelityfx_dx12.dll` (6.7 MB - AMD FSR DX12)
  - `amd_fidelityfx_vk.dll` → `Dll version\amd_fidelityfx_vk.dll` (9.3 MB - AMD FSR Vulkan)
  - Registry files for signature override/restore
  - License files for XeSS, FidelityFX, and DirectX

### ✅ Repository Files Integration
- **Copied missing files from original repository:**
  - `DLSS Enabler Intro.rtf` - Introduction file for installer
  - `License (DLSS enabler).txt` - DLSS Enabler license
  - All existing repository modules and documentation

### ✅ Installer Script Updates
- **Enhanced [Files] section:**
  - Uses latest OptiScaler configuration file (OptiScaler.ini) instead of legacy nvngx.ini
  - Includes AMD FSR libraries (DX12 and Vulkan) without fallback flags
  - All OptiScaler license files included for legal compliance
  - Updated component description to reflect OptiScaler 0.7.7
  - Restored SetupIconFile=FSR3.ico reference

### ✅ File Source Strategy
- **OptiScaler files:** Latest libraries and configuration from official release
- **Repository files:** Core DLSS Enabler modules and legacy support files
- **No duplicates:** OptiScaler files replace older versions where applicable
- **Complete coverage:** All files from both old and new installer outputs included

## File Comparison: Old vs New

### Files Now Using Latest OptiScaler Versions:
| File | Old Version | New Version | Source |
|------|-------------|-------------|---------|
| dlss-enabler-upscaler.dll | 22.9 MB (Feb 2025) | 23.6 MB (Jun 2025) | OptiScaler 0.7.7-pre12 |
| libxess.dll | 120.3 MB (Dec 2024) | 77.7 MB (Jun 2025) | OptiScaler 0.7.7-pre12 |
| amd_fidelityfx_dx12.dll | 6.6 MB (Feb 2025) | 6.7 MB (Jun 2025) | OptiScaler 0.7.7-pre12 |
| amd_fidelityfx_vk.dll | 9.3 MB (Feb 2025) | 9.3 MB (Jun 2025) | OptiScaler 0.7.7-pre12 |
| nvngx.ini config | 24 KB (Mar 2025) | 29 KB (Jun 2025) | OptiScaler 0.7.7-pre12 |

### Files Preserved from Repository:
- `dlss-enabler.asi` - Main DLSS Enabler module
- `dlssg_to_fsr3_amd_is_better.dll` - DLSSG to FSR3 converter
- All NVIDIA Environment files (dxgi.dll, dlss-finder.bin, nvapi64-proxy.dll)
- Documentation and license files
- Registry override files (updated from OptiScaler)

## Build Strategy

### For Automated Builds:
1. **Download OptiScaler release** automatically
2. **Extract and copy** files to repository structure
3. **Use updated installer script** with all file references
4. **Build complete installer** with latest libraries and all legacy support

### For Manual Builds:
- All files are now present in repository structure
- Installer script references existing files directly
- No external dependencies required for compilation

## Benefits

✅ **Latest Technology**: OptiScaler 0.7.7-pre12 with FSR 3.1 and XeSS 1.3 support  
✅ **Complete Functionality**: All features from both old and new installers  
✅ **Reduced Size**: Optimized XeSS library reduces overall installer size  
✅ **Legal Compliance**: All necessary license files included  
✅ **Build Reliability**: No missing file errors during compilation  
✅ **Future-Proof**: Easy to update OptiScaler versions in automated builds
