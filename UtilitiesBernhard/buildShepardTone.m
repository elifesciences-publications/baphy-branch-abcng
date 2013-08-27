function Sound = buildShepardTone(Par,SR,Seed)

if ~exist('Seed','var') Seed = rand; end
if ~isfield(Par,'ComponentJitter') Par.ComponentJitter = 0; end

StimSteps = Par.Durations*SR; 
Time = [0:1/SR:(StimSteps-1)/SR];
Time = Time';
Fmin = 5; Fmax = SR/2;
Octs = [-10:Par.BaseSeps:10];
Fs = Par.BaseFreqs*2.^Octs;
Fs = Fs.*2^((Par.PitchClasses + Par.PitchClassShift)/12);
Ind = logical((Fs>Fmin).*(Fs<Fmax));
Fs = Fs(Ind); Octs = Octs(Ind);cPos = find(Par.EnvStyle==' ',1,'first');
if ~isempty(cPos) Par.EnvStyle = Par.EnvStyle(1:cPos-1); end
NFs = length(Fs); NTime = length(Time);

% ASSIGN A FIXED SET OF PHASES (UNIQUE PHASE FOR EACH FREQ.)
Phases = zeros(size(Fs));
% Changed on 9/16/11 to improve efficiency
% Old:
% for i=1:length(Fs)  R = RandStream('mrg32k3a','Seed',Fs(i)); Phases(i) = R.rand;  end
% New:
% R = RandStream('mrg32k3a','Seed',Fs(1)); Phases = R.rand(size(Fs)); 
% Attempt to sort out potential influence of phase in AMA029
% Phases = rand(size(Fs)); %fprintf('WARNING: Randomized!\n'); 
% Made Permanent starting from 9/22/11, where seed is usually the position in the sequence
R = RandStream('mrg32k3a','Seed',Seed*Fs(1)); Phases = R.rand(size(Fs)); 

% CHECK ENVELOPE POSITION
A = zeros(1,NFs);
for i=1:NFs
  switch Par.EnvStyle
    case 'Gaussian';
      if abs(log2(Fs(i)) - log2(Par.EnvCenters))<=Par.EnvWidths
        A(i) = (1+cos(2*pi*(log2(Fs(i))-log2(Par.EnvCenters))/(2*Par.EnvWidths)))/2;
      end
    case 'Constant';    A(i) = 1;
    case 'Tones';
      FsInd = find(Octs==0);
      if i==FsInd A(FsInd) = 1; end
      
    otherwise  error('Unknown Envelope!');
  end
end
% More efficient computation of the sines
if Par.ComponentJitter == 0
  Sound = sum(bsxfun(@times,sin(bsxfun(@times,bsxfun(@plus,repmat(Time,1,NFs),Phases),2*pi*Fs)),A),2);
else
  R = RandStream('mrg32k3a','Seed',2*Seed*Fs(1)); Jitters = Par.ComponentJitter*R.rand(size(Fs));
  Sound = zeros(round(max(Jitters)*SR)+length(Time),1);
  for i=1:NFs
    iStart = round(Jitters(i)*SR);
    Inds = [iStart:iStart-1+length(Time)];
    Sound(Inds) = Sound(Inds) +  addSinRamp(A(i)*sin(2*pi*Fs(i)*(Time + Phases(i))),0.002,SR,'<=>');  
  end
end

Sound = IOAdjustVolume(Sound,Par.Amplitudes,'Method','RMS');