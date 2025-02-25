unit uCEFWindowComponent;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
{$ENDIF}

{$I cef.inc}

{$IFNDEF TARGET_64BITS}{$ALIGN ON}{$ENDIF}
{$MINENUMSIZE 4}

interface

uses
  {$IFDEF DELPHI16_UP}
    {$IFDEF MSWINDOWS}WinApi.Windows,{$ENDIF} System.Classes,
  {$ELSE}
    {$IFDEF MSWINDOWS}Windows,{$ENDIF} Classes,
    {$IFDEF FPC}
    LCLProc, LCLType, LCLIntf, LResources, InterfaceBase,
    {$ENDIF}
  {$ENDIF}
  uCEFTypes, uCEFInterfaces, uCEFConstants, uCEFViewsFrameworkEvents, uCEFPanelComponent;

type
  {$IFNDEF FPC}{$IFDEF DELPHI16_UP}[ComponentPlatformsAttribute(pfidWindows or pfidOSX or pfidLinux)]{$ENDIF}{$ENDIF}
  TCEFWindowComponent = class(TCEFPanelComponent, ICefWindowDelegateEvents)
    protected
      FWindow                       : ICefWindow;
      FWindowDlg                    : ICefWindowDelegate;

      // ICefWindowDelegateEvents
      FOnWindowCreated              : TOnWindowCreatedEvent;
      FOnWindowClosing              : TOnWindowClosingEvent;
      FOnWindowDestroyed            : TOnWindowDestroyedEvent;
      FOnWindowActivationChanged    : TOnWindowActivationChangedEvent;
      FOnWindowBoundsChanged        : TOnWindowBoundsChangedEvent;
      FOnGetParentWindow            : TOnGetParentWindowEvent;
      FOnIsWindowModalDialog        : TOnIsWindowModalDialogEvent;
      FOnGetInitialBounds           : TOnGetInitialBoundsEvent;
      FOnGetInitialShowState        : TOnGetInitialShowStateEvent;
      FOnIsFrameless                : TOnIsFramelessEvent;
      FOnWithStandardWindowButtons  : TOnWithStandardWindowButtonsEvent;
      FOnGetTitlebarHeight          : TOnGetTitlebarHeightEvent;
      FOnCanResize                  : TOnCanResizeEvent;
      FOnCanMaximize                : TOnCanMaximizeEvent;
      FOnCanMinimize                : TOnCanMinimizeEvent;
      FOnCanClose                   : TOnCanCloseEvent;
      FOnAccelerator                : TOnAcceleratorEvent;
      FOnKeyEvent                   : TOnWindowKeyEventEvent;
      FOnWindowFullscreenTransition : TOnWindowFullscreenTransitionEvent;

      procedure DestroyView; override;
      procedure Initialize; override;

      function  GetInitialized : boolean; override;
      function  GetAsView : ICefView; override;
      function  GetAsPanel : ICefPanel; override;
      function  GetAsWindow : ICefWindow; override;
      function  GetIsClosed : boolean;
      function  GetIsActive : boolean;
      function  GetIsAlwaysOnTop : boolean;
      function  GetIsMaximized : boolean;
      function  GetIsMinimized : boolean;
      function  GetIsFullscreen : boolean;
      function  GetTitle : ustring;
      function  GetWindowIcon : ICefImage;
      function  GetWindowAppIcon : ICefImage;
      function  GetDisplay : ICefDisplay;
      function  GetClientAreaBoundsInScreen : TCefRect;
      function  GetWindowHandle : TCefWindowHandle;

      procedure SetAlwaysOnTop(on_top: boolean);
      procedure SetFullscreen(fullscreen: boolean);
      procedure SetTitle(const title_: ustring);
      procedure SetWindowIcon(const image: ICefImage);
      procedure SetWindowAppIcon(const image: ICefImage);

      // ICefWindowDelegateEvents
      procedure doOnWindowCreated(const window_: ICefWindow);
      procedure doOnWindowClosing(const window_: ICefWindow);
      procedure doOnWindowDestroyed(const window_: ICefWindow);
      procedure doOnWindowActivationChanged(const window_: ICefWindow; active: boolean);
      procedure doOnWindowBoundsChanged(const window_: ICefWindow; const new_bounds: TCefRect);
      procedure doOnGetParentWindow(const window_: ICefWindow; var is_menu, can_activate_menu: boolean; var aResult : ICefWindow);
      procedure doOnIsWindowModalDialog(const window_: ICefWindow; var aResult : boolean);
      procedure doOnGetInitialBounds(const window_: ICefWindow; var aResult : TCefRect);
      procedure doOnGetInitialShowState(const window_: ICefWindow; var aResult : TCefShowState);
      procedure doOnIsFrameless(const window_: ICefWindow; var aResult : boolean);
      procedure doOnWithStandardWindowButtons(const window_: ICefWindow; var aResult : boolean);
      procedure doOnGetTitlebarHeight(const window_: ICefWindow; var titlebar_height: Single; var aResult : boolean);
      procedure doOnCanResize(const window_: ICefWindow; var aResult : boolean);
      procedure doOnCanMaximize(const window_: ICefWindow; var aResult : boolean);
      procedure doOnCanMinimize(const window_: ICefWindow; var aResult : boolean);
      procedure doOnCanClose(const window_: ICefWindow; var aResult : boolean);
      procedure doOnAccelerator(const window_: ICefWindow; command_id: Integer; var aResult : boolean);
      procedure doOnKeyEvent(const window_: ICefWindow; const event: TCefKeyEvent; var aResult : boolean);
      procedure doOnWindowFullscreenTransition(const window_: ICefWindow; is_completed: boolean);

      // ICefViewDelegateEvents
      procedure doCreateCustomView; override;

    public
      procedure CreateTopLevelWindow;
      procedure Show;
      procedure Hide;
      procedure CenterWindow(const size_: TCefSize);
      procedure Close;
      procedure Activate;
      procedure Deactivate;
      procedure BringToTop;
      procedure Maximize;
      procedure Minimize;
      procedure Restore;
      function  AddOverlayView(const view: ICefView; docking_mode: TCefDockingMode): ICefOverlayController;
      procedure ShowMenu(const menu_model: ICefMenuModel; const screen_point: TCefPoint; anchor_position : TCefMenuAnchorPosition);
      procedure CancelMenu;
      procedure SetDraggableRegions(regionsCount: NativeUInt; const regions: PCefDraggableRegionArray);
      procedure SendKeyPress(key_code: Integer; event_flags: cardinal);
      procedure SendMouseMove(screen_x, screen_y: Integer);
      procedure SendMouseEvents(button: TCefMouseButtonType; mouse_down, mouse_up: boolean);
      procedure SetAccelerator(command_id, key_code : Integer; shift_pressed, ctrl_pressed, alt_pressed: boolean);
      procedure RemoveAccelerator(command_id: Integer);
      procedure RemoveAllAccelerators;

      property Title                    : ustring            read GetTitle                     write SetTitle;
      property WindowIcon               : ICefImage          read GetWindowIcon                write SetWindowIcon;
      property WindowAppIcon            : ICefImage          read GetWindowAppIcon             write SetWindowAppIcon;
      property Display                  : ICefDisplay        read GetDisplay;
      property ClientAreaBoundsInScreen : TCefRect           read GetClientAreaBoundsInScreen;
      property WindowHandle             : TCefWindowHandle   read GetWindowHandle;
      property IsClosed                 : boolean            read GetIsClosed;
      property IsActive                 : boolean            read GetIsActive;
      property IsAlwaysOnTop            : boolean            read GetIsAlwaysOnTop             write SetAlwaysOnTop;
      property IsFullscreen             : boolean            read GetIsFullscreen              write SetFullscreen;
      property IsMaximized              : boolean            read GetIsMaximized;
      property IsMinimized              : boolean            read GetIsMinimized;

    published
      property OnWindowCreated              : TOnWindowCreatedEvent              read FOnWindowCreated              write FOnWindowCreated;
      property OnWindowClosing              : TOnWindowClosingEvent              read FOnWindowClosing              write FOnWindowClosing;
      property OnWindowDestroyed            : TOnWindowDestroyedEvent            read FOnWindowDestroyed            write FOnWindowDestroyed;
      property OnWindowActivationChanged    : TOnWindowActivationChangedEvent    read FOnWindowActivationChanged    write FOnWindowActivationChanged;
      property OnWindowBoundsChanged        : TOnWindowBoundsChangedEvent        read FOnWindowBoundsChanged        write FOnWindowBoundsChanged;
      property OnGetParentWindow            : TOnGetParentWindowEvent            read FOnGetParentWindow            write FOnGetParentWindow;
      property OnIsWindowModalDialog        : TOnIsWindowModalDialogEvent        read FOnIsWindowModalDialog        write FOnIsWindowModalDialog;
      property OnGetInitialBounds           : TOnGetInitialBoundsEvent           read FOnGetInitialBounds           write FOnGetInitialBounds;
      property OnGetInitialShowState        : TOnGetInitialShowStateEvent        read FOnGetInitialShowState        write FOnGetInitialShowState;
      property OnIsFrameless                : TOnIsFramelessEvent                read FOnIsFrameless                write FOnIsFrameless;
      property OnWithStandardWindowButtons  : TOnWithStandardWindowButtonsEvent  read FOnWithStandardWindowButtons  write FOnWithStandardWindowButtons;
      property OnGetTitlebarHeight          : TOnGetTitlebarHeightEvent          read FOnGetTitlebarHeight          write FOnGetTitlebarHeight;
      property OnCanResize                  : TOnCanResizeEvent                  read FOnCanResize                  write FOnCanResize;
      property OnCanMaximize                : TOnCanMaximizeEvent                read FOnCanMaximize                write FOnCanMaximize;
      property OnCanMinimize                : TOnCanMinimizeEvent                read FOnCanMinimize                write FOnCanMinimize;
      property OnCanClose                   : TOnCanCloseEvent                   read FOnCanClose                   write FOnCanClose;
      property OnAccelerator                : TOnAcceleratorEvent                read FOnAccelerator                write FOnAccelerator;
      property OnKeyEvent                   : TOnWindowKeyEventEvent             read FOnKeyEvent                   write FOnKeyEvent;
      property OnWindowFullscreenTransition : TOnWindowFullscreenTransitionEvent read FOnWindowFullscreenTransition write FOnWindowFullscreenTransition;
  end;

