# GitHub Actions Workflows for DLSS-Enabler

This directory contains automated workflows for building DLSS-Enabler installers with the latest OptiScaler releases.

## Workflows

### 1. Build Installer (`build-installer.yml`)

**Purpose**: Automatically builds DLSS-Enabler installer with the latest OptiScaler components.

**Triggers**:
- Daily schedule (12:00 UTC) to check for new releases
- Manual trigger with version selection
- Push to main/master branch (for testing)

**What it does**:
1. Checks for new OptiScaler releases (nightly or stable)
2. Downloads the latest OptiScaler archive
3. Extracts `nvngx.dll` and renames it to `dlss-enabler-upscaler.dll`
4. Downloads the latest XeSS library (`libxess.dll`)
5. Updates version information in the Inno Setup script
6. Builds the installer using Inno Setup 6.2.0
7. Creates a GitHub release with the installer

**Manual Usage**:
```bash
# Trigger build with specific OptiScaler version
gh workflow run build-installer.yml \
  -f optiscaler_version=v0.7.7-pre12 \
  -f force_build=true

# Trigger build with nightly version
gh workflow run build-installer.yml \
  -f optiscaler_version=nightly \
  -f force_build=false
```

### 2. Monitor OptiScaler (`monitor-optiscaler.yml`)

**Purpose**: Monitors the OptiScaler repository for new releases and automatically triggers builds.

**Triggers**:
- Every 6 hours via schedule
- Manual trigger with version selection

**What it does**:
1. Checks OptiScaler repository for new releases
2. Compares with recent DLSS-Enabler builds
3. Triggers the build workflow if a new version is detected
4. Avoids duplicate builds for the same OptiScaler version

**Manual Usage**:
```bash
# Check for nightly releases
gh workflow run monitor-optiscaler.yml \
  -f check_version=nightly

# Check for latest stable release
gh workflow run monitor-optiscaler.yml \
  -f check_version=latest
```

## Setup Requirements

### Repository Secrets
- `GITHUB_TOKEN`: Automatically provided by GitHub Actions (no setup needed)

### Permissions
The workflows require the following permissions:
- `contents: write` - To create releases and upload assets
- `actions: write` - To trigger other workflows

### Dependencies
The workflows automatically install:
- **Inno Setup**: Using [Minionguyjpro/Inno-Setup-Action@v1.2.4](https://github.com/Minionguyjpro/Inno-Setup-Action)
- **7-Zip**: Using [milliewalky/setup-7-zip@v2](https://github.com/milliewalky/setup-7-zip)
- **PowerShell**: Pre-installed on Windows runners

### Best Practices Implemented
- **Retry Logic**: Network downloads include retry mechanisms with exponential backoff
- **Error Handling**: Comprehensive error checking and detailed logging
- **File Validation**: Size and integrity checks for downloaded files
- **Artifacts**: Build artifacts are uploaded for debugging and manual download
- **Permissions**: Minimal required permissions for security
- **Official Actions**: Uses verified marketplace actions for tooling

## File Structure

```
.github/workflows/
├── build-installer.yml     # Main build workflow
└── monitor-optiscaler.yml  # Release monitoring workflow

# Generated during build:
Output/                     # Installer output directory
├── dlss-enabler-setup-*.exe

# Updated during build:
Dll version/
├── dlss-enabler-upscaler.dll  # From OptiScaler nvngx.dll
└── libxess.dll                # Latest from Intel
```

## Version Naming

**DLSS-Enabler Version Format**: `3.01.YYYYMMDD.HHMMSS`
- Base version: `3.01` (following current versioning)
- Timestamp: Build date and time

**Release Naming**: `DLSS Enabler vX.XX.XXXXXX.XXXXXX (OptiScaler vX.X.X-preXX)`

## Customization

### Changing OptiScaler Source
Edit the `OPTISCALER_REPO` environment variable in `build-installer.yml`:
```yaml
env:
  OPTISCALER_REPO: your-username/OptiScaler-Fork
```

### Changing Schedule
Modify the cron expressions in the workflow files:
```yaml
schedule:
  - cron: '0 */12 * * *'  # Every 12 hours instead of 6
```

### Adding More Components
To include additional DLLs or components:

1. Add download steps in `build-installer.yml`
2. Update the Inno Setup script (`DLSS enabler.iss`)
3. Test locally with the PowerShell script

## Local Testing

Use the included PowerShell script for local testing:

```powershell
# Test with nightly OptiScaler
.\update-optiscaler.ps1 -OptiScalerVersion nightly -Force

# Test with specific version
.\update-optiscaler.ps1 -OptiScalerVersion v0.7.7-pre12 -Force

# Skip XeSS download
.\update-optiscaler.ps1 -SkipXeSS
```

## Troubleshooting

### Build Failures

1. **OptiScaler download fails**:
   - Check if the release exists
   - Verify archive format (zip/7z)
   - Check network connectivity

2. **Inno Setup compilation fails**:
   - Verify all required files exist in `Dll version/`
   - Check Inno Setup script syntax
   - Ensure version format is correct

3. **Release creation fails**:
   - Check repository permissions
   - Verify GITHUB_TOKEN has sufficient scope
   - Check for conflicting tag names

### Monitoring Issues

1. **Workflows not triggering**:
   - Check workflow permissions
   - Verify schedule syntax
   - Manually trigger to test

2. **Duplicate builds**:
   - Check version comparison logic
   - Verify recent build detection
   - Adjust time window for duplicate checking

## Security Considerations

- **Antivirus False Positives**: The installer may trigger false positives due to DLL injection techniques
- **Code Signing**: Consider adding code signing for production releases
- **Supply Chain**: All dependencies are downloaded from official sources (GitHub releases)

## Contributing

When modifying the workflows:

1. Test changes in a fork first
2. Use manual triggers for testing
3. Check workflow logs for issues
4. Update documentation if needed

## Support

For issues with the workflows:
1. Check the Actions tab for detailed logs
2. Compare with successful runs
3. Test components locally first
4. Create an issue with full error details
