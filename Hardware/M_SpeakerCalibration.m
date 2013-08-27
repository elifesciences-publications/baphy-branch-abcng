function R  = M_SpeakerCalibration(varargin)
% During the execution, the user is asked to visually judge the length of
% the IIR. A typical value is 10ms.
% see also: SpeakerCalib, findAmplitudeAndDelay, VolumeConversion, StimConversion
% 
% This file is part of MANTA licensed under the GPL. See MANTA.m for details.

Dirs = setgetDirs;

%%  PARSE INPUT
P = parsePairs(varargin);
if ~isfield(P,'Speaker') P.Speaker = 'Unknown'; end
if ~isfield(P,'Microphone') P.Microphone = 'BK4944A';  % PATRICK'S B&K
end
if ~isfield(P,'VRef') P.VRef = .5; end
if ~isfield(P,'Max80dB') P.Max80dB = 5; end
if ~isfield(P,'dBSPLRef') P.dBSPLRef = 80; end
if ~isfield(P,'Device') P.Device='D0'; end
if ~isfield(P,'SR') P.SR=100000; end
if ~isfield(P,'LStim') P.LStim=10; end
if ~isfield(P,'TestDur') P.TestDur = 5; end
if ~isfield(P,'PreDur') P.PreDur=0.05; end
if ~isfield(P,'PostDur') P.PostDur=0.05; end
if ~isfield(P,'NoiseStd') P.NoiseStd=0.1; end
if ~isfield(P,'FIG') P.FIG=1; end
if ~isfield(P,'LowFreq') P.LowFreq = 1000; end
if ~isfield(P,'HighFreq') P.HighFreq  = 45000; end
if ~isfield(P,'ImpRespDur') P.ImpRespDur = 0.009; end
if ~isfield(P,'TestMode') P.TestMode = 0; end
if ~isfield(P,'RampDur') P.RampDur = 0.005; end
if ~isfield(P,'AdBTarget') P.AdBTarget = 80; end
if ~isfield(P,'Ftest') P.Ftest = 1000; end
if ~isfield(P,'Vmax') P.Vmax = 10; end
if ~isfield(P,'ChIn') P.ChIn = 3; end
if ~isfield(P,'ChOut') P.ChOut = 0; end
if ~isfield(P,'InputRange') P.InputRange = [-5,5]; end
if ~isfield(P,'SpeakerPath') P.SpeakerPath = Dirs.Speaker; end
if ~isfield(P,'NFFT') P.NFFT = round(P.ImpRespDur*P.SR); end
if ~isfield(P,'Colors')
  P.Colors = struct('Signal',[0,0,0],'Response',[1,0,0],'Filter',[0,0,1]); end
P.PreSteps = round(P.PreDur*P.SR);
P.PostSteps = round(P.PostDur*P.SR);

fprintf(['\n ====== Calibrating Speaker [ ',P.Speaker,' ] on DAQ Device ',P.Device,' =====\n']);

