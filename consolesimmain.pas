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
    procedure fneLoadConfigChange(Sender: TObject);
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
    procedure pnlLoadConfigClick(Sender: TObject);
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
    procedure InitialiseControls;
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


//for debugging
procedure TfrmMain.log(info: string);
begin
//  mOutputOld.Append(info);
//  mOutputOld.Text:=mOutputOld.Text + #10 + info;
  //mOutput.Lines.Add(info);
  writeln(info);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  //Give the spacehack controls access to our instance of the MQTT client object
  spacehackcontrols.MQTTClient := MQTTClient;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin

end;

procedure TfrmMain.gbStdSubClick(Sender: TObject);
begin

end;

procedure TfrmMain.btnDisconnectClick(Sender: TObject);
begin
  //To disconnect...
  //Unsubscribe from everything
  btnClearSubs.Click;
  //disable the buttons for interacting with the server
  gbComServer.Enabled:=false;
  log('Disconnecting...');
  //if we are connected...
  if MQTTClient.isConnected then begin
    log('Graceful disconnect...');
    //try to disconnect nicely
    if not MQTTClient.Disconnect then begin
      log('Forecful disconnect...');
      //if that fails then just abandon ship
      MQTTClient.ForceDisconnect;
    end;
  end;
end;

procedure TfrmMain.btnPinShowClick(Sender: TObject);
begin

end;

procedure TfrmMain.btnPublishClick(Sender: TObject);
begin
  //Allow user to publish arbitrary payloads to arbitrary topics
  MQTTClient.Publish(edtPublishTopic.Text, memPublishPayload.Text);
end;

procedure TfrmMain.btnRegisterClick(Sender: TObject);
begin
  //register with the game server simply by sending the interface section of the config to the server
  MQTTClient.Publish('server/register', interfaceConfigJSON.FormatJSON());
end;

procedure TfrmMain.subscribeTo(topic: string; isAdditional: boolean = false);
begin
  //subscribe to the requested topic
  MQTTClient.Subscribe(topic);
  if isAdditional then begin
    //If this is a user request for an arbitrary topic then add it to the additional subscription list
    memAddSub.Append(topic);
  end else
    //otherwise it should go in the standard list
    memStdSub.Append(topic);
end;

procedure TfrmMain.btnAutoSubscribeClick(Sender: TObject);
var
  prefix: string;
  i: integer;
begin
  //subscribe to default topics
  prefix := 'clients/' + myIP + '/';
  subscribeTo(prefix + 'configure');
  subscribeTo(prefix + 'instructions');

  //subscribe to all of the topics that are required for each control in the config
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
  //loop through all subscriptions of each type and unsubscribe from them
  for i := 0 to memStdSub.Lines.Count-1 do begin
    MQTTClient.Unsubscribe(memStdSub.Lines[i]);
  end;
  memStdSub.Clear;
  for i := 0 to memAddSub.Lines.Count-1 do begin
    MQTTClient.Unsubscribe(memAddSub.Lines[i]);
  end;
  memAddSub.Clear;
end;

procedure TfrmMain.InitialiseControls;
var
  i: integer;
  thisControl: TSpacehackControl;
  thisPanel: TPanel;
  thisLabel: TLabel;
