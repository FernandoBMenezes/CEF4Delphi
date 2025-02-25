unit uCEFDisplay;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
{$ENDIF}

{$I cef.inc}

{$IFNDEF TARGET_64BITS}{$ALIGN ON}{$ENDIF}
{$MINENUMSIZE 4}

interface

uses
  {$IFDEF DELPHI16_UP}
  System.Classes, System.SysUtils, System.Types,
  {$ELSE}
  Classes, SysUtils, Types,
  {$ENDIF}
  uCEFBaseRefCounted, uCEFInterfaces, uCEFTypes;

type
  TCefDisplayRef = class(TCefBaseRefCountedRef, ICefDisplay)
    protected
      function  GetID : int64;
      function  GetDeviceScaleFactor : Single;
      procedure ConvertPointToPixels(var point: TCefPoint);
      procedure ConvertPointFromPixels(var point: TCefPoint);
      function  GetBounds : TCefRect;
      function  GetWorkArea : TCefRect;
      function  GetRotation : Integer;

    public
      class function UnWrap(data: Pointer): ICefDisplay;
      class function Primary: ICefDisplay;
      class function NearestPoint(const point: TCefPoint; input_pixel_coords: boolean): ICefDisplay;
      class function MatchingBounds(const bounds: TCefRect; input_pixel_coords: boolean): ICefDisplay;
      class function GetCount: NativeUInt;
      class function GetAlls(var aDisplayArray : TCefDisplayArray) : boolean;
      class function ScreenPointToPixels(const aScreenPoint : TPoint) : TPoint;
      class function ScreenPointFromPixels(const aPixelsPoint : TPoint) : TPoint;
      class function ScreenRectToPixels(const aScreenRect : TRect) : TRect;
      class function ScreenRectFromPixels(const aPixelsRect : TRect) : TRect;
  end;

implementation

uses
  uCEFLibFunctions, uCEFApplicationCore;

function TCefDisplayRef.GetID : int64;
begin
  Result := PCefDisplay(FData)^.get_id(PCefDisplay(FData));
end;

function TCefDisplayRef.GetDeviceScaleFactor : Single;
begin
  Result := PCefDisplay(FData)^.get_device_scale_factor(PCefDisplay(FData));
end;

procedure TCefDisplayRef.ConvertPointToPixels(var point: TCefPoint);
begin
  PCefDisplay(FData)^.convert_point_to_pixels(PCefDisplay(FData), @point);
end;

procedure TCefDisplayRef.ConvertPointFromPixels(var point: TCefPoint);
begin
  PCefDisplay(FData)^.convert_point_from_pixels(PCefDisplay(FData), @point);
end;

function TCefDisplayRef.GetBounds : TCefRect;
begin
  Result := PCefDisplay(FData)^.get_bounds(PCefDisplay(FData));
end;

function TCefDisplayRef.GetWorkArea : TCefRect;
begin
  Result := PCefDisplay(FData)^.get_work_area(PCefDisplay(FData));
end;

function TCefDisplayRef.GetRotation : Integer;
begin
  Result := PCefDisplay(FData)^.get_rotation(PCefDisplay(FData));
end;

class function TCefDisplayRef.UnWrap(data: Pointer): ICefDisplay;
begin
  if (data <> nil) then
    Result := Create(data) as ICefDisplay
   else
    Result := nil;
end;

class function TCefDisplayRef.Primary: ICefDisplay;
begin
  if assigned(GlobalCEFApp) and GlobalCEFApp.LibLoaded then
    Result := UnWrap(cef_display_get_primary())
   else
    Result := nil;
end;

class function TCefDisplayRef.NearestPoint(const point: TCefPoint; input_pixel_coords: boolean): ICefDisplay;
begin
  if assigned(GlobalCEFApp) and GlobalCEFApp.LibLoaded then
    Result := UnWrap(cef_display_get_nearest_point(@point, ord(input_pixel_coords)))
   else
    Result := nil;
end;

class function TCefDisplayRef.MatchingBounds(const bounds: TCefRect; input_pixel_coords: boolean): ICefDisplay;
begin
  if assigned(GlobalCEFApp) and GlobalCEFApp.LibLoaded then
    Result := UnWrap(cef_display_get_matching_bounds(@bounds, ord(input_pixel_coords)))
   else
    Result := nil;
