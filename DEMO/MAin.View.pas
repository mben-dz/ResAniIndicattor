unit MAin.View;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs
, FMX.Objects
, FMX.StdCtrls
, FMX.Controls.Presentation
, MBenCtrls.ResAniIndicator, FMX.Ani, FMX.Layouts, FMX.TabControl
;

type
  TMainView = class(TForm)
    BtnStartStop: TButton;
    Lyt_Main: TLayout;
    Rect_Main: TRectangle;
    Lyt_Top: TLayout;
    Lyt_Bottom: TLayout;
    Lyt_Client: TLayout;
    Lyt_SysBar: TLayout;
    Rect_Title: TRectangle;
    Lyt_Tool: TLayout;
    Rect_Tool: TRectangle;
    Rect_Status: TRectangle;
    Txt_Title: TText;
    TabView: TTabControl;
    Tab_Loading: TTabItem;
    Tab_Main: TTabItem;
    Txt_Status: TText;
    ResAniIndicator_Loading: TResAniIndicator;
    Btn_Close: TButton;
    ResAniIndicator_Main: TResAniIndicator;
    procedure BtnStartStopClick(Sender: TObject);
    procedure Btn_CloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ResAniIndicator_MainTerminateLoop(Sender: TObject);
    procedure ResAniIndicator_MainProcess(Sender: TObject);
    procedure ResAniIndicator_MainFinish(Sender: TObject);
    procedure ResAniIndicator_LoadingTerminateLoop(Sender: TObject);
    procedure ResAniIndicator_LoadingFinish(Sender: TObject);


  private
    fAppGoingToclose: Boolean;
  public
    property AppGoingToclose: Boolean read fAppGoingToclose write fAppGoingToclose;
  end;

implementation

uses
  DM.Resources;

{$R *.fmx}

procedure TMainView.BtnStartStopClick(Sender: TObject);
begin
  case BtnStartStop.Tag of
    0: ResAniIndicator_Main.Animation.Active := True;
    1: ResAniIndicator_Main.Animation.Active := False;
  end;

end;

procedure TMainView.ResAniIndicator_LoadingFinish(Sender: TObject);
begin
//
end;

procedure TMainView.ResAniIndicator_LoadingTerminateLoop(Sender: TObject);
begin


  if not AppGoingToclose then begin
    Rect_Status.Visible := True;
    Rect_Title.Visible := True;

    TabView
    .SetActiveTabWithTransitionAsync(Tab_Main, TTabTransition.Slide,
      TTabTransitionDirection.Normal, nil);
  end;
end;

procedure TMainView.ResAniIndicator_MainFinish(Sender: TObject);
begin
  Txt_Status.Text := 'Current Loop : '+
    ResAniIndicator_Main.LoopedCount.ToString;
  // Format(Txt_Status.Text,
  //  [ResAniIndicator_Loading.LoopedCount.ToString]);
end;

procedure TMainView.ResAniIndicator_MainProcess(Sender: TObject);
begin
  BtnStartStop.Text := 'Stop Animation';
  BtnStartStop.Tag  := 1;
end;

procedure TMainView.ResAniIndicator_MainTerminateLoop(Sender: TObject);
begin
  if not AppGoingToclose then begin
    BtnStartStop.Text := 'Start Animation';
    BtnStartStop.Tag  := 0;
    Txt_Status.Text := 'Current Loop : '+
      ResAniIndicator_Main.LoopedCount.ToString;
  end;
end;

procedure TMainView.Btn_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TMainView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  AppGoingToclose := True;
end;

procedure TMainView.FormCreate(Sender: TObject);
begin
  fAppGoingToclose := False;
  TabView.ActiveTab := Tab_Loading;
end;

end.
