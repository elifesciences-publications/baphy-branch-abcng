function s =  TARCs(TARCDur, ModTar)

baphy_set_path

RippleRates = (4:4:48)';
ModTarInd = find(RippleRates == ModTar);
T = round(1000/4);
RippleFrequencies = (1.4:-0.2:-1.4);
RateNum = length(RippleRates);
FrqNum = length(RippleFrequencies);
AM = ones(RateNum,FrqNum);
PH = rand(RateNum,FrqNum)*360 - 180;
RippleRates = RippleRates*ones(1,FrqNum);
RippleFrequencies = ones(RateNum,1)*RippleFrequencies;

% Phase optimization
NumIterations=250;
StepSize=5;
for s = 1:FrqNum,
    disp(['Phase optimization: Stimulus ' num2str(s)])
    [yo,PH(:,s),mi,mo,mvec] = PhaseOptimization(AM(:,s),RippleRates(:,s),RippleFrequencies(:,s),PH(:,s),NumIterations,StepSize,T,1000);
end
PH=round(PH);

% Inverse-polarity
AM = [AM AM];
RippleRates = [RippleRates RippleRates];
RippleFrequencies = [RippleFrequencies RippleFrequencies];
PH = [PH PH-180];

% generate ripples
T0 = {[0 0 TARCDur]}; 	% actual duration in seconds
f0 = 125;	% lowest freq
BW = 8;	% bandwidth, # of octaves
SF = 80000;	% sample freq, 16384, must be an even number
CF = 1;	% component-spacing flag, 1->log spacing, 0->harmonic
df = 1/100;	% freq. spacing, in oct (CF=1) or in Hz (CF=0)
RO = 0;	% roll-off in dB/Oct
AF = 1;	% amplitude flag, 1->linear, 0->log (dB)
Mo = 1;	% amp. total mod: 0<Mo<1 (Af=1); 0<Mo dB (Af=0)
wM = 120;%Maximum temporal velocity to consider in Hz (DEFAULT = 120)
PhFlag = 1;% Flag which determines how to set the compnent flags

Durs = T0{1};
if Durs(1) > 0 && Durs(2) == 0 && Durs(3) == 0
    fname  = 'TORC';
elseif Durs(1) == 0 && Durs(2) == 0 && Durs(3) > 0
    fname = 'TARC';
elseif Durs(1) > 0 && Durs(2) > 0 && Durs(3) > 0
    fname = 'TORCTARC';
end

nstim = size(AM,2);
cond = [T0 f0 BW SF CF df RO AF Mo wM PhFlag];
for i = 1:nstim
    rippleList =  [AM(:,i),RippleRates(:,i),RippleFrequencies(:,i),PH(:,i)];
    rippleList_rad =  [AM(:,i),RippleRates(:,i),RippleFrequencies(:,i),PH(:,i)./180.*pi];
    s = TarcGenerator(rippleList_rad, cond, ModTarInd);
    wavname=[fname '_'  num2str(RippleRates(ModTarInd,1)) '_' num2str(i) '.wav']
    wavwrite(.999.*(s./max(abs(s))),SF,wavname)
    %     save parameters with phase in degrees to be compaitble with ststims code
    a = writeTorcInfo([fname '_'  num2str(RippleRates(ModTarInd,1)) '_' num2str(i) '.txt'],rippleList,cond);
end


