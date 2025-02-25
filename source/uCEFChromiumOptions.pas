unit uCEFChromiumOptions;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
{$ENDIF}

{$I cef.inc}

{$IFNDEF TARGET_64BITS}{$ALIGN ON}{$ENDIF}
{$MINENUMSIZE 4}

interface

uses
  {$IFDEF DELPHI16_UP}
  System.Classes,
  {$ELSE}
  Classes,
  {$ENDIF}
  uCEFTypes, uCEFConstants;

type
  TChromiumOptions = class(TPersistent)
    protected
      FWindowlessFrameRate         : Integer;
      FJavascript                  : TCefState;
      FJavascriptCloseWindows      : TCefState;
      FJavascriptAccessClipboard   : TCefState;
      FJavascriptDomPaste          : TCefState;
      FImageLoading                : TCefState;
      FImageShrinkStandaloneToFit  : TCefState;
      FTextAreaResize              : TCefState;
      FTabToLinks                  : TCefState;
      FLocalStorage                : TCefState;
      FDatabases                   : TCefState;
      FWebgl                       : TCefState;
      FBackgroundColor             : TCefColor;
      FAcceptLanguageList          : ustring;
      FChromeStatusBubble          : TCefState;

    public
      constructor Create; virtual;

    published
      property Javascript                  : TCefState read FJavascript                   write FJavascript                  default STATE_DEFAULT;
      property JavascriptCloseWindows      : TCefState read FJavascriptCloseWindows       write FJavascriptCloseWindows      default STATE_DEFAULT;
      property JavascriptAccessClipboard   : TCefState read FJavascriptAccessClipboard    write FJavascriptAccessClipboard   default STATE_DEFAULT;
      property JavascriptDomPaste          : TCefState read FJavascriptDomPaste           write FJavascriptDomPaste          default STATE_DEFAULT;
      property ImageLoading                : TCefState read FImageLoading                 write FImageLoading                default STATE_DEFAULT;
      property ImageShrinkStandaloneToFit  : TCefState read FImageShrinkStandaloneToFit   write FImageShrinkStandaloneToFit  default STATE_DEFAULT;
      property TextAreaResize              : TCefState read FTextAreaResize               write FTextAreaResize              default STATE_DEFAULT;
      property TabToLinks                  : TCefState read FTabToLinks                   write FTabToLinks                  default STATE_DEFAULT;
      property LocalStorage                : TCefState read FLocalStorage                 write FLocalStorage                default STATE_DEFAULT;
      property Databases                   : TCefState read FDatabases                    write FDatabases                   default STATE_DEFAULT;
      property Webgl                       : TCefState read FWebgl                        write FWebgl                       default STATE_DEFAULT;
      property BackgroundColor             : TCefColor read FBackgroundColor              write FBackgroundColor             default 0;
      property AcceptLanguageList          : ustring   read FAcceptLanguageList           write FAcceptLanguageList;
      property WindowlessFrameRate         : Integer   read FWindowlessFrameRate          write FWindowlessFrameRate         default CEF_OSR_FRAMERATE_DEFAULT;
      property ChromeStatusBubble          : TCefState read FChromeStatusBubble           write FChromeStatusBubble          default STATE_DEFAULT;
  end;

implementation

constructor TChromiumOptions.Create;
begin
  FWindowlessFrameRate         := CEF_OSR_FRAMERATE_DEFAULT;  // Use CEF_OSR_SHARED_TEXTURES_FRAMERATE_DEFAULT if the shared textures are enabled.
  FJavascript                  := STATE_DEFAULT;
  FJavascriptCloseWindows      := STATE_DEFAULT;
  FJavascriptAccessClipboard   := STATE_DEFAULT;
  FJavascriptDomPaste          := STATE_DEFAULT;
  FImageLoading                := STATE_DEFAULT;
  FImageShrinkStandaloneToFit  := STATE_DEFAULT;
  FTextAreaResize              := STATE_DEFAULT;
  FTabToLinks                  := STATE_DEFAULT;
  FLocalStorage                := STATE_DEFAULT;
  FDatabases                   := STATE_DEFAULT;
  FWebgl                       := STATE_DEFAULT;
  FBackgroundColor             := 0;
  FChromeStatusBubble          := STATE_DEFAULT;
end;

end.