%% INITIALIZE ATTENUATOR FOR SPR1 & 2
% switch lower(HF_getHostname)
%   case 'avw2202n'
%     devices = instrfindall;     % this matlab command find the open devices
%     for cnt1 = 1:length(devices) delete(devices(cnt1)); end
%        
%     % INITIALIZE ATTENUATOR
%     HW.Atten = attenuator;
%     init(HW.Atten);% Set properties and fopen gpib
%     attenuate(HW.Atten,0);% Set attenuation to 0db
%     
%     % INITIALIZE FILTER
%     HW.filter = khfilter(22); % Set properties and fopen gpib
%     init(HW.filter);
%     setfilter(HW.filter, 'Channels', 'All', 'InputGain', 0, 'OutputGain', 0);
%     setfilter(HW.filter,'Channels',1,'Frequency',P.SR); % Sound Out
%     setfilter(HW.filter,'Channels',3,'Frequency',20); % Microphone
%     % INITIAZLIZE EQUALIZER
%     attenuation = -20;
%     
%     HW.Eqz = rpmequalizer;
%     HW.Eqz = set(HW.Eqz,'IPAddress','128.8.140.198');
%     HW.Eqz = init(HW.Eqz);
%     zeroequalizer(HW.Eqz);
%     % also, set the gain of input and output to zero:
%     adjustinputoutputgain(HW.Eqz,[192 192]);   %192 means 0 db
% 
%     % Initialize calibration signal
%     freq = [25.0, 31.5, 40.0, 50.0, 63.0, 80.0, 100.0, 125.0, 160.0,...
%       200.0, 250.0, 315.0, 400.0, 500.0, 630.0, 800.0, 1000.0, 1250.0,...
%       1600.0, 2000.0, 2500.0, 3150.0, 4000.0, 5000.0, 6300.0, 8000.0,...
%       10000.0, 12500.0, 16000.0, 20000.0];
%     % init signal to tones of above frequencies
%     voltage      = 10.0;   %This is the peak-to-peak of the output from computer.
%     signaldur    =0.75;
%     %%%%%% calibration signal initialized %%%%%%%
%     % Start the calibration sequence
%     bandatten = zeros(length(freq),1)+14+attenuation;
% 
%     % Nima add -14 attenuation to the input module of the equalizer, so the
%     % overal max gain is zero, and the maximum attenuation is -36-14=-50,
%     % should be enough.
%     loadequalizer(HW.Eqz,bandatten);
%     adjustinputoutputgain(HW.Eqz,[164 192]); % 152: input at -20, 164: -14dB,  192: output at 0db        
% end


%% PREPARE NOISE STIMULUS
[Signal,P] = LF_prepareSignal(P); R = [ ];

if ~P.TestMode
  % PREPARE SOUND OUTPUT & INPUT
  [AI,AO] = LF_prepareEngines(P);
  
  % SEND AND ACQUIRE DATA
  fprintf(['\n ==== Calibration stimulus playing (',n2s(P.LStim),' s)'])
  [Signal,Response] = LF_getData(AI,AO,Signal,P); fprintf('\n');
else
  % PRODUCE SIMULATION DATA
  [Signal,Response] = LF_createData(Signal,P);  
end
  
% PREPARE FIGURE
if P.FIG>0
  P.DC = HF_axesDivide([1,1,1],[.8,1,1],[.08,.88],[.12,.8],[.4],[.8,.5]);
  P.AxisOpt = {'FontSize',7,'FontName','Helvetica Neue','XGrid','on','YGrid','on','Box','on'};
  P.AxisLabelOpt = {'FontSize',8,'FontName','Helvetica Neue'};
  P.XTick = [100,1000,10000]; P.XTickLabel = {'100','1000','10000'};
  figure(P.FIG); clf; set(P.FIG,'Name',...
    ['Speaker: ',P.Speaker,' (SR=',n2s(P.SR),'Hz)'],...
    'MenuBar','none','Toolbar','figure');
end
  
% ESTIMATE TRANSFERFUNCTION 
[R,P] = LF_estimateTF(Signal,Response,R,P);

% ESTIMATE INVERSE TRANSFERFUNCTION
[R,P] = LF_estimateITF(Signal,Response,R,P);

if ~P.TestMode
  % ADJUST VOLUME INTERACTIVELY & TEST TRANSFERFUNCTION
  R = LF_testCalibration(AI,AO,R,P);
  
  % SAVE RESULTS
  LF_saveResults(R,P);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [AI,AO] = LF_prepareEngines(P)
daqreset;
% SETUP ANALOG IN AND OUT
AI = analoginput('nidaq',P.Device);
AO = analogoutput('nidaq',P.Device);
addchannel(AI,P.ChIn); addchannel(AO,P.ChOut);
C= get(AI,'Channel'); set(C,'InputRange',P.InputRange);
set([AI],'TriggerType','HwDigital','InputType','SingleEnded',...
  'TriggerCondition','PositiveEdge','HwDigitalTriggerSource','RTSI0');
