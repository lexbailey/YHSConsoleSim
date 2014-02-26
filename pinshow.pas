unit pinShow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TfrmPinShow }

  TfrmPinShow = class(TForm)
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
    myLabels: array[1..92] of TLabel;
    myActivePins: array[1..92] of boolean;

  public
    procedure clearPins;
    procedure activatePin(pinName: string);
    { public declarations }
  end;

var
  frmPinShow: TfrmPinShow;

implementation

{$R *.lfm}

{ TfrmPinShow }

procedure TfrmPinShow.clearPins;
var i: integer;
begin
  for i := 1 to 92 do begin
    myActivePins[i] := false;
  end;
end;

procedure TfrmPinShow.activatePin(pinName: string);
var pinNum: integer;
begin
  if length(pinName) = 4 then begin
    pinNum := strtoint(pinName[4]);
  end else
  begin
    pinNum := strtoint(pinName[4]+pinName[5]);
  end;
  if pinName[2] = '8' then begin
    pinNum += 46;
  end;

  myActivePins[pinNum] := true;
end;

procedure TfrmPinShow.FormCreate(Sender: TObject);
var
  i:integer;
const
  labelHeight: extended = 13.4;
begin
  clearPins;
  for i := 1 to 92 do begin
    myLabels[i] := TLabel.Create(frmPinShow);
    with myLabels[i] do begin
      Color:=clRed;
      if i<= 46 then begin
        Top:= round(240+((i-((i-1) mod 2))*labelHeight));
        left := 40+(60*((i-1) mod 2));
        caption:='P9_' + inttostr(i);
      end else
      begin
        Top:=round(240+(((i-((i-1) mod 2))-46)*labelHeight));
        left := 550+(60*((i-1) mod 2));
        caption:='P8_' + inttostr(i-46);
      end;
      height:=round(labelHeight);
      Parent:= frmPinShow;
      Visible:=true;
    end;
  end;
end;

procedure TfrmPinShow.FormShow(Sender: TObject);
var i: integer;
begin
  for i := 1 to 92 do begin
    myLabels[i].Visible:=myActivePins[i];
  end;
end;

end.

