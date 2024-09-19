program TestDemo;

{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  DM.Resources in 'API\DM\DM.Resources.pas' {dmRes: TDataModule},
  MAin.View in 'MAin.View.pas' {MainView};

{$R *.res}

var
  MainView: TMainView;
begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.CreateForm(TdmRes, dmRes);
  Application.CreateForm(TMainView, MainView);
  Application.Run;
end.
