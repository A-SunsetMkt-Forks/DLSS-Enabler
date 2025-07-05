# DLSS-Enabler File Sources and Path Management

## File Source Classification

### ✅ Files from OptiScaler Release (Downloaded by Workflow)
These files are extracted from OptiScaler releases and copied to target locations by the GitHub Actions workflow:

| OptiScaler File | Workflow Copies To | Installer References | Purpose |
|----------------|-------------------|---------------------|---------|
| `OptiScaler.dll` | `Dll version\dlss-enabler-upscaler.dll` | `Dll version\dlss-enabler-upscaler.dll` | Main upscaling engine |
| `OptiScaler.ini` | `Dll version\OptiScaler.ini` | `Dll version\OptiScaler.ini` | Configuration file |
| `libxess.dll` | `Dll version\libxess.dll` | `Dll version\libxess.dll` | Intel XeSS library |
| `amd_fidelityfx_dx12.dll` | `Dll version\amd_fidelityfx_dx12.dll` | `Dll version\amd_fidelityfx_dx12.dll` | AMD FSR DX12 |
| `amd_fidelityfx_vk.dll` | `Dll version\amd_fidelityfx_vk.dll` | `Dll version\amd_fidelityfx_vk.dll` | AMD FSR Vulkan |
| `DlssOverrides\DisableSignatureOverride.reg` | `DLLSG mod\DisableNvidiaSignatureChecks.reg` | `DLLSG mod\DisableNvidiaSignatureChecks.reg` | Registry override |
| `DlssOverrides\EnableSignatureOverride.reg` | `DLLSG mod\RestoreNvidiaSignatureChecks.reg` | `DLLSG mod\RestoreNvidiaSignatureChecks.reg` | Registry restore |
| `Licenses\XeSS_LICENSE.txt` | `Dll version\XeSS_LICENSE.txt` | `Dll version\XeSS_LICENSE.txt` | XeSS license (optional) |
| `Licenses\FidelityFX_LICENSE.md` | `Dll version\FidelityFX_LICENSE.md` | `Dll version\FidelityFX_LICENSE.md` | FSR license (optional) |
| `Licenses\DirectX_LICENSE.txt` | `Dll version\DirectX_LICENSE.txt` | `Dll version\DirectX_LICENSE.txt` | DirectX license (optional) |

### ✅ Files from Repository (Always Available)
These files are part of the DLSS-Enabler repository and are always available:

| Repository File | Installer References | Purpose |
|----------------|---------------------|---------|
| `Dll version\dlss-enabler.asi` | `Dll version\dlss-enabler.asi` | Main DLSS Enabler module |
| `Dll version\dlss-enabler.log` | `Dll version\dlss-enabler.log` | Log file template |
| `Dll version\nvngx.ini` | `Dll version\nvngx.ini` | Legacy config file |
| `DLLSG mod\dlssg_to_fsr3_amd_is_better.dll` | `DLLSG mod\dlssg_to_fsr3_amd_is_better.dll` | DLSSG to FSR3 converter |
| `DLLSG mod\nvngx.dll` | `DLLSG mod\nvngx.dll` | NVNGX wrapper |
| `DLLSG mod\dlssg_to_fsr3.ini` | `DLLSG mod\dlssg_to_fsr3.ini` | DLSSG config |
| `DLLSG mod\READ ME.txt` | `DLLSG mod\READ ME.txt` | DLSSG documentation |
| `DLLSG mod\LICENSE.txt` | `DLLSG mod\LICENSE.txt` | DLSSG license |
| `NVIDIA Environment\dxgi.dll` | `NVIDIA Environment\dxgi.dll` | NVIDIA runtime |
| `NVIDIA Environment\dlss-finder.bin` | `NVIDIA Environment\dlss-finder.bin` | DLSS detector |
| `NVIDIA Environment\nvapi64-proxy.dll` | `NVIDIA Environment\nvapi64-proxy.dll` | NVAPI proxy |
| `XESS LICENSE.pdf` | `XESS LICENSE.pdf` | XeSS license (repository version) |
| `Readme (DLSS enabler).txt` | `Readme (DLSS enabler).txt` | Main documentation |

## Installer Script Strategy

### ✅ Primary Sources (Always Available)
- Repository files are always referenced directly
- Repository XESS license takes priority over OptiScaler version

### ✅ Secondary Sources (Dynamic/Optional)
- OptiScaler files use `skipifsourcedoesntexist` flag
- If workflow fails to copy OptiScaler files, installer still works with repository files
- OptiScaler license files are supplementary to repository versions

### ✅ Error Handling
- All OptiScaler-sourced files use `skipifsourcedoesntexist` to prevent build failures
- Repository files provide baseline functionality even without OptiScaler updates
- Workflow validation ensures OptiScaler files are copied before build

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
