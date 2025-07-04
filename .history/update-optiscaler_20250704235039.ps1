# DLSS-Enabler Auto-Update Script
# This script downloads the latest OptiScaler and prepares it for DLSS-Enabler

param(
    [string]$OptiScalerVersion = "nightly",  # Can be "nightly", "latest", or specific version like "v0.7.7-pre12"
    [switch]$Force = $false,                 # Force download even if file exists
    [switch]$SkipXeSS = $false              # Skip XeSS download
)

$ErrorActionPreference = "Stop"

# Configuration
$OptiScalerRepo = "optiscaler/OptiScaler"
$XeSSRepo = "intel/xess"
$DllVersionDir = "Dll version"

Write-Host "🚀 DLSS-Enabler Auto-Update Script" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Function to get GitHub release
function Get-GitHubRelease {
    param($Repo, $Tag)
    
    $headers = @{
        'Accept' = 'application/vnd.github.v3+json'
        'User-Agent' = 'DLSS-Enabler-Update-Script'
    }
    
    try {
        if ($Tag -eq "nightly") {
            $url = "https://api.github.com/repos/$Repo/releases"
            $releases = Invoke-RestMethod -Uri $url -Headers $headers
            return $releases | Where-Object { $_.prerelease -eq $true -and $_.tag_name -eq "nightly" } | Select-Object -First 1
        } elseif ($Tag -eq "latest") {
            $url = "https://api.github.com/repos/$Repo/releases/latest"
            return Invoke-RestMethod -Uri $url -Headers $headers
        } else {
            $url = "https://api.github.com/repos/$Repo/releases/tags/$Tag"
            return Invoke-RestMethod -Uri $url -Headers $headers
        }
    } catch {
        Write-Error "Failed to get release info for $Repo/$Tag : $($_.Exception.Message)"
        return $null
    }
}

# Function to download and extract file
function Download-AndExtract {
    param($Url, $DestinationDir, $ExpectedFile)
    
    $fileName = Split-Path $Url -Leaf
    $tempPath = Join-Path $env:TEMP $fileName
    $extractDir = Join-Path $env:TEMP "extract_$(Get-Random)"
    
    try {
        Write-Host "📥 Downloading: $fileName" -ForegroundColor Yellow
        Invoke-WebRequest -Uri $Url -OutFile $tempPath -UseBasicParsing
        
        Write-Host "📂 Extracting archive..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
        
        if ($fileName -match "\.7z$") {
            # Try to use 7z if available
            $7zPath = Get-Command "7z.exe" -ErrorAction SilentlyContinue
            if ($7zPath) {
                & $7zPath.Source x "$tempPath" "-o$extractDir" -y
            } else {
                Write-Warning "7-Zip not found. Please install 7-Zip to extract .7z files."
                return $null
            }
        } elseif ($fileName -match "\.zip$") {
            Expand-Archive -Path $tempPath -DestinationPath $extractDir -Force
        } else {
            Write-Error "Unsupported archive format: $fileName"
            return $null
        }
        
        # Find the expected file
        $foundFile = Get-ChildItem -Path $extractDir -Name $ExpectedFile -Recurse | Select-Object -First 1
        
        if ($foundFile) {
            $fullPath = Get-ChildItem -Path $extractDir -Filter $ExpectedFile -Recurse | Select-Object -First 1
            return $fullPath.FullName
        } else {
            Write-Warning "Could not find $ExpectedFile in extracted archive"
            Write-Host "Archive contents:" -ForegroundColor Gray
            Get-ChildItem -Path $extractDir -Recurse | ForEach-Object { Write-Host "  $($_.FullName)" -ForegroundColor Gray }
            return $null
        }
    } finally {
        # Cleanup
        if (Test-Path $tempPath) { Remove-Item $tempPath -Force }
        if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
    }
}

