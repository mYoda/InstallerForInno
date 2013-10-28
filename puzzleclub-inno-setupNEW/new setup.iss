
#define AppName "Пазл КЛУБ"
#define AppGUID "35CFF40B-77C8-4b05-B6C8-A3D32D533C6C"
#define AppId "{{35CFF40B-77C8-4b05-B6C8-A3D32D533C6C}"
#define AppFile "puzzleclub.exe"
#define AppVersion GetFileVersion(AppFile)

[Setup]
AppName={#AppName}
AppID={#AppId}
AppVerName={#AppName} версия {#AppVersion}
DefaultDirName={pf}\{#AppName}
DefaultGroupName={#AppName}
DisableDirPage=yes
DisableReadyMemo=yes
DisableReadyPage=yes
DisableStartupPrompt=yes
DisableProgramGroupPage=yes


LicenseFile=license.txt
UninstallDisplayIcon={app}\{#AppFile},0
Compression=lzma
AllowNoIcons=yes
OutputBaseFilename=puzzleclub
;SetupIconFile=logo.ico
;VersionInfoCompany
VersionInfoDescription={#GetFileDescription(AppFile)}
VersionInfoTextVersion={#GetFileVersionString(AppFile)}
VersionInfoVersion={#AppVersion}
AppMutex=PUZZLECLUB-35CFF40B-77C8-4b05-B6C8-A3D32D533C6C,Global\PUZZLECLUB-35CFF40B-77C8-4b05-B6C8-A3D32D533C6C
UsePreviousAppDir=yes

[Dirs]
Name: "{userappdata}\{#AppName}\colors"
Name: "{userappdata}\{#AppName}\sounds"
Name: "{userappdata}\{#AppName}\textures"
Name: "{userappdata}\{#AppName}\puzzles"
Name: "{userappdata}\{#AppName}\save"






[Languages]
Name: "ru"; MessagesFile: "compiler:\Languages\Russian.isl"


[Tasks]
Name: desktopicon; Description: "{cm:CreateDesktopIcon}"


[Run]
Filename: "{userappdata}\{#AppName}\puzzleclub.exe"; Description: "Запустить Пазл КЛУБ"; Flags: postinstall nowait skipifsilent


[UninstallDelete]

[CustomMessages]
AlreadyInstalled=Программа %1 версия %2 уже установлена.
ConfirmReinstall=Переустановить программу?
NewVersionFound=Вы устанавливаете версию %1 программы %2, в то время как уже установлена более новая версия %s этой программы.
AbortInstalation=Процесс установки будет завершен.
HowToInstallOldVersion=Чтобы установить старую версию, сначала удалите новую.