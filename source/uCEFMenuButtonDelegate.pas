unit uCEFMenuButtonDelegate;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
{$ENDIF}

{$I cef.inc}

{$IFNDEF TARGET_64BITS}{$ALIGN ON}{$ENDIF}
{$MINENUMSIZE 4}

interface

uses
  {$IFDEF DELPHI16_UP}
  System.Classes, System.SysUtils,
  {$ELSE}
  Classes, SysUtils,
  {$ENDIF}
  uCEFBaseRefCounted, uCEFInterfaces, uCEFTypes, uCEFButtonDelegate;

type
  TCefMenuButtonDelegateRef = class(TCefButtonDelegateRef, ICefMenuButtonDelegate)
    protected
      procedure OnMenuButtonPressed(const menu_button: ICefMenuButton; const screen_point: TCefPoint; const button_pressed_lock: ICefMenuButtonPressedLock);

    public
      class function UnWrap(data: Pointer): ICefMenuButtonDelegate;
  end;

  TCefMenuButtonDelegateOwn = class(TCefButtonDelegateOwn, ICefMenuButtonDelegate)
    protected
      procedure OnMenuButtonPressed(const menu_button: ICefMenuButton; const screen_point: TCefPoint; const button_pressed_lock: ICefMenuButtonPressedLock); virtual;

      procedure InitializeCEFMethods; override;
    public
      constructor Create; override;
  end;

  TCustomMenuButtonDelegate = class(TCefMenuButtonDelegateOwn)
    protected
      FEvents : Pointer;

      // ICefViewDelegate
      procedure OnGetPreferredSize(const view: ICefView; var aResult : TCefSize); override;
      procedure OnGetMinimumSize(const view: ICefView; var aResult : TCefSize); override;
      procedure OnGetMaximumSize(const view: ICefView; var aResult : TCefSize); override;
      procedure OnGetHeightForWidth(const view: ICefView; width: Integer; var aResult: Integer); override;
      procedure OnParentViewChanged(const view: ICefView; added: boolean; const parent: ICefView); override;
      procedure OnChildViewChanged(const view: ICefView; added: boolean; const child: ICefView); override;
      procedure OnWindowChanged(const view: ICefView; added: boolean); override;
      procedure OnLayoutChanged(const view: ICefView; new_bounds: TCefRect); override;
      procedure OnFocus(const view: ICefView); override;
      procedure OnBlur(const view: ICefView); override;

      // ICefButtonDelegate
      procedure OnButtonPressed(const button: ICefButton); override;
      procedure OnButtonStateChanged(const button: ICefButton); override;

      // ICefMenuButtonDelegate
      procedure OnMenuButtonPressed(const menu_button: ICefMenuButton; const screen_point: TCefPoint; const button_pressed_lock: ICefMenuButtonPressedLock); override;

    public
      constructor Create(const events: ICefMenuButtonDelegateEvents); reintroduce;
  end;

implementation

uses
  uCEFLibFunctions, uCEFMiscFunctions, uCEFMenuButton, uCEFMenuButtonPressedLock;


// **************************************************************
// **************** TCefMenuButtonDelegateRef *******************
// **************************************************************

procedure TCefMenuButtonDelegateRef.OnMenuButtonPressed(const menu_button         : ICefMenuButton;
                                                        const screen_point        : TCefPoint;
                                                        const button_pressed_lock : ICefMenuButtonPressedLock);
begin
  PCefMenuButtonDelegate(FData)^.on_menu_button_pressed(PCefMenuButtonDelegate(FData),
                                                        CefGetData(menu_button),
                                                        @screen_point,
                                                        CefGetData(button_pressed_lock));
end;

class function TCefMenuButtonDelegateRef.UnWrap(data: Pointer): ICefMenuButtonDelegate;
begin
  if (data <> nil) then
    Result := Create(data) as ICefMenuButtonDelegate
   else
    Result := nil;
end;


// **************************************************************
// **************** TCefMenuButtonDelegateOwn *******************
// **************************************************************

procedure cef_menubutton_delegate_on_menu_button_pressed(      self                : PCefMenuButtonDelegate;
                                                               menu_button         : PCefMenuButton;
                                                         const screen_point        : PCefPoint;
                                                               button_pressed_lock : PCefMenuButtonPressedLock); stdcall;
var
  TempObject : TObject;
begin
  TempObject := CefGetObject(self);

  if (TempObject <> nil) and (TempObject is TCefMenuButtonDelegateOwn) then
    TCefMenuButtonDelegateOwn(TempObject).OnMenuButtonPressed(TCefMenuButtonRef.UnWrap(menu_button),
                                                              screen_point^,
                                                              TCefMenuButtonPressedLockRef.UnWrap(button_pressed_lock));
end;

constructor TCefMenuButtonDelegateOwn.Create;
begin
  inherited CreateData(SizeOf(TCefMenuButtonDelegate));

  InitializeCEFMethods;
end;

procedure TCefMenuButtonDelegateOwn.InitializeCEFMethods;
begin
  inherited InitializeCEFMethods;

  with PCefMenuButtonDelegate(FData)^ do
    on_menu_button_pressed := {$IFDEF FPC}@{$ENDIF}cef_menubutton_delegate_on_menu_button_pressed;
end;

procedure TCefMenuButtonDelegateOwn.OnMenuButtonPressed(const menu_button         : ICefMenuButton;
                                                        const screen_point        : TCefPoint;
                                                        const button_pressed_lock : ICefMenuButtonPressedLock);
begin
  //
end;


// **************************************************************
// **************** TCustomMenuButtonDelegate *******************
// **************************************************************

constructor TCustomMenuButtonDelegate.Create(const events: ICefMenuButtonDelegateEvents);
begin
  inherited Create;

  FEvents := Pointer(events);
