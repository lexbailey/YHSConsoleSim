unit spacehackcontrolscombosevensegcolourrotary;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  StdCtrls, controls, Graphics,
  ExtCtrls, ComCtrls, Buttons, MQTTComponent, spacehackcontrols;

type
  TSpacehackGameControlCombo7SegColourRotary = class(TSpacehackGameControl)
    CWButton, CCWButton, PushButton: TButton;
    procedure initUI(thisPanel:TPanel) override;
  end;

implementation

procedure TSpacehackGameControlCombo7SegColourRotary.initUI(thisPanel: TPanel);
begin;
  inherited;
  PushButton := TButton.Create(thisPanel);
  with PushButton do begin
    Parent:= thisPanel;
    Visible := true;
    height := 50;
    top := 140;
    width:= 100;
    left:=50;
    Caption:='Push';
  end;

  CCWButton := TButton.Create(thisPanel);
  with CCWButton do begin
    Parent:= thisPanel;
    Visible := true;
    height := 50;
    top := 90;
    width:= 80;
    left:=10;
    Caption:='<CCW';
  end;

  CWButton := TButton.Create(thisPanel);
  with CWButton do begin
    Parent:= thisPanel;
    Visible := true;
    height := 50;
    top := 90;
    width:= 80;
    left:=110;
    Caption:='CW>';
  end;
end;

end.