{$IFDEF FPC}
procedure Register;
{$ENDIF}

// *********************************************************
// ********************** ATTENTION ! **********************
// *********************************************************
// **                                                     **
// **  MANY OF THE EVENTS IN CEF4DELPHI COMPONENTS LIKE   **
// **  TCHROMIUM, TFMXCHROMIUM OR TCEFAPPLICATION ARE     **
// **  EXECUTED IN A CEF THREAD BY DEFAULT.               **
// **                                                     **
// **  WINDOWS CONTROLS MUST BE CREATED AND DESTROYED IN  **
// **  THE SAME THREAD TO AVOID ERRORS.                   **
// **  SOME OF THEM RECREATE THE HANDLERS IF THEY ARE     **
// **  MODIFIED AND CAN CAUSE THE SAME ERRORS.            **
// **                                                     **
// **  DON'T CREATE, MODIFY OR DESTROY WINDOWS CONTROLS   **
// **  INSIDE THE CEF4DELPHI EVENTS AND USE               **
// **  SYNCHRONIZATION OBJECTS TO PROTECT VARIABLES AND   **
// **  FIELDS IF THEY ARE ALSO USED IN THE MAIN THREAD.   **
// **                                                     **
// **  READ THIS FOR MORE INFORMATION :                   **
// **  https://www.briskbard.com/index.php?pageid=cef     **
// **                                                     **
// **  USE OUR FORUMS FOR MORE QUESTIONS :                **
// **  https://www.briskbard.com/forum/                   **
// **                                                     **
// *********************************************************
// *********************************************************

