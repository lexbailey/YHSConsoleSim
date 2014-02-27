unit spacehackcontrolsinstructiondisplay;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  StdCtrls, controls, Graphics,
  ExtCtrls, ComCtrls, Buttons, MQTTComponent, spacehackcontrols;

type
  TSPacehackInstructionDisplay = class(TSpacehackControl)
    finstruction: string;
    timeAvailable: integer; //time available in milliseconds
    timeLeft: integer;

    progressBar: TProgressBar;

    procedure newInstruction(value: string);

    procedure initUI(thisPanel:TPanel) override;
    procedure updateUI override;
    property instruction: string read finstruction write newInstruction;
  end;

implementation

procedure TSPacehackInstructionDisplay.initUI(thisPanel: TPanel);
begin;
  inherited;

  progressBar := TProgressBar.Create(thisPanel);
  with progressBar do begin
    parent := thisPanel;
    width := thisPanel.Width - 8;
    left := 4;
    Max:=timeAvailable;
    Min := 0;
    Position:=timeLeft;
    Smooth:=true;
    //BarShowText:=true;
    Step:=1;
    height := 20;
    top := thisPanel.Height - 24;
    Caption:='Time remaining';
  end;

  updateUI;
end;


procedure TSPacehackInstructionDisplay.newInstruction(value: string);
begin
  finstruction:=value;
  timeLeft:=timeAvailable;
end;

procedure TSPacehackInstructionDisplay.updateUI;
begin;
  aLabel.Caption:=instruction;
  progressBar.Max:=timeAvailable;
  progressBar.Position:=timeLeft;
end;

end.

