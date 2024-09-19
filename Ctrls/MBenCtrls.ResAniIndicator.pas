unit MBenCtrls.ResAniIndicator;

interface

uses
  System.Classes,
  System.SysUtils,
  FMX.Types,
  FMX.Objects,
  FMX.Graphics,
  FMX.Ani,
  FMX.Controls.Presentation,
  API.MBenCtrls.Types;

type
  TLoopCount = 1..100; // Customizable ..

  TMP_Animation = class(TMBenPersistent)
  private
    [Weak] fAnimation: TBitmapListAnimation;
    fResourceName: string;
    fFrameCount: Integer;
    fRowCount: Integer;
    fDuration: Single;
    fActive: Boolean;
    fLoopCount: TLoopCount;

    procedure SetResourceName(const aValue: string);
    procedure SetFrameCount(const aValue: Integer);
    procedure SetRowCount(const aValue: Integer);
    procedure SetDuration(const aValue: Single);
    procedure SetActive(const aValue: Boolean);
    procedure SetLoopCount(const aValue: TLoopCount);

    procedure InitializeAnimation;
    procedure UpdateAnimation;
    procedure GetFirstFrame; inline;
    procedure LoadBitmapFramesFromResource;
  protected
    procedure Clear; override;
  public
    constructor Create(aOwner: TPersistent); override;
    destructor Destroy; override;
  published
    property ResourceName: string read fResourceName write SetResourceName;
    property FrameCount: Integer read fFrameCount write SetFrameCount default 1;
    property RowCount: Integer read fRowCount write SetRowCount default 1;
    property Duration: Single read fDuration write SetDuration;
    property Active: Boolean read fActive write SetActive default False;
    property LoopCount: TLoopCount read fLoopCount write SetLoopCount default 1;
  end;

  TResAniIndicator = class(TImage)
  private
    fAniSettings: TMP_Animation;
    fLooppedCount: Cardinal;

    fOnProcess,
    FOnFinish,
    fOnTerminateLoop: TNotifyEvent;

    procedure DoOnProcess(aSender: TObject);
    procedure DoOnFinish(aSender: TObject);
    procedure DoOnTerminateLoop(aSender: TObject);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure UpdateResourceName(const aResName: string);
  published
    property Animation: TMP_Animation read fAniSettings write fAniSettings;
    property OnProcess: TNotifyEvent read FOnProcess write FOnProcess;
    property OnFinish: TNotifyEvent read fOnFinish write fOnFinish;
    property OnTerminateLoop: TNotifyEvent read fOnTerminateLoop write fOnTerminateLoop;
    property LoopedCount: Cardinal read fLooppedCount;

  {$REGION '  Inherited .. '}
    property Align;
    property Anchors;
    property BitmapMargins;
    property ClipChildren default False;
    property ClipParent default False;
    property Cursor;
    property DisableInterpolation;
    property DragMode;
    property EnableDragHighlight;
    property Enabled;
    property Locked;
    property Height;
    property Hint;
    property HitTest default True;
    property Padding;
    property Margins;
    property Opacity;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property Visible default True;
    property Width;
    property WrapMode;
    property ParentShowHint;
    property ShowHint;
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnPainting;
    property OnPaint;
    property OnResize;
    property OnResized;
  {$ENDREGION}
  end;

procedure Register;

implementation

uses
  System.Types,
  System.UITypes;

{ TMP_Animation }

{$REGION '  TMP_Animation .. '}
procedure TMP_Animation.GetFirstFrame;
var
  LFrameWidth, LFrameHeight: Integer;
  LSrcRect: TRectF;
  LFirstFrameBitmap: TBitmap;
begin
  if (fAnimation.AnimationBitmap = nil) or
     (fAnimation.AnimationCount = 0) or
     (fAnimation.AnimationRowCount = 0) then
    Exit;

  // Calculate the width and height of each frame
  LFrameWidth  := fAnimation.AnimationBitmap.Width div
                 (fAnimation.AnimationCount div fAnimation.AnimationRowCount);

  LFrameHeight := fAnimation.AnimationBitmap.Height div fAnimation.AnimationRowCount;

  LSrcRect := TRectF.Create(0, 0, LFrameWidth, LFrameHeight);

  LFirstFrameBitmap := TBitmap.Create(LFrameWidth, LFrameHeight);
  try
    LFirstFrameBitmap.Canvas.BeginScene;
    try
      LFirstFrameBitmap.Canvas.Clear(TAlphaColorRec.Null);  // Clear the canvas first
      LFirstFrameBitmap.Canvas
        .DrawBitmap(fAnimation.AnimationBitmap,
                    LSrcRect, TRectF.Create(0, 0, LFrameWidth, LFrameHeight), 1, True);
    finally
      LFirstFrameBitmap.Canvas.EndScene;
    end;
    TResAniIndicator(ParentControl).Bitmap.Assign(LFirstFrameBitmap);
  finally
    LFirstFrameBitmap.Free;
  end;
end;

procedure TMP_Animation.LoadBitmapFramesFromResource;
var
  LResStream: TResourceStream;
begin
  if fResourceName.IsEmpty then Exit;
//    raise Exception.Create('Resource name is empty!');
  if Assigned(fAnimation) then begin

    LResStream := TResourceStream.Create(HInstance, fResourceName, RT_RCDATA);
    try
      fAnimation.AnimationBitmap.LoadFromStream(LResStream);
      GetFirstFrame;

    finally
      LResStream.Free;
      UpdateAnimation;
    end;
  end;