# Main execution
try {
    # Ensure we're in the right directory
    if (-not (Test-Path "DLSS enabler.iss")) {
        Write-Error "Please run this script from the DLSS-Enabler repository root directory"
        exit 1
    }
    
    # Create Dll version directory if it doesn't exist
    if (-not (Test-Path $DllVersionDir)) {
        New-Item -ItemType Directory -Path $DllVersionDir -Force | Out-Null
    }
    
    # Get OptiScaler release
    Write-Host "🔍 Checking OptiScaler release: $OptiScalerVersion" -ForegroundColor Green
    $optiRelease = Get-GitHubRelease -Repo $OptiScalerRepo -Tag $OptiScalerVersion
    
    if (-not $optiRelease) {
        Write-Error "Could not find OptiScaler release: $OptiScalerVersion"
        exit 1
    }
    
    Write-Host "✅ Found OptiScaler: $($optiRelease.tag_name)" -ForegroundColor Green
    Write-Host "📅 Published: $($optiRelease.published_at)" -ForegroundColor Gray
    
    # Find archive asset
    $archiveAsset = $optiRelease.assets | Where-Object { 
        $_.name -match "OptiScaler.*\.(zip|7z)$" 
    } | Select-Object -First 1
    
    if (-not $archiveAsset) {
        Write-Error "Could not find OptiScaler archive in release assets"
        Write-Host "Available assets:" -ForegroundColor Gray
        $optiRelease.assets | ForEach-Object { Write-Host "  $($_.name)" -ForegroundColor Gray }
        exit 1
    }
    
    # Download and extract OptiScaler
    $targetDll = Join-Path $DllVersionDir "dlss-enabler-upscaler.dll"
    
    if ((Test-Path $targetDll) -and -not $Force) {
        $choice = Read-Host "dlss-enabler-upscaler.dll already exists. Overwrite? (y/N)"
        if ($choice -ne "y" -and $choice -ne "Y") {
            Write-Host "⏭️  Skipping OptiScaler download" -ForegroundColor Yellow
        } else {
            $Force = $true
        }
    }
    
    if ($Force -or -not (Test-Path $targetDll)) {
        $nvngxPath = Download-AndExtract -Url $archiveAsset.browser_download_url -DestinationDir $DllVersionDir -ExpectedFile "nvngx.dll"
        
        if ($nvngxPath) {
            Copy-Item -Path $nvngxPath -Destination $targetDll -Force
            Write-Host "✅ Updated: dlss-enabler-upscaler.dll" -ForegroundColor Green
            
            # Show file info
            try {
                $fileInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($targetDll)
                Write-Host "📋 File Version: $($fileInfo.FileVersion)" -ForegroundColor Gray
                Write-Host "📋 Product Version: $($fileInfo.ProductVersion)" -ForegroundColor Gray
            } catch {
                Write-Host "📋 Could not read version info" -ForegroundColor Gray
            }
        } else {
            Write-Error "Failed to extract nvngx.dll from OptiScaler archive"
            exit 1
        }
    }
    
    # Download XeSS if requested
    if (-not $SkipXeSS) {
        Write-Host ""
        Write-Host "🔍 Checking XeSS library..." -ForegroundColor Green
        
        $xessTarget = Join-Path $DllVersionDir "libxess.dll"
        
        if ((Test-Path $xessTarget) -and -not $Force) {
            $choice = Read-Host "libxess.dll already exists. Update? (y/N)"
            if ($choice -ne "y" -and $choice -ne "Y") {
                Write-Host "⏭️  Skipping XeSS download" -ForegroundColor Yellow
            } else {
                $Force = $true
            }
        }
        
        if ($Force -or -not (Test-Path $xessTarget)) {
            try {
                # Try to get latest XeSS release
                $xessRelease = Get-GitHubRelease -Repo $XeSSRepo -Tag "latest"
                
                if ($xessRelease) {
                    $xessAsset = $xessRelease.assets | Where-Object { $_.name -eq "libxess.dll" } | Select-Object -First 1
                    
                    if ($xessAsset) {
                        Write-Host "📥 Downloading XeSS $($xessRelease.tag_name)..." -ForegroundColor Yellow
                        Invoke-WebRequest -Uri $xessAsset.browser_download_url -OutFile $xessTarget -UseBasicParsing
                        Write-Host "✅ Updated: libxess.dll" -ForegroundColor Green
                    } else {
                        Write-Warning "No libxess.dll found in XeSS release, using direct download"
                        Invoke-WebRequest -Uri "https://github.com/intel/xess/releases/latest/download/libxess.dll" -OutFile $xessTarget -UseBasicParsing
                        Write-Host "✅ Downloaded: libxess.dll (direct)" -ForegroundColor Green
                    }
                } else {
                    Write-Warning "Could not get XeSS release info, using direct download"
                    Invoke-WebRequest -Uri "https://github.com/intel/xess/releases/latest/download/libxess.dll" -OutFile $xessTarget -UseBasicParsing
                    Write-Host "✅ Downloaded: libxess.dll (direct)" -ForegroundColor Green
                }
            } catch {
                Write-Warning "Failed to download XeSS: $($_.Exception.Message)"
            }
        }
    }
    
    Write-Host ""
    Write-Host "🎉 Update completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📁 Updated files in '$DllVersionDir':" -ForegroundColor Cyan
    Get-ChildItem -Path $DllVersionDir -File | ForEach-Object {
        $size = [math]::Round($_.Length / 1MB, 2)
        Write-Host "  📄 $($_.Name) ($size MB)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "💡 Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Open 'DLSS enabler.iss' in Inno Setup" -ForegroundColor White
    Write-Host "  2. Update version number if needed" -ForegroundColor White
    Write-Host "  3. Build the installer" -ForegroundColor White
    
} catch {
    Write-Error "Script failed: $($_.Exception.Message)"
    exit 1
}