set([AO],'TriggerType','Manual','ExternalTriggerDriveLine','RTSI0');
% CHECK AND SET SAMPLING RATES
SRactualIN = setverify(AI,'SampleRate',P.SR);
SRactualOUT = setverify(AO,'SampleRate',P.SR);
if SRactualIN~=P.SR 
  if SRactualIN==SRactualOUT
    P.SR = SRactualIN; fprintf(['Note: Sampling Rate changed to ',n2s(P.SR)])
  else
    error('No common sampling rate for the chosen sampling rate between the cards.');
  end
end
set([AI,AO],'SampleRate',P.SR);

fprintf(['   < Output Channel\t:\t',n2s(P.ChOut),'\n']);
fprintf(['   > Input Channel\t:\t',n2s(P.ChIn),'\n']);
fprintf(['   = Sampling Rate\t:\t',n2s(P.SR),' Hz\n']);

function [Signal,P] = LF_prepareSignal(P)
%P.NSteps = round(P.LStim*P.SR);
%Signal = [randn(1,P.NSteps,1)]';
% svd reduced to 4 times downsampling
P.NSteps = round(P.LStim*P.SR);
Signal = [randn(1,P.NSteps,1)]';
%Signal=resample(Signal,P.SR,P.SR/4);
Signal = P.NoiseStd*Signal/std(Signal);

function [Signal,Response] = LF_getData(AI,AO,Signal,P)
FinalSignal = [zeros(P.PreSteps,1);Signal;zeros(P.PostSteps,1)];
flushdata(AI); set(AI,'SamplesPerTrigger',length(FinalSignal)); 
putdata(AO,FinalSignal); start([AI,AO]); trigger(AO);
while strcmp(get(AO,'Running'),'On') pause(1); end;
stop([AI,AO]);
Response = getdata(AI,length(FinalSignal));
Response = Response - mean(Response(round(P.PreSteps/2):P.PreSteps));
Range = [P.PreSteps:P.PreSteps+length(Signal)];
Signal = FinalSignal(Range); Response = Response(Range);

function [Signal,Response] = LF_createData(Signal,P)
Sigma = 30;
Kernel = exp(-([0:1000]).^2/(2*Sigma.^2)).*sin(2*pi*1000*[0:1000]/P.SR);
Response = conv(Signal,Kernel);
Range = [1:length(Signal)];
Response = Response(Range);

function [R,P] = LF_estimateTF(Signal,Response,R,P)
fprintf('   >> Computing Forward Transformations\n')

P.FNyquist = P.SR/2;
P.NSpectrum = P.NFFT/2+1; Window = P.NFFT;
R.Fs = P.FNyquist*(1:P.NSpectrum-1)/(P.NSpectrum-1); % spectral frequencies in Hz (except 0)

% SPECTRA OF INPUT AND OUTPUT
SignalSpec = pwelch(Signal/std(Signal),Window,floor(Window/2),P.NFFT,P.SR);
ResponseSpec = pwelch(Response/std(Response),Window,floor(Window/2),P.NFFT,P.SR);
SignalSpecdB = LF_x2dBScale(abs(SignalSpec(2:P.NSpectrum,:)),1,10);
ResponseSpecdB = LF_x2dBScale(abs(ResponseSpec(2:P.NSpectrum,:)),1,10);

P.SpecAxis = axes('Po',HF_fusePos(P.DC{1,1:2}),P.AxisOpt{:}); hold on;
plot(R.Fs,SignalSpecdB,'Color',P.Colors.Signal);
plot(R.Fs,ResponseSpecdB,'Color',P.Colors.Response); 
xlabel('F [Hz]',P.AxisLabelOpt{:}); 
ylabel('[dB (V^2/Hz)]',P.AxisLabelOpt{:}); 
title('Power Spectral Densities',P.AxisLabelOpt{:}); 
set(gca,'XTick',[P.XTick,P.FNyquist],'XTickLabel',{P.XTickLabel{:},n2s(P.FNyquist)} ,'XScale','log');
   
% TRANSFER FUNCTION
R.TF = tfestimate(Signal,Response,2*P.NFFT,[],P.NFFT,'twosided'); 
R.TF(P.NSpectrum) = 0;

