# DLSS-Enabler File Sources and Path Management

## Build Strategy: Dynamic OptiScaler Integration

### ✅ Files Downloaded from OptiScaler Release (NOT stored in repo)
These files are downloaded from OptiScaler releases during the build process and should NOT be stored in the repository:

| OptiScaler File | Build Copies To | Installer References | Purpose |
|----------------|-------------------|---------------------|---------|
| `OptiScaler.dll` | `Dll version\dlss-enabler-upscaler.dll` | `Dll version\dlss-enabler-upscaler.dll` | Main upscaling engine |
| `OptiScaler.ini` | `Dll version\OptiScaler.ini` | `Dll version\OptiScaler.ini` | Configuration file |
| `libxess.dll` | `Dll version\libxess.dll` | `Dll version\libxess.dll` | Intel XeSS library |
| `libxess_dx11.dll` | `Dll version\libxess_dx11.dll` | `Dll version\libxess_dx11.dll` | Intel XeSS DX11 library |
| `amd_fidelityfx_dx12.dll` | `Dll version\amd_fidelityfx_dx12.dll` | `Dll version\amd_fidelityfx_dx12.dll` | AMD FSR DX12 |
| `amd_fidelityfx_vk.dll` | `Dll version\amd_fidelityfx_vk.dll` | `Dll version\amd_fidelityfx_vk.dll` | AMD FSR Vulkan |
| `D3D12_Optiscaler\D3D12Core.dll` | `Dll version\D3D12Core.dll` | `Dll version\D3D12Core.dll` | DirectX 12 support |
| `DlssOverrides\DisableSignatureOverride.reg` | `DLLSG mod\DisableNvidiaSignatureChecks.reg` | `DLLSG mod\DisableNvidiaSignatureChecks.reg` | Registry override |
| `DlssOverrides\EnableSignatureOverride.reg` | `DLLSG mod\RestoreNvidiaSignatureChecks.reg` | `DLLSG mod\RestoreNvidiaSignatureChecks.reg` | Registry restore |
| `Licenses\XeSS_LICENSE.txt` | `Dll version\XeSS_LICENSE.txt` | `Dll version\XeSS_LICENSE.txt` | XeSS license |
| `Licenses\FidelityFX_LICENSE.md` | `Dll version\FidelityFX_LICENSE.md` | `Dll version\FidelityFX_LICENSE.md` | FSR license |
| `Licenses\DirectX_LICENSE.txt` | `Dll version\DirectX_LICENSE.txt` | `Dll version\DirectX_LICENSE.txt` | DirectX license |

### ✅ Files from Repository (Always Available)
These files are part of the DLSS-Enabler repository and are always available:

| Repository File | Installer References | Purpose |
|----------------|---------------------|---------|
| `Dll version\dlss-enabler.asi` | `Dll version\dlss-enabler.asi` | Main DLSS Enabler module |
| `Dll version\dlss-enabler.log` | `Dll version\dlss-enabler.log` | Log file template |
| `Dll version\nvngx.ini` | `Dll version\nvngx.ini` | Legacy config file (for cleanup) |
| `DLLSG mod\dlssg_to_fsr3_amd_is_better.dll` | `DLLSG mod\dlssg_to_fsr3_amd_is_better.dll` | DLSSG to FSR3 converter |
| `DLLSG mod\nvngx.dll` | `DLLSG mod\nvngx.dll` | NVNGX wrapper |
| `DLLSG mod\dlssg_to_fsr3.ini` | `DLLSG mod\dlssg_to_fsr3.ini` | DLSSG config |
| `DLLSG mod\READ ME.txt` | `DLLSG mod\READ ME.txt` | DLSSG documentation |
| `DLLSG mod\LICENSE.txt` | `DLLSG mod\LICENSE.txt` | DLSSG license |
| `NVIDIA Environment\dxgi.dll` | `NVIDIA Environment\dxgi.dll` | NVIDIA runtime |
| `NVIDIA Environment\dlss-finder.bin` | `NVIDIA Environment\dlss-finder.bin` | DLSS detector |
| `NVIDIA Environment\nvapi64-proxy.dll` | `NVIDIA Environment\nvapi64-proxy.dll` | NVAPI proxy |
| `Readme (DLSS enabler).txt` | `Readme (DLSS enabler).txt` | Main documentation |
| `DLSS Enabler Intro.rtf` | `DLSS Enabler Intro.rtf` | Introduction file |
| `License (DLSS enabler).txt` | `License (DLSS enabler).txt` | DLSS Enabler license |

## Build Process Flow

### 🚀 Automated Build Process:
1. **Download OptiScaler Release**: GitHub Actions downloads latest OptiScaler 7z archive
2. **Extract OptiScaler Files**: Extract all files from archive to build directory
3. **Copy to Build Structure**: Map OptiScaler files to expected installer paths
4. **Compile Installer**: Inno Setup compiles with both repository and OptiScaler files
5. **Result**: Complete installer with latest OptiScaler libraries and all DLSS Enabler features

### 📁 File Mapping Strategy:
- **OptiScaler files** use `skipifsourcedoesntexist` flag in installer script
- **Repository files** are always available and provide core functionality
- **No file duplication**: Repository only contains files not available in OptiScaler
- **Dynamic licensing**: Uses OptiScaler license files instead of duplicating them

## Benefits

✅ **Always Latest**: Automatically uses newest OptiScaler libraries  
✅ **Reduced Repo Size**: No large binary files stored in repository  
✅ **No Duplication**: Single source of truth for each file type  
✅ **Build Resilience**: Graceful handling of missing OptiScaler files  
✅ **Legal Compliance**: Uses original license files from each project  
✅ **Easy Updates**: OptiScaler updates require no repository changes

## Build Process Flow

1. **GitHub Actions Workflow**:
   - Downloads OptiScaler release
   - Extracts files to temporary directory
   - Copies OptiScaler files to expected locations in repository structure
   - Updates version and filename in installer script
   - Compiles installer with Inno Setup

2. **Installer Script**:
   - References files in their final locations (where workflow places them)
   - Uses repository files as primary sources
   - Uses OptiScaler files as enhancements/updates
   - Gracefully handles missing OptiScaler files

3. **Result**:
   - Installer always builds successfully
   - Contains latest OptiScaler components when available
   - Falls back to repository versions if needed
   - Maintains all functionality regardless of OptiScaler availability

## Key Benefits

✅ **Resilient**: Builds even if OptiScaler download fails  
✅ **Dynamic**: Automatically gets latest OptiScaler components  
✅ **Compatible**: Repository files ensure baseline functionality  
✅ **Comprehensive**: Includes all necessary licenses and documentation  
✅ **Maintainable**: Clear separation between static and dynamic content
