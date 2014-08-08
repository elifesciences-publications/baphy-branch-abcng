function Tones = SingleChord(F,LvlDiff,sF,Duration,RandomPhase)
% sF in Hz // LvlDiff<0 for lvl lower [-20 20]
if nargin<=3
    Duration = 0.025;        % s
end
ScalingSPL = .1;          % SPL/normalized units
RampDuration = 0.005;         % s
Tone = [];
if nargin<5 || isempty(RandomPhase)
    RandomPhase = rand(1,1)*360;
end

% Generate the tones
TimeSamples = repmat( linspace(0,Duration,round(Duration*sF)) ,length(F),1);
Tone = sin(2*pi*repmat(F',1,length(TimeSamples)).*TimeSamples+repmat(RandomPhase',1,length(TimeSamples)));
Tones = sum(Tone,1);

% Ramp at onset:
ramp = hanning(round(RampDuration * sF*2));
ramp = ramp(1:floor(length(ramp)/2))';
Tones(1:length(ramp)) = Tones(1:length(ramp)) .* ramp;
Tones(end-length(ramp)+1:end) = Tones(end-length(ramp)+1:end) .* fliplr(ramp);
% Tone = ScalingSPL*Tone/max(abs(Tone)) / 2;
% Tone = Tone / (10^(-LvlDiff/20));