implementation

uses
  uCEFMiscFunctions, uCEFWindowDelegate, uCEFWindow, uCEFTask;

procedure TCEFWindowComponent.Initialize;
begin
  inherited Initialize;

  FWindow                       := nil;
  FWindowDlg                    := nil;
  FOnWindowCreated              := nil;
  FOnWindowClosing              := nil;
  FOnWindowDestroyed            := nil;
  FOnWindowActivationChanged    := nil;
  FOnWindowBoundsChanged        := nil;
  FOnGetParentWindow            := nil;
  FOnIsWindowModalDialog        := nil;
  FOnGetInitialBounds           := nil;
  FOnGetInitialShowState        := nil;
  FOnIsFrameless                := nil;
  FOnWithStandardWindowButtons  := nil;
  FOnGetTitlebarHeight          := nil;
  FOnCanResize                  := nil;
  FOnCanMaximize                := nil;
  FOnCanMinimize                := nil;
  FOnCanClose                   := nil;
  FOnAccelerator                := nil;
  FOnKeyEvent                   := nil;
  FOnWindowFullscreenTransition := nil;
end;

procedure TCEFWindowComponent.CreateTopLevelWindow;
begin
  CreateView;
end;

procedure TCEFWindowComponent.doCreateCustomView;
var
  TempWindow   : ICefWindow;
