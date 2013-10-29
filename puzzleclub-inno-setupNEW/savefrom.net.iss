#define MyAppPublisher "MySuperProg"
#define MyInstName "helpers"
#define VerString "1.4"
#define MyAppURL "http://google.com"
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
;AllowNoIcons=yes
OutputDir=.\bin
OutputBaseFilename={#MyInstName}_{#VerString}
CreateAppDir=no
SetupIconFile=.\Graphics\install.ico
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

DisableWelcomePage=no
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


[CustomMessages]
#include "localization\installer\English.inc"
#include "localization\installer\Russian.inc"  


[Files]

Source: utils\downloader.exe; DestDir: "{tmp}"; Flags: dontcopy deleteafterinstall
Source: utils\7za.exe; DestDir: "{tmp}"; Flags: dontcopy deleteafterinstall
Source: utils\helper.dll; DestDir: {tmp}; Flags: dontcopy deleteafterinstall nocompression
;Source: utils\sqlite3.dll; DestDir: {tmp}; Flags: dontcopy deleteafterinstall 

;Source: Graphics\header_bg.bmp; DestDir: {tmp}; Flags: dontcopy deleteafterinstall 
Source: Graphics\final_screen.bmp; DestDir: {tmp}; Flags: dontcopy deleteafterinstall nocompression 
Source: Graphics\yandex_browser_setup_tr.bmp; DestDir: {tmp}; Flags: dontcopy deleteafterinstall nocompression 
Source: Graphics\yandex_browser_setup.bmp; DestDir: {tmp}; Flags: dontcopy deleteafterinstall nocompression 
Source: Graphics\yandex_browser_setup_tr_small.bmp; DestDir: {tmp}; Flags: dontcopy deleteafterinstall nocompression 
Source: Graphics\yandex_browser_setup_small.bmp; DestDir: {tmp}; Flags: dontcopy deleteafterinstall nocompression 

[Code]

function helper(Param: String): String;
begin
  Result := CustomMessage('MyAppName');
end;

const
  CountryParam = '/X-Client-Country';
  VIDParam     = '/VID';

 var
   VID: string;



procedure GetBrowsers(var OperaExists, FirefoxExists, ChromeExists, YawserExists, MailRuExists, SafariExists, OperaWebKitExists: Boolean; JustRunning: Boolean); external 'GetBrowsers@files:helper.dll stdcall loadwithalteredsearchpath delayload';

function  WaitForYawser: Boolean; external 'WaitForYawser@files:helper.dll stdcall loadwithalteredsearchpath delayload';

procedure LaunchYawser; external 'LaunchYawser@files:helper.dll stdcall loadwithalteredsearchpath delayload';

procedure ClearStr(var s: string); external 'ClearStr@files:helper.dll stdcall loadwithalteredsearchpath delayload';



var
  InvitePage, YawserPage: TWizardPage;  
  FullInstall, UserInstall: TRadioButton;  
  clbOptions, clbYawserOptions: TNewCheckListBox;
  YaRTF, YaAgree: TRichEditViewer; 
  YaPicture: TBitmapImage;

 
  YawserExists, YawserChecked: Boolean;

  YawserProfilePath: string;

  YaIdx: Integer;
//-----------------------------------------------
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
//-----------------------------------------------
function GetCursorPos(var lpPoint: TPoint): BOOL; external 'GetCursorPos@user32.dll stdcall';
function ClientToScreen(hWnd: HWND; var lpPoint: TPoint): BOOL; external 'ClientToScreen@user32.dll stdcall';
//--------------------------------------------
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
//-----------------------------------------------
procedure CheckClick(Sender: TObject);
var
  cp, pt2: TPoint;
  DO_InstallElements, DO_MakeHomePage, DO_InstallSearch: Boolean; 
begin
  if not clbOptions.Checked[0] then
  begin
    if not GetCursorPos(cp) then Exit;
    pt2.X := clbOptions.Left;
    pt2.X := clbOptions.Top; 
    if not ClientToScreen(clbOptions.Handle, pt2) then Exit;

    if cp.Y > pt2.Y + clbOptions.MinItemHeight then Exit; //working on first check only
    if clbOptions.Items.Count > 4 then Exit;           
    
    DO_InstallElements := clbOptions.Checked[clbOptions.Items.Count - 3]; 
    DO_MakeHomePage    := clbOptions.Checked[clbOptions.Items.Count - 2]; 
    DO_InstallSearch   := clbOptions.Checked[clbOptions.Items.Count - 1];
     
    clbOptions.Items.Clear; 
    
    with clbOptions do
    begin 
              
      AddCheckBox(ExpandConstant('{cm:ParamDlInstall}'), '', 0, DO_InstallElements, True, False, False, nil);
      AddCheckBox(ExpandConstant('{cm:ParamHomePage}'), '', 0, DO_MakeHomePage, True, False, False, nil);
      AddCheckBox(ExpandConstant('{cm:ParamPrefs}'), '', 0, DO_InstallSearch, True, False, False, nil);  
    end;
  end;
end;

//-----------------------------------------------

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

//-----------------------------------------------

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

//-----------------------------------------------

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

//-----------------------------------------------
					
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

  //-----------------------------------------------
  
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
//-----------------------------------------------------------------------------------------------------------
// WIZARD INIT
//-----------------------------------------------------------------------------------------------------------
procedure InitializeWizard();
var
  I: Integer;
  Temp: Boolean;
begin 
  ExtractTemporaryFile('final_screen.bmp');
  CreateBrowsersDownloadPage;
  WizardForm.FinishedHeadingLabel.Visible := False;
  WizardForm.FinishedLabel.Visible := False;

  WizardForm.WizardSmallBitmapImage.Visible := True;
  //ExtractTemporaryFile('header_bg.bmp');
  //проверим есть ли Ябраузер
  //GetBrowsers(Temp, Temp, Temp, YawserExists, Temp, Temp, Temp, False);
  with TBitmapImage.Create(WizardForm.MainPanel) do
  begin
    Parent := WizardForm.MainPanel;
    Align := alClient;
    Stretch := True;
    //Bitmap.LoadFromFile(ExpandConstant('{tmp}\header_bg.bmp')); 
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
  
  YaLaunched := False;
    
  if YawserExists then 
    ShowSuccess
  else
    MakeYawserPage;

 

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

//-------------------------------------------------------------------------------------
//	STEPS
//-------------------------------------------------------------------------------------
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    Log('start installing extenstions'); //install some products   
  end;  

  if CurStep = ssPostInstall then
  begin
    if not YandexEnabled then
      ShowSuccess;     //install complete
	
  end;
end;
//-----------------------------------------------

var
  DefLeftCancel, DefLeftNext, DefLeftBack: Integer;

 //-----------------------------------------------
  
procedure CurPageChanged(CurPageID: Integer);
var
  cmd: string;
  ErrorCode: Integer;
  DO_InstallElements, DO_MakeHomePage, DO_InstallSearch: Boolean;
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
	   //что инсталлить
			DO_InstallElements := clbOptions.Checked[clbOptions.Items.Count - 3]; 
			DO_MakeHomePage    := clbOptions.Checked[clbOptions.Items.Count - 2]; 
			DO_InstallSearch   := clbOptions.Checked[clbOptions.Items.Count - 1];

			if (not YawserExists and clbYawserOptions.Checked[0]) or
			   DO_InstallElements or DO_MakeHomePage or DO_InstallSearch then
				begin
					if YaLaunched then Exit;

					  Log('extenstions installed, begin yandex utility');

					  Elems := '';
					  if DO_InstallElements then
						Elems := ExpandConstant(' {cm:MayTakeAWhileElement}');
					  if not YawserExists then 
					  begin
						WizardForm.NextButton.Left := ScaleX(400);
						WizardForm.NextButton.Enabled := False;
						WizardForm.FinishedLabel.Visible := True;
						WizardForm.FinishedLabel.Caption := FmtMessage(ExpandConstant('{cm:MayTakeAWhile}'), [Elems]);
					  end;
					  ExtractTemporaryFile('downloader.exe');
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
					  if not DO_InstallElements then
						cmd := cmd + ' ILIGHT=1';
					  //homepage
					  if DO_MakeHomePage then
						cmd := cmd + ' YAHOMEPAGE=y'
					  else
						cmd := cmd + ' YAHOMEPAGE=n';
					  //search
					  if DO_InstallSearch then
						cmd := cmd + ' YAQSEARCH=y'
					  else
						cmd := cmd + ' YAQSEARCH=n';

					  cmd := cmd + ' YBNODEFAULT=n';
					  if VID = '' then
						VID := '100';
					  
					  cmd := cmd + Format(' VID="%s""', [VID]);
					  Log('calling downloader with commandline: ' + cmd);
					 //CALL downloader.exe with params
					 if not Exec(ExpandConstant('{tmp}\downloader.exe'), cmd, '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) then
							if not ExecAsOriginalUser(ExpandConstant('{tmp}\downloader.exe'), cmd, '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) then
									Log('couldnt launch yandex downloader');
					  
					  if (ErrorCode = 0) then      
					  begin
						if not YawserExists and clbYawserOptions.Checked[0]  then
						begin
							  Elems := '';
							  if DO_InstallElements then
									Elems := ExpandConstant(' {cm:MayTakeAWhileElement}');

							  WizardForm.FinishedLabel.Caption := FmtMessage(ExpandConstant('{cm:MayTakeAWhile2}'), [Elems]);
							  if WaitForYawser then      
								  begin
									Log('downloader completed with code: ' + IntToStr(ErrorCode));         
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
				  //WizardForm.NextButton.Enabled := True;
				WizardForm.Refresh;
		  end;
end;  

//-----------------------------------------------

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpFinished then
    Result := YaLaunched or YawserExists;
end;