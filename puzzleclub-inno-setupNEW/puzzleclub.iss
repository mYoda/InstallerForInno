
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
LicenseFile=license.txt
UninstallDisplayIcon={app}\{#AppFile},0
Compression=lzma
DisableProgramGroupPage=yes
DisableReadyMemo=yes
DisableReadyPage=yes
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
Name: "{app}\colors"
Name: "{app}\sounds"
Name: "{app}\textures"
Name: "{app}\puzzles"
Name: "{app}\save"

[Files]
Source: "puzzleclub.exe"; DestDir: "{app}"
Source: "puzzleclub.chm"; DestDir: "{app}"
Source: "hint.ani"; DestDir: "{app}"
Source: "License.txt"; DestDir: "{app}"
;Source: "Readme.txt"; DestDir: "{app}";
Source: "colors\*.clr"; DestDir: "{app}\colors"
Source: "sounds\*.wav"; DestDir: "{app}\sounds"
Source: "textures\*"; DestDir: "{app}\textures"
Source: "puzzles\*.jsp"; DestDir: "{app}\puzzles"


[Icons]
Name: "{group}\Пазл КЛУБ"; Filename: "{app}\puzzleclub.exe"; WorkingDir: "{app}"
Name: "{group}\Пазл КЛУБ Справка"; Filename: "{app}\puzzleclub.chm"; WorkingDir: "{app}"
Name: "{group}\Удаление\Удалить Пазл КЛУБ"; Filename: "{uninstallexe}"
;Name: "{commondesktop}\Пазл КЛУБ"; Filename: "{app}\puzzleclub.exe"; WorkingDir: "{app}"; Tasks: desktopicon;
Name: "{commondesktop}\Пазл КЛУБ"; Filename: "{app}\puzzleclub.exe"; WorkingDir: "{app}"; 

[Languages]
Name: "ru"; MessagesFile: "compiler:\Languages\Russian.isl"


[Tasks]
;Name: desktopicon; Description: "{cm:CreateDesktopIcon}"


[Run]
Filename: "{app}\puzzleclub.exe"; Description: "Запустить Пазл КЛУБ"; Flags: postinstall nowait skipifsilent


[UninstallDelete]



[CustomMessages]
AlreadyInstalled=Программа %1 версия %2 уже установлена.
ConfirmReinstall=Переустановить программу?
NewVersionFound=Вы устанавливаете версию %1 программы %2, в то время как уже установлена более новая версия %s этой программы.
AbortInstalation=Процесс установки будет завершен.
HowToInstallOldVersion=Чтобы установить старую версию, сначала удалите новую.



[Code]
procedure DecodeVersion( verstr: String; var verint: array of Integer );
var
  i,p: Integer; s: string;
begin
  // initialize array
  verint := [0,0,0,0];
  i := 0;
  while ( (Length(verstr) > 0) and (i < 4) ) do
  begin
  p := pos('.', verstr);
  if p > 0 then
  begin
      if p = 1 then s:= '0' else s:= Copy( verstr, 1, p - 1 );
    verint[i] := StrToInt(s);
    i := i + 1;
    verstr := Copy( verstr, p+1, Length(verstr));
  end
  else
  begin
    verint[i] := StrToInt( verstr );
    verstr := '';
  end;
  end;

end;

// This function compares version string
// return -1 if ver1 < ver2
// return  0 if ver1 = ver2
// return  1 if ver1 > ver2
function CompareVersion( ver1, ver2: String ) : Integer;
var
  verint1, verint2: array of Integer;
  i: integer;
begin

  SetArrayLength( verint1, 4 );
  DecodeVersion( ver1, verint1 );

  SetArrayLength( verint2, 4 );
  DecodeVersion( ver2, verint2 );

  Result := 0; i := 0;
  while ( (Result = 0) and ( i < 4 ) ) do
  begin
  if verint1[i] > verint2[i] then
    Result := 1
  else
      if verint1[i] < verint2[i] then
      Result := -1
    else
      Result := 0;

  i := i + 1;
  end;

end;



const APP_ID = '{' + '{#AppGUID}' + '}';

// Get where the application was installed
function GetPathInstalled( AppID: String ): String;
var
   sPrevPath, sRegKey: String;
begin
  sPrevPath := '';
  sRegKey := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\'+APP_ID+'_is1';
  
  if RegKeyExists(HKEY_LOCAL_MACHINE, sRegKey) then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE, sRegKey, 'Inno Setup: App Path', sPrevpath);
  end
  else if RegKeyExists(HKEY_CURRENT_USER, sRegKey) then
  begin
     RegQueryStringValue(HKEY_CURRENT_USER, sRegKey, 'Inno Setup: App Path', sPrevpath);
  end;
  
  Result := sPrevPath;
