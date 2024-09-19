unit DM.Resources;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls;

type
  TdmRes = class(TDataModule)
    StyleMgr_APP: TStyleBook;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmRes: TdmRes;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
