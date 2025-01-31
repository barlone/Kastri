unit DW.AudioPlayer;

{*******************************************************}
{                                                       }
{                      Kastri                           }
{                                                       }
{         Delphi Worlds Cross-Platform Library          }
{                                                       }
{  Copyright 2020-2021 Dave Nottage under MIT license   }
{  which is located in the root folder of this library  }
{                                                       }
{*******************************************************}

{$I DW.GlobalDefines.inc}

// NOTE: This feature is a work in progress, so please expect changes

interface

type
  TAudioPlayer = class;

  /// <summary>
  ///   State of audio
  /// </summary>
  /// <remarks>
  ///   Ready:      Audio has been preprared for playing
  ///   PlayStart:  Play has been called, but the audio has not necessarily started playing
  ///   Playing:    Audio has actually started to play (may be a slight delay after Play is called)
  ///   Stopped:    Audio has finished playing (to be implemented)
  /// </remarks>
  TAudioState = (Ready, PlayStart, Playing, Stopped);

  TAudioStateChangeEvent = procedure(Sender: TObject; const State: TAudioState) of object;

  TCustomPlatformAudioPlayer = class(TObject)
  private
    FAudioPlayer: TAudioPlayer;
    FIsReady: Boolean;
  protected
    procedure DoAudioStateChange(const AState: TAudioState); virtual;
    function GetDelay: Integer; virtual;
    procedure LoadFromFile(const AFileName: string); virtual;
    procedure SetIsReady(const AValue: Boolean);
    procedure Pause; virtual;
    procedure Play; virtual;
    property AudioPlayer: TAudioPlayer read FAudioPlayer;
    property IsReady: Boolean read FIsReady;
  public
    constructor Create(const AAudioPlayer: TAudioPlayer); virtual;
    destructor Destroy; override;
  end;

  TAudioPlayer = class(TObject)
  private
    FAudioState: TAudioState;
    FFileName: string;
    FPlatformAudioPlayer: TCustomPlatformAudioPlayer;
    FOnAudioStateChange: TAudioStateChangeEvent;
    function GetDelay: Integer;
  protected
    procedure DoAudioStateChange(const AState: TAudioState);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const AFileName: string);
    procedure Pause;
    procedure Play;
    property AudioState: TAudioState read FAudioState;
    /// <summary>
    ///   Represents the delay in milliseconds between the call to Play, and when the audio actually starts playing
    /// </summary>
    /// <remarks>
    ///   At present, implemented only on Android, since MediaPlayer seems to have a lag, even after having already called Prepare
    /// </remarks>
    property Delay: Integer read GetDelay;
    property FileName: string read FFileName;
    property OnAudioStateChange: TAudioStateChangeEvent read FOnAudioStateChange write FOnAudioStateChange;
  end;

implementation

{$IF Defined(IOS)}
uses
  DW.AudioPlayer.iOS;
{$ENDIF}
{$IF Defined(ANDROID)}
uses
  DW.AudioPlayer.Android;
{$ENDIF}

{$IF Defined(MSWINDOWS)}
type
  TPlatformAudioPlayer = class(TCustomPlatformAudioPlayer);
{$ENDIF}

{ TCustomPlatformAudioPlayer }

constructor TCustomPlatformAudioPlayer.Create(const AAudioPlayer: TAudioPlayer);
begin
  inherited Create;
  FAudioPlayer := AAudioPlayer;
end;

destructor TCustomPlatformAudioPlayer.Destroy;
begin
  //
  inherited;
end;

procedure TCustomPlatformAudioPlayer.DoAudioStateChange(const AState: TAudioState);
begin
  FAudioPlayer.DoAudioStateChange(AState);
end;

function TCustomPlatformAudioPlayer.GetDelay: Integer;
begin
  Result := 0;
end;

procedure TCustomPlatformAudioPlayer.LoadFromFile(const AFileName: string);
begin
  //
end;

procedure TCustomPlatformAudioPlayer.Pause;
begin
  //
end;

procedure TCustomPlatformAudioPlayer.Play;
begin
  //
end;

procedure TCustomPlatformAudioPlayer.SetIsReady(const AValue: Boolean);
begin
  if AValue <> FIsReady then
  begin
    FIsReady := AValue;
    DoAudioStateChange(TAudioState.Ready);
  end;
end;

{ TAudioPlayer }

constructor TAudioPlayer.Create;
begin
  inherited;
  FAudioState := TAudioState.Stopped;
  FPlatformAudioPlayer := TPlatformAudioPlayer.Create(Self);
end;

destructor TAudioPlayer.Destroy;
begin
  FPlatformAudioPlayer.Free;
  inherited;
end;

procedure TAudioPlayer.DoAudioStateChange(const AState: TAudioState);
begin
  FAudioState := AState;
  if Assigned(FOnAudioStateChange) then
    FOnAudioStateChange(Self, AState);
end;

function TAudioPlayer.GetDelay: Integer;
begin
  Result := FPlatformAudioPlayer.GetDelay;
end;

procedure TAudioPlayer.LoadFromFile(const AFileName: string);
begin
  FFileName := AFileName;
  FPlatformAudioPlayer.LoadFromFile(FFileName);
end;

procedure TAudioPlayer.Pause;
begin
  FPlatformAudioPlayer.Pause;
end;

procedure TAudioPlayer.Play;
begin
  DoAudioStateChange(TAudioState.PlayStart);
  FPlatformAudioPlayer.Play;
end;

end.
