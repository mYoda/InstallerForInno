#define MyAppPublisher "SaveFrom.net"
#define MyInstName "helpers"
#define VerString "1.4"
#define MyAppURL "http://savefrom.net"
#define MyAppVerName MyAppPublisher + " helper " + VerString

[Setup]
AppName={code:helper}
AppVerName={#MyAppVerName}
AppPublisher={#MyAppPublisher}
VersionInfoVersion=1.4.0.0
VersionInfoProductName={#MyAppVerName}
VersionInfoDescription={#MyAppVerName}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
AllowNoIcons=yes
OutputDir=.\bin
OutputBaseFilename={#MyInstName}_{#VerString}
CreateAppDir=no
SetupIconFile=Graphics\install.ico
WizardSmallImageFile=Graphics\header.bmp

FlatComponentsList=yes
Compression=lzma/max
SolidCompression=yes
AllowCancelDuringInstall=yes
ShowComponentSizes=yes
ShowLanguageDialog=auto
UsePreviousLanguage=no

AppCopyright=All Rights reserved © 2013
UsePreviousTasks=no
DirExistsWarning=no
UsePreviousSetupType=no  

;DisableWelcomePage=yes
DisableReadyMemo=yes
DisableReadyPage=yes
DisableProgramGroupPage=yes

PrivilegesRequired=none
CreateUninstallRegKey=no
UpdateUninstallLogAppName=no
Uninstallable=no
;SignTool=SaveFromNet

[Languages]
Name: russian; MessagesFile: compiler:Languages\Russian.isl
Name: english; MessagesFile: compiler:Default.isl
Name: german;  MessagesFile: compiler:Languages\German.isl
Name: turkish; MessagesFile: localization\installer\Turkish.isl

[CustomMessages]
#include "localization\installer\English.inc"
#include "localization\installer\Russian.inc"  
#include "localization\installer\German.inc" 
#include "localization\installer\Turkish.inc"

[Files]
;Source: "files\helper_opera.oex"; DestDir: "{tmp}"; Flags: dontcopy deleteafterinstall
;Source: "files\wuid-b1f04b44-0bb6-764c-9a1c-65b806959575\*"; DestDir: "{tmp}\wuid-b1f04b44-0bb6-764c-9a1c-65b806959575\"; Flags: dontcopy recursesubdirs createallsubdirs deleteafterinstall
;Source: "files\helper_firefox.xpi"; DestDir: "{tmp}"; Flags: dontcopy deleteafterinstall
;Source: "files\helper_firefox.json"; DestDir: "{tmp}"; Flags: dontcopy deleteafterinstall
;Source: "files\helper_safari.safariextz"; DestDir: "{tmp}"; Flags: dontcopy deleteafterinstall
;Source: "files\helper_chrome.crx"; DestDir: "{tmp}"; Flags: dontcopy deleteafterinstall
;Source: "files\helper_chrome.json"; DestDir: "{tmp}"; Flags: dontcopy deleteafterinstall
;Source: "files\helper_opera_webkit.crx"; DestDir: "{tmp}"; Flags: dontcopy deleteafterinstall
;Source: "files\helper_opera_webkit.json"; DestDir: "{tmp}"; Flags: dontcopy deleteafterinstall

Source: utils\downloader.exe; DestDir: "{tmp}"; Flags: dontcopy deleteafterinstall
Source: utils\7za.exe; DestDir: "{tmp}"; Flags: dontcopy deleteafterinstall
Source: utils\helper.dll; DestDir: {tmp}; Flags: dontcopy deleteafterinstall nocompression
;Source: utils\sqlite3.dll; DestDir: {tmp}; Flags: dontcopy deleteafterinstall 

Source: Graphics\header_bg.bmp; DestDir: {tmp}; Flags: dontcopy deleteafterinstall 
Source: Graphics\final_screen.bmp; DestDir: {tmp}; Flags: dontcopy deleteafterinstall nocompression 
Source: Graphics\yandex_browser_setup_tr.bmp; DestDir: {tmp}; Flags: dontcopy deleteafterinstall nocompression 
Source: Graphics\yandex_browser_setup.bmp; DestDir: {tmp}; Flags: dontcopy deleteafterinstall nocompression 
Source: Graphics\yandex_browser_setup_tr_small.bmp; DestDir: {tmp}; Flags: dontcopy deleteafterinstall nocompression 
Source: Graphics\yandex_browser_setup_small.bmp; DestDir: {tmp}; Flags: dontcopy deleteafterinstall nocompression 

[Code]

//получение id без хрома: http://stackoverflow.com/questions/1882981/google-chrome-alphanumeric-hashes-to-identify-extensions/2050916#2050916
#define ChromeID "mdpljndcmbeikfnlflcggaipgnhiedbl"
#define ChromeExtVer "2.13"
#define FFExtVer "2.14"

#define OperaChromeID "mdpljndcmbeikfnlflcggaipgnhiedbl"
#define OperaChromeExtVer "2.13"

function helper(Param: String): String;
begin
  Result := CustomMessage('MyAppName');
end;

const
  CountryParam = '/X-Client-Country';
  VIDParam     = '/VID';

 var
   VID: string;

function YandexEnabled: Boolean;
var
  I: Integer;
  sCountryCode: string;
begin
  sCountryCode := '';
  for I := 0 to ParamCount - 1 do
  if CompareText(ParamStr(I), CountryParam) = 0 then
  begin
    sCountryCode := LowerCase(ParamStr(I + 1));
    Break;
  end;

  if (sCountryCode = '') or (sCountryCode = 'n\a') then 
    Result := (ActiveLanguage = 'russian') or (ActiveLanguage = 'turkish')
  else
    //показывать для: Российской Федерация, Украина, Белоруссия, Азербайджан, Армения, Киргизия, Казахстан, Молдавия, Таджикистан, Туркменистан, Узбекистан, Грузия, Латвия, Эстония, Литва) и в Турции
    Result := (sCountryCode = 'ru') or (sCountryCode = 'ua') or (sCountryCode = 'by') or (sCountryCode = 'az') or (sCountryCode = 'am') or
              (sCountryCode = 'kg') or (sCountryCode = 'kz') or (sCountryCode = 'md') or (sCountryCode = 'tj') or (sCountryCode = 'tm') or 
              (sCountryCode = 'uz') or (sCountryCode = 'ge') or (sCountryCode = 'lv') or (sCountryCode = 'ee') or (sCountryCode = 'lt') or
              (sCountryCode = 'tr');
end;

procedure GetBrowsers(var OperaExists, FirefoxExists, ChromeExists, YawserExists, MailRuExists, SafariExists, OperaWebKitExists: Boolean; JustRunning: Boolean); external 'GetBrowsers@files:helper.dll stdcall loadwithalteredsearchpath delayload';
procedure fOperaProfilePath(var s: string);  external 'OperaProfilePath@files:helper.dll stdcall loadwithalteredsearchpath delayload';
procedure fOperaWebKitProfilePath(var s: string);  external 'OperaWebKitProfilePath@files:helper.dll stdcall loadwithalteredsearchpath delayload';
procedure fFFProfilePath(var s: string);     external 'FFProfilePath@files:helper.dll stdcall loadwithalteredsearchpath delayload';
procedure fChromeProfilePath(var s: string); external 'ChromeProfilePath@files:helper.dll stdcall loadwithalteredsearchpath delayload';
procedure fYawserProfilePath(var s: string); external 'YawserProfilePath@files:helper.dll stdcall loadwithalteredsearchpath delayload';
procedure fMawserProfilePath(var s: string); external 'MawserProfilePath@files:helper.dll stdcall loadwithalteredsearchpath delayload';
function  WaitForYawser: Boolean; external 'WaitForYawser@files:helper.dll stdcall loadwithalteredsearchpath delayload';
procedure LaunchYawser; external 'LaunchYawser@files:helper.dll stdcall loadwithalteredsearchpath delayload';
procedure fSafariProfilePath(var s: string); external 'SafariProfilePath@files:helper.dll stdcall loadwithalteredsearchpath delayload';
procedure fSafariUtilPath(var s: string); external 'SafariConvertUtilPath@files:helper.dll stdcall loadwithalteredsearchpath delayload';
procedure ClearStr(var s: string); external 'ClearStr@files:helper.dll stdcall loadwithalteredsearchpath delayload';

type
  TBrowser = (brOpera, brOperaWebKit, brFF, brChrome, brYawser, brMawser, brSafari, brSafariUtil);

function  GetBrowserProfilePath(br: TBrowser): string;
var
  sTemp: string;
begin
  sTemp := '';
  try
    case br of
      brOpera:  fOperaProfilePath(sTemp);
      //experimental
      brOperaWebKit: fOperaWebKitProfilePath(sTemp);

      brFF:     fFFProfilePath(sTemp);
      brChrome: fChromeProfilePath(sTemp);
      brYawser: fYawserProfilePath(sTemp);
      brMawser: fMawserProfilePath(sTemp);
      brSafari: fSafariProfilePath(sTemp);
      brSafariUtil: fSafariUtilPath(sTemp);
    end;
  finally
    Result := Copy(sTemp, 1, Length(sTemp));
    ClearStr(sTemp);
    sTemp := '';
  end
end;

var
  InvitePage, YawserPage: TWizardPage;  
  FullInstall, UserInstall: TRadioButton;  
  clbOptions, clbYawserOptions: TNewCheckListBox;
  YaRTF, YaAgree: TRichEditViewer; 
  YaPicture: TBitmapImage;

  OperaExists, OperaChecked,
  OperaWKExists, OperaWKChecked,
  FirefoxExists, FirefoxChecked,
  ChromeExists, ChromeChecked,
  YawserExists, YawserChecked,
  MailRuExists, MailRuChecked,
  SafariExists, SafariChecked: Boolean;

  OperaProfilePath, OperaWKProfilePath, FFProfilePath, ChromeProfilePath, YawserProfilePath, MawserProfilePath, SafariProfilePath, SafariUtilPath: string;

  OperaIdx, OperaWKIdx, FFIdx, ChromeIdx, YaIdx, MIdx, SafariIdx: Integer;

procedure RbClick(Sender: TObject);
begin
  clbOptions.Enabled := UserInstall.Checked;
  if not UserInstall.Checked then
    clbOptions.Checked[0] := True;

  if clbOptions.Checked[0] then
  begin
    clbOptions.Checked[clbOptions.Items.Count - 3] := True; 
    clbOptions.Checked[clbOptions.Items.Count - 2] := True; 
    clbOptions.Checked[clbOptions.Items.Count - 1] := True;
  end;
end;

function GetCursorPos(var lpPoint: TPoint): BOOL; external 'GetCursorPos@user32.dll stdcall';
function ClientToScreen(hWnd: HWND; var lpPoint: TPoint): BOOL; external 'ClientToScreen@user32.dll stdcall';

procedure CheckClick(Sender: TObject);
var
  cp, pt2: TPoint;
  InstallElements, MakeHomePage, InstallSearch: Boolean; 
begin
  if not clbOptions.Checked[0] and (OperaExists or FirefoxExists or ChromeExists or YawserExists or OperaWKExists or SafariExists) then
  begin
    if not GetCursorPos(cp) then Exit;
    pt2.X := clbOptions.Left;
    pt2.X := clbOptions.Top; 
    if not ClientToScreen(clbOptions.Handle, pt2) then Exit;

    if cp.Y > pt2.Y + clbOptions.MinItemHeight then Exit; //working on first check only
    if clbOptions.Items.Count > 4 then Exit;           
    
    InstallElements := clbOptions.Checked[clbOptions.Items.Count - 3]; 
    MakeHomePage    := clbOptions.Checked[clbOptions.Items.Count - 2]; 
    InstallSearch   := clbOptions.Checked[clbOptions.Items.Count - 1];
     
    clbOptions.Items.Clear; 
    
    with clbOptions do
    begin 
      AddCheckBox(ExpandConstant('{cm:InstallToAllBrowsers}'), '', 0, False, True, True, False, nil);
      if OperaExists then
        OperaIdx := AddCheckBox('Opera', '', 1, OperaChecked, True, False, True, nil);
      if OperaWKExists then
        OperaWKIdx := AddCheckBox('Opera WebKit', '', 1, OperaWKChecked, True, False, True, nil);
      if FirefoxExists then
        FFIdx := AddCheckBox('Firefox', '', 1, FirefoxChecked, True, False, True, nil);
      if ChromeExists then
        ChromeIdx := AddCheckBox('Chrome', '', 1, ChromeChecked, True, False, True, nil);
      if YawserExists then
        YaIdx := AddCheckBox(ExpandConstant('{cm:Yawser}'), '', 1, YawserChecked, True, False, True, nil);
      if MailRuExists then
        MIdx := AddCheckBox(ExpandConstant('{cm:MailRu}'), '', 1, MailRuChecked, True, False, True, nil);
      if SafariExists then
        SafariIdx := AddCheckBox('Safari', '', 1, SafariChecked, True, False, True, nil);
          
      AddCheckBox(ExpandConstant('{cm:ParamDlInstall}'), '', 0, InstallElements, True, False, False, nil);
      AddCheckBox(ExpandConstant('{cm:ParamHomePage}'), '', 0, MakeHomePage, True, False, False, nil);
      AddCheckBox(ExpandConstant('{cm:ParamPrefs}'), '', 0, InstallSearch, True, False, False, nil);  
    end;
  end;
end;

procedure YawserCheckClick(Sender: TObject);
begin
  clbYawserOptions.ItemEnabled[1] := clbYawserOptions.Checked[0];
end;
      
function EncodedText(x: String): WideString;
 var
   b: string;
   i: Integer;
 begin
   b := x;
   Result:='';
   for i := 1 to Length(b) do  
     Result := Result + '\u' + Inttostr(Word(Ord(b[i]))) + '?';
end;

procedure CreateBrowsersDownloadPage;
var
  h: Integer;
begin
  InvitePage := CreateCustomPage(wpSelectDir, ExpandConstant('{cm:HeaderText}'), ExpandConstant('{cm:HeaderDescr}'));                                                                              

  if YandexEnabled then
  begin
    FullInstall := TRadioButton.Create(InvitePage);
    with FullInstall do
    begin
      Parent := InvitePage.Surface;
      Caption := ExpandConstant('{cm:FullInstall}');
      Left := ScaleX(28);
      Top := ScaleY(17);
      Width := ScaleX(204);
      Height := ScaleY(17);
      h := Top + Height;
      Checked := True;
      TabOrder := 1;
      TabStop := True;
      OnClick := @RbClick;
    end;

    with TNewStaticText.Create(InvitePage) do
    begin
      Left     := ScaleX(50);
      Top      := h;
      Width    := InvitePage.SurfaceWidth;
      Caption  := ExpandConstant('{cm:FullDescr}');

      AutoSize := True;
      WordWrap := True;
      Parent   := InvitePage.Surface;

      h := Top + Height;
    end;

    UserInstall := TRadioButton.Create(InvitePage);
    with UserInstall do
    begin
      Parent := InvitePage.Surface;
      Caption := ExpandConstant('{cm:ParamInstall}');
      Left := ScaleX(28);
      Top := h + ScaleY(8);
      Width := InvitePage.SurfaceWidth;
      Height := ScaleY(17);
      h := Top + Height;
      TabStop := True;
      OnClick := @RbClick;
    end;
  end;

  clbOptions := TNewCheckListBox.Create(InvitePage);
  with clbOptions do
  begin
    if YandexEnabled then  
      OnClickCheck := @CheckClick;
    Enabled := not YandexEnabled;
    Top := h + ScaleY(5);   
    if YandexEnabled then  
      Left := ScaleX(47)
    else
      Left := ScaleX(20);
    Width := InvitePage.SurfaceWidth - Left;
    Height := ScaleY(110);
    if not YandexEnabled then
      Height := Height + ScaleY(105);
    BorderStyle := bsNone;
    ParentColor := True;
    MinItemHeight := WizardForm.TasksList.MinItemHeight;
    ShowLines := False;
    WantTabs := True;
    Parent := InvitePage.Surface;
    
    if YandexEnabled then
    begin
      AddCheckBox(ExpandConstant('{cm:InstallToAllBrowsers}'), '', 0, True, True, False, False, nil);
      AddCheckBox(ExpandConstant('{cm:ParamDlInstall}'), '', 0, True, True, False, False, nil);
      AddCheckBox(ExpandConstant('{cm:ParamHomePage}'), '', 0, True, True, False, False, nil);
      AddCheckBox(ExpandConstant('{cm:ParamPrefs}'), '', 0, True, True, False, False, nil);    
    end;      
  end;

  if YandexEnabled then
  begin
    with TBevel.Create(InvitePage) do
    begin
      Parent   := InvitePage.Surface;
      Top := ScaleY(204);
      Left := 0;
      Shape := bsTopLine;
      Width := InvitePage.SurfaceWidth;
      h := Top + ScaleY(5);
    end;

    
    with TRichEditViewer.Create(InvitePage) do
    begin
      Left     := ScaleX(0);
      Top      := h;
      Width  := InvitePage.SurfaceWidth;
      Height := ScaleY(40);
      Parent := InvitePage.Surface;
      ScrollBars := ssNone;
      Color := clBtnFace;
      BorderStyle := bsNone;
      UseRichEdit := True;     
      TabStop := False;
      RTFText := '{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fnil\fcharset0 Tahoma;}}' + #13#10 +
                 '{\colortbl ;\red0\green0\blue255;\red0\green0\blue128;}' + #13#10 +
                 '\viewkind4\uc1\pard\nowidctlpar\lang1033\kerning1\f0\fs16' + EncodedText(ExpandConstant('{cm:byinstalling}')) + 
                 ' {\field{\*\fldinst{HYPERLINK "' + ExpandConstant('{cm:LicAgreeLink}') + '" }}{\fldrslt{\cf2\ul' + EncodedText(ExpandConstant('{cm:urlagree}')) + '}}}' + 
                 EncodedText(ExpandConstant('{cm:agree_end}')) + 
                 '\cf0\ulnone\f0\fs16\par' + #13#10 +
                 '}';
      ReadOnly := True;
    end;
  end;
end;

const
  YawserAdsRTFFmt = '{\rtf1\ansi\ansicpg1251\deff0\deflang1049{\fonttbl{\f0\fnil\fcharset0 Tahoma;}{\f1\fnil\fcharset2 Symbol;}}' +
                    '{\colortbl ;\red0\green0\blue0;}' +
                    '\viewkind4\uc1\pard\cf1\lang1033\b\f0\fs16%1 \b0%2 \par' + #13#10 +
                    '\par' +
                    '\pard{\pntext\f1\''B7\tab}{\*\pn\pnlvlblt\pnf1\pnindent0{\pntxtb\''B7}}\li57\sa44\sl240\slmult1  %3 \par' +
                    '{\pntext\f1\''B7\tab} %4 \par' +
                    '{\pntext\f1\''B7\tab} %5 \par' +
                    '{\pntext\f1\''B7\tab} %6 \par' +
                    '{\pntext\f1\''B7\tab} %7 \par' +
                    '\pard{\pntext\f1\''B7\tab}{\*\pn\pnlvlblt\pnf1\pnindent0{\pntxtb\''B7}}\li57\sl240\slmult1  %8 \cf0\lang9\fs16\par' +
                    '}';