% GAIN
P.TFGainAxis = axes('Po',P.DC{2,1},P.AxisOpt{:}); hold on
R.TFdB = LF_x2dBScale(abs(R.TF(1:P.NSpectrum-1)),1,20);
plot(R.Fs(1:P.NSpectrum-2),R.TFdB(2:P.NSpectrum-1),...
  'Color',P.Colors.Filter);
title('Transfer Function (Gain)',P.AxisLabelOpt{:});
set(gca,'XTick',P.XTick,'XTickLabel',P.XTickLabel ,'XScale','log');
ylabel('A [dB]',P.AxisLabelOpt{:});

% PHASE
P.TFPhiAxis = axes('Po',P.DC{2,2},P.AxisOpt{:}); hold on;
PhaseUnwrap = unwrap(angle(R.TF(1:P.NSpectrum-1)))/(2*pi);
plot(R.Fs(1:P.NSpectrum-2),PhaseUnwrap(2:P.NSpectrum-1),...
  'Color',P.Colors.Filter);  axis tight;
title('Transfer Function (Phase)',P.AxisLabelOpt{:}); 
set(gca,'XTick',P.XTick,'XTickLabel',P.XTickLabel ,'XScale','log');
ylabel('\phi [2\pi]',P.AxisLabelOpt{:}); 

% COMPUTE IMPULSE-RESPONSE
R.IR = real(ifft(R.TF));  P.dt = 1/P.SR; 
R.Time = [0:P.dt:(P.NFFT-1)*P.dt];

axes('Po',HF_fusePos(P.DC{2,3}),P.AxisOpt{:}); hold on
plot(R.Time*1000,R.IR,'Color',P.Colors.Filter); axis tight;
title('Impulse Response',P.AxisLabelOpt{:}); 
ylabel('V [Volts]',P.AxisLabelOpt{:}); 

% RECOMPUTE TRANSFER FUNCTION (IR ZEROED ABOVE IMPRESPDUR)
IndCutIR = floor(P.ImpRespDur*P.SR); 
R.IR(IndCutIR+1:P.NFFT) = 0;
R.TF = fft(R.IR);  R.TF(P.NSpectrum) = 0;

axes(P.TFGainAxis);
R.TFdB = LF_x2dBScale(abs(R.TF(1:P.NSpectrum-1)),1,20);
plot(R.Fs(1:P.NSpectrum-2),R.TFdB(2:P.NSpectrum-1),...
  'Color',HF_whiten(P.Colors.Filter,.5));  axis tight
Labels = {'TF from Spectra',['TF from IR (0-',n2s(P.ImpRespDur*1000),'ms)']};
Colors = {P.Colors.Filter,HF_whiten(P.Colors.Filter,.5)};
for i=1:length(Labels) 
  text(0.05,.9-(i-1)*0.15,Labels{i},'Units','normalized','Horiz','Left',...
    'Color',Colors{i},'FontWeight','bold','FontSize',8); 
end

axes(P.TFPhiAxis);
R.PhaseUnwrap = unwrap(angle(R.TF(1:P.NSpectrum-1)))/(2*pi);
semilogx(R.Fs(1:P.NSpectrum-2),R.PhaseUnwrap(2:P.NSpectrum-1),...
  'Color',HF_whiten(P.Colors.Filter,0.5)); axis tight

function [R,P] = LF_estimateITF(Signal,Response,R,P)
% The inverse TF is calculated by dividing the TF 
% of an FIR bandpass filter (low_cf ... high_cf)
% by the TF of the forward system.
fprintf('   >> Computing Inverse Transformations\n')
P.NSamples = round(P.ImpRespDur*P.SR);  
% Make P.NSamples odd.
if rem(P.NSamples,2) == 0   P.NSamples = P.NSamples+1; end

% COMPUTE INVERSE TRANSFER FUNCTION
P.UpperEdge = min([P.HighFreq,0.9*P.FNyquist]);
P.FilterFreq = [0,0.8*P.LowFreq,P.LowFreq,...
  P.UpperEdge,1.1*P.UpperEdge,P.FNyquist]./P.FNyquist;  
