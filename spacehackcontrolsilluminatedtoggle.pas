unit spacehackcontrolsilluminatedtoggle;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  StdCtrls, controls, Graphics,
  ExtCtrls, ComCtrls, Buttons, MQTTComponent, spacehackcontrols;

type
  TSpacehackGameControlIlluminatedToggle = class(TSpacehackGameControl)
    lightIsOn: boolean;
    lblLight: TLabel;
    btnOn, btnOff: TButton;
    panelWidth: integer;
    procedure initUI(thisPanel:TPanel) override;
    procedure updateUI override;
    procedure handleOnClick(Sender: TObject);
    procedure handleOffClick(Sender: TObject);
    function controlTypeValid(value: string): boolean override;
  end;

implementation

procedure TSpacehackGameControlIlluminatedToggle.initUI(thisPanel: TPanel);
begin;
  inherited;
  lblLight := TLabel.Create(thisPanel);
  panelWidth := thisPanel.Width;
  with lblLight do begin
    top := 40;
    left := 0;
    AutoSize:=true;
    Font.Size:=20;
    Parent:= thisPanel;
    Visible:=true;
  end;
  btnOn := TButton.Create(thisPanel);
  with btnOn do begin
    width := 100;
    height := 50;
    top := 90;
    left := 50;
    parent := thisPanel;
    Visible:=true;
    Caption:='On';
    tag := 1;
    OnClick:=@handleOnClick;
  end;
  btnOff := TButton.Create(thisPanel);
  with btnOff do begin
    width := 100;
    height := 50;
    top := 140;
    left := 50;
    parent := thisPanel;
    Visible:=true;
    Caption:='Off';
    tag := 0;
    OnClick:=@handleOffClick;
  end;
  updateUI;
end;

procedure TSpacehackGameControlIlluminatedToggle.handleOnClick(Sender: TObject);
begin;
  lightIsOn:=true;
  MQTTClient.Publish(changeTopic, '1');
end;

procedure TSpacehackGameControlIlluminatedToggle.handleOffClick(Sender: TObject);
begin;
  lightIsOn:=false;
  MQTTClient.Publish(changeTopic, '0');
end;

procedure TSpacehackGameControlIlluminatedToggle.updateUI;
begin
  inherited;
  with lblLight do begin
    if lightIsOn then
    begin
      Caption:= 'ON';
      Color:=clGreen;
      btnOff.Enabled:=true;
      btnOn.Enabled:=false;
    end else
    begin
      Caption:= 'OFF';
      Color:=clRed;
      btnoff.Enabled:=false;
      btnOn.Enabled:=true;
    end;
    left := round((panelWidth/2) - (width/2));
  end;
end;

function TSpacehackGameControlIlluminatedToggle.controlTypeValid(value: string): boolean;
begin
  result := (value = 'toggle');
end;

end.

