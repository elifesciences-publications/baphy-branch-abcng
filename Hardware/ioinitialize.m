% function DAQ=ioinitialize(params)
%
% initialize DAQ connection based on settings in params.
%
% created SVD 2005-10-21
%
function DAQ=ioinitialize(params)

if params.TESTMODE
    % empty DAQ signals running in test mode
    DAQ=[];
elseif 1
    % Initialize Analog output for Sound output
    DAQ.AO = analogoutput('nidaq',1);
    hwAnOut = addchannel(DAQ.AO,0:1);                 % Add channels for each speaker
    %set(DAQ.AO,'TriggerType','HwDigital');
    set(DAQ.AO,'TriggerType','Immediate');
    set(DAQ.AO,'TransferMode','DualDMA');
    set(DAQ.AO,'SampleRate',params.fs); 
    
    fsAI = 1000;  % 20000 for spike data
    aichannel = 0:1;
    ainames = {'Touch','Spike'};
    DAQ.AI = analoginput('nidaq',1);       % Create object DAQ.AI - NI Daq(2)
    hwAnIn = addchannel(DAQ.AI,aichannel,ainames);     % Add the h/w line
    % Line 1 is for touch input
    % Line 2 is for spike data
    set(DAQ.AI,'InputType','NonReferencedSingleEnded');      % Single ended input
    set(DAQ.AI,'DriveAISenseToGround','On');    % Do not use DAQ.AI sense to ground
    set(DAQ.AI,'SampleRate',fsAI);           % Sample rate
    set(hwAnIn,'InputRange',[-10 10]);      % Output from Amplifiers
    set(hwAnIn,'SensorRange',[-10 10]);     % for evp data set to
    set(hwAnIn,'UnitsRange',[-10 10]);      % [-10 10]Volts
    %set(DAQ.AI,'TriggerType','HwDigital');         % Trigger type=Manual
    set(DAQ.AI,'TriggerType','Immediate');
    set(DAQ.AI,'LoggingMode','Memory');
    set(DAQ.AI,'SamplesPerTrigger',fsAI*10);
    
    % Initialize Digital IO
    DAQ.DIO     = digitalio('nidaq',1);
    hwDIOut = addline(DAQ.DIO,0:1,'Out'); % Shock Light and Shock Switch   
    hwDiIn  = addline(DAQ.DIO,2,'In'); 
    hwTrOut = addline(DAQ.DIO,3:4,'Out'); % Trigger for AI and AO
    hwDiOut = addLine(DAQ.DIO,5,'Out'); % Water Pump
    hwDiIn2 = addLine(DAQ.DIO,6,'In');
    hwDiIn2 = addLine(DAQ.DIO,7,'In'); % touch input
end