P.NFreq = length(P.FilterFreq); P.FreqAmplitudes = [0,0.1,1,1,0.1,0];

axes(P.SpecAxis);
plot(P.FilterFreq*P.FNyquist,LF_x2dBScale(P.FreqAmplitudes,1,20),...
  'Color',P.Colors.Filter); axis tight;
Labels = {'Signal','Response','Filter'};
for i=1:length(Labels) 
  text(0.01,.15+(i-1)*.2,Labels{i},'Units','normalized','Horiz','Left',...
    'Color',P.Colors.(Labels{i}),'FontWeight','bold','FontSize',8); 
end

R.IRfir = fir2(P.NSamples-1,P.FilterFreq,P.FreqAmplitudes,kaiser(P.NSamples,3));  % provides impulse-response for the filter.
R.IRfir = R.IRfir(1:P.NFFT)'; % patched with zeros to full NFFT samples
R.TFfir = fft(R.IRfir);  % go to frequency-representation of the fir-filter
R.TFfir(P.NSpectrum) = 0; % set the middle point to 0
R.iTF = [complex(0,0);R.TFfir(2:P.NSpectrum-1)./R.TF(2:P.NSpectrum-1);complex(0,0)]; % Freq 0..P.FNyquist (1x1025)
R.iTFtot = [R.iTF ; flipud(conj(R.iTF(2:end-1)))];

% COMPUTE INVERSE IMPULSE RESPONSE
R.IIR1 = real(ifft(R.iTFtot));

P.IIRAxis = axes('Po',P.DC{3,3},P.AxisOpt{:}); hold on
plot(R.Time*1000,R.IIR1,'Color',P.Colors.Filter);

% INVERSE TRANSFER FUNCTION
% GAIN
P.ITFGainAxis = axes('Po',P.DC{3,1},P.AxisOpt{:}); hold on;
R.iTFtotdB = LF_x2dBScale(abs(R.iTFtot(2:P.NSpectrum-1)),1,20); 
plot(R.Fs(1:P.NSpectrum-2),R.iTFtotdB,'Color',P.Colors.Filter);  axis tight;
ylabel('A [dB]',P.AxisLabelOpt{:}); 
title('Inverse Transfer Function (Gain)',P.AxisLabelOpt{:});
set(gca,'XTick',P.XTick,'XTickLabel',P.XTickLabel ,'XScale','log');

% PHASE
P.ITFPhiAxis = axes('Po',P.DC{3,2},P.AxisOpt{:}); hold on;
PhaseUnwrap = unwrap(angle(R.iTFtot(2:P.NSpectrum-1)))/(2*pi); 
plot(R.Fs(1:P.NSpectrum-2),PhaseUnwrap,'Color',P.Colors.Filter);  axis tight;
ylabel('\phi [2\pi]',P.AxisLabelOpt{:}); 
title('Inverse Transfer Function (Phase)',P.AxisLabelOpt{:});
set(gca,'XTick',P.XTick,'XTickLabel',P.XTickLabel ,'XScale','log');

% COMPUTE INVERSE IMPULSE RESPONSE (QUENCHED AT END)
% WEIGHTING FUNCTION OF TYPE y(t)=a*t^n*exp(-b*t):
% PEAKS AT PeakTimeRel
P.Gating = 'sinusoidal';
switch lower(P.Gating)
  case 'alpha';
    PeakTimeRel = 0.003/R.Time(P.NFFT-1);
    Time = [0:length(R.IIR1)-1]';
    alpha = 0.02;    kw = 1/PeakTimeRel;
    Exponent = -log(alpha)/(kw-1-log(kw));
    t1 = round(PeakTimeRel*(length(Time)-1));
    bw = t1/Exponent;
    aw = 1/(((Exponent*bw)^Exponent)*exp(-Exponent));
    R.ImpWeight = aw*(Time.^Exponent).*exp(-Time/bw);
  case 'sinusoidal'
    R.ImpWeight = tukeywin(length(R.IIR1),0.1);
