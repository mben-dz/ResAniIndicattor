unit API.MBenCtrls.Types;

interface

uses
  System.Classes
, FMX.Controls
;

type

  TMBenPersistent = class(TPersistent)
   private
     fOwner: TPersistent;
     fParentControl: TControl;
   public
     constructor Create(aOwner: TPersistent); overload; virtual;
  protected
    procedure Clear; virtual;

    property ParentControl: TControl read fParentControl;
  end;


implementation

{ TMBenPersistent }

procedure TMBenPersistent.Clear;
begin
//
end;

constructor TMBenPersistent.Create(aOwner: TPersistent);
begin inherited Create;
  fOwner := aOwner;

  if aOwner is TControl then
    fParentControl := TControl(aOwner) else
    fParentControl := nil;
end;

end.