procedure MakeYawserPage;
var
  h: Integer;
begin
  if not YandexEnabled then Exit;

  YawserPage := CreateCustomPage(InvitePage.ID, ExpandConstant('{cm:HeaderText}'), ExpandConstant('{cm:HeaderDescr}'));

  YaPicture := TBitmapImage.Create(YawserPage);
  with YaPicture do
  begin
    Align  := alLeft;
    Width  := ScaleX(120);
    Parent := YawserPage.Surface;
    if ActiveLanguage = 'turkish' then
      Bitmap.LoadFromFile(ExpandConstant('{tmp}\yandex_browser_setup_tr_small.bmp'));  
    if ActiveLanguage = 'russian' then
      Bitmap.LoadFromFile(ExpandConstant('{tmp}\yandex_browser_setup_small.bmp'));  
  end;

  YaRTF := TRichEditViewer.Create(YawserPage);
  with YaRTF do
  begin
    Left   := YaPicture.Left + YaPicture.Width + ScaleX(5);
    Top    := 0;
    Width  := YawserPage.SurfaceWidth - Left;
    Height := ScaleY(165);
    Parent := YawserPage.Surface;
    ScrollBars := ssNone;
    Color := YawserPage.Surface.Color;
    BorderStyle := bsNone;
    UseRichEdit := True;   
    TabStop := False;  
    RTFText := FmtMessage(YawserAdsRTFFmt, [EncodedText(ExpandConstant('{cm:Yawser}')), 
                                            EncodedText(ExpandConstant('{cm:YawserDescr}')),
                                            EncodedText(ExpandConstant('{cm:YawserOption1}')),
                                            EncodedText(ExpandConstant('{cm:YawserOption2}')),
                                            EncodedText(ExpandConstant('{cm:YawserOption3}')),
                                            EncodedText(ExpandConstant('{cm:YawserOption4}')),
                                            EncodedText(ExpandConstant('{cm:YawserOption5}')),
                                            EncodedText(ExpandConstant('{cm:YawserOption6}'))]);
    ReadOnly := True;
    Enabled := False;
    h := Height;
  end;

  clbYawserOptions := TNewCheckListBox.Create(YawserPage);
  with clbYawserOptions do
  begin
    Top := h + ScaleY(5);
    Left := YaPicture.Left + YaPicture.Width + ScaleX(5);
    Width := YawserPage.SurfaceWidth - Left;
    Height := ScaleY(70);
    BorderStyle := bsNone;
    ParentColor := True;
    MinItemHeight := WizardForm.TasksList.MinItemHeight;
    ShowLines := False;
    WantTabs := True;
    Parent := YawserPage.Surface;
    AddCheckBox(ExpandConstant('{cm:YawserDLInstall}'), '', 0, True, True, False, False, nil);
    AddCheckBox(ExpandConstant('{cm:YawserParticipate}'), '', 0, True, True, False, False, nil);
    OnClickCheck := @YawserCheckClick;
  end;

  YaAgree := TRichEditViewer.Create(YawserPage);
  with YaAgree do
  begin
    Height := ScaleY(40);
    Top    := WizardForm.Bevel.Top + (WizardForm.CancelButton.Top - WizardForm.Bevel.Top) div 2 + ScaleY(2);
    Left   := WizardForm.ClientWidth - WizardForm.CancelButton.Left - WizardForm.CancelButton.Width + ScaleX(10);
    Width  := WizardForm.NextButton.Left - Left;
    Parent := WizardForm;
    ScrollBars := ssNone; 
    ParentColor := True;
    BorderStyle := bsNone;
    UseRichEdit := True;  
    TabStop := False;   
    RTFText := '{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fnil\fcharset0 Tahoma;}}' + #13#10 +
               '{\colortbl ;\red0\green0\blue255;\red0\green0\blue128;}' + #13#10 +
               '\viewkind4\uc1\pard\nowidctlpar\lang1033\kerning1\f0\fs16' + EncodedText(ExpandConstant('{cm:YawserByInstalling}')) + 
               ' {\field{\*\fldinst{HYPERLINK "' + ExpandConstant('{cm:BrowserAgreement}') + '" }}{\fldrslt{\cf2\ul' + EncodedText(ExpandConstant('{cm:YawserEULA}')) + '}}}\cf0\ulnone\f0\fs16\par' + #13#10 +
               '}';
    ReadOnly := True;
  end;
