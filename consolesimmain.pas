unit consolesimMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynHighlighterPo, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, MaskEdit, ComCtrls, EditBtn, Buttons, Menus,
  MQTTComponent, fpjson, JSONParser, pinShow,

  spacehackcontrols,
  spacehackcontrolsinstructiondisplay,
  spacehackcontrolsilluminatedtoggle,
  spacehackcontrolskeypad,
  spacehackcontrolsilluminatedbutton,
  spacehackcontrolsfourbuttons,
  spacehackcontrolspotentiometer,
  spacehackcontrolscombosevensegcolourrotary
  ;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnSubscribe: TButton;
    btnConnect: TButton;
    btnDisconnect: TButton;
    btnRegister: TButton;
    btnReload: TButton;
    btnAutoSubscribe: TButton;
    btnClearSubs: TButton;
    btnCreateControls: TButton;
    btnPublish: TButton;
    cbUIUpdate: TCheckBox;
    edtPublishTopic: TEdit;
    eServer: TEdit;
    eSubscription: TEdit;
    ePort: TMaskEdit;
    fneLoadConfig: TFileNameEdit;
    gbServer: TGroupBox;
    gbSub: TGroupBox;
    gbStdSub: TGroupBox;
    gbAddSub: TGroupBox;
    gbLoadConfig: TGroupBox;
    gbControls: TGroupBox;
    gbComServer: TGroupBox;
    gbComLocal: TGroupBox;
    gbSend: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    lblServerIP: TLabel;
    lblMyIP: TLabel;
    memAddSub: TMemo;
    memPublishPayload: TMemo;
    memStdSub: TMemo;
    miControlPins: TMenuItem;
    miShowPins: TMenuItem;
    MQTTClient: TMQTTClient;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    pnlControls: TPanel;
    pnlLoadConfig: TPanel;
    pmBusOptions: TPopupMenu;
    pmControlOptions: TPopupMenu;
    sbDrawingArea: TScrollBox;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Splitter4: TSplitter;
    statusBar: TStatusBar;
    tmrUIUpdate: TTimer;
    tmrStat: TTimer;
    tvControls: TTreeView;
    procedure btnAutoSubscribeClick(Sender: TObject);
    procedure btnClearSubsClick(Sender: TObject);
    procedure btnCreateControlsClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure btnPinShowClick(Sender: TObject);
    procedure btnPublishClick(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
    procedure btnReloadClick(Sender: TObject);
    procedure cbUIUpdateChange(Sender: TObject);
    procedure fneLoadConfigAcceptFileName(Sender: TObject; var Value: String);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure gbStdSubClick(Sender: TObject);
    procedure log(info: string);
    procedure btnConnectClick(Sender: TObject);
    procedure btnSubscribeClick(Sender: TObject);
    procedure miControlPinsClick(Sender: TObject);
    procedure miShowPinsClick(Sender: TObject);
    procedure MQTTClientConnAck(Sender: TObject; ReturnCode: integer);
    procedure MQTTClientPingResp(Sender: TObject);
    procedure MQTTClientPublish(Sender: TObject; topic, payload: ansistring);
    procedure MQTTClientSubAck(Sender: TObject; MessageID: integer;
      GrantedQoS: integer);
    procedure pnlLoadConfigResize(Sender: TObject);
    procedure sbDrawingAreaPaint(Sender: TObject);
    procedure tmrStatTimer(Sender: TObject);
    procedure loadControlData;
    procedure controlDataToTree;
    procedure loadConfiguration(configFile: string);
    procedure subscribeTo(topic: string; isAdditional: boolean = false);
    procedure setInstruction(instruction: string);
    procedure setTimeout(timeout: extended);
    procedure tmrUIUpdateTimer(Sender: TObject);
    procedure handleControlUpdate(controlID: integer; topic, payload: string);
    procedure initiateRound(roundConfig: TJSONObject);
    procedure tvControlsClick(Sender: TObject);
    procedure tvControlsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmMain: TfrmMain;
  myJSONParser: TJSONParser;
  localConfigJSON, interfaceConfigJSON: TJSONObject;
  roundJSONParser: TJSONParser;
  roundConfigJSON: TJSONObject;
  controlsJSON, busesJSON : TJSONObject;
  myIP, serverIP: string;
  numControls, numBuses: integer;
  controlJSON, busJSON: array of TJSONObject;
  controlID: array of integer;
  busID: array of string;
  myspacehackControls: array of TSpacehackControl;
  spacehackBuses: array of TSpacehackBus;

  nextTop, nextLeft: integer;

implementation

{$R *.lfm}
{ TfrmMain }

procedure TfrmMain.log(info: string);
begin
//  mOutputOld.Append(info);
//  mOutputOld.Text:=mOutputOld.Text + #10 + info;
  //mOutput.Lines.Add(info);
  writeln(info);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
end;

procedure TfrmMain.gbStdSubClick(Sender: TObject);
begin

end;

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  spacehackcontrols.MQTTClient := MQTTClient;
end;

procedure TfrmMain.btnDisconnectClick(Sender: TObject);
begin
  btnClearSubs.Click;
  gbComServer.Enabled:=false;
  log('Disconnecting...');
  if MQTTClient.isConnected then begin
    log('Graceful disconnect...');
    if not MQTTClient.Disconnect then begin
      log('Forecful disconnect...');
      MQTTClient.ForceDisconnect;
    end;
  end;
end;

procedure TfrmMain.btnPinShowClick(Sender: TObject);
begin
  frmPinShow.show;
end;

procedure TfrmMain.btnPublishClick(Sender: TObject);
begin
  MQTTClient.Publish(edtPublishTopic.Text, memPublishPayload.Text);
end;

procedure TfrmMain.btnRegisterClick(Sender: TObject);
begin
  MQTTClient.Publish('server/register', interfaceConfigJSON.FormatJSON());
end;

procedure TfrmMain.subscribeTo(topic: string; isAdditional: boolean = false);
begin
  MQTTClient.Subscribe(topic);
  if isAdditional then begin
    memAddSub.Append(topic);
  end else
    memStdSub.Append(topic);
end;

procedure TfrmMain.btnAutoSubscribeClick(Sender: TObject);
var
  prefix: string;
  i: integer;
begin
  prefix := 'clients/' + myIP + '/';
  subscribeTo(prefix + 'configure');
  subscribeTo(prefix + 'instructions');

  for i := 0 to numControls-1 do
  begin
    if myspacehackControls[i].hardware <> 'instructions' then begin
      subscribeTo(prefix + inttostr(controlID[i]) + '/name');
      subscribeTo(prefix + inttostr(controlID[i]) + '/enabled');
    end;
  end;
end;

procedure TfrmMain.btnClearSubsClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to memStdSub.Lines.Count-1 do begin
    MQTTClient.Unsubscribe(memStdSub.Lines[i]);
  end;
  memStdSub.Clear;
  for i := 0 to memAddSub.Lines.Count-1 do begin
    MQTTClient.Unsubscribe(memAddSub.Lines[i]);
  end;
  memAddSub.Clear;
end;

procedure TfrmMain.btnCreateControlsClick(Sender: TObject);
var
  i: integer;
  thisControl: TSpacehackControl;
  thisPanel: TPanel;
  thisLabel: TLabel;
begin
  for i := pnlControls.ControlCount-1 downto 0 do begin
    pnlControls.Controls[i].Free;
  end;
  pnlControls.Width:=sbDrawingArea.Width - 20;
  pnlControls.Height:=220;
  nextTop := 10;
  nextLeft := 10;
  for i := 0 to numControls-1 do
  begin
    thisControl := myspacehackControls[i];
    thisPanel := TPanel.Create(pnlControls);
    with thisPanel do begin
      Width:=200;
      height:=200;
      Top:=nextTop;
      Left:=nextLeft;
      Parent:= pnlControls;
      Visible:=true;
    end;
    thisLabel := TLabel.Create(thisPanel);
    with thisLabel do begin
      top := 0;
      left := 0;
      caption := myspacehackControls[i].hardware;
      parent := TWinControl(thisPanel);
      visible := true;
      font.Color:=clGray;
    end;
    thisPanel.Tag:=i;
    thisControl.initUI(thisPanel);
    nextLeft += 210;
    if nextLeft+210 >= pnlControls.Width then
    begin
      nextLeft := 10;
      nextTop += 210;
      pnlControls.Height := pnlControls.Height + 210;
    end;
  end;
end;

procedure TfrmMain.btnReloadClick(Sender: TObject);
begin
  loadConfiguration(fneLoadConfig.Text);
end;

procedure TfrmMain.cbUIUpdateChange(Sender: TObject);
begin
  tmrUIUpdate.Enabled:=cbUIUpdate.Checked;
end;

procedure TfrmMain.fneLoadConfigAcceptFileName(Sender: TObject;
  var Value: String);

begin
  loadConfiguration(Value);

end;

procedure TfrmMain.btnConnectClick(Sender: TObject);
begin
  log('Starting connection...');
  if MQTTClient.isConnected then begin
    if not MQTTClient.Disconnect then begin
      MQTTClient.ForceDisconnect;
    end;
  end;
  log('Host: ' + eServer.Text);
  log('Port: ' + trim(ePort.Text));
  log('CID: ' + MQTTClient.ClientID);
  MQTTClient.Hostname:=eServer.Text;
  MQTTClient.Port:=strToInt(trim(ePort.Text));
  log('Waiting for connection...');
  MQTTClient.Connect;
end;

procedure TfrmMain.btnSubscribeClick(Sender: TObject);
var
  subscription: string;
begin
  subscribeTo(eSubscription.Text, true);
end;

procedure TfrmMain.miControlPinsClick(Sender: TObject);
var index, numPins, i: integer;
begin
  try
    index := tvControls.Selected.Index;
    frmPinShow.Caption:='Pin Finder - Control pins for '+myspacehackControls[index].hardware;
    numPins := myspacehackControls[index].pins.numPins;
    frmPinShow.clearPins;
    for i:= 0 to numPins-1 do begin
      frmPinShow.activatePin(myspacehackControls[index].pins.pinIDs[i]);
    end;
    frmPinShow.Hide;
    frmPinShow.Show;
  except
    ShowMessage('All pins must be defined');
  end;
end;

procedure TfrmMain.miShowPinsClick(Sender: TObject);
var index, numPins, i: integer;

begin
  try
    index := tvControls.Selected.Index;
    frmPinShow.Caption:='Pin Finder - Bus pins for '+spacehackBuses[index].busName;
    numPins := spacehackBuses[index].pins.numPins;
    frmPinShow.clearPins;
    for i:= 0 to numPins-1 do begin
      frmPinShow.activatePin(spacehackBuses[index].pins.pinIDs[i]);
    end;
    frmPinShow.Hide;
    frmPinShow.Show;
  except
    ShowMessage('All pins must be defined');
  end;

end;

procedure TfrmMain.MQTTClientConnAck(Sender: TObject; ReturnCode: integer);
begin
  log('Connection established, returned: '+ inttostr(ReturnCode));
  gbComServer.Enabled:=true;
end;

procedure TfrmMain.MQTTClientPingResp(Sender: TObject);
begin
  //log('Ping response');
end;

procedure TfrmMain.setInstruction(instruction: string);
var
  i: integer;
begin
  for i := 0 to numControls-1 do
  begin
    if myspacehackControls[i].hardware = 'instructions' then begin
      log('Instruction update');
      TSPacehackInstructionDisplay(myspacehackControls[i]).instruction:=instruction;
    end;
  end;
end;

procedure TfrmMain.setTimeout(timeout: extended);
var
  i: integer;
begin
  for i := 0 to numControls-1 do
  begin
    if myspacehackControls[i].hardware = 'instructions' then begin
      log('Instruction time update');
      TSPacehackInstructionDisplay(myspacehackControls[i]).timeAvailable:=round(timeout*1000);
      TSPacehackInstructionDisplay(myspacehackControls[i]).timeLeft:=round(timeout*1000);
    end;
  end;
end;

procedure TfrmMain.tmrUIUpdateTimer(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to numControls-1 do
  begin
    myspacehackControls[i].updateUI;
    if myspacehackControls[i].hardware = 'instructions' then begin
       TSPacehackInstructionDisplay(myspacehackControls[i]).timeLeft:=
       TSPacehackInstructionDisplay(myspacehackControls[i]).timeLeft - tmrUIUpdate.Interval;
    end;
  end;
end;

procedure TfrmMain.handleControlUpdate(controlID: integer; topic, payload: string);
var
  enable: boolean;
begin
  if topic = 'name' then begin
    log('Setting name');
    myspacehackControls[controlID].name:=payload;
  end;
  if topic = 'enabled' then begin
    enable := payload='1';
    TSpacehackGameControl(myspacehackControls[controlID]).Enabled:=enable;
  end;
end;

procedure TfrmMain.initiateRound(roundConfig: TJSONObject);
var controlsJSON: TJSONObject;
  numControls: integer;
  i: integer;
  thisID: integer;
  thisIDText: string;
  thisControlJSON: TJSONObject;

  controlEnabled: integer;
  controlType: string;
  controlName: string;
begin
  controlsJSON := TJSONObject(roundConfig.Find('controls'));
  numControls := controlsJSON.Count;
  for i := 0 to numControls-1 do begin
    thisID := i+1;
    thisIDText := inttostr(thisID);
    log ('testing ID: '+thisIDText);
    thisControlJSON := controlsJSON.Objects[thisIDText];
    if assigned(thisControlJSON) then begin
      controlType := thisControlJSON.Strings['type'];
      controlName := thisControlJSON.Strings['name'];
      controlEnabled := thisControlJSON.Integers['enabled'];

      myspacehackControls[thisID].enabled:= controlEnabled = 1;
      myspacehackControls[thisID].name := controlName;
      TSpacehackGameControl(myspacehackControls[thisID]).controlType := controlType;
      log('Control '+inttostr(thisID)+' is now ' + controlName + ', ' + controlType + ', Active: ' + inttostr(controlEnabled));

    end;
  end;
  setInstruction(roundConfig.Strings['instructions']);

  if roundConfig.Find('timeout') <> nil then begin;
    setTimeout(roundConfig.Floats['timeout']);
  end;
end;

procedure TfrmMain.tvControlsClick(Sender: TObject);
begin

end;

procedure TfrmMain.tvControlsMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbRight then begin
    if assigned(tvControls.Selected) and assigned(tvControls.Selected.Parent) then begin
      if tvControls.Selected.Parent.Text = 'Buses' then begin
        pmBusOptions.PopUp;
      end;
      if tvControls.Selected.Parent.Text = 'Controls' then begin
        pmControlOptions.PopUp;
      end;
    end;
  end;
end;

procedure TfrmMain.MQTTClientPublish(Sender: TObject; topic, payload: ansistring
  );
var
  topicParser: TStrings;
  controlID: integer;
  thisTopic: string;
begin
  log(topic + ': ' + payload);
  topicParser := TStringList.Create;
  topicParser.Delimiter:='/';
  topicParser.DelimitedText:=topic;
  if  (topicParser.Count > 0) and (topicParser.Strings[0] <> 'clients') then begin
    log('Non-client topic received.');
  end else
  begin
    if topicParser.Count > 1 then begin
      if topicParser.Strings[1] <> myIP then begin
        log('IP address mismatch');
      end else
      begin
        //yay, my message!
        if topicParser.Count > 2 then begin
          if topicParser.Strings[2] = 'instructions' then begin
            log('next instruction is '+payload);
            setInstruction(payload);
          end else
          begin
            if topicParser.Strings[2] = 'configure' then begin
              log('got configuration: ' +payload);
              try
                roundJSONParser := TJSONParser.Create(payload);
                roundConfigJSON := TJSONObject(roundJSONParser.Parse);
                initiateRound(roundConfigJSON);
              finally
                roundConfigJSON.Free;
                roundJSONParser.Free;
              end;
            end else
            begin
              //lets assume that the topic is a control number
              try
                controlID := strtoint(topicParser.Strings[2]);
                if topicParser.Count>3 then begin
                  thisTopic := topicParser.Strings[3];
                  handleControlUpdate(controlID, thisTopic, payload);
                end else
                begin
                  log('Published to incorrect topic');
                end;
              except
                log('unexpected topic');
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TfrmMain.MQTTClientSubAck(Sender: TObject; MessageID: integer;
  GrantedQoS: integer);
begin
  log('Subscription established');
end;

procedure TfrmMain.pnlLoadConfigResize(Sender: TObject);
begin
  fneLoadConfig.Width:=pnlLoadConfig.Width-26;
end;

procedure TfrmMain.sbDrawingAreaPaint(Sender: TObject);
begin

end;

procedure TfrmMain.tmrStatTimer(Sender: TObject);
begin
  if MQTTClient.isConnected then begin
    statusBar.SimpleText:='Connected';
    gbComServer.Enabled:=true;
    MQTTClient.PingReq;
  end else
  begin
    statusBar.SimpleText:='Disconnected';
    gbComServer.Enabled:=false;
  end;
end;

procedure TfrmMain.loadControlData();
var
  i, j: integer;
  thisDisplayJSON, thisPinsJSON: TJSONObject;
  hardwareType : string;
begin
  //Get the number of controls by the number of children of the controls JSON object
  numControls := controlsJSON.Count;
  setLength(controlJSON,            numControls);
  setLength(controlID,              numControls);
  setLength(myspacehackControls,      numControls);

  //Loop through all controls
  for i := 0 to numControls-1 do begin
    //get a JSON object for each one
    controlJSON[i] := TJSONObject(controlsJSON.find(inttostr(i)));
    //set its ID (maybe not needed)
    controlID[i] := i;
    //store the hardware type
    hardwareType := controlJSON[i].Find('hardware').AsString;
    if hardwareType = 'instructions' then myspacehackControls[i] := TSPacehackInstructionDisplay.create;
    if hardwareType = 'combo7SegColourRotary' then myspacehackControls[i] := TSpacehackGameControlCombo7SegColourRotary.create;
    if hardwareType = 'illuminatedtoggle' then myspacehackControls[i] := TSpacehackGameControlIlluminatedToggle.create;
    if hardwareType = 'fourbuttons' then myspacehackControls[i] := TSpacehackGameControlFourButtons.create;
    if hardwareType = 'potentiometer' then myspacehackControls[i] := TSpacehackGameControlPotentiometer.create;
    if hardwareType = 'illuminatedbutton' then myspacehackControls[i] := TSpacehackGameControlIlluminatedButton.create;
    if hardwareType = 'keypad' then myspacehackControls[i] := TSpacehackGameControlKeypad.create;
    if not assigned(myspacehackControls[i]) then begin
      myspacehackControls[i] := TSpacehackGameControl.Create;
    end;

    if myspacehackControls[i] is TSpacehackGameControl then begin
      TSpacehackGameControl(myspacehackControls[i]).changeTopic:='clients/'+myIP+'/' + inttostr(i)+'/valuechanged';
    end;

    myspacehackControls[i].hardware:=hardwareType;

    //get the JSON for the display object
    thisDisplayJSON := TJSONObject(controlJSON[i].Find('display'));
    //get the display information
    myspacehackControls[i].display.displayType:=thisDisplayJSON.Find('type').AsString;
    myspacehackControls[i].display.charHeight:=thisDisplayJSON.Find('height').AsInteger;
    myspacehackControls[i].display.charWidth:=thisDisplayJSON.Find('width').AsInteger;

    //get the JSON for the pins object
    thisPinsJSON := TJSONObject(controlJSON[i].Find('pins'));
    //get the display information
    myspacehackControls[i].pins.numPins:=thisPinsJSON.Count;
    setLength(myspacehackControls[i].pins.pinNames, thisPinsJSON.Count);
    setLength(myspacehackControls[i].pins.pinIDs, thisPinsJSON.Count);

    for j := 0 to myspacehackControls[i].pins.numPins-1 do
    begin
      myspacehackControls[i].pins.pinNames[j] := thisPinsJSON.Names[j];
      myspacehackControls[i].pins.pinIDs[j] := thisPinsJSON.Strings[thisPinsJSON.Names[j]];
    end;

  end;



  //Get the number of controls by the number of children of the controls JSON object
  numBuses := busesJSON.Count;
  setLength(busJSON,            numControls);
  setLength(busID,              numControls);
  setLength(spacehackBuses,      numControls);

  //Loop through all controls
  for i := 0 to numBuses-1 do begin
    //set its ID
    busID[i] := busesJSON.Names[i];
    //get a JSON object for each one
    busJSON[i] := TJSONObject(busesJSON.Objects[busID[i]]);
    //set the bus name
    spacehackBuses[i].busName := busID[i];

    //get the JSON for the pins object
    thisPinsJSON := TJSONObject(busJSON[i]);

    //get the pin information
    spacehackBuses[i].pins.numPins:=thisPinsJSON.Count;
    setLength(spacehackBuses[i].pins.pinNames, thisPinsJSON.Count);
    setLength(spacehackBuses[i].pins.pinIDs, thisPinsJSON.Count);

    for j := 0 to spacehackBuses[i].pins.numPins-1 do
    begin
      spacehackBuses[i].pins.pinNames[j] := thisPinsJSON.Names[j];
      spacehackBuses[i].pins.pinIDs[j] := thisPinsJSON.Strings[thisPinsJSON.Names[j]];
    end;

  end;
end;

procedure TfrmMain.controlDataToTree;
var
  rootControlNode, rootBusNode: TTreeNode;
  thisNode, thisDisplay, thisPins: TTreeNode;
  i, j: integer;
begin

  tvControls.Items.Clear;

  rootControlNode := tvControls.Items.Add(nil, 'Controls');
  rootBusNode := tvControls.Items.Add(nil, 'Buses');
  for i := 0 to numControls-1 do
  begin
    thisNode := tvControls.Items.AddChild(rootControlNode, inttostr(controlID[i]));
    tvControls.Items.AddChild(thisNode, 'hardware: '+ myspacehackControls[i].hardware);
    thisDisplay := tvControls.Items.AddChild(thisNode, 'display');
    tvControls.Items.AddChild(thisDisplay, 'Type: ' + myspacehackControls[i].display.displayType);
    tvControls.Items.AddChild(thisDisplay, 'Width: ' + inttostr(myspacehackControls[i].display.charWidth));
    tvControls.Items.AddChild(thisDisplay, 'Height: ' + inttostr(myspacehackControls[i].display.charHeight));
    thisPins := tvControls.Items.AddChild(thisNode, 'pins');
    for j := 0 to myspacehackControls[i].pins.numPins-1 do
    begin
      tvControls.Items.AddChild(thisPins, 'Pin name: ' + myspacehackControls[i].pins.pinNames[j] + '   =>   ID: ' + myspacehackControls[i].pins.pinIDs[j]);
    end;
  end;
  for i := 0 to numBuses-1 do
  begin
    thisNode := tvControls.Items.AddChild(rootBusNode, (busID[i]));

    for j := 0 to spacehackBuses[i].pins.numPins-1 do
    begin
      tvControls.Items.AddChild(thisNode, 'Pin name: ' + spacehackBuses[i].pins.pinNames[j] + '   =>   ID: ' + spacehackBuses[i].pins.pinIDs[j]);
    end;

  end;
end;

procedure TfrmMain.loadConfiguration(configFile: string);
var
  myFile: TFileStream;
  myJSONRoot: TJSONObject;
begin
  myFile := TFileStream.Create(configFile, fmOpenRead);
  if myFile = nil then begin
    showmessage('File load failed.');
  end else
  begin
    try
      myJSONParser := TJSONParser.Create(myFile);
      myJSONRoot := TJSONObject(myJSONParser.Parse);
      localConfigJSON := TJSONObject(myJSONRoot.Find('local'));
      interfaceConfigJSON := TJSONObject(myJSONRoot.Find('interface'));

      controlsJSON := TJSONObject(localConfigJSON.Find('controls'));
      busesJSON := TJSONObject(localConfigJSON.Find('buses'));

      myIP := interfaceConfigJSON.Find('ip').AsString;
      serverIP := localConfigJSON.Find('server').AsString;

      eServer.Text := serverIP;

      lblMyIP.Caption := 'My IP: ' + myIP;
      lblServerIP.Caption := 'Server IP:' + serverIP;
    except
      showmessage('JSON Parsing failed');
    end;
    myJSONParser.Free;
    myFile.Free;
  end;

  loadControlData;
  controlDataToTree;
end;

end.

