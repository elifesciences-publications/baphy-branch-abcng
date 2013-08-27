function Z = getImpedances(varargin)
% Configuration File for Electrodes is located in 
% \Users\dzb\AppData\Local\nanoZ\electrodes.ini


%% PARSE PARAMETERS
P = parsePairs(varargin);
checkField(P,'Frequency',1000); % Hz
checkField(P,'Channels','all');      % Channel Range
checkField(P,'DevNum',1);         % NanoZ Device number
checkField(P,'Reps',40);            % # of periods of measurement
checkField(P,'BufferSize',64);     % Read Buffer Size : increase if hardware buffer overruns
checkField(P,'NumOverlap',2);   % Number of overlapping Z readings
checkField(P,'Array','LMA0x2D10') % Provide Name of the array
checkField(P,'NanoZPath',[fileparts(which('baphy')) '\Hardware\NanoZ\']); % Basepath for NanoZ software
NSamples = P.Frequency * P.Reps; % Number of samples per Z reading

%% GET ELECTRODE AND ADAPTOR DEFINITIONS
S = load_definitions([P.NanoZPath,'MatlabSDK\electrodes.ini']);
% clear nanoz   % Close any nanoZ handles that might have been erroneously left open
Devs = nanoz('enumdevs');
if isempty(Devs) disp('No nanoZ devices attached, or in use by other applications'); return;
end

%% SETUP NANOZ
hDev = nanoz('open',Devs{P.DevNum},P.BufferSize); 
fprintf('\nOpened nanoZ %s\n',Devs{P.DevNum});
ActualFreq = nanoz('setfreq',hDev,P.Frequency); % Set frequency, storing the achieved value

%% PERFORM MEASUREMENTS
fprintf('Measuring at frequency %.1f Hz\n',ActualFreq,' : ');
if ischar(P.Channels) & strcmp(P.Channels,'all') P.Channels = S.(P.Array).ChMap; end
for i=1:length(P.Channels)  
  fprintf('%d ',cChannel);
  cChannel = P.Channels(i);
  nanoz('selectchannel',hDev,cChannel);
  pause(0.5);  % Pause 0.5s for circuit settlement after a channel switch
  [D,Z(i)] =  impedance_loop(hDev,NSamples,P.NumOverlap,1);
  fprintf('(%3.1) ',I(i));
end
fprintf('\n');

%% SAVE IMPEDANCES TO DATABASE
if P.DB
  
end