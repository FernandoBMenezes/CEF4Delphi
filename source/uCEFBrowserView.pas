unit uCEFBrowserView;

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
  uCEFBaseRefCounted, uCEFInterfaces, uCEFTypes, uCEFView;

type
  TCefBrowserViewRef = class(TCefViewRef, ICefBrowserView)
    protected
      function  GetBrowser : ICefBrowser;
      function  GetChromeToolbar : ICefView;
      procedure SetPreferAccelerators(prefer_accelerators: boolean);

    public
      class function UnWrap(data: Pointer): ICefBrowserView;
      class function CreateBrowserView(const client: ICefClient; const url: ustring; const settings: TCefBrowserSettings; const extra_info: ICefDictionaryValue; const request_context: ICefRequestContext; const delegate: ICefBrowserViewDelegate): ICefBrowserView;
      class function GetForBrowser(const browser: ICefBrowser): ICefBrowserView;
  end;

implementation

uses
  uCEFLibFunctions, uCEFMiscFunctions, uCEFBrowser;

function TCefBrowserViewRef.GetBrowser : ICefBrowser;
begin
  Result := TCefBrowserRef.UnWrap(PCefBrowserView(FData)^.get_browser(PCefBrowserView(FData)));
end;

function TCefBrowserViewRef.GetChromeToolbar : ICefView;
begin
  Result := TCefViewRef.UnWrap(PCefBrowserView(FData)^.get_chrome_toolbar(PCefBrowserView(FData)));
end;

procedure TCefBrowserViewRef.SetPreferAccelerators(prefer_accelerators: boolean);
begin
  PCefBrowserView(FData)^.set_prefer_accelerators(PCefBrowserView(FData),
                                                  ord(prefer_accelerators));
end;

class function TCefBrowserViewRef.UnWrap(data: Pointer): ICefBrowserView;
begin
  if (data <> nil) then
    Result := Create(data) as ICefBrowserView
   else
    Result := nil;
end;

class function TCefBrowserViewRef.CreateBrowserView(const client          : ICefClient;
                                                    const url             : ustring;
                                                    const settings        : TCefBrowserSettings;
                                                    const extra_info      : ICefDictionaryValue;
                                                    const request_context : ICefRequestContext;
                                                    const delegate        : ICefBrowserViewDelegate): ICefBrowserView;

var
  TempURL         : TCefString;
  TempBrowserView : PCefBrowserView;
begin
  Result := nil;

  if (client <> nil) and (delegate <> nil) then
    begin
      TempURL         := CefString(url);
      TempBrowserView := cef_browser_view_create(CefGetData(client),
                                                 @TempURL,
                                                 @settings,
                                                 CefGetData(extra_info),
                                                 CefGetData(request_context),
                                                 CefGetData(delegate));

      if (TempBrowserView <> nil) then
        Result := Create(TempBrowserView) as ICefBrowserView;
    end;
end;

class function TCefBrowserViewRef.GetForBrowser(const browser: ICefBrowser): ICefBrowserView;
var
  TempBrowserView : PCefBrowserView;
begin
  Result := nil;

  if (browser <> nil) then
    begin
      TempBrowserView := cef_browser_view_get_for_browser(CefGetData(browser));

      if (TempBrowserView <> nil) then
        Result := Create(TempBrowserView) as ICefBrowserView;
    end;
end;

end.

