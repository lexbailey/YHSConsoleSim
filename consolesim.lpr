program consolesim;

{$mode objfpc}{$H+}

uses
  //{$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  //{$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, consolesimMain, sysutils, spacehackcontrols,
  spacehackcontrolsinstructiondisplay, spacehackcontrolsilluminatedtoggle,
  spacehackcontrolskeypad, spacehackcontrolsfourbuttons,
  spacehackcontrolspotentiometer, spacehackcontrolscombosevensegcolourrotary,
  spacehackcontrolsilluminatedbutton, pinShow;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  writeln('');
  writeln('About to init');
  Application.Initialize;
  writeln('Main program: init done');
  Application.CreateForm(TfrmMain, frmMain);
  writeln('Main program: main form created');
  Application.CreateForm(TfrmPinShow, frmPinShow);
  Application.Run;
end.