end;

var
  YaLaunched: Boolean;

procedure ShowSuccess;
begin
  WizardForm.WizardBitmapImage2.Bitmap.LoadFromFile(ExpandConstant('{tmp}\final_screen.bmp'));
  WizardForm.WizardBitmapImage2.Stretch := False;
  WizardForm.WizardBitmapImage2.Width   := WizardForm.MainPanel.Width;
  WizardForm.WizardBitmapImage2.Height  := 180;
  WizardForm.WizardBitmapImage2.Top     := 133;

  WizardForm.NextButton.Enabled := True;
  WizardForm.FinishedHeadingLabel.Visible := False;
  WizardForm.FinishedLabel.Visible := False;

  with TLabel.Create(WizardForm) do
  begin
    AutoSize := False;
    WordWrap := True;
    Caption  := ExpandConstant('{cm:InstallSuccess}');
    Parent   := PageFromID(wpFinished).Surface;
    Left     := ScaleX(106);
    Top      := WizardForm.FinishedHeadingLabel.Top;
    Width    := WizardForm.FinishedHeadingLabel.Width;
    Height   := WizardForm.FinishedHeadingLabel.Height;
    Font.Assign(WizardForm.FinishedHeadingLabel.Font);
    BringToFront;
  end;
  
  WizardForm.WizardSmallBitmapImage.Visible := True;
  WizardForm.WizardSmallBitmapImage.Parent  := PageFromID(wpFinished).Surface;
  WizardForm.WizardSmallBitmapImage.Left    := 21;
  WizardForm.WizardSmallBitmapImage.Top     := WizardForm.FinishedHeadingLabel.Top;
  WizardForm.WizardSmallBitmapImage.Width   := 64;
  WizardForm.WizardSmallBitmapImage.Height  := 64;
  WizardForm.WizardSmallBitmapImage.Stretch := True;

  with TLabel.Create(WizardForm) do
  begin
    AutoSize := False;
    WordWrap := True;
    Caption  := ExpandConstant('{cm:RestartBrowsers}');
    Parent   := PageFromID(wpFinished).Surface;
    Left     := ScaleX(106);
    Top      := ScaleY(50);
    Width    := PageFromID(wpFinished).SurfaceWidth - Left;
    Height   := 60;
    Font.Size := 9;
    BringToFront;
  end;

  with TRichEditViewer.Create(WizardForm.MainPanel) do
  begin
    Left   := ScaleX(21);
    Top    := ScaleY(106);
    Width  := PageFromID(wpFinished).SurfaceWidth - Left;
    Height := ScaleY(16);
    Parent := PageFromID(wpFinished).Surface;
    ScrollBars := ssNone; 
    ParentColor := True;
    BorderStyle := bsNone;
    UseRichEdit := True;  
    TabStop := False;
    RTFText := '{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fnil\fcharset0 Tahoma;}}' + #13#10 +
               '{\colortbl ;\red0\green0\blue255;\red0\green0\blue128;}' + #13#10 +
               '\viewkind4\uc1\pard\nowidctlpar\lang1033\kerning1\f0\fs18' + EncodedText(ExpandConstant('{cm:SuccessText}')) + 
               ' {\field{\*\fldinst{HYPERLINK "http://ru.savefrom.net/user.php" }}{\fldrslt{\cf2\ul' + EncodedText(ExpandConstant('{cm:SuccessLink}')) + '}}}.\cf0\ulnone\f0\fs18\par' + #13#10 +
               '}';
    ReadOnly := True;
  end;
  WizardForm.WizardBitmapImage2.BringToFront;
  WizardForm.Refresh;