begin
  if (FWindow = nil) then
    begin
      if (FWindowDlg = nil) then
        FWindowDlg := TCustomWindowDelegate.Create(self);

      TempWindow := TCefWindowRef.CreateTopLevel(FWindowDlg);

      if (FWindow = nil) then FWindow := TempWindow;
    end;
end;

procedure TCEFWindowComponent.DestroyView;
begin
  if (FWindowDlg <> nil) then
    begin
      FWindowDlg.DestroyOtherRefs;
      FWindowDlg := nil;
    end;

  FWindow := nil;
end;

function TCEFWindowComponent.GetInitialized : boolean;
begin
  Result := (FWindow <> nil);
end;

function TCEFWindowComponent.GetAsView : ICefView;
begin
  Result := FWindow as ICefView;
end;

function TCEFWindowComponent.GetAsPanel : ICefPanel;
begin
  if Initialized then
    Result := FWindow as ICefPanel
   else
    Result := nil;
end;

function TCEFWindowComponent.GetAsWindow : ICefWindow;
begin
  Result := FWindow;
end;

procedure TCEFWindowComponent.doOnWindowCreated(const window_: ICefWindow);
begin
  if (FWindow = nil) then FWindow := window_;

  if assigned(FOnWindowCreated) then
    FOnWindowCreated(self, window_);
end;

procedure TCEFWindowComponent.doOnWindowClosing(const window_: ICefWindow);
begin
  if assigned(FOnWindowClosing) then
    FOnWindowClosing(self, window_);
end;

procedure TCEFWindowComponent.doOnWindowDestroyed(const window_: ICefWindow);
begin
  if assigned(FOnWindowDestroyed) then
    FOnWindowDestroyed(self, window_);

  FWindow := nil;
end;

procedure TCEFWindowComponent.doOnWindowActivationChanged(const window_: ICefWindow; active: boolean);
begin
  if assigned(FOnWindowActivationChanged) then
    FOnWindowActivationChanged(self, window_, active);
end;

procedure TCEFWindowComponent.doOnWindowBoundsChanged(const window_: ICefWindow; const new_bounds: TCefRect);
begin
  if assigned(FOnWindowBoundsChanged) then
    FOnWindowBoundsChanged(self, window_, new_bounds);
end;

procedure TCEFWindowComponent.doOnGetParentWindow(const window_: ICefWindow; var is_menu, can_activate_menu: boolean; var aResult : ICefWindow);
begin
  if assigned(FOnGetParentWindow) then
    FOnGetParentWindow(self, window_, is_menu, can_activate_menu, aResult);
end;

procedure TCEFWindowComponent.doOnIsWindowModalDialog(const window_: ICefWindow; var aResult : boolean);
begin
  if assigned(FOnIsWindowModalDialog) then
    FOnIsWindowModalDialog(self, window_, aResult);
end;

procedure TCEFWindowComponent.doOnGetInitialBounds(const window_: ICefWindow; var aResult : TCefRect);
begin
  if assigned(FOnGetInitialBounds) then
    FOnGetInitialBounds(self, window_, aResult);
end;

procedure TCEFWindowComponent.doOnGetInitialShowState(const window_: ICefWindow; var aResult : TCefShowState);
begin
  if assigned(FOnGetInitialShowState) then
    FOnGetInitialShowState(self, window_, aResult);
end;

procedure TCEFWindowComponent.doOnIsFrameless(const window_: ICefWindow; var aResult : boolean);
begin
  if assigned(FOnIsFrameless) then
    FOnIsFrameless(self, window_, aResult);
end;

procedure TCEFWindowComponent.doOnWithStandardWindowButtons(const window_: ICefWindow; var aResult : boolean);
begin
  if assigned(FOnWithStandardWindowButtons) then
    FOnWithStandardWindowButtons(self, window_, aResult);