end;

procedure TMP_Animation.UpdateAnimation;
begin
  if Assigned(fAnimation) then begin

    fAnimation.AnimationCount    := fFrameCount;
    fAnimation.AnimationRowCount := fRowCount;
    fAnimation.Duration          := fDuration;
  end;
end;

procedure TMP_Animation.InitializeAnimation;
begin
  if not Assigned(fAnimation) then begin

    fAnimation := TBitmapListAnimation.Create(TResAniIndicator(ParentControl));
    try
      fAnimation.Parent            := TResAniIndicator(ParentControl);
      fAnimation.PropertyName      := 'Bitmap';
      fAnimation.Loop              := False;
      fAnimation.AnimationCount    := fFrameCount;
      fAnimation.AnimationRowCount := fRowCount;
      fAnimation.Duration          := fDuration;
      fAnimation.AnimationType     := TAnimationType.In;
    finally
      fAnimation.Enabled := fActive;
    end;
  end;
end;

constructor TMP_Animation.Create(aOwner: TPersistent);
begin inherited Create(aOwner);

  fFrameCount := 1;
  fRowCount   := 1;
  fDuration   := 1.5;
  fActive     := False;
  fLoopCount  := 1;
  fAnimation  := nil;
end;

procedure TMP_Animation.Clear;
begin
  if Assigned(fAnimation) then begin
    fAnimation.Enabled := False;
    fAnimation.Parent := nil;
    FreeAndNil(fAnimation);
  end;

end;

destructor TMP_Animation.Destroy;
begin
  Clear;

  inherited;
end;

procedure TMP_Animation.SetResourceName(const aValue: string);
begin
  if fResourceName <> aValue then
  begin
    fResourceName := aValue;
    UpdateAnimation;
  end;
end;

procedure TMP_Animation.SetFrameCount(const aValue: Integer);
begin
  if fFrameCount <> aValue then
  begin
    fFrameCount := aValue;
    UpdateAnimation;
  end;
end;

procedure TMP_Animation.SetLoopCount(const aValue: TLoopCount);
begin
  if fLoopCount <> aValue then
  begin
    fLoopCount := aValue;
  end;
end;

procedure TMP_Animation.SetRowCount(const aValue: Integer);
begin
  if fRowCount <> aValue then
  begin
    fRowCount := aValue;
    UpdateAnimation;
  end;
end;

procedure TMP_Animation.SetDuration(const aValue: Single);
begin
  if fDuration <> aValue then
  begin
    fDuration := aValue;
    UpdateAnimation;
  end;
end;

procedure TMP_Animation.SetActive(const aValue: Boolean);
begin
  if fActive <> aValue then
  begin
    if aValue then
      TResAniIndicator(ParentControl).fLooppedCount := 0;

    fActive := aValue;
    UpdateAnimation;

    if Assigned(fAnimation) then
    begin
      if aValue then
        fAnimation.Start else
        fAnimation.Stop;
    end;

  end;
end;
{$ENDREGION}

{ TResAniIndicator }

constructor TResAniIndicator.Create(AOwner: TComponent);
begin inherited Create(AOwner);

  fOnProcess       := nil;
  FOnFinish        := nil;
  fOnTerminateLoop := nil;
  fAniSettings     := TMP_Animation.Create(Self);

  fLooppedCount    := 0;

end;

destructor TResAniIndicator.Destroy;
begin
  if Assigned(fAniSettings) then
    if Assigned(fAniSettings.fAnimation) then begin
      fAniSettings.Active := False;
      fAniSettings.Free;
    end;

  inherited Destroy;
end;

procedure TResAniIndicator.DoOnTerminateLoop(aSender: TObject);
begin
  TThread.Synchronize(nil, procedure begin
    if Assigned(fOnTerminateLoop) then
      fOnTerminateLoop(aSender);

    fAniSettings.Active := False;
    fLooppedCount := 0;
  end);
end;

procedure TResAniIndicator.DoOnFinish(aSender: TObject);
begin
  TThread.Synchronize(nil, procedure begin

    inc(fLooppedCount);

    if Assigned(fOnFinish) then
      fOnFinish(aSender);

    if fLooppedCount >= fAniSettings.fLoopCount then
      DoOnTerminateLoop(aSender) else
      fAniSettings.fAnimation.Start;

  end);

end;

procedure TResAniIndicator.DoOnProcess(aSender: TObject);
begin
  TThread.Synchronize(nil, procedure begin
    if Assigned(fOnProcess) then
      fOnProcess(aSender);
  end);
end;

procedure TResAniIndicator.Loaded;
begin inherited Loaded;

  if [csDesigning, csReading, csLoading] * ComponentState = [] then begin
    fAniSettings.InitializeAnimation;
    fAniSettings.fAnimation.OnProcess := DoOnProcess;
    fAniSettings.fAnimation.OnFinish  := DoOnFinish;
    fAniSettings.LoadBitmapFramesFromResource;

    fAniSettings.fAnimation.Enabled := fAniSettings.fActive;
  end;
end;

procedure TResAniIndicator.Notification(AComponent: TComponent;
  Operation: TOperation);
begin inherited Notification(AComponent, Operation);
end;

procedure TResAniIndicator.UpdateResourceName(const aResName: string);
begin
  fAniSettings.fResourceName := aResName;
  fAniSettings.LoadBitmapFramesFromResource;
end;

procedure Register;
begin
  RegisterComponents('MBenControls', [TResAniIndicator]);
end;

end.