end;

procedure InitializeWizard();
var
  I: Integer;
begin 
  ExtractTemporaryFile('final_screen.bmp');
  CreateBrowsersDownloadPage;
  WizardForm.FinishedHeadingLabel.Visible := False;
  WizardForm.FinishedLabel.Visible := False;

  WizardForm.WizardSmallBitmapImage.Visible := False;
  ExtractTemporaryFile('header_bg.bmp');
  
  with TBitmapImage.Create(WizardForm.MainPanel) do
  begin
    Parent := WizardForm.MainPanel;
    Align := alClient;
    Stretch := True;
    Bitmap.LoadFromFile(ExpandConstant('{tmp}\header_bg.bmp')); 
    SendToBack;
  end;

  if ActiveLanguage = 'turkish' then
  begin
    ExtractTemporaryFile('yandex_browser_setup_tr_small.bmp');
    ExtractTemporaryFile('yandex_browser_setup_tr.bmp');
    WizardForm.WizardBitmapImage2.Bitmap.LoadFromFile(ExpandConstant('{tmp}\yandex_browser_setup_tr.bmp'));  
  end;
  if ActiveLanguage = 'russian' then
  begin
    ExtractTemporaryFile('yandex_browser_setup_small.bmp');
    ExtractTemporaryFile('yandex_browser_setup.bmp');
    WizardForm.WizardBitmapImage2.Bitmap.LoadFromFile(ExpandConstant('{tmp}\yandex_browser_setup.bmp'));  
  end;

  WizardForm.PageNameLabel.Visible := False;
  WizardForm.PageDescriptionLabel.Visible := False;    
  
  OperaIdx  := -1;
  FFIdx     := -1;
  ChromeIdx := -1;
  YaIdx     := -1;
  MIdx      := -1;
  SafariIdx := -1;

  OperaExists   := False;
  FirefoxExists := False;
  ChromeExists  := False;
  YawserExists  := False;
  MailRuExists  := False;
  SafariExists  := False;
  
  GetBrowsers(OperaExists, FirefoxExists, ChromeExists, YawserExists, MailRuExists, SafariExists, OperaWKExists, False);
  OperaChecked   := OperaExists;
  OperaWKChecked := OperaWKExists;
  FirefoxChecked := FirefoxExists;
  ChromeChecked  := ChromeExists;
  YawserChecked  := YawserExists;
  MailRuChecked  := MailRuExists;
  SafariChecked  := SafariExists;

  OperaProfilePath  := GetBrowserProfilePath(brOpera);
  OperaWKProfilePath:= GetBrowserProfilePath(brOperaWebKit); 
  FFProfilePath     := GetBrowserProfilePath(brFF);
  ChromeProfilePath := GetBrowserProfilePath(brChrome);
  YawserProfilePath := GetBrowserProfilePath(brYawser);
  MawserProfilePath := GetBrowserProfilePath(brMawser);
  SafariProfilePath := GetBrowserProfilePath(brSafari);
  SafariUtilPath    := GetBrowserProfilePath(brSafariUtil);

  if SafariUtilPath = '' then
  begin
    Log('no plutil found');
    SafariProfilePath := '';
    SafariExists := False;
  end;

  if OperaExists   then Log('OperaExists');
  if OperaWKExists then  Log('Opera WebKit Exists');
  if FirefoxExists then Log('FirefoxExists');
  if ChromeExists  then Log('ChromeExists');
  if YawserExists  then Log('YawserExists');
  if MailRuExists  then Log('MailRuExists'); 
  if SafariExists  then Log('SafariExists');

  Log('Opera profile path: '  + OperaProfilePath);
  Log('FF profile path: '     + FFProfilePath);
  Log('Chrome profile path: ' + ChromeProfilePath);
  Log('Yawser profile path: ' + YawserProfilePath);
  Log('Mawser profile path: ' + MawserProfilePath);   
  Log('Safari profile path: ' + SafariProfilePath);
  Log('Opera WebKit profile path: ' + OperaWKProfilePath);
  
  YaLaunched := False;
    
  if YawserExists then 
    ShowSuccess
  else
    MakeYawserPage;

  if not YandexEnabled then
  with clbOptions do
  begin      
    AddCheckBox(ExpandConstant('{cm:InstallToAllBrowsers}'), '', 0, True, True, False, True, nil);
    if OperaExists then
      OperaIdx := AddCheckBox('Opera', '', 1, OperaChecked, True, False, True, nil);
    if OperaWKExists then
      OperaWKIdx := AddCheckBox('Opera WebKit', '', 1, OperaWKChecked, True, False, True, nil);
    if FirefoxExists then
      FFIdx := AddCheckBox('Firefox', '', 1, FirefoxChecked, True, False, True, nil);
    if ChromeExists then
      ChromeIdx := AddCheckBox('Chrome', '', 1, ChromeChecked, True, False, True, nil);
    if YawserExists then
      YaIdx := AddCheckBox(ExpandConstant('{cm:Yawser}'), '', 1, YawserChecked, True, False, True, nil);
    if MailRuExists then
      MIdx := AddCheckBox(ExpandConstant('{cm:MailRu}'), '', 1, MailRuChecked, True, False, True, nil);
    if SafariExists then
      SafariIdx := AddCheckBox('Safari', '', 1, SafariChecked, True, False, True, nil); 
  end;

  VID := '';
  for I := 0 to ParamCount - 1 do
  if CompareText(ParamStr(I), VIDParam) = 0 then
  begin
    VID := LowerCase(ParamStr(I + 1));
    Break;
  end;
  Log('VID=' + VID);
end;

const
  ExtGuid     = 'wuid-b1f04b44-0bb6-764c-9a1c-65b806959575';
  OperaConfig = '  <section id="' + ExtGuid + '">' + #13#10 +
                '    <value id="path to widget data" xml:space="preserve">{SmallPreferences}widgets/savefrom.net.oex</value>' + #13#10 +
                '    <value id="download_URL" null="yes"/>' + #13#10 +
                '    <value id="content-type" xml:space="preserve">3</value>' + #13#10 +
                '    <value id="class state" xml:space="preserve">enabled</value>' + #13#10 +
                '  </section>';
  OperaADConfig = '  <section id="' + ExtGuid + '">' + #13#10 +
                  '    <value id="path to widget data" xml:space="preserve">{LargePreferences}widgets/savefrom.net.oex</value>' + #13#10 +
                  '    <value id="download_URL" null="yes"/>' + #13#10 +
                  '    <value id="content-type" xml:space="preserve">3</value>' + #13#10 +
                  '    <value id="class state" xml:space="preserve">enabled</value>' + #13#10 +
                  '  </section>';