end;


const THIS_VERSION = '{#AppVersion}';
const APP_FILE = '{#AppFile}';

var
  // previuos install dir
  PrevDir: String;
  // tell if it's an upgrade
  Upgrade: Boolean;
  // installed program version
  InstalledVer: String;

function InitializeSetup(): Boolean;

var
vercomp, answ : Integer;
msg : String;
begin

  Result := true;

  // read the installtion folder
  PrevDir := GetPathInstalled( '{#SetupSetting("AppID")}' );

  if length( Prevdir ) > 0 then
  begin
    // I found the folder so
    // It's an upgrade
    Upgrade := true;

    // read the version of MyProg.exe already installed
    GetVersionNumbersString(  PrevDir + '\' + APP_FILE, InstalledVer );

    // compare versions
    vercomp := CompareVersion( InstalledVer, THIS_VERSION );
    
    // version smaller
    if vercomp < 0 then
    begin
      // keep Result as true and go on with upgrade
    end;

    // same version ask what to do
    if vercomp = 0 then
    begin
      msg := ExpandConstant('{cm:AlreadyInstalled, {#AppName}, {#AppVersion}}') + #13#13 +
        ExpandConstant('{cm:ConfirmReinstall}');
        answ := MsgBox(msg, mbConfirmation, MB_YESNO )
      // If user answer is NO abort setup
      Result := ( answ = IDYES );
    end;

    // version bigger, cannot upgrade with a smaller version
    if vercomp > 0 then
    begin
      msg := ExpandConstant('{cm:NewVersionFound, {#AppVersion}, {#AppName}}');
      msg := Format(msg, [InstalledVer]);
      msg := msg + #13#13 + ExpandConstant('{cm:AbortInstalation}') + #13#13 +  ExpandConstant('{cm:HowToInstallOldVersion}');
      answ := MsgBox(msg, mbInformation, MB_OK);
      Result := false;
    end;
  end;
end;


function GetPrevDir( s: String ) : String;
begin
  if length( PrevDir ) = 0 then
    Result := s
  else
    Result := PrevDir;
end;



function ShouldSkipPage(PageID: Integer): Boolean;
begin
  // skip selectdir if It's an upgrade
  if (( PageID = wpSelectDir ) or ( PageID = wpSelectProgramGroup ))  and Upgrade then
    Result := true
  else
    Result := false;
end;



procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  RegKeyComp: String;
  RegKeyProg: String;
  RegKeyProgReg: String;
begin
  if (CurUninstallStep = usPostUninstall) then
  begin
    if (MsgBox('Сохранить профили игроков, созданные пазлы и сохраненные игры?',
      mbConfirmation, MB_YESNO or MB_DEFBUTTON1) = IDNO) then
    begin
      DelTree(ExpandConstant('{app}\puzzles'), True, True, True);
      DelTree(ExpandConstant('{app}\players'), True, True, True);
      DelTree(ExpandConstant('{app}\save'), True, True, True);
    end;

    RegKeyComp := 'Software\Mike Samokhvalov';
    RegKeyProg := RegKeyComp + '\Puzzle CLUB';
    RegKeyProgReg := RegKeyProg + '\Registration';

    //if RegKeyExists(HKEY_CURRENT_USER, RegKeyProgReg) then
    if RegKeyExists(HKEY_LOCAL_MACHINE, RegKeyProgReg) then
    begin
      if (MsgBox('Сохранить регистрационные данные?', mbConfirmation, MB_YESNO or MB_DEFBUTTON1) = IDNO) then
      begin
        RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, RegKeyProg);
      end
    end
    else if RegKeyExists(HKEY_CURRENT_USER, RegKeyProgReg) then
    begin
      if (MsgBox('Сохранить регистрационные данные?', mbConfirmation, MB_YESNO or MB_DEFBUTTON1) = IDNO) then
      begin
        RegDeleteKeyIncludingSubkeys(HKEY_CURRENT_USER, RegKeyProg);
      end
    end
    else
    begin
      RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, RegKeyProg);
      RegDeleteKeyIncludingSubkeys(HKEY_CURRENT_USER, RegKeyProg);
    end;

    RegDeleteKeyIfEmpty(HKEY_LOCAL_MACHINE, RegKeyComp);
    RegDeleteKeyIfEmpty(HKEY_CURRENT_USER, RegKeyComp);
  end;
end;

