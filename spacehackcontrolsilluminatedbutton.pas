unit spacehackcontrolsilluminatedbutton;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  StdCtrls, controls, Graphics,
  ExtCtrls, ComCtrls, Buttons, MQTTComponent, spacehackcontrols;

type
  TSpacehackGameControlIlluminatedButton = class(TSpacehackGameControl)
   lightIsOn: boolean;

   lblLight: TLabel;
   theButton: TButton;
   panelWidth: integer;
   procedure initUI(thisPanel:TPanel) override;
   procedure handleButtonUp(Sender: TObject; Button: TMouseButton;
                         Shift: TShiftState; X, Y: Integer);
   procedure handleButtonDown(Sender: TObject; Button: TMouseButton;
                         Shift: TShiftState; X, Y: Integer);
   procedure updateUI override;
   function  controlTypeValid(value: string): boolean override;
 end;

implementation

procedure TSpacehackGameControlIlluminatedButton.initUI(thisPanel: TPanel);
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
  updateUI;
  theButton := TButton.Create(thisPanel);
  with theButton do begin
    width := 100;
    height := 100;
    top := 90;
    left := 50;
    parent := thisPanel;
    Visible:=true;
    tag := 1;
    OnMouseDown:= @handleButtonDown;
    OnMouseUp:= @handleButtonUp;
  end;
end;

procedure TSpacehackGameControlIlluminatedButton.handleButtonUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if controlType = 'toggle' then begin;
    lightIsOn := not lightIsOn;
    updateUI;
    if lightIsOn then begin;
      MQTTClient.Publish(changeTopic, '1');
    end else begin;
      MQTTClient.Publish(changeTopic, '0');
    end;
  end else
  begin
     if controlType = 'button' then begin
       lightIsOn := false;
       updateUI;
       MQTTClient.Publish(changeTopic, '0');
     end;
  end;
end;

procedure TSpacehackGameControlIlluminatedButton.handleButtonDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin;
  if self.controlType = 'button' then begin;
    lightIsOn := true;
    updateUI;
    MQTTClient.Publish(changeTopic, '1');
  end;
end;

procedure TSpacehackGameControlIlluminatedButton.updateUI;
begin
  inherited;
  with lblLight do
  begin;
    if lightIsOn then
    begin
      Caption:= 'ON';
      Color:=clGreen;
    end else
    begin
      Caption:= 'OFF';
      Color:=clRed;
    end;
    left := round((panelWidth/2) - (width/2));
  end;
end;

function TSpacehackGameControlIlluminatedButton.controlTypeValid(value: string): boolean;
begin
  result := (value = 'toggle') or (value = 'button');
end;

end.