end
R.IIR2 = R.ImpWeight.*R.IIR1;

% FILTER OUT HIGH FREQUENCY PART
% NN=P.SR/2; hif=24000;
% order = 4;
% [bLow,aLow] = butter(order,hif/NN,'low');
% R.IIR2 = filter(bLow,aLow,R.IIR2);
R.IIR = R.IIR2;

R.iTFtot2 = fft(R.IIR2);

axes(P.IIRAxis);
plot(R.Time*1000,R.IIR2,'Color',HF_whiten(P.Colors.Filter,.5)); axis tight;
xlabel('t (ms)',P.AxisLabelOpt{:}); 
ylabel('V [Volts]',P.AxisLabelOpt{:});
title('Inv. Impulse Response',P.AxisLabelOpt{:}); 
Labels = {'IIR',['IIR weighted with alpha-Kernel']};
Colors = {P.Colors.Filter,HF_whiten(P.Colors.Filter,.5)};
for i=1:length(Labels) 
  text(0.05,.9-(i-1)*0.15,Labels{i},'Units','normalized','Horiz','Left',...
    'Color',Colors{i},'FontWeight','bold','FontSize',8); 
end

% GAIN (QUENCHED)
axes(P.ITFGainAxis); 
R.iTFtot2dB = LF_x2dBScale(abs(R.iTFtot2(2:P.NSpectrum-1)),1,20); 
plot(R.Fs(1:P.NSpectrum-2),R.iTFtot2dB,'Color',HF_whiten(P.Colors.Filter,.5)); 
xlabel('F [Hz])',P.AxisLabelOpt{:}); 
ylabel('A [dB]',P.AxisLabelOpt{:}); 

% PHASE (QUENCHED)
axes(P.ITFPhiAxis);
PhaseUnwrap = unwrap(angle(R.iTFtot2(2:P.NSpectrum-1)))/(2*pi);
plot(R.Fs(1:P.NSpectrum-2),PhaseUnwrap,'Color',HF_whiten(P.Colors.Filter,.5)); 
xlabel('F [Hz]',P.AxisLabelOpt{:});
ylabel('\phi [2\pi]',P.AxisLabelOpt{:}); 

% CONVOLVE THE FORWARD AND INVERSE IMPULSE RESPONSES
R.IIR2 = R.IIR2(1:min([round(2*P.ImpRespDur*P.SR),length(R.IIR2)]));
R.truncIR = R.IR(1:floor(P.ImpRespDur*P.SR));  
R.convIR = conv(R.IIR2,R.truncIR);
R.IRdelayPos = find(max(R.convIR)==R.convIR); 
if length(R.IRdelayPos)>1
  warning('Maximum found at multiple points in convolved impulse response'); 
  R.IRdelayPos = R.IRdelayPos(1);
end
R.IRdelayTime = R.IRdelayPos/P.SR;
Time = [0:P.dt:(length(R.convIR)-1)*P.dt];
axes('Po',P.DC{1,3},P.AxisOpt{:}); hold on;
plot(Time*1000,R.convIR,'Color',P.Colors.Filter); axis tight;
xlabel('t [ms]',P.AxisLabelOpt{:});
title('Convolved IRs',P.AxisLabelOpt{:});
text(0.05,0.9,['Peak at ',n2s(R.IRdelayPos),'steps = ',...
  n2s(R.IRdelayTime*1000),'ms'],'Units','Normalized',P.AxisLabelOpt{:})

function R = LF_testCalibration(AI,AO,R,P)

figure(P.FIG+1); clf;
GUI.Axis = axes('Pos',[.1,.2,.85,.75]);
GUI.Stopbutton = uicontrol('style','Togglebutton','String','Sweet!','Value',0,...
  'Units','normalized','Pos',[.01,.01,.1,.06]);