begin
  //free all of the controls we currently have from the panel 'pnlControls'
  for i := pnlControls.ControlCount-1 downto 0 do begin
    pnlControls.Controls[i].Free;
  end;
  //make the panel as wide as possible
  pnlControls.Width:=sbDrawingArea.Width - 20;
  //make it high enough for one control
  pnlControls.Height:=220;
  nextTop := 10;
  nextLeft := 10;
  //loop through all controls loaded from the config
  for i := 0 to numControls-1 do
  begin
    thisControl := myspacehackControls[i];
    //create a panel for each one
    thisPanel := TPanel.Create(pnlControls);
    with thisPanel do begin
      Width:=200;
      height:=200;
      Top:=nextTop;
      Left:=nextLeft;
      Parent:= pnlControls;
      Visible:=true;
    end;
    //put a label on the panel
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
    //tell the control to initialise the panel to its liking
    thisControl.initUI(thisPanel);
    //move for next control
    nextLeft += 210;
    //if this control goes over the edge then move down one
    if nextLeft+210 >= pnlControls.Width then
    begin
      nextLeft := 10;
      nextTop += 210;
      //make panel bigger to fit
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
  //if connected, disconnect
  if MQTTClient.isConnected then begin
    if not MQTTClient.Disconnect then begin
      MQTTClient.ForceDisconnect;
    end;
  end;
  log('Host: ' + eServer.Text);
  log('Port: ' + trim(ePort.Text));
  log('CID: ' + MQTTClient.ClientID);
  //set the host name
  MQTTClient.Hostname:=eServer.Text;
  //set the port
  MQTTClient.Port:=strToInt(trim(ePort.Text));
  log('Waiting for connection...');
  //connect
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
    //get the index of the control that is selected
    index := tvControls.Selected.Index;
    //prepare the pin diagram form for display
    frmPinShow.Caption:='Pin Finder - Control pins for '+myspacehackControls[index].hardware;
    numPins := myspacehackControls[index].pins.numPins;
    //hide all of the pins on the pin diagram
    frmPinShow.clearPins;
    for i:= 0 to numPins-1 do begin
      //show each pin found in the config for this control
      frmPinShow.activatePin(myspacehackControls[index].pins.pinIDs[i]);
    end;
    //re-show the pin form
    frmPinShow.Hide;
    frmPinShow.Show;
  except
    //if a pin has an invalid syntax (and is therefore undefined) aler the user
    ShowMessage('All pins must be defined');
  end;
end;

procedure TfrmMain.miShowPinsClick(Sender: TObject);
var index, numPins, i: integer;

begin
  //similar to above but for busses
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
  //once connected, allow access to the server interaction buttons
  gbComServer.Enabled:=true;
end;

procedure TfrmMain.setInstruction(instruction: string);
var
  i: integer;
begin
  //loop through all controls
  for i := 0 to numControls-1 do
  begin
    if myspacehackControls[i].hardware = 'instructions' then begin
      log('Instruction update');
      //for every instrtuction display found, update the text
      TSPacehackInstructionDisplay(myspacehackControls[i]).instruction:=instruction;
    end;
  end;
end;

procedure TfrmMain.setTimeout(timeout: extended);
var
  i: integer;
begin
  //loop through all controls
  for i := 0 to numControls-1 do
  begin
    if myspacehackControls[i].hardware = 'instructions' then begin
      log('Instruction time update');
      //for each instruction display found, update the time remaining
      TSPacehackInstructionDisplay(myspacehackControls[i]).timeAvailable:=round(timeout*1000);
      TSPacehackInstructionDisplay(myspacehackControls[i]).timeLeft:=round(timeout*1000);
    end;
  end;
end;

procedure TfrmMain.tmrUIUpdateTimer(Sender: TObject);
var
  i: integer;
  instr: TSPacehackInstructionDisplay;
begin
  //timer to update the UI elements constantly
  //loop through all controls
  for i := 0 to numControls-1 do
  begin
    if myspacehackControls[i].hardware = 'instructions' then begin
      //if an instruction display is found then decrement the time it is showing
      instr := TSPacehackInstructionDisplay(myspacehackControls[i]);
      instr.timeLeft := instr.timeLeft - tmrUIUpdate.Interval;
    end;
    //update the UI for each control
    myspacehackControls[i].updateUI;
  end;
end;

procedure TfrmMain.handleControlUpdate(controlID: integer; topic, payload: string);
var
  enable: boolean;
