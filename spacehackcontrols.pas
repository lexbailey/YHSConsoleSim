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

    //ui stuff
    aLabel: TLabel;

    procedure initUI(thisPanel:TPanel) virtual;
    procedure updateUI virtual;
  end;

  TSpacehackGameControl = class(TSpacehackControl)
    public
    enabled: boolean;
  end;

var
  MQTTClient: TMQTTClient;

implementation

{ Spacehack controls }

procedure TSpacehackControl.initUI(thisPanel: TPanel);
begin;
  aLabel := TLabel.Create(thisPanel);
  with aLabel do begin
    top := 14;
    left := 0;
    Font.Size:=12;
    Font.Style:=[fsBold];
    Parent:= thisPanel;
    Visible:=true;
    caption := name;
  end;
  myPanel := thisPanel;
end;

procedure TSpacehackControl.updateUI;
begin
  aLabel.Caption:=name;
end;

end.

