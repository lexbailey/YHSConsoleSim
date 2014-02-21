unit spacehackcontrolsinstructiondisplay;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  StdCtrls, controls, Graphics,
  ExtCtrls, ComCtrls, Buttons, MQTTComponent, spacehackcontrols;

type
  TSPacehackInstructionDisplay = class(TSpacehackControl)
    instruction: string;
    procedure initUI(thisPanel:TPanel) override;
    procedure updateUI override;
  end;

implementation

procedure TSPacehackInstructionDisplay.initUI(thisPanel: TPanel);
begin;
  inherited;
  with aLabel do begin
    WordWrap:=true;
    //AutoSize:=true;
    width := thisPanel.Width - 4;
  end;
  updateUI;
end;

procedure TSPacehackInstructionDisplay.updateUI;
begin;
  aLabel.Caption:=instruction;
  aLabel.width := myPanel.Width - 4;
  //aLabel.Height:=;
end;

end.

