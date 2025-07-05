#define MyAppName "DLSS Enabler"
#define MyAppVersion "3.01.20250705"
#define MyAppPublisher "artur_07305"
;#define MyAppURL "https://discord.com/invite/2JDHx6kcXB"
#define MyAppExeName "my-game.exe"

[Setup]
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; This section is temporarily commented out, as it seems that soem AVs are sensitive to the presence of any URL in the executable and increase the risk of false positive
;AppPublisherURL={#MyAppURL}
;AppSupportURL={#MyAppURL}
;AppUpdatesURL={#MyAppURL}
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DefaultDirName=c:\games\my-game\bin\x64
DisableProgramGroupPage=yes
DirExistsWarning=no
LicenseFile=DLSS for AMD and Intel - License.rtf
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
OutputBaseFilename=dlss-enabler-setup
AppendDefaultDirName=no
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Compression type is very important here, bzip/9 is the safest one in regards to false positives, lzma2 on the other hand triggers some AVs, but reduce the file size by 50%
;Compression=bzip/9
Compression=lzma2
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
InternalCompressLevel=ultra
LZMADictionarySize=231072
LZMAUseSeparateProcess=yes
LZMANumFastBytes=200
SolidCompression=no
WizardStyle=modern
UsePreviousAppDir=no
InfoBeforeFile=DLSS Enabler Intro.rtf
; SetupIconFile=artifacts\dlss-enabler.ico
EnableDirDoesntExistWarning=yes
Uninstallable=yes
RestartApplications=no
RestartIfNeededByRun=no
TerminalServicesAware=no
CreateUninstallRegKey=no
LanguageDetectionMethod=none
UninstallDisplayIcon={uninstallexe}
UninstallFilesDir={app}
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Some AVs do not like InnoSetup in x64 configuration...
;ArchitecturesAllowed=x64
;ArchitecturesInstallIn64BitMode=x64
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CloseApplications=no

[Types]
Name: "full"; Description: "Preferred installation (DLL package)"
Name: "debug"; Description: "Troubleshooting installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom
Name: "experimental"; Description: "Experimental support for AMD and Intel GPUs"

[Components]
Name: mainfiles; Description: Install main DLSS Enabler files (game dependant); Types: full
Name: mainfiles/dllversion; Description: Install as a version.dll file (optimal compatibility); Types: full; Flags: exclusive
Name: mainfiles/dllwinmm; Description: Install as a winmm.dll file (if version.dll didn't work); Types: custom; Flags: exclusive
Name: mainfiles/asiversion; Description: Install as an ASI plugin (if the game is heavily modded); Types: custom debug; Flags: exclusive
Name: mainfiles/dlldxgi; Description: Install as a dxgi.dll file (if nothing above works); Types: custom; Flags: exclusive

Name: nonnvidia; Description: Enable support for AMD and Intel GPUs (DON'T INSTALL if you have a NVIDIA GPU); Types: experimental custom
Name: nonnvidia/localdir; Description: Install NVIDIA Runtime files into game directory; Types: experimental custom; Flags: exclusive
Name: upscalers; Description: Install XeSS 1.3 and FSR 2.2 replacements for DLSS upscaler (Optiscaler 0.6); Flags: fixed; Types: full debug custom
Name: mandatory; Description: Install Nukem9 DLSSG-to-FSR3 module (version 0.100); Types: full debug custom; Flags: fixed

Name: optional; Description: Install optional files; Flags: fixed; Types: full debug custom
Name: mandatory/regentries; Description: (optional) Install .reg files enabling/disabling driver signature checks (only for troubleshooting purposes); Types: debug custom
Name: mandatory/fgdebug; Description: (optional) Install debug configuration file for Nukem9 DLSSG-to-FSR3 module (only for troubleshooting purposes); Types: debug custom



[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]

[Code]
// Global variables to track which files existed before installation
var
  BackupDir: String;
  OriginalFilesExisted: TArrayOfString;

// Initialize backup directory and check for existing files
procedure InitializeBackup();
var
  FilesToCheck: TArrayOfString;
  I: Integer;
  FileName: String;
begin
  BackupDir := ExpandConstant('{app}') + '\dlss-enabler-backup';
  
  // List of files that might be overwritten by our installer
  SetArrayLength(FilesToCheck, 11);
  FilesToCheck[0] := 'amd_fidelityfx_dx12.dll';
  FilesToCheck[1] := 'amd_fidelityfx_vk.dll';
  FilesToCheck[2] := 'libxess.dll';
  FilesToCheck[3] := 'version.dll';
  FilesToCheck[4] := 'winmm.dll';
  FilesToCheck[5] := 'dxgi.dll';
  FilesToCheck[6] := 'nvngx.dll';
  FilesToCheck[7] := 'dlss-enabler.dll';
  FilesToCheck[8] := 'nvapi64-proxy.dll';
  FilesToCheck[9] := 'dlss-finder.exe';
  FilesToCheck[10] := 'plugins\dlss-enabler.asi';
  
  SetArrayLength(OriginalFilesExisted, 0);
  
  // Check which files already exist and back them up
  for I := 0 to GetArrayLength(FilesToCheck) - 1 do
  begin
    FileName := ExpandConstant('{app}') + '\' + FilesToCheck[I];
    if FileExists(FileName) then
    begin
      Log('Found existing file: ' + FileName);
      SetArrayLength(OriginalFilesExisted, GetArrayLength(OriginalFilesExisted) + 1);
      OriginalFilesExisted[GetArrayLength(OriginalFilesExisted) - 1] := FilesToCheck[I];
      
      // Create backup directory if it doesn't exist
      if not DirExists(BackupDir) then
        CreateDir(BackupDir);
      
      // Create subdirectory in backup if needed (e.g., for plugins\dlss-enabler.asi)
      if Pos('\', FilesToCheck[I]) > 0 then
      begin
        if not DirExists(BackupDir + '\' + ExtractFileDir(FilesToCheck[I])) then
          CreateDir(BackupDir + '\' + ExtractFileDir(FilesToCheck[I]));
      end;
      
      // Backup the original file
      if FileCopy(FileName, BackupDir + '\' + FilesToCheck[I], False) then
        Log('Backed up: ' + FilesToCheck[I])
      else
        Log('Failed to backup: ' + FilesToCheck[I]);
    end;
  end;
end;

// Save backup info to a file for uninstaller
procedure SaveBackupInfo();
var
  BackupInfoFile: String;
  I: Integer;
  FileContent: String;
begin
  BackupInfoFile := BackupDir + '\backup-info.txt';
  FileContent := '';
  
  for I := 0 to GetArrayLength(OriginalFilesExisted) - 1 do
  begin
    FileContent := FileContent + OriginalFilesExisted[I] + #13#10;
  end;
  
  if FileContent <> '' then
    SaveStringToFile(BackupInfoFile, FileContent, False);
end;

// Restore backed up files during uninstall
procedure RestoreBackedUpFiles();
var
  BackupInfoFile: String;
  BackupContent: String;
  FilesToRestore: TArrayOfString;
  I: Integer;
  OriginalFile, BackupFile: String;
  FilesToDelete: TArrayOfString;
begin
  BackupInfoFile := ExpandConstant('{app}') + '\dlss-enabler-backup\backup-info.txt';
  
  // Initialize list of our installed files that should be deleted if no backup exists
  SetArrayLength(FilesToDelete, 11);
  FilesToDelete[0] := 'amd_fidelityfx_dx12.dll';
  FilesToDelete[1] := 'amd_fidelityfx_vk.dll';
  FilesToDelete[2] := 'libxess.dll';
  FilesToDelete[3] := 'version.dll';
  FilesToDelete[4] := 'winmm.dll';
  FilesToDelete[5] := 'dxgi.dll';
  FilesToDelete[6] := 'nvngx.dll';
  FilesToDelete[7] := 'dlss-enabler.dll';
  FilesToDelete[8] := 'nvapi64-proxy.dll';
  FilesToDelete[9] := 'dlss-finder.exe';
  FilesToDelete[10] := 'plugins\dlss-enabler.asi';
  
  if FileExists(BackupInfoFile) then
  begin
    Log('Found backup info file, restoring original files...');
    
    if LoadStringFromFile(BackupInfoFile, BackupContent) then
    begin
      FilesToRestore := SplitString(BackupContent, #13#10);
      
      for I := 0 to GetArrayLength(FilesToRestore) - 1 do
      begin
        if Trim(FilesToRestore[I]) <> '' then
        begin
          OriginalFile := ExpandConstant('{app}') + '\' + Trim(FilesToRestore[I]);
          BackupFile := ExpandConstant('{app}') + '\dlss-enabler-backup\' + Trim(FilesToRestore[I]);
          
          if FileExists(BackupFile) then
          begin
            // Create target directory if it doesn't exist (for subdirectories like plugins)
            if Pos('\', Trim(FilesToRestore[I])) > 0 then
            begin
              if not DirExists(ExpandConstant('{app}') + '\' + ExtractFileDir(Trim(FilesToRestore[I]))) then
                CreateDir(ExpandConstant('{app}') + '\' + ExtractFileDir(Trim(FilesToRestore[I])));
            end;
            
            if FileCopy(BackupFile, OriginalFile, True) then
              Log('Restored original file: ' + Trim(FilesToRestore[I]))
            else
              Log('Failed to restore: ' + Trim(FilesToRestore[I]));
          end;
        end;
      end;
    end;
  end
  else
  begin
    Log('No backup info found, deleting our installed files...');
    // Delete our files if no backups exist (clean installation)
    for I := 0 to GetArrayLength(FilesToDelete) - 1 do
    begin
      OriginalFile := ExpandConstant('{app}') + '\' + FilesToDelete[I];
      if FileExists(OriginalFile) then
      begin
        if DeleteFile(OriginalFile) then
          Log('Deleted our installed file: ' + FilesToDelete[I])
        else
          Log('Failed to delete: ' + FilesToDelete[I]);
      end;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    InitializeBackup();
  end
  else if CurStep = ssPostInstall then
  begin
    SaveBackupInfo();
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    Log('Starting uninstall - restoring backed up files...');
    RestoreBackedUpFiles();
  end;
end;

[Files]
; cleanup
Source: "Dll version\nvngx.ini"; DestDir: "{app}"; DestName: "dlss-enabler-xess.dll"; Flags: ignoreversion deleteafterinstall; Components: mandatory
Source: "Dll version\nvngx.ini"; DestDir: "{app}"; DestName: "dlss-enabler-fsr.dll"; Flags: ignoreversion deleteafterinstall; Components: mandatory
Source: "Dll version\dlss-enabler.log"; DestDir: "{app}"; Flags: ignoreversion; Components: mandatory
Source: "Dll version\dlss-enabler.log"; DestDir: "{app}"; DestName: "dlssg_to_fsr3.log"; Flags: ignoreversion; Components: mandatory

; runtime env
Source: "NVIDIA Environment\dxgi.dll"; DestDir: "{app}"; Components: nonnvidia/localdir mainfiles/dlldxgi
Source: "NVIDIA Environment\dlss-finder.bin"; DestName: "dlss-finder.exe"; DestDir: "{app}"; Components: nonnvidia/localdir
Source: "NVIDIA Environment\nvapi64-proxy.dll"; DestName: "nvapi64-proxy.dll"; DestDir: "{app}"; Components: nonnvidia/localdir
Source: "DLLSG mod\nvngx.dll"; DestDir: "{app}"; DestName: "_nvngx.dll"; Flags: ignoreversion; Components: nonnvidia/localdir

; DLSSG
Source: "DLLSG mod\dlssg_to_fsr3.ini"; DestDir: "{app}"; Flags: ignoreversion; Components: mandatory/fgdebug
Source: "DLLSG mod\DisableNvidiaSignatureChecks.reg"; DestDir: "{app}"; Flags: ignoreversion; Components: mandatory/regentries nonnvidia/localdir
Source: "DLLSG mod\RestoreNvidiaSignatureChecks.reg"; DestDir: "{app}"; Flags: ignoreversion; Components: mandatory/regentries nonnvidia/localdir
Source: "DLLSG mod\dlssg_to_fsr3_amd_is_better.dll"; DestDir: "{app}"; Flags: ignoreversion; Components: mandatory mainfiles/dllversion mainfiles/asiversion mainfiles/dllwinmm mainfiles/dlldxgi
Source: "DLLSG mod\READ ME.txt"; DestDir: "{app}"; DestName: "READ ME (DLSSG to FSR3 mod).txt"; Flags: ignoreversion deleteafterinstall; Components: mandatory mainfiles/dllversion mainfiles/asiversion mainfiles/dllwinmm mainfiles/dlldxgi
Source: "DLLSG mod\READ ME.txt"; DestDir: "{app}/licenses"; DestName: "READ ME (DLSSG to FSR3 mod).txt"; Flags: ignoreversion; Components: mandatory mainfiles/dllversion mainfiles/asiversion mainfiles/dllwinmm mainfiles/dlldxgi
Source: "DLLSG mod\LICENSE.txt"; DestDir: "{app}"; DestName: "LICENSE (DLSSG to FSR3 mod).txt"; Flags: ignoreversion deleteafterinstall; Components: mandatory mainfiles/dllversion mainfiles/asiversion mainfiles/dllwinmm mainfiles/dlldxgi
Source: "DLLSG mod\LICENSE.txt"; DestDir: "{app}/licenses"; DestName: "LICENSE (DLSSG to FSR3 mod).txt"; Flags: ignoreversion; Components: mandatory mainfiles/dllversion mainfiles/asiversion mainfiles/dllwinmm mainfiles/dlldxgi
Source: "DLLSG mod\nvngx.dll"; DestDir: "{app}"; DestName: "nvngx-wrapper.dll"; Flags: ignoreversion; Components: mandatory mainfiles/dllversion mainfiles/asiversion mainfiles/dllwinmm mainfiles/dlldxgi

; upscalers
Source: "Dll version\dlss-enabler-upscaler.dll"; DestDir: "{app}"; Flags: ignoreversion; Components: upscalers
Source: "Dll version\nvngx.ini"; DestDir: "{app}"; Flags: ignoreversion; Components: upscalers
Source: "Dll version\OptiScaler.ini"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\libxess.dll"; DestDir: "{app}"; Flags: ignoreversion; Components: upscalers
Source: "Dll version\amd_fidelityfx_dx12.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "Dll version\amd_fidelityfx_vk.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist; Components: upscalers
Source: "XESS LICENSE.pdf"; DestDir: "{app}"; DestName: "XESS LICENSE.pdf"; Flags: ignoreversion deleteafterinstall; Components: upscalers
Source: "XESS LICENSE.pdf"; DestDir: "{app}/licenses"; DestName: "XESS LICENSE.pdf"; Flags: ignoreversion; Components: upscalers

; main module
Source: "Dll version\dlss-enabler.asi"; DestDir: "{app}/plugins"; DestName: "dlss-enabler.asi"; Flags: confirmoverwrite; Components: mainfiles/asiversion
Source: "Dll version\dlss-enabler.asi"; DestDir: "{app}"; DestName: "dlss-enabler.dll"; Flags: confirmoverwrite; Components: mainfiles/dlldxgi
Source: "Dll version\dlss-enabler.asi"; DestDir: "{app}"; DestName: "version.dll"; Flags: confirmoverwrite; Components: mainfiles/dllversion
Source: "Dll version\dlss-enabler.asi"; DestDir: "{app}"; DestName: "winmm.dll"; Flags: confirmoverwrite; Components: mainfiles/dllwinmm

; common docs
Source: "Readme (DLSS enabler).txt"; DestDir: "{app}"; Flags: ignoreversion deleteafterinstall; Components: mainfiles/dllwinmm mainfiles/dllversion mainfiles/asiversion mainfiles/dlldxgi
Source: "Readme (DLSS enabler).txt"; DestDir: "{app}/licenses"; Flags: ignoreversion; Components: mainfiles/dllwinmm mainfiles/dllversion mainfiles/asiversion mainfiles/dlldxgi

; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[UninstallDelete]
; Only delete files that are specifically part of DLSS Enabler (not original game files)
Type: files; Name: "{app}\dlss-enabler.log"
Type: files; Name: "{app}\dlssg_to_fsr3.log"
Type: files; Name: "{app}\nvngx.ini"
Type: files; Name: "{app}\OptiScaler.ini"
Type: files; Name: "{app}\dlssg_to_fsr3.ini"
Type: files; Name: "{app}\DisableNvidiaSignatureChecks.reg"
Type: files; Name: "{app}\RestoreNvidiaSignatureChecks.reg"
Type: files; Name: "{app}\_nvngx.dll"
Type: files; Name: "{app}\nvngx-wrapper.dll"
Type: files; Name: "{app}\dlss-enabler-upscaler.dll"
Type: files; Name: "{app}\READ ME (DLSSG to FSR3 mod).txt"
Type: files; Name: "{app}\LICENSE (DLSSG to FSR3 mod).txt"
Type: files; Name: "{app}\XESS LICENSE.pdf"
Type: files; Name: "{app}\Readme (DLSS enabler).txt"
Type: filesandordirs; Name: "{app}\licenses"
Type: filesandordirs; Name: "{app}\plugins"
Type: filesandordirs; Name: "{app}\dlss-enabler-backup"
Type: dirifempty; Name: "{app}"

[Icons]

[Run]
Filename: "{app}\licenses\Readme (DLSS enabler).txt"; Description: "View the DLSS Enabler README file"; Flags: postinstall shellexec skipifsilent
Filename: "{app}\nvngx.ini"; Description: "Edit the configuration file (optional)"; Flags: postinstall shellexec skipifsilent unchecked
Filename: "{app}\dlss-finder.exe"; Parameters: "/s"; StatusMsg: "Disabling NVIDIA signature checks for DLSS 3.7"; WorkingDir: "{app}"; Description: "DLSS 3.7 activation step"; Flags: skipifsilent skipifdoesntexist

[UninstallRun]
; Clean up any processes that might be using our DLLs
Filename: "taskkill"; Parameters: "/f /im dlss-finder.exe"; Flags: runhidden; RunOnceId: "killdlssfinder"

