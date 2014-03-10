unit spacehackcontrols;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  StdCtrls, controls, Graphics,
  ExtCtrls, ComCtrls, Buttons, MQTTComponent;

type

  TSpacehackDisplay = record
    displayType: string;
    charWidth, charHeight: integer;
  end;

  TSpacehackPins = record
    numPins: integer;
    pinNames: array of string;
    pinIDs: array of string;
  end;

  TSpacehackBus = record
    busName: string;
    pins: TSpacehackPins;
  end;

  TSpacehackControl = class(TObject)
    display: TSpacehackDisplay;
    hardware: string;
    pins: TSpacehackPins;
    name: string;
    mypanel: TPanel;
    enabled: boolean;
    //ui stuff
    aLabel: TLabel;

    procedure initUI(thisPanel:TPanel) virtual;
    procedure updateUI virtual;
  end;

  TSpacehackGameControl = class(TSpacehackControl)
    fcontrolType: string;
    changeTopic : string;
    procedure updateUI override;
    procedure setControlType(value: string) virtual;
    function controlTypeValid(value: string): boolean virtual;
    property controlType: string read fcontrolType write setControlType;
  end;

var
  MQTTClient: TMQTTClient;

implementation

{ Spacehack controls }

procedure TSpacehackControl.initUI(thisPanel: TPanel);
begin;
  aLabel := TLabel.Create(thisPanel);
  with aLabel do begin
    Font.Size:=12;
    Font.Style:=[fsBold];
    Parent:= thisPanel;
    Visible:=true;
    caption := name;
    WordWrap:=true;
    Align:=alTop;
    BorderSpacing.Top:=14;
  end;
  myPanel := thisPanel;
end;

procedure TSpacehackControl.updateUI;
begin
  mypanel.Enabled:=Self.enabled;
end;

procedure TSpacehackGameControl.updateUI;
begin
  if enabled then begin
    aLabel.Caption:=name;
  end
  else
    aLabel.Caption:='';
end;

function TSpacehackGameControl.controlTypeValid(value: string):boolean;
begin
  result := true;
end;

procedure TSpacehackGameControl.setControlType(value: string);
begin
  if (controlTypeValid(value)) then begin
    fcontrolType:=value;
  end else
  begin
    raise Exception.Create('Invalid control type selected for control "' + name + '".');
  end;
end;
//ygs=ycf+ypi
end.