%% PLAY A LONG NOISE UNTIL THE USER PRESSES A BUTTON
% User is supposed to adjust the Volume dial on the amplifier during this period
% in a figure the current volume is shown every 0.2s
% for Details of the Signal conversion see IOAdjustVolume
STIMORIG = P.Max80dB/sqrt(2)*randn(round(60*P.SR),1); % WITH STANDARD DEVIATION VRef = 5V/sqrt(2)
STIM = conv(STIMORIG,R.IIR);

MAX = max(abs(STIM)); R.A80dB = P.VRef/MAX;
STIM = R.A80dB * STIM; % STIMULUS NOW SAFELY WITHIN [-VRef,VRef]V
R.IIR80dB = R.A80dB*R.IIR;

set(AI,'SamplesPerTrigger',length(STIM));
putdata(AO,STIM); Volumes = zeros(10000,1); i=0;
start([AO,AI]); trigger(AO); TotalSamples = 0;
while ~get(GUI.Stopbutton,'Value')   
  i=i+1;   pause(0.2); cla(GUI.Axis); hold on;
  DATA = getdata(AI,get(AI,'SamplesAvailable'));
  Vcurrent = std(DATA);
  Volumes(i) = M_VolumeConversion(Vcurrent,'V2dB',P.Microphone);
  Ind = [max(1,i-10):i]; 
  plot([Ind(1)-.5,Ind(end)+.5],[P.dBSPLRef,P.dBSPLRef],'r');
  plot(GUI.Axis,Ind,Volumes(Ind),'.-b'); grid on;
  axis([Ind(1)-0.5,Ind(end)+0.5,...
    min([P.dBSPLRef-1,floor(min(Volumes(Ind)))]),...
    max([P.dBSPLRef+1,ceil(max(Volumes(Ind)))])]);
  TotalSamples = TotalSamples + length(DATA);
end
fprintf(['  >> Collecting Data for Delay & Spectrum Estimation (',n2s(P.TestDur),'s)']);
pause(P.TestDur);
stop([AI,AO]);
DATA = getdata(AI,get(AI,'SamplesAvailable'));
T = [1:length(DATA)]/P.SR;
STIMORIG = STIMORIG(TotalSamples+1:TotalSamples+length(DATA));
cdBSPL = M_VolumeConversion(Vcurrent,'V2dB',P.Microphone);
fprintf([' => Volume : ',n2s(cdBSPL),'\n']);

%% COMPUTE DELAY
MaxDelay = round(0.02*P.SR);
X_SD = xcorr(DATA,STIMORIG,MaxDelay); 
[MAX,R.ConvDelaySteps] = max(X_SD);
R.ConvDelaySteps = R.ConvDelaySteps - MaxDelay -1;
R.ConvDelay = R.ConvDelaySteps/P.SR;
fprintf(['   => Convolution Delay\t:\t',num2str(R.ConvDelay),' s (',num2str(R.ConvDelaySteps),' samples)\n'])

%% SPECTRAL CHECK
DATAshifted = DATA(R.ConvDelaySteps:end);
STIMORIGtrimmed = STIMORIG(1:end-R.ConvDelaySteps+1);
R.TFCalib = tfestimate(STIMORIGtrimmed,DATAshifted,2*P.NFFT,[],P.NFFT,'twosided');
R.TFCalib(P.NSpectrum) = 0;
R.TFCalibdB = LF_x2dBScale(abs(R.TFCalib(1:P.NSpectrum-1)),1,20);
PhaseUnwrap = unwrap(angle(R.TFCalib(1:P.NSpectrum-1)))/(2*pi);

%% TEST TONAL CALIBRATION
LStim = 10; fbase = P.LowFreq; Xges = log2(P.HighFreq/P.LowFreq);
[ZAPORIG,TZAP,FZAP] = LF_createZAP(LStim,Xges,fbase,P.SR);
ZAPORIG = P.VRef*ZAPORIG'; % Brings ZAP Stimulus to +/-V peak to peak
ZAP = conv(ZAPORIG,R.IIR80dB);