begin
  //this function called when 'name' or 'enabled' topic gets a payload for a given control 'controlID'

  //update control names
  if topic = 'name' then begin
    log('Setting name');
    myspacehackControls[controlID].name:=payload;
  end;
  //update enabled
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
  //initiates a round based on the JSON config received from the 'config' topic
  if (roundConfig <> nil) and (roundConfig.Find('controls') <> nil) then begin
    controlsJSON := TJSONObject(roundConfig.Find('controls'));
    numControls := controlsJSON.Count;
    for i := 0 to numControls-1 do begin
      //this mostly explains itself...
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
    //if a new timeout is defined then show it
    if roundConfig.Find('timeout') <> nil then begin;
      setTimeout(roundConfig.Floats['timeout']);
    end else
    begin
      //if not then show no timeout
      setTimeout(0);
    end;

  end;
end;

procedure TfrmMain.tvControlsMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //check if a right click was on a bus or control that can be shown in the pin window
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
  //this event fires when a payload arrives at a topic to which this client is subscribed
  log(topic + ': ' + payload);
  //topicParser splits the topic string into individual tokens e.g. client/ip/4/enabled will be split into:
  // [0] = client
  // [1] = ip
  // [2] = 4
  // [3] = enabled
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
                if roundConfigJSON <> nil then begin
                  initiateRound(roundConfigJSON);
                end else
                begin
                  log('Invalid config received');
                end;
              finally
                roundConfigJSON.Free;
                roundJSONParser.Free;
              end;
            end else
            begin
              //lets assume that the next part of the topic is a control number
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
  //file name edit boxes are such a pain in the neck...
  fneLoadConfig.Width:=pnlLoadConfig.Width-26;
end;

procedure TfrmMain.tmrStatTimer(Sender: TObject);
begin
  //this timer updates the status bar text
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
    //create the correct type of hardware
    if hardwareType = 'instructions' then myspacehackControls[i] := TSPacehackInstructionDisplay.create;
    if hardwareType = 'combo7SegColourRotary' then myspacehackControls[i] := TSpacehackGameControlCombo7SegColourRotary.create;
    if hardwareType = 'illuminatedtoggle' then myspacehackControls[i] := TSpacehackGameControlIlluminatedToggle.create;
    if hardwareType = 'fourbuttons' then myspacehackControls[i] := TSpacehackGameControlFourButtons.create;
    if hardwareType = 'potentiometer' then myspacehackControls[i] := TSpacehackGameControlPotentiometer.create;
    if hardwareType = 'illuminatedbutton' then myspacehackControls[i] := TSpacehackGameControlIlluminatedButton.create;
    if hardwareType = 'keypad' then myspacehackControls[i] := TSpacehackGameControlKeypad.create;
    //as a backup just create the superclass
    if not assigned(myspacehackControls[i]) then begin
      myspacehackControls[i] := TSpacehackGameControl.Create;
    end;

    //if the control is a game control (not an instruction display) then tell it where to send value changes
    if myspacehackControls[i] is TSpacehackGameControl then begin
      TSpacehackGameControl(myspacehackControls[i]).changeTopic:='clients/'+myIP+'/' + inttostr(i)+'/value';
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
  //loop through our controls and buses and put the data on the tree view.
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
  //load the file to memory
  myFile := TFileStream.Create(configFile, fmOpenRead);
  if myFile = nil then begin
    showmessage('File load failed.');
  end else
  begin
    try
      //parse the JSON in the file and store the JSON objects for later
      myJSONParser := TJSONParser.Create(myFile);
      myJSONRoot := TJSONObject(myJSONParser.Parse);
      localConfigJSON := TJSONObject(myJSONRoot.Find('local'));
      interfaceConfigJSON := TJSONObject(myJSONRoot.Find('interface'));
      controlsJSON := TJSONObject(localConfigJSON.Find('controls'));
      busesJSON := TJSONObject(localConfigJSON.Find('buses'));

      //get my ip and the server ip
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

  //init some stuff with this data
  loadControlData;
  controlDataToTree;
  InitialiseControls;
end;

end.