end;

procedure TCEFWindowComponent.doOnGetTitlebarHeight(const window_: ICefWindow; var titlebar_height: Single; var aResult : boolean);
begin
  if assigned(FOnGetTitlebarHeight) then
    FOnGetTitlebarHeight(self, window_, titlebar_height, aResult);
end;

procedure TCEFWindowComponent.doOnCanResize(const window_: ICefWindow; var aResult : boolean);
begin
  if assigned(FOnCanResize) then
    FOnCanResize(self, window_, aResult);
end;

procedure TCEFWindowComponent.doOnCanMaximize(const window_: ICefWindow; var aResult : boolean);
begin
  if assigned(FOnCanMaximize) then
    FOnCanMaximize(self, window_, aResult);
end;

procedure TCEFWindowComponent.doOnCanMinimize(const window_: ICefWindow; var aResult : boolean);
begin
  if assigned(FOnCanMinimize) then
    FOnCanMinimize(self, window_, aResult);
end;

procedure TCEFWindowComponent.doOnCanClose(const window_: ICefWindow; var aResult : boolean);
begin
  if assigned(FOnCanClose) then
    FOnCanClose(self, window_, aResult);
end;

procedure TCEFWindowComponent.doOnAccelerator(const window_: ICefWindow; command_id: Integer; var aResult : boolean);
begin
  if assigned(FOnAccelerator) then
    FOnAccelerator(self, window_, command_id, aResult);
end;

procedure TCEFWindowComponent.doOnKeyEvent(const window_: ICefWindow; const event: TCefKeyEvent; var aResult : boolean);
begin
  if assigned(FOnKeyEvent) then
    FOnKeyEvent(self, window_, event, aResult);
end;

procedure TCEFWindowComponent.doOnWindowFullscreenTransition(const window_: ICefWindow; is_completed: boolean);
begin
  if assigned(FOnWindowFullscreenTransition) then
    FOnWindowFullscreenTransition(self, window_, is_completed);
end;

procedure TCEFWindowComponent.Show;
begin
  if Initialized then FWindow.Show;
end;

procedure TCEFWindowComponent.Hide;
begin
  if Initialized then FWindow.Hide;
end;

procedure TCEFWindowComponent.CenterWindow(const size_: TCefSize);
begin
  if Initialized then FWindow.CenterWindow(size_);
end;

procedure TCEFWindowComponent.Close;
begin
  if Initialized then FWindow.Close;
end;

function TCEFWindowComponent.GetIsClosed : boolean;
begin
  Result := Initialized and FWindow.IsClosed;
end;

procedure TCEFWindowComponent.Activate;
begin
  if Initialized then FWindow.Activate;
end;

procedure TCEFWindowComponent.Deactivate;
begin
  if Initialized then FWindow.Deactivate;
end;

function TCEFWindowComponent.GetIsActive : boolean;
begin
  Result := Initialized and FWindow.IsActive;
end;

procedure TCEFWindowComponent.BringToTop;
begin
  if Initialized then FWindow.BringToTop;
end;

procedure TCEFWindowComponent.SetAlwaysOnTop(on_top: boolean);
begin
  if Initialized then FWindow.SetAlwaysOnTop(on_top);
end;

function TCEFWindowComponent.GetIsAlwaysOnTop : boolean;
begin
  Result := Initialized and FWindow.IsAlwaysOnTop;
end;

procedure TCEFWindowComponent.Maximize;
begin
  if Initialized then FWindow.Maximize;
end;

procedure TCEFWindowComponent.Minimize;
begin
  if Initialized then FWindow.Minimize;
end;

procedure TCEFWindowComponent.Restore;
begin
  if Initialized then FWindow.Restore;
end;

procedure TCEFWindowComponent.SetFullscreen(fullscreen: boolean);
begin
  if Initialized then FWindow.SetFullscreen(fullscreen);
end;

function TCEFWindowComponent.GetIsMaximized : boolean;
begin
  Result := Initialized and FWindow.IsMaximized;
end;

function TCEFWindowComponent.GetIsMinimized : boolean;
begin
  Result := Initialized and FWindow.IsMinimized;
end;

function TCEFWindowComponent.GetIsFullscreen : boolean;
begin
  Result := Initialized and FWindow.IsFullscreen;