set(AI,'SamplesPerTrigger',length(ZAP));
putdata(AO,ZAP); start([AO,AI]); trigger(AO); pause(LStim); stop([AI,AO]);
ZAPDATA = getdata(AI,get(AI,'SamplesAvailable'));
TZAP = [1:length(ZAPDATA)]/P.SR;
if length(ZAPDATA)<=length(FZAP); 
  FZAP =  FZAP(1:length(ZAPDATA));
else
  FZAP(end+1:length(ZAPDATA)) = 0;
end
BinBounds = round(linspace(0,length(ZAPDATA),200));
for i=1:length(BinBounds)-1
  Vcurrent = std(ZAPDATA(BinBounds(i)+1:BinBounds(i+1)));
  VolZAP(i) = M_VolumeConversion(Vcurrent,'V2dB',P.Microphone);
  FVolZAP(i) = mean(FZAP(BinBounds(i)+1:BinBounds(i+1)));
end

%% PLOT RESULTS
figure(P.FIG+1); clf;
DC = HF_axesDivide(1,6,[.08,.85],[.06,.9],[],[.7]);

for i=1:length(DC)
  axes('Po',DC{i},P.AxisOpt{:}); hold on;
  switch i
    case 1;  title('Stimulus for Calibration'); 
      plot(T,STIMORIG); axis tight; grid on
    case 2;  title('Response for Calibration')
      plot(T,DATA); axis tight; grid on
    case 3; title('Crosscorrelation');
      plot([-MaxDelay:MaxDelay]/P.SR,X_SD);  grid on
    case 4; title('Transfer Function (Gain)',P.AxisLabelOpt{:});
      plot(R.Fs(1:P.NSpectrum-2),R.TFCalibdB(2:P.NSpectrum-1),...
        'Color',P.Colors.Filter); axis tight;
      set(gca,'XTick',P.XTick,'XTickLabel',P.XTickLabel ,'XScale','log');
      ylabel('A [dB]',P.AxisLabelOpt{:});
    case 5; title('Transfer Function (Phase)',P.AxisLabelOpt{:});
      plot(R.Fs(1:P.NSpectrum-2),PhaseUnwrap(2:P.NSpectrum-1),...
        'Color',P.Colors.Filter);  axis tight;
      set(gca,'XTick',P.XTick,'XTickLabel',P.XTickLabel ,'XScale','log');
      ylabel('\phi [2\pi]',P.AxisLabelOpt{:});
    case 6; title('Tonal Amplitude Response')
      hold off;
      [AX,H1,H2] = plotyy(FZAP,ZAPDATA,FVolZAP,VolZAP,'semilogx','semilogx'); 
      set(AX,'XLim',[FZAP(1),FZAP(end)]); grid on
      xlabel('Frequency [Hz]');
  end
end

function LF_saveResults(Rall,P);
% GET BAPHY PATH
Sep = HF_getSep; Path = which('baphy');
if ~isempty(Path) Path = Path(1:find(Path==Sep,1,'last')); 
else Path = input('Enter Baphy Path: ');
end
Path = [Path,'Hardware',Sep,'Speakers',Sep];
FileName = [Path,'SpeakerCalibration_',P.Speaker,'_',P.Microphone,'.mat'];
Rall.SR = P.SR; Rall.VRef = P.VRef; Rall.dBSPLRef = P.dBSPLRef;

% COLLECT VARIABLES NECESSARY FOR SPEAKER CORRECTION
Vars = {'SR','IIR80dB','ConvDelay','VRef','dBSPLRef'};
for i=1:length(Vars) eval(['R.(Vars{i}) = Rall.',Vars{i},';']); end

fprintf(['\n ===== Saving Calibration =====\n  >> File\t:\t',escapeMasker(FileName),'\n']);
save(FileName,'R');

function [STIM,T,F] = LF_createZAP(Lstim,Xges,fbase,SRHz)

dt = 1/SRHz;
T = [0:1/SRHz:Lstim]; X =  linspace(0,Xges,length(T));  F = fbase*2.^X;  

phaseinc = dt.*F;
phases = cumsum(phaseinc); 
STIM = sin(2*pi*phases);

function dB = LF_x2dBScale(x,base,fact)
dB = fact*log10(x/base);