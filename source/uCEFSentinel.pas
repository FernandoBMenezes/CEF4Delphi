unit uCEFSentinel;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
{$ENDIF}

{$I cef.inc}

{$IFNDEF TARGET_64BITS}{$ALIGN ON}{$ENDIF}
{$MINENUMSIZE 4}

interface

uses
  {$IFDEF DELPHI16_UP}
    {$IFDEF MSWINDOWS}WinApi.Windows, WinApi.Messages,{$ENDIF}
    System.Classes, Vcl.Controls, Vcl.ExtCtrls, System.SysUtils, System.SyncObjs, System.Math,
  {$ELSE}
    {$IFDEF MSWINDOWS}Windows, {$ENDIF} Classes, Controls, ExtCtrls, SysUtils, SyncObjs, Math,
    {$IFDEF FPC}
    LCLIntf, LResources, Forms,
    {$ELSE}
    Messages,
    {$ENDIF}
  {$ENDIF}
  uCEFTypes, uCEFInterfaces, uCEFConstants;

const
  CEFSENTINEL_DEFAULT_DELAYPERPROCMS = 200;
  CEFSENTINEL_DEFAULT_MININITDELAYMS = 1500;
  CEFSENTINEL_DEFAULT_FINALDELAYMS   = 100;
  CEFSENTINEL_DEFAULT_MINCHILDPROCS  = 2;
  CEFSENTINEL_DEFAULT_MAXCHECKCOUNTS = 10;

type
  TSentinelStatus = (ssIdle, ssInitialDelay, ssCheckingChildren, ssClosing);

  {$IFNDEF FPC}{$IFDEF DELPHI16_UP}[ComponentPlatformsAttribute(pfidWindows or pfidOSX or pfidLinux)]{$ENDIF}{$ENDIF}
  /// <summary>
  /// TCEFSentinel is used as a timer that checks the number of running
  /// CEF processes when you close all browsers before shutdown.
  /// This component is only used as a last resort when there's an unresolved
  /// shutdown issue in CEF or CEF4Delphi that generates exceptions when the
  /// application is closed.
  /// </summary>
  TCEFSentinel = class(TComponent)
    protected
      {$IFDEF MSWINDOWS}
      FCompHandle             : HWND;
      {$ENDIF}
      FStatus                 : TSentinelStatus;
      FStatusCS               : TCriticalSection;
      FDelayPerProcMs         : cardinal;
      FMinInitDelayMs         : cardinal;
      FFinalDelayMs           : cardinal;
      FMinChildProcs          : integer;
      FMaxCheckCount          : integer;
      FCheckCount             : integer;
      FOnClose                : TNotifyEvent;
      FTimer                  : TTimer;

      function  GetStatus : TSentinelStatus;
      function  GetChildProcCount : integer;

      {$IFDEF MSWINDOWS}
      procedure WndProc(var aMessage: TMessage);
      {$ENDIF}
      procedure doStartMsg({$IFDEF MSWINDOWS}var aMessage : TMessage{$ELSE IFDEF FPC}Data: PtrInt{$ENDIF}); virtual;
      procedure doCloseMsg({$IFDEF MSWINDOWS}var aMessage : TMessage{$ELSE IFDEF FPC}Data: PtrInt{$ENDIF}); virtual;
      function  SendCompMessage(aMsg : cardinal) : boolean;
      function  CanClose : boolean; virtual;

      procedure Timer_OnTimer(Sender: TObject); virtual;

    public
      constructor Create(AOwner: TComponent); override;
      destructor  Destroy; override;
      procedure   AfterConstruction; override;
      procedure   Start; virtual;

      property Status          : TSentinelStatus  read GetStatus;
      property ChildProcCount  : integer          read GetChildProcCount;

    published
      property DelayPerProcMs  : cardinal         read FDelayPerProcMs   write FDelayPerProcMs  default CEFSENTINEL_DEFAULT_DELAYPERPROCMS;
      property MinInitDelayMs  : cardinal         read FMinInitDelayMs   write FMinInitDelayMs  default CEFSENTINEL_DEFAULT_MININITDELAYMS;
      property FinalDelayMs    : cardinal         read FFinalDelayMs     write FFinalDelayMs    default CEFSENTINEL_DEFAULT_FINALDELAYMS;
      property MinChildProcs   : integer          read FMinChildProcs    write FMinChildProcs   default CEFSENTINEL_DEFAULT_MINCHILDPROCS;
      property MaxCheckCount   : integer          read FMaxCheckCount    write FMaxCheckCount   default CEFSENTINEL_DEFAULT_MAXCHECKCOUNTS;

      property OnClose         : TNotifyEvent     read FOnClose          write FOnClose;
  end;

{$IFDEF FPC}
procedure Register;
{$ENDIF}

implementation

uses
  uCEFLibFunctions, uCEFApplicationCore, uCEFMiscFunctions;

 // Attribution :
 // TCEFSentinel icon made by Everaldo Coelho
 // https://www.iconfinder.com/icons/17914/castle_fortress_tower_war_icon
 // http://www.everaldo.com/