end;

class function TCefDisplayRef.GetCount: NativeUInt;
begin
  if assigned(GlobalCEFApp) and GlobalCEFApp.LibLoaded then
    Result := cef_display_get_count()
   else
    Result := 0;
end;

class function TCefDisplayRef.GetAlls(var aDisplayArray : TCefDisplayArray) : boolean;
type
  TDisplayArray = array of PCefDisplay;
var
  i, displaysCount: NativeUInt;
  displays: PPCefDisplay;
  TempSize : integer;
begin
  Result := False;
  if (GlobalCEFApp = nil) or not(GlobalCEFApp.LibLoaded) then
    exit;

  displaysCount := GetCount;

  if (displaysCount > 0) then
    try
      TempSize := SizeOf(TCefDisplay) * displaysCount;
      GetMem(displays, TempSize);
      FillChar(displays, TempSize, 0);

      cef_display_get_alls(@displaysCount, displays);

      SetLength(aDisplayArray, displaysCount);

      i := 0;
      while (i < displaysCount) do
        begin
          aDisplayArray[i] := TCefDisplayRef.UnWrap(TDisplayArray(displays)[i]);
          inc(i);
        end;

      Result := True;
    finally
      FreeMem(displays);
    end;
end;

class function TCefDisplayRef.ScreenPointToPixels(const aScreenPoint : TPoint) : TPoint;
var
  TempScreenPt, TempPixelsPt : TCefPoint;
begin
  if assigned(GlobalCEFApp) and GlobalCEFApp.LibLoaded then
    begin
      TempScreenPt.x := aScreenPoint.X;
      TempScreenPt.y := aScreenPoint.Y;
      TempPixelsPt   := cef_display_convert_screen_point_to_pixels(@TempScreenPt);
      Result.X       := TempPixelsPt.x;
      Result.Y       := TempPixelsPt.y;
    end
   else
    Result := aScreenPoint;
end;

class function TCefDisplayRef.ScreenPointFromPixels(const aPixelsPoint : TPoint) : TPoint;
var
  TempScreenPt, TempPixelsPt : TCefPoint;
begin
  if assigned(GlobalCEFApp) and GlobalCEFApp.LibLoaded then
    begin
      TempPixelsPt.x := aPixelsPoint.X;
      TempPixelsPt.y := aPixelsPoint.Y;
      TempScreenPt   := cef_display_convert_screen_point_from_pixels(@TempPixelsPt);
      Result.X       := TempScreenPt.x;
      Result.Y       := TempScreenPt.y;
    end
   else
    Result := aPixelsPoint;
end;

class function TCefDisplayRef.ScreenRectToPixels(const aScreenRect : TRect) : TRect;
var
  TempScreenRc, TempPixelsRc : TCefRect;
begin
  if assigned(GlobalCEFApp) and GlobalCEFApp.LibLoaded then
    begin
      TempScreenRc.x := aScreenRect.Left;
      TempScreenRc.y := aScreenRect.Top;
      TempPixelsRc   := cef_display_convert_screen_rect_to_pixels(@TempScreenRc);
      Result.Left    := TempPixelsRc.x;
      Result.Top     := TempPixelsRc.y;
      Result.Right   := TempPixelsRc.x + TempPixelsRc.Width - 1;
      Result.Bottom  := TempPixelsRc.y + TempPixelsRc.Height - 1;
    end
   else
    Result := aScreenRect;
end;

class function TCefDisplayRef.ScreenRectFromPixels(const aPixelsRect : TRect) : TRect;
var
  TempScreenRc, TempPixelsRc : TCefRect;
begin
  if assigned(GlobalCEFApp) and GlobalCEFApp.LibLoaded then
    begin
      TempPixelsRc.x := aPixelsRect.Left;
      TempPixelsRc.y := aPixelsRect.Top;
      TempScreenRc   := cef_display_convert_screen_rect_from_pixels(@TempPixelsRc);
      Result.Left    := TempScreenRc.x;
      Result.Top     := TempScreenRc.y;
      Result.Right   := TempScreenRc.x + TempScreenRc.Width - 1;
      Result.Bottom  := TempScreenRc.y + TempScreenRc.Height - 1;
    end
   else
    Result := aPixelsRect;
end;

end.
