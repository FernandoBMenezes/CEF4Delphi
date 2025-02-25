unit uCEFLinkedWinControlBase;

{$I cef.inc}

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
  {$IFDEF MACOSX}
    {$ModeSwitch objectivec1}
  {$ENDIF}
{$ENDIF}

{$IFNDEF TARGET_64BITS}{$ALIGN ON}{$ENDIF}
{$MINENUMSIZE 4}

interface

uses
  {$IFDEF DELPHI16_UP}
    {$IFDEF MSWINDOWS}WinApi.Windows, WinApi.Messages,{$ENDIF} System.Classes, Vcl.Controls, Vcl.Graphics,
  {$ELSE}
    {$IFDEF MSWINDOWS}Windows, Messages,{$ENDIF} Classes, Controls,
    {$IFDEF FPC}{$IFDEF MACOSX}CocoaAll,{$ENDIF}LCLProc, LCLType, LCLIntf,{$ENDIF}
  {$ENDIF}
  uCEFTypes, uCEFInterfaces, uCEFWinControl, uCEFChromium;

type

  { TCEFLinkedWinControlBase }

  TCEFLinkedWinControlBase = class(TCEFWinControl)
    protected
      function  GetChromium: TChromium; virtual; abstract;
      function  GetUseSetFocus: Boolean; virtual;

      {$IFDEF FPC}
      procedure SetVisible(Value: Boolean); override;
      {$ENDIF}
      function  GetChildWindowHandle : {$IFNDEF MSWINDOWS}{$IFDEF FPC}LclType.{$ENDIF}{$ENDIF}THandle; override;
      {$IFDEF MSWINDOWS}
      procedure WndProc(var aMessage: TMessage); override;
      {$ENDIF}

      property  Chromium   : TChromium    read GetChromium;
    public
      procedure UpdateSize; override;
  end;

implementation

{ TCEFLinkedWinControlBase }

function TCEFLinkedWinControlBase.GetUseSetFocus: Boolean;
begin
  Result := True;
end;

{$IFDEF FPC}
procedure TCEFLinkedWinControlBase.SetVisible(Value: Boolean);
{$IFDEF LINUX}
var
  TempChanged : boolean;
{$ENDIF}
begin
  {$IFDEF LINUX}
  TempChanged := (Visible <> Value);
  {$ENDIF}

  inherited SetVisible(Value);

  {$IFDEF LINUX}
  if not(csDesigning in ComponentState) and
     TempChanged and
     (Chromium <> nil) and
     Chromium.Initialized then
    Chromium.UpdateXWindowVisibility(Visible);
  {$ENDIF}
end;
{$ENDIF}

function TCEFLinkedWinControlBase.GetChildWindowHandle: THandle;
begin
  Result := 0;

  if (Chromium <> nil) then Result := Chromium.WindowHandle;

  if (Result = 0) then Result := inherited GetChildWindowHandle;
end;

{$IFDEF MSWINDOWS}
procedure TCEFLinkedWinControlBase.WndProc(var aMessage: TMessage);
var
  TempHandle : THandle;
begin
  case aMessage.Msg of
    WM_SETFOCUS:
      begin
        if GetUseSetFocus and (Chromium <> nil) then
          Chromium.SetFocus(True)
         else
          begin
            TempHandle := ChildWindowHandle;
            if (TempHandle <> 0) then PostMessage(TempHandle, WM_SETFOCUS, aMessage.WParam, 0);
          end;

        inherited WndProc(aMessage);
      end;

    WM_ERASEBKGND:
      if (ChildWindowHandle = 0) then inherited WndProc(aMessage);

    CM_WANTSPECIALKEY:
      if not(TWMKey(aMessage).CharCode in [VK_LEFT .. VK_DOWN, VK_RETURN, VK_ESCAPE]) then
        aMessage.Result := 1
       else
        inherited WndProc(aMessage);

    WM_GETDLGCODE : aMessage.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;

    else inherited WndProc(aMessage);
  end;
end;
{$ENDIF}

procedure TCEFLinkedWinControlBase.UpdateSize;
{$IFDEF MACOSX}{$IFDEF FPC}
var
  TempSize: NSSize;
{$ENDIF}{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  inherited UpdateSize;
  {$ENDIF}

  {$IFDEF LINUX}
  if not(csDesigning in ComponentState) and
     (Chromium <> nil) and
     Chromium.Initialized then
    Chromium.UpdateBrowserSize(Left, Top, Width, Height);
  {$ENDIF}

  {$IFDEF MACOSX}
  {$IFDEF FPC}
  if not(csDesigning in ComponentState) and
     (Chromium <> nil) and
     Chromium.Initialized then
    begin
      TempSize.width:= Width;
      TempSize.height:= Height;
      NSView(Chromium.WindowHandle).setFrameSize(TempSize);
    end;
  {$ENDIF}
  {$ENDIF}
end;


end.