constructor TCEFSentinel.Create(AOwner: TComponent);
begin
  inherited Create(aOwner);

  {$IFDEF MSWINDOWS}
  FCompHandle             := 0;
  {$ENDIF}
  FDelayPerProcMs         := CEFSENTINEL_DEFAULT_DELAYPERPROCMS;
  FMinInitDelayMs         := CEFSENTINEL_DEFAULT_MININITDELAYMS;
  FFinalDelayMs           := CEFSENTINEL_DEFAULT_FINALDELAYMS;
  FMinChildProcs          := CEFSENTINEL_DEFAULT_MINCHILDPROCS;
  FMaxCheckCount          := CEFSENTINEL_DEFAULT_MAXCHECKCOUNTS;
  FOnClose                := nil;
  FTimer                  := nil;
  FStatusCS               := nil;
  FStatus                 := ssIdle;
  FCheckCount             := 0;
end;

procedure TCEFSentinel.AfterConstruction;
begin
  inherited AfterConstruction;

  if not(csDesigning in ComponentState) then
    begin
      {$IFDEF MSWINDOWS}
      FCompHandle      := AllocateHWnd({$IFDEF FPC}@{$ENDIF}WndProc);
      {$ENDIF}

      FStatusCS        := TCriticalSection.Create;
      FTimer           := TTimer.Create(nil);
      FTimer.Enabled   := False;
      FTimer.OnTimer   := {$IFDEF FPC}@{$ENDIF}Timer_OnTimer;
    end;
end;

destructor TCEFSentinel.Destroy;
begin
  try
    {$IFDEF MSWINDOWS}
    if (FCompHandle <> 0) then
      begin
        DeallocateHWnd(FCompHandle);
        FCompHandle := 0;
      end;
    {$ENDIF}

    if (FTimer    <> nil) then FreeAndNil(FTimer);
    if (FStatusCS <> nil) then FreeAndNil(FStatusCS);
  finally
    inherited Destroy;
  end;
end;

{$IFDEF MSWINDOWS}
procedure TCEFSentinel.WndProc(var aMessage: TMessage);
begin
  case aMessage.Msg of
    CEF_SENTINEL_START   : doStartMsg(aMessage);
    CEF_SENTINEL_DOCLOSE : doCloseMsg(aMessage);

    else aMessage.Result := DefWindowProc(FCompHandle, aMessage.Msg, aMessage.WParam, aMessage.LParam);
  end;
end;
{$ENDIF}

procedure TCEFSentinel.doStartMsg({$IFDEF MSWINDOWS}var aMessage : TMessage{$ELSE IFDEF FPC}Data: PtrInt{$ENDIF});
begin
  if (FTimer <> nil) then
    begin
      FTimer.Interval := max(ChildProcCount * CEFSENTINEL_DEFAULT_DELAYPERPROCMS, FMinInitDelayMs);
      FTimer.Enabled  := True;
    end;
end;

procedure TCEFSentinel.doCloseMsg({$IFDEF MSWINDOWS}var aMessage : TMessage{$ELSE IFDEF FPC}Data: PtrInt{$ENDIF});
begin
  if assigned(FOnClose) then FOnClose(self);
end;

function TCEFSentinel.SendCompMessage(aMsg : cardinal) : boolean;
begin
  {$IFDEF MSWINDOWS}
  Result := (FCompHandle <> 0) and PostMessage(FCompHandle, aMsg, 0, 0);
  {$ELSE IFDEF FPC}
  case aMsg of
    CEF_SENTINEL_START   : Application.QueueAsyncCall(@doStartMsg, 0);
    CEF_SENTINEL_DOCLOSE : Application.QueueAsyncCall(@doCloseMsg, 0);
  end;
  {$ENDIF}
end;

procedure TCEFSentinel.Start;
begin
  try
    if (FStatusCS <> nil) then FStatusCS.Acquire;

    if (FStatus = ssIdle) then
      begin
        FStatus := ssInitialDelay;
        SendCompMessage(CEF_SENTINEL_START);
      end;
  finally
    if (FStatusCS <> nil) then FStatusCS.Release;
  end;
end;

function TCEFSentinel.GetStatus : TSentinelStatus;
begin
  Result := ssIdle;

  if (FStatusCS <> nil) then
    try
      FStatusCS.Acquire;
      Result := FStatus;
    finally
      FStatusCS.Release;
    end;
end;

function TCEFSentinel.GetChildProcCount : integer;
begin
  if (GlobalCEFApp <> nil) then
    Result := GlobalCEFApp.ChildProcessesCount
   else
    Result := 0;
end;

function TCEFSentinel.CanClose : boolean;
begin
  Result := (FCheckCount >= FMaxCheckCount) or
            (GlobalCEFApp = nil) or
            (ChildProcCount <= FMinChildProcs);
end;

procedure TCEFSentinel.Timer_OnTimer(Sender: TObject);
begin
  FTimer.Enabled := False;

  try
    if (FStatusCS <> nil) then FStatusCS.Acquire;

    case FStatus of
      ssInitialDelay :
        if CanClose then
          begin
            FStatus := ssClosing;
            SendCompMessage(CEF_SENTINEL_DOCLOSE);
          end
         else
          begin
            FStatus         := ssCheckingChildren;
            FCheckCount     := 0;
            FTimer.Interval := FFinalDelayMs;
            FTimer.Enabled  := True;
          end;

      ssCheckingChildren :
        if CanClose then
          begin
            FStatus := ssClosing;
            SendCompMessage(CEF_SENTINEL_DOCLOSE);
          end
         else
          begin
            inc(FCheckCount);
            FTimer.Enabled := True;
          end;
    end;
  finally
    if (FStatusCS <> nil) then FStatusCS.Release;
  end;
end;

{$IFDEF FPC}
procedure Register;
begin
  {$I res/tcefsentinel.lrs}
  RegisterComponents('Chromium', [TCEFSentinel]);
end;
{$ENDIF}

end.
