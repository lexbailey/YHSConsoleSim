unit spacehackcontrolsfourbuttons;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  StdCtrls, controls, Graphics,
  ExtCtrls, ComCtrls, Buttons, MQTTComponent, spacehackcontrols;

type
  TSpacehackGameControlFourButtons = class(TSpacehackGameControl)
    button1Name, button2Name, button3Name, button4Name: string;
    Button1, Button2, Button3, Button4: TButton;
    procedure initUI(thisPanel:TPanel) override;
    procedure handleButtonClick(sender: TObject);
    function controlTypeValid(value: string):boolean override;
  end;

implementation

procedure TSpacehackGameControlFourButtons.initUI(thisPanel: TPanel);
          procedure initButton(button: TButton; panel: TPanel; buttontop: integer; buttonTag: integer; buttonname: string);
          begin;
            button := TButton.Create(panel);
            with button do begin
              left := 5; top := buttontop; width := 190; height := 35;
              caption := buttonname;
              parent := thisPanel; visible := true;
              tag := buttonTag;
              OnClick:= @handleButtonClick;
            end;
          end;
begin;
  inherited;
  initButton(Button1, thisPanel, 40, 1, self.button1Name);
  initButton(Button2, thisPanel, 75, 2, self.button2Name);
  initButton(Button3, thisPanel, 110, 3, self.button3Name);
  initButton(Button4, thisPanel, 145, 4, self.button4Name);
end;

procedure TSpacehackGameControlFourButtons.handleButtonClick(sender: TObject);
begin;
  //TODO handle four buttons
end;

function TSpacehackGameControlFourButtons .controlTypeValid(value: string): boolean;
begin
  result := (value = 'verbs') or (value = 'colour');
end;

end.