end;

procedure TCEFWindowComponent.SetTitle(const title_: ustring);
begin
  if Initialized then FWindow.SetTitle(title_);
end;

function TCEFWindowComponent.GetTitle : ustring;
begin
  if Initialized then
    Result := FWindow.GetTitle
   else
    Result := '';
end;

procedure TCEFWindowComponent.SetWindowIcon(const image: ICefImage);
begin
  if Initialized then FWindow.SetWindowIcon(image);
end;

function TCEFWindowComponent.GetWindowIcon : ICefImage;
begin
  if Initialized then
    Result := FWindow.GetWindowIcon
   else
    Result := nil;
end;

procedure TCEFWindowComponent.SetWindowAppIcon(const image: ICefImage);
begin
  if Initialized then FWindow.SetWindowAppIcon(image);
end;

function TCEFWindowComponent.GetWindowAppIcon : ICefImage;
begin
  if Initialized then
    Result := FWindow.GetWindowAppIcon
   else
    Result := nil;
end;

function TCEFWindowComponent.AddOverlayView(const view: ICefView; docking_mode: TCefDockingMode): ICefOverlayController;
begin
  if Initialized then
    Result := FWindow.AddOverlayView(view, docking_mode)
   else
    Result := nil;
end;

procedure TCEFWindowComponent.ShowMenu(const menu_model: ICefMenuModel; const screen_point: TCefPoint; anchor_position : TCefMenuAnchorPosition);
begin
  if Initialized then FWindow.ShowMenu(menu_model, screen_point, anchor_position);
end;

procedure TCEFWindowComponent.CancelMenu;
begin
  if Initialized then FWindow.CancelMenu;
end;

function TCEFWindowComponent.GetDisplay : ICefDisplay;
begin
  if Initialized then
    Result := FWindow.GetDisplay
   else
    Result := nil;
end;

function TCEFWindowComponent.GetClientAreaBoundsInScreen : TCefRect;
var
  TempRect : TCefRect;
begin
  if Initialized then
    TempRect := FWindow.GetClientAreaBoundsInScreen
   else
    begin
      TempRect.x      := 0;
      TempRect.y      := 0;
      TempRect.width  := 0;
      TempRect.height := 0;
    end;

  Result := TempRect;
end;

procedure TCEFWindowComponent.SetDraggableRegions(regionsCount: NativeUInt; const regions: PCefDraggableRegionArray);
begin
  if Initialized then FWindow.SetDraggableRegions(regionsCount, regions);
end;

function TCEFWindowComponent.GetWindowHandle : TCefWindowHandle;
var
  TempHandle : TCefWindowHandle;
begin
  InitializeWindowHandle(TempHandle);
  if Initialized then TempHandle := FWindow.GetWindowHandle;
  Result := TempHandle;
end;

procedure TCEFWindowComponent.SendKeyPress(key_code: Integer; event_flags: cardinal);
begin
  if Initialized then FWindow.SendKeyPress(key_code, event_flags);
end;

procedure TCEFWindowComponent.SendMouseMove(screen_x, screen_y: Integer);
begin
  if Initialized then FWindow.SendMouseMove(screen_x, screen_y);
end;

procedure TCEFWindowComponent.SendMouseEvents(button: TCefMouseButtonType; mouse_down, mouse_up: boolean);
begin
  if Initialized then FWindow.SendMouseEvents(button, mouse_down, mouse_up);
end;

procedure TCEFWindowComponent.SetAccelerator(command_id, key_code : Integer; shift_pressed, ctrl_pressed, alt_pressed: boolean);
begin
  if Initialized then FWindow.SetAccelerator(command_id, key_code, shift_pressed, ctrl_pressed, alt_pressed);
end;

procedure TCEFWindowComponent.RemoveAccelerator(command_id: Integer);
begin
  if Initialized then FWindow.RemoveAccelerator(command_id);
end;

procedure TCEFWindowComponent.RemoveAllAccelerators;
begin
  if Initialized then FWindow.RemoveAllAccelerators;
end;

{$IFDEF FPC}
procedure Register;
begin
  {$I res/tcefwindowcomponent.lrs}
  RegisterComponents('Chromium Views Framework', [TCEFWindowComponent]);
end;
{$ENDIF}

end.