function ContainsText(FileName, Text: string): Boolean;
var
  Strs: TArrayOfString;
  I: Integer;
begin
  Result := FileExists(FileName);
  if not Result then Exit;
  
  Result := LoadStringsFromFile(FileName, Strs);
  if not Result then Exit;

  Result := False;
  for I := 0 to GetArrayLength(Strs) - 1 do
  if (Pos(Text, Strs[I]) > 0) then
  begin
    Result := True;
    Exit;
  end;
end;

procedure InstallToOpera;
var
  WidgetsDat: TStringList;
  I, J: Integer;
  wuid, replace_str, replace_text: string;
  bFound: Boolean; 
  OperaRunning, Foo: Boolean;
  AskCount: Integer;
begin
  if OperaProfilePath = '' then
    OperaProfilePath := GetBrowserProfilePath(brOpera);
  if OperaProfilePath = '' then Exit;

  Log('installing to opera');

  AskCount := 0;
  repeat
    GetBrowsers(OperaRunning, Foo, Foo, Foo, Foo, Foo, Foo, True);

    if OperaRunning then
    begin
      Log('opera is running, ask user');
      if MsgBox(FmtMessage(ExpandConstant('{cm:PleaseClose}'), ['Opera']), mbInformation, MB_OKCANCEL) = IDCANCEL then
        Exit
      else
        Sleep(3000);
    end
    else
      Break;

    OperaRunning := False;
    Inc(AskCount);
  until AskCount > 3;

  if AskCount >= 3 then Exit;
  
  //patch config
  WidgetsDat := TStringList.Create;
  try
    ForceDirectories(OperaProfilePath + 'widgets');
    if FileExists(OperaProfilePath + 'widgets\widgets.dat') then
    begin
      WidgetsDat.LoadFromFile(OperaProfilePath + 'widgets\widgets.dat');
      Log('widgets.dat exist');
    end;    
    
    if WidgetsDat.Count > 0 then
    begin   
      bFound := False;
      //ищем, есть ли уже установленное но с другим guid
      for I := 0 to WidgetsDat.Count - 1 do
      if Pos('  <section id="wuid-', WidgetsDat[I]) = 1 then
      begin
        wuid := Trim(WidgetsDat[I]);
        Delete(wuid, 1, 13); 
        StringChangeEx(wuid, '">', '', True);

        //проверяем, не наше ли это расширение
        if ContainsText(OperaProfilePath + 'widgets\' + wuid + '\prefs.dat', ExpandConstant('{#MyAppPublisher}')) then
        begin
          bFound := True;
          replace_str := WidgetsDat[I] + #13#10;
          for J := I + 1 to WidgetsDat.Count - 1 do 
          begin
            replace_str := replace_str + WidgetsDat[J] + #13#10;
            if Pos('</section>', WidgetsDat[J]) > 0 then Break;
          end;
        end;

        //нашли нужный wuid, нужно заменить секцию на пустую, ибо свою мы уже вписали в конец           
        if bFound then
        begin
          Log('widget record already exist, replace with the new one');
          replace_text := WidgetsDat.Text;
          StringChangeEx(replace_text, replace_str, '', True);
          WidgetsDat.Text := replace_text;
          Break;
        end;
     end;//for
     
     Log('adding new record');
     WidgetsDat.Delete(WidgetsDat.Count - 1);//delete </preferences>
     if Pos('\profile\', OperaProfilePath) > 0 then
       WidgetsDat.Add(OperaConfig)
     else
       WidgetsDat.Add(OperaADConfig);
       
     WidgetsDat.Add('</preferences>');            
    end//WidgetsDat.Count > 0
    else
      begin
        Log('creating new widgets.dat');
        WidgetsDat.Add('<?xml version="1.0" encoding="utf-8"?>');
        WidgetsDat.Add('<preferences>');
        WidgetsDat.Add('  <section id="widgets">');
        WidgetsDat.Add('  <value id="version" xml:space="preserve">1</value>');
        WidgetsDat.Add('  </section>');
        if Pos('\profile\', OperaProfilePath) > 0 then
          WidgetsDat.Add(OperaConfig)
        else
          WidgetsDat.Add(OperaADConfig);
        WidgetsDat.Add('</preferences>');
      end;

    Log('extracting files');

    //now make directories and copy files
    ExtractTemporaryFile('00000000');
    ExtractTemporaryFile('psindex.dat');
    ExtractTemporaryFile('prefs.dat');
    ForceDirectories(OperaProfilePath + 'widgets\' + ExtGuid + '\pstorage\03\07\');
    ForceDirectories(OperaProfilePath + 'widgets\' + ExtGuid + '\cache');
    FileCopy(ExpandConstant('{tmp}\00000000'), OperaProfilePath + 'widgets\' + ExtGuid + '\pstorage\03\07\00000000', False);
    FileCopy(ExpandConstant('{tmp}\psindex.dat'), OperaProfilePath + 'widgets\' + ExtGuid + '\pstorage\psindex.dat', False);
    FileCopy(ExpandConstant('{tmp}\prefs.dat'), OperaProfilePath + 'widgets\' + ExtGuid + '\prefs.dat', False);


    ExtractTemporaryFile('helper_opera.oex');
    if not DeleteFile(OperaProfilePath + 'widgets\savefrom.net.oex') then DeleteFile(OperaProfilePath + 'widgets\savefrom.net.oex');
    if not FileCopy(ExpandConstant('{tmp}\helper_opera.oex'), OperaProfilePath + 'widgets\savefrom.net.oex', False) then Exit;

    Log('saving file');
    WidgetsDat.SaveToFile(OperaProfilePath + 'widgets\widgets.dat');
  finally
    WidgetsDat.Free;
  end;    
end;

procedure InstallToFF;
begin  
  if FFProfilePath = '' then
    FFProfilePath := GetBrowserProfilePath(brFF);
  if FFProfilePath = '' then Exit;

  Log('installing to firefox');

  Log('extracting firefox extension');
  ExtractTemporaryFile('helper_firefox.xpi');
  ExtractTemporaryFile('helper_firefox.json');
  ForceDirectories(FFProfilePath + 'extensions\staged\');  
  if not RemoveDir(FFProfilePath + 'extensions\staged\helper@savefrom.net') then RemoveDir(FFProfilePath + 'extensions\staged\helper@savefrom.net');
  FileCopy(ExpandConstant('{tmp}\helper_firefox.xpi'), FFProfilePath + 'extensions\staged\helper@savefrom.net.xpi', False);
  FileCopy(ExpandConstant('{tmp}\helper_firefox.json'), FFProfilePath + 'extensions\staged\helper@savefrom.net.json', False);
end;

procedure InstallChromeExtenstion(ToPath: string; UseOperaExt: Boolean);
var
  ErrorCode, I, J, K, L, DelIdx: Integer;
  prefs_json_str: AnsiString;
  del_json_text, realText: string;
  Json: TStringList;
  bEndFound, bExtFound: Boolean;
  sChromeID, sChromeIDExt, extName, config: string;
  
begin
  if ToPath = '' then Exit;  

  extName      := 'helper_chrome.crx';
  config       := 'helper_chrome.json';
  sChromeID    := ExpandConstant('{#ChromeID}');
  sChromeIDExt := ExpandConstant('{#ChromeID}\{#ChromeExtVer}_0');
  if UseOperaExt then
  begin
    extName      := 'helper_opera_webkit.crx';
    config       := 'helper_opera_webkit.json';
    sChromeID    := ExpandConstant('{#OperaChromeID}');
    sChromeIDExt := ExpandConstant('{#OperaChromeID}\{#OperaChromeExtVer}_0');
  end; 

  Log('extracting extention to ' + ToPath + 'extensions\' + sChromeIDExt);
  ForceDirectories(ToPath + 'extensions\' + sChromeIDExt);
  
  ExtractTemporaryFile(extName);
  ExtractTemporaryFile('7za.exe');
  if not Exec(ExpandConstant('{tmp}\7za.exe'), ExpandConstant('x -r -y -o"' + ToPath + '\Extensions\' + sChromeIDExt + '" {tmp}\' + extName), '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) then
    if not ExecAsOriginalUser(ExpandConstant('{tmp}\7za.exe'), ExpandConstant('x -r -y -o"' + ToPath + '\Extensions\' + sChromeIDExt + '" {tmp}\' + extName), '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) then 
    begin
      Log('couldn''t launch 7za');
      Exit;
    end;

  ExtractTemporaryFile(config);
  if not LoadStringFromFile(ExpandConstant('{tmp}\' + config), prefs_json_str) then Exit;
  
  if not FileExists(ExpandConstant(ToPath + 'Preferences')) then Exit;

  Log('chrome profile prefs found, start patching');

  Json := TStringList.Create;
  try
    Json.LoadFromFile(ExpandConstant(ToPath + 'Preferences'));
    if Json.Count = 0 then Exit;

    bExtFound := False;
    for I := 0 to Json.Count - 1 do
    if Json[I] = '   "extensions": {' then
    begin
      bExtFound := True;
      Log('extensions object found, searching for place to patch');
      for J := I to Json.Count - 1 do
      if Json[J] = '      "settings": {' then
      begin
        //search for already added ext id
        for K := J + 1 to Json.Count - 1 do
        if Pos('"' + sChromeID + '":', Json[K]) > 0 then
        begin
          del_json_text := Json[K] + #13#10;
          bEndFound := False;
          DelIdx := -1;
          for L := K + 1 to Json.Count - 1 do
          begin          
            del_json_text := del_json_text + Json[L] + #13#10;  
            if Pos('"path": "' + sChromeID, Json[L]) > 0 then bEndFound := True;
            if bEndFound and (Pos('}', Json[L]) > 0) then
            begin
              DelIdx := L;
              if (Pos('},', Json[L]) = 0) then 
                Delete(prefs_json_str, Length(prefs_json_str), 1);//удаляем последнюю запятую, если если это последний объект в settings
              Break;
            end;
          end;
          if DelIdx > 0 then
          begin
            Log('replacing old extension prefs');
            //if we found one, replace with the fresh strings
            realText := Json.Text;
            StringChangeEx(realText, del_json_text, prefs_json_str + #13#10, True);
            Json.Text := realText;
            Exit;
          end;
        end;

        Json.Insert(J + 1, prefs_json_str + #13#10);
        Exit;
      end;
    end;

    if not bExtFound then
    begin
      Log('extensions object is not found, creatу new one');

      Json.Insert(1, '   "extensions": {' + #13#10);       
      Json.Insert(2, '      "settings": {' + #13#10); 
      SetLength(prefs_json_str, Length(prefs_json_str) - 1);
      Json.Insert(3, prefs_json_str + '}' + #13#10 + '},' + #13#10);
    end;
   
  finally
    if Json.Count > 0 then
      Json.SaveToFile(ExpandConstant(ToPath + 'Preferences'));
    Json.Free;
  end;  
end;

procedure InstallToChrome;
var
  ChromeRunning, Foo: Boolean;
  AskCount: Integer;
begin
  if ChromeProfilePath = '' then
    ChromeProfilePath := GetBrowserProfilePath(brChrome);
  if ChromeProfilePath = '' then Exit;

  Log('instaling to chrome');

  AskCount := 0;
  repeat
    GetBrowsers(Foo, Foo, ChromeRunning, Foo, Foo, Foo, Foo, True);

    if ChromeRunning then
    begin
      Log('chrome is running, ask user');
      if MsgBox(FmtMessage(ExpandConstant('{cm:PleaseClose}'), ['Chrome']), mbInformation, MB_OKCANCEL) = IDCANCEL then
        Exit
      else
        Sleep(3000);
    end
    else
      Break;

    ChromeRunning := False;
    Inc(AskCount);
  until AskCount > 3;

  if AskCount >= 3 then Exit;

  Log('installing');
  InstallChromeExtenstion(ChromeProfilePath, False);
end;

procedure InstallToYawser(PatchPrefs: Boolean);
var
  YaRunning, Foo: Boolean;
  AskCount: Integer;
begin
  if YawserProfilePath = '' then
    YawserProfilePath := GetBrowserProfilePath(brYawser);
  if YawserProfilePath = '' then Exit;

  Log('installing to yawser');
  
  if PatchPrefs then
  begin
    AskCount := 0;
    repeat
      GetBrowsers(Foo, Foo, Foo, YaRunning, Foo, Foo, Foo, True);

      if YaRunning then
      begin
        Log('yawser running, ask user');
        if MsgBox(FmtMessage(ExpandConstant('{cm:PleaseClose}'), [ExpandConstant('{cm:Yawser}')]), mbInformation, MB_OKCANCEL) = IDCANCEL then
          Exit
        else
          Sleep(3000);
      end
      else
        Break;

      YaRunning := False;
      Inc(AskCount);
    until AskCount > 3;

    if AskCount >= 3 then Exit;

    Log('installing');
    InstallChromeExtenstion(YawserProfilePath, False);
  end
  else
    begin
      Log('extracting yawser crx extention to ' + YawserProfilePath + 'extensions\');
      ForceDirectories(YawserProfilePath + 'extensions\');
      ExtractTemporaryFile('helper_chrome.crx');                                 
      FileCopy(ExpandConstant('{tmp}\helper_chrome.crx'), YawserProfilePath + 'extensions\helper@savefrom.net.crx', False);  

      if not RegWriteStringValue(HKEY_LOCAL_MACHINE, ExpandConstant('Software\Yandex\YandexBrowser\\Extensions\{#ChromeID}'), 'path', YawserProfilePath + 'extensions\helper@savefrom.net.crx') then
        RegWriteStringValue(HKEY_CURRENT_USER, ExpandConstant('Software\Yandex\YandexBrowser\\Extensions\{#ChromeID}'), 'path', YawserProfilePath + 'extensions\helper@savefrom.net.crx');
      if not RegWriteStringValue(HKEY_LOCAL_MACHINE, ExpandConstant('Software\Yandex\YandexBrowser\\Extensions\{#ChromeID}'), 'version', ExpandConstant('{#ChromeExtVer}')) then
        RegWriteStringValue(HKEY_CURRENT_USER, ExpandConstant('Software\Yandex\YandexBrowser\\Extensions\{#ChromeID}'), 'version', ExpandConstant('{#ChromeExtVer}'));
      if IsWin64 then
      begin
        if not RegWriteStringValue(HKEY_LOCAL_MACHINE, ExpandConstant('Software\Wow6432Node\Yandex\YandexBrowser\\Extensions\{#ChromeID}'), 'path', YawserProfilePath + 'extensions\helper@savefrom.net.crx') then
          RegWriteStringValue(HKEY_CURRENT_USER, ExpandConstant('Software\Wow6432Node\Yandex\YandexBrowser\\Extensions\{#ChromeID}'), 'path', YawserProfilePath + 'extensions\helper@savefrom.net.crx');
        if not RegWriteStringValue(HKEY_LOCAL_MACHINE, ExpandConstant('Software\Wow6432Node\Yandex\YandexBrowser\\Extensions\{#ChromeID}'), 'version', ExpandConstant('{#ChromeExtVer}')) then
          RegWriteStringValue(HKEY_CURRENT_USER, ExpandConstant('Software\Wow6432Node\Yandex\YandexBrowser\\Extensions\{#ChromeID}'), 'version', ExpandConstant('{#ChromeExtVer}'));
      end;
    end;
end;

procedure InstallToMailRu;
var
  MailRuRunning, Foo: Boolean;
  AskCount: Integer;
begin
  if MawserProfilePath = '' then
    MawserProfilePath := GetBrowserProfilePath(brMawser);
  if MawserProfilePath = '' then Exit;

  Log('installing to MailRu');
  
  AskCount := 0;
  repeat
    GetBrowsers(Foo, Foo, Foo, Foo, MailRuRunning, Foo, Foo, True);

    if MailRuRunning then
    begin
      Log('MailRu running, ask user');
      if MsgBox(FmtMessage(ExpandConstant('{cm:PleaseClose}'), [ExpandConstant('{cm:MailRu}')]), mbInformation, MB_OKCANCEL) = IDCANCEL then
        Exit
      else
        Sleep(3000);
    end
    else
      Break;

    MailRuRunning := False;
    Inc(AskCount);
  until AskCount > 3;

  if AskCount >= 3 then Exit;

  Log('installing');
  InstallChromeExtenstion(MawserProfilePath, False);
end;

procedure InstallToOperaWebKit;
var
  OperaWebKitRunning, Foo: Boolean;
  AskCount: Integer;
begin
  if OperaWKProfilePath = '' then
    OperaWKProfilePath := GetBrowserProfilePath(brOperaWebKit);
  if OperaWKProfilePath = '' then Exit;

  Log('instaling to opera webkit');

  AskCount := 0;
  repeat
    GetBrowsers(Foo, Foo, Foo, Foo, Foo, Foo, OperaWebKitRunning, True);

    if OperaWebKitRunning then
    begin
      Log('opera is running, ask user');
      if MsgBox(FmtMessage(ExpandConstant('{cm:PleaseClose}'), ['Opera WebKit']), mbInformation, MB_OKCANCEL) = IDCANCEL then
        Exit
      else
        Sleep(3000);
    end
    else
      Break;

    OperaWebKitRunning := False;
    Inc(AskCount);
  until AskCount > 3;

  if AskCount >= 3 then Exit;

  Log('installing');
  InstallChromeExtenstion(OperaWKProfilePath, True);
end;

const
  EmptySafariConfig = '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
                      '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' + #13#10 +
                      '<plist version="1.0">' + #13#10 +
                      '<dict>' + #13#10 +
                      '  <key>Available Updates</key>' + #13#10 +
                      '  <dict>' + #13#10 +
                      '    <key>Last Update Check Time</key>' + #13#10 +
                      '    <real>383689169.63533998</real>' + #13#10 +
                      '    <key>Updates List</key>' + #13#10 +
                      '    <array/>' + #13#10 +
                      '  </dict>' + #13#10 +
                      '  <key>Installed Extensions</key>' + #13#10 +
                      '  <array>' + #13#10 +
                      '  </array>' + #13#10 +
                      '  <key>Version</key>' + #13#10 +
                      '  <integer>1</integer>' + #13#10 +
                      '</dict>' + #13#10 +
                      '</plist>';
  SafariConfig = '<dict>' + #13#10 +
                 '  <key>Added Non-Default Toolbar Items</key>' + #13#10 +
                 '  <array/>' + #13#10 +
                 '  <key>Archive File Name</key>' + #13#10 +
                 '  <string>SaveFrom.net helper.safariextz</string>' + #13#10 +
                 '  <key>Bundle Directory Name</key>' + #13#10 +
                 '  <string>SaveFrom.net helper.safariextension</string>' + #13#10 +
                 '  <key>Enabled</key>' + #13#10 +
                 '  <true/>' + #13#10 +
                 '  <key>Hidden Bars</key>' + #13#10 +
                 '  <array/>' + #13#10 +
                 '  <key>Removed Default Toolbar Items</key>' + #13#10 +
                 '  <array/>' + #13#10 +
                 '</dict>';
  SafariPrefs = '<string>com.savefrom.helper-8XGXRJZ23E savefrom_toolbar</string>';

procedure InstallToSafari;
var
  SafariRunning, Foo, bConvert: Boolean;
  AskCount, ErrorCode, I, J: Integer;
  XmlConfig: TStringList;
  sTemp: AnsiString;
  sArray: string;
begin
  if SafariProfilePath = '' then
    SafariProfilePath := GetBrowserProfilePath(brSafari);
  if SafariProfilePath = '' then Exit;

  Log('installing to Safari');
  
  AskCount := 0;
  repeat
    GetBrowsers(Foo, Foo, Foo, Foo, Foo, SafariRunning, Foo, True);

    if SafariRunning then
    begin
      Log('Safari running, ask user');
      if MsgBox(FmtMessage(ExpandConstant('{cm:PleaseClose}'), ['Safari']), mbInformation, MB_OKCANCEL) = IDCANCEL then
        Exit
      else
        Sleep(3000);
    end
    else
      Break;

    SafariRunning := False;
    Inc(AskCount);
  until AskCount > 3;

  if AskCount >= 3 then Exit;

  Log('installing');

  bConvert := True;

  ForceDirectories(SafariProfilePath + 'Extensions\');
  //first convert to xml
  if FileExists(SafariProfilePath + 'Extensions\Extensions.plist') then
  begin
    LoadStringFromFile(SafariProfilePath + 'Extensions\Extensions.plist', sTemp);
    bConvert := Pos('<?xml version="1.0"', sTemp) <> 1;
    
    if bConvert then
    if not Exec(SafariUtilPath, '-convert xml1 "' + SafariProfilePath + 'Extensions\Extensions.plist"', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) or (ErrorCode <> 0) then
    begin
      Log('convert from binary to xml attempt 1 failed: ' + IntToStr(ErrorCode) + ' (' +SysErrorMessage(ErrorCode) + ')');
      if not ExecAsOriginalUser(SafariUtilPath, '-convert xml1 "' + SafariProfilePath + 'Extensions\Extensions.plist"', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) or (ErrorCode <> 0) then
      begin
        Log('couldnt convert from binary to xml, exiting: ' + IntToStr(ErrorCode) + ' (' +SysErrorMessage(ErrorCode) + ')');
        Exit;
      end;
    end
    else
      Log('conversion to xml done');
  end;

  //now patch xml
  XmlConfig := TStringList.Create;
  try
    if FileExists(SafariProfilePath + 'Extensions\Extensions.plist') then
      XmlConfig.LoadFromFile(SafariProfilePath + 'Extensions\Extensions.plist')
    else
      XmlConfig.Text := EmptySafariConfig;

    if Pos('<string>SaveFrom', XmlConfig.Text) = 0 then
    for I := 0 to XmlConfig.Count - 1 do
    if Trim(XmlConfig[I]) = '<key>Installed Extensions</key>' then
    begin
      if Trim(XmlConfig[I + 1]) = '<array/>' then
      begin
        sArray := XmlConfig[I + 1];
        StringChangeEx(sArray, '<array/>', '<array>', True);
        XmlConfig[I + 1] := sArray;
        XmlConfig.Insert(I + 2, SafariConfig + #13#10'</array>');
      end
      else
        XmlConfig.Insert(I + 2, SafariConfig);
      Break; 
    end;
  finally
    if XmlConfig.Count > 0 then    
      XmlConfig.SaveToFile(SafariProfilePath + 'Extensions\Extensions.plist');
    XmlConfig.Free;
  end;

  //no need in result checking - safari will handle it anyway
  if bConvert then
  begin
    Exec(SafariUtilPath, '-convert binary1 "' + SafariProfilePath + 'Extensions\Extensions.plist"', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
    Log('convert back to from binary done with ' + IntToStr(ErrorCode) + ' (' +SysErrorMessage(ErrorCode) + ')');
  end;

  ExtractTemporaryFile('helper_safari.safariextz');                                      
  if not DeleteFile(SafariProfilePath + 'Extensions\SaveFrom.net helper.safariextz') then DeleteFile(SafariProfilePath + 'Extensions\SaveFrom.net helper.safariextz');
  FileCopy(ExpandConstant('{tmp}\helper_safari.safariextz'), SafariProfilePath + 'Extensions\SaveFrom.net helper.safariextz', False);

  //patch preferences file
  sArray := ExpandFileName(SafariProfilePath + '..\Preferences\com.apple.Safari.plist'); 
  Log('patching preferences on path ' + sArray);
  if not Exec(SafariUtilPath, '-convert xml1 "' + ExpandFileName(SafariProfilePath + '..\Preferences\com.apple.Safari.plist') + '"', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) or (ErrorCode <> 0) then
  begin
    Log('prefs convert from binary to xml attempt 1 failed: ' + IntToStr(ErrorCode) + ' (' +SysErrorMessage(ErrorCode) + ')');
    if not ExecAsOriginalUser(SafariUtilPath, '-convert xml1 "' + ExpandFileName(SafariProfilePath + '..\Preferences\com.apple.Safari.plist') + '"', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) or (ErrorCode <> 0) then
    begin
      Log('couldnt convert prefs from binary to xml, exiting: ' + IntToStr(ErrorCode) + ' (' +SysErrorMessage(ErrorCode) + ')');
      Exit;
    end;
  end;

  XmlConfig := TStringList.Create;
  try
    XmlConfig.LoadFromFile(sArray);    		

    if Pos('<string>com.savefrom.helper', XmlConfig.Text) = 0 then
    for I := 0 to XmlConfig.Count - 1 do
    if Trim(XmlConfig[I]) = '<key>SafariToolbarIdentifier</key>' then
    begin
      if Trim(XmlConfig[I + 1]) = '<array/>' then
      begin
        sArray := XmlConfig[I + 1];
        StringChangeEx(sArray, '<array/>', '<array>', True);
        XmlConfig[I + 1] := sArray;
        XmlConfig.Insert(I + 2, SafariPrefs + #13#10'</array>');
      end
      else
        for J := I + 1 to XmlConfig.Count - 2 do
        begin
          if Trim(XmlConfig[J]) = '<string>HomeToolbarIdentifier</string>' then
          begin
            XmlConfig.Insert(J + 1, SafariPrefs);
            Break;
          end;

          if (Trim(XmlConfig[J]) = '<string>BackForwardToolbarIdentifier</string>') and 
             (Trim(XmlConfig[J + 1]) <> '<string>HomeToolbarIdentifier</string>') then
          begin
            XmlConfig.Insert(J + 1, SafariPrefs);
            Break;
          end;                

          if Trim(XmlConfig[J + 1]) = '</array>' then
          begin
            XmlConfig.Insert(J, SafariPrefs);
            Break;
          end;
        end;//else

      Break; 
    end;
  finally
    if XmlConfig.Count > 0 then    
      XmlConfig.SaveToFile(ExpandFileName(SafariProfilePath + '..\Preferences\com.apple.Safari.plist'));
    XmlConfig.Free;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    Log('start installing extenstions');

    if (OperaIdx > 0) then
      OperaChecked := OperaExists and clbOptions.Checked[OperaIdx]
    else
      OperaChecked := OperaExists and clbOptions.Checked[0];

    if (OperaWKIdx > 0) then
      OperaWKChecked := OperaWKExists and clbOptions.Checked[OperaWKIdx]
    else
      OperaWKChecked := OperaWKExists and clbOptions.Checked[0];

    if (FFIdx > 0) then
      FirefoxChecked := FirefoxExists and clbOptions.Checked[FFIdx]
    else
      FirefoxChecked := FirefoxExists and clbOptions.Checked[0];

    if (ChromeIdx > 0) then
      ChromeChecked := ChromeExists  and clbOptions.Checked[ChromeIdx]
    else
      ChromeChecked := ChromeExists and clbOptions.Checked[0];

    if (YaIdx > 0) then
      YawserChecked := YawserExists  and clbOptions.Checked[YaIdx]
    else
      YawserChecked := YawserExists and clbOptions.Checked[0];
   
    if (MIdx > 0) then
      MailRuChecked := MailRuExists and clbOptions.Checked[MIdx]
    else
      MailRuChecked := MailRuExists and clbOptions.Checked[0];

    if (SafariIdx > 0) then
      SafariChecked := SafariExists and clbOptions.Checked[SafariIdx]
    else
      SafariChecked := SafariExists and clbOptions.Checked[0];

    if OperaChecked then
      InstallToOpera;
    if OperaWKChecked then
      InstallToOperaWebKit;
    if FirefoxChecked then
      InstallToFF;
    if ChromeChecked then
      InstallToChrome;
    if YawserChecked then
      InstallToYawser(True);
    if MailRuChecked then
      InstallToMailRu;
    if SafariChecked then
      InstallToSafari;
  end;  

  if CurStep = ssPostInstall then
  begin
    if not YandexEnabled then
      ShowSuccess;     
  end;
end;

var
  DefLeftCancel, DefLeftNext, DefLeftBack: Integer;

procedure CurPageChanged(CurPageID: Integer);
var
  cmd: string;
  ErrorCode: Integer;
  InstallElements, MakeHomePage, InstallSearch: Boolean;
  Elems: string;
  
 begin
  WizardForm.Bevel.Visible := not YandexEnabled or (CurPageID <> InvitePage.ID);
  if (CurPageID = wpFinished) and YandexEnabled and YawserExists then
    WizardForm.NextButton.Left := ScaleX(400);

  if YaAgree <> nil then
    YaAgree.Visible := YandexEnabled and (YawserPage <> nil) and (CurPageID = YawserPage.ID);

  if YandexEnabled and (CurPageID = InvitePage.ID) then
  begin
    if DefLeftCancel = 0 then
    begin
      DefLeftCancel := WizardForm.CancelButton.Left;
      DefLeftNext   := WizardForm.NextButton.Left;
      DefLeftBack   := WizardForm.BackButton.Left;
    end;

    WizardForm.CancelButton.Left := DefLeftCancel;
    WizardForm.NextButton.Left   := DefLeftNext;
    WizardForm.BackButton.Left   := DefLeftBack;
  end;

  if YandexEnabled and (YawserPage <> nil) and (CurPageID = YawserPage.ID) then
  begin
    WizardForm.CancelButton.Left := ScaleX(900);
    WizardForm.NextButton.Left   := DefLeftCancel;
    WizardForm.BackButton.Left   := DefLeftNext;
  end;

  if YandexEnabled and (CurPageID = wpFinished) then
  begin
    InstallElements := clbOptions.Checked[clbOptions.Items.Count - 3]; 
    MakeHomePage    := clbOptions.Checked[clbOptions.Items.Count - 2]; 
    InstallSearch   := clbOptions.Checked[clbOptions.Items.Count - 1]; //последняя галочка

    if (not YawserExists and clbYawserOptions.Checked[0]) or
       InstallElements or MakeHomePage or InstallSearch then
    begin
      if YaLaunched then Exit;

      Log('extenstions installed, begin yandex utility');

      Elems := '';
      if InstallElements then
        Elems := ExpandConstant(' {cm:MayTakeAWhileElement}');
      if not YawserExists then 
      begin
        WizardForm.NextButton.Left := ScaleX(400);
        WizardForm.NextButton.Enabled := False;
        WizardForm.FinishedLabel.Visible := True;
        WizardForm.FinishedLabel.Caption := FmtMessage(ExpandConstant('{cm:MayTakeAWhile}'), [Elems]);
      end;
      ExtractTemporaryFile('downloader.exe');
      if ActiveLanguage = 'turkish' then
        cmd := '--partner savefrom-elements-tr --distr /passive /msicl "'
      else
        cmd := '--partner savefrom-elements --distr /passive /msicl "';
      //install yawser
      if not YawserExists and clbYawserOptions.Checked[0] then
        cmd := cmd + ' YABROWSER=y'
      else
        cmd := cmd + ' YABROWSER=n';
      //participate
      if not YawserExists and clbYawserOptions.Checked[0] and clbYawserOptions.Checked[1] then
        cmd := cmd + ' YBSENDSTAT=y'
      else
        cmd := cmd + ' YBSENDSTAT=n';
      //install elements
      if not InstallElements then
        cmd := cmd + ' ILIGHT=1';
      //homepage
      if MakeHomePage then
        cmd := cmd + ' YAHOMEPAGE=y'
      else
        cmd := cmd + ' YAHOMEPAGE=n';
      //search
      if InstallSearch then
        cmd := cmd + ' YAQSEARCH=y'
      else
        cmd := cmd + ' YAQSEARCH=n';

      cmd := cmd + ' YBNODEFAULT=n';
      if VID = '' then
        VID := '100';
      
      cmd := cmd + Format(' VID="%s""', [VID]);
      Log('calling downloader with commandline: ' + cmd);
      if not Exec(ExpandConstant('{tmp}\downloader.exe'), cmd, '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) then
        if not ExecAsOriginalUser(ExpandConstant('{tmp}\downloader.exe'), cmd, '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) then
          Log('couldnt launch yandex downloader');
      
      if (ErrorCode = 0) then      
      begin
        if not YawserExists and clbYawserOptions.Checked[0] then
        begin
          Elems := '';
          if InstallElements then
            Elems := ExpandConstant(' {cm:MayTakeAWhileElement}');

          WizardForm.FinishedLabel.Caption := FmtMessage(ExpandConstant('{cm:MayTakeAWhile2}'), [Elems]);
          if WaitForYawser then      
          begin
            Log('downloader completed with code: ' + IntToStr(ErrorCode));
            InstallToYawser(True);
            LaunchYawser;
          end
        end;//yawser installing
      end
      else
        Log('error executing downloader or wait timeout');
    end;

    YaLaunched := True;
    
    WizardForm.NextButton.Left := ScaleX(400);
    ShowSuccess;
    WizardForm.Refresh;
  end;
end;  

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpFinished then
    Result := YaLaunched or YawserExists;
end;