end;

procedure TCustomMenuButtonDelegate.OnGetPreferredSize(const view: ICefView; var aResult : TCefSize);
begin
  try
    if (FEvents <> nil) then
      ICefMenuButtonDelegateEvents(FEvents).doOnGetPreferredSize(view, aResult);
  except
    on e : exception do
      if CustomExceptionHandler('TCustomMenuButtonDelegate.OnGetPreferredSize', e) then raise;
  end;
end;

procedure TCustomMenuButtonDelegate.OnGetMinimumSize(const view: ICefView; var aResult : TCefSize);
begin
  try
    if (FEvents <> nil) then
      ICefMenuButtonDelegateEvents(FEvents).doOnGetMinimumSize(view, aResult);
  except
    on e : exception do
      if CustomExceptionHandler('TCustomMenuButtonDelegate.OnGetMinimumSize', e) then raise;
  end;
end;

procedure TCustomMenuButtonDelegate.OnGetMaximumSize(const view: ICefView; var aResult : TCefSize);
begin
  try
    if (FEvents <> nil) then
      ICefMenuButtonDelegateEvents(FEvents).doOnGetMaximumSize(view, aResult);
  except
    on e : exception do
      if CustomExceptionHandler('TCustomMenuButtonDelegate.OnGetMaximumSize', e) then raise;
  end;
end;

procedure TCustomMenuButtonDelegate.OnGetHeightForWidth(const view: ICefView; width: Integer; var aResult: Integer);
begin
  try
    if (FEvents <> nil) then
      ICefMenuButtonDelegateEvents(FEvents).doOnGetHeightForWidth(view, width, aResult);
  except
    on e : exception do
      if CustomExceptionHandler('TCustomMenuButtonDelegate.OnGetHeightForWidth', e) then raise;
  end;
end;

procedure TCustomMenuButtonDelegate.OnParentViewChanged(const view: ICefView; added: boolean; const parent: ICefView);
begin
  try
    if (FEvents <> nil) then
      ICefMenuButtonDelegateEvents(FEvents).doOnParentViewChanged(view, added, parent);
  except
    on e : exception do
      if CustomExceptionHandler('TCustomMenuButtonDelegate.OnParentViewChanged', e) then raise;
  end;
end;

procedure TCustomMenuButtonDelegate.OnChildViewChanged(const view: ICefView; added: boolean; const child: ICefView);
begin
  try
    if (FEvents <> nil) then
      ICefMenuButtonDelegateEvents(FEvents).doOnChildViewChanged(view, added, child);
  except
    on e : exception do
      if CustomExceptionHandler('TCustomMenuButtonDelegate.OnChildViewChanged', e) then raise;
  end;
end;

procedure TCustomMenuButtonDelegate.OnWindowChanged(const view: ICefView; added: boolean);
begin
  try
    if (FEvents <> nil) then
      ICefMenuButtonDelegateEvents(FEvents).doOnWindowChanged(view, added);
  except
    on e : exception do
      if CustomExceptionHandler('TCustomMenuButtonDelegate.OnWindowChanged', e) then raise;
  end;
end;

procedure TCustomMenuButtonDelegate.OnLayoutChanged(const view: ICefView; new_bounds: TCefRect);
begin
  try
    if (FEvents <> nil) then
      ICefMenuButtonDelegateEvents(FEvents).doOnLayoutChanged(view, new_bounds);
  except
    on e : exception do
      if CustomExceptionHandler('TCustomMenuButtonDelegate.OnLayoutChanged', e) then raise;
  end;
end;

procedure TCustomMenuButtonDelegate.OnFocus(const view: ICefView);
begin
  try
    if (FEvents <> nil) then
      ICefMenuButtonDelegateEvents(FEvents).doOnFocus(view);
  except
    on e : exception do
      if CustomExceptionHandler('TCustomMenuButtonDelegate.OnFocus', e) then raise;
  end;
end;

procedure TCustomMenuButtonDelegate.OnBlur(const view: ICefView);
begin
  try
    if (FEvents <> nil) then
      ICefMenuButtonDelegateEvents(FEvents).doOnBlur(view);
  except
    on e : exception do
      if CustomExceptionHandler('TCustomMenuButtonDelegate.OnBlur', e) then raise;
  end;
end;

procedure TCustomMenuButtonDelegate.OnButtonPressed(const button: ICefButton);
begin
  try
    if (FEvents <> nil) then
      ICefMenuButtonDelegateEvents(FEvents).doOnButtonPressed(button);
  except
    on e : exception do
      if CustomExceptionHandler('TCustomMenuButtonDelegate.OnButtonPressed', e) then raise;
  end;
end;

procedure TCustomMenuButtonDelegate.OnButtonStateChanged(const button: ICefButton);
begin
  try
    if (FEvents <> nil) then
      ICefMenuButtonDelegateEvents(FEvents).doOnButtonStateChanged(button);
  except
    on e : exception do
      if CustomExceptionHandler('TCustomMenuButtonDelegate.OnButtonStateChanged', e) then raise;
  end;
end;

procedure TCustomMenuButtonDelegate.OnMenuButtonPressed(const menu_button         : ICefMenuButton;
                                                        const screen_point        : TCefPoint;
                                                        const button_pressed_lock : ICefMenuButtonPressedLock);
begin
  try
    if (FEvents <> nil) then
      ICefMenuButtonDelegateEvents(FEvents).doOnMenuButtonPressed(menu_button, screen_point, button_pressed_lock);
  except
    on e : exception do
      if CustomExceptionHandler('TCustomMenuButtonDelegate.OnMenuButtonPressed', e) then raise;
  end;
end;

end.

