function Tone = SingleTone(F,LvlDiff,sF,Duration)
% sF in Hz // LvlDiff<0 for lvl lower [-20 20]
if nargin<=3
    Duration = 0.025;        % s
end
ScalingSPL = .1;          % SPL/normalized units
RampDuration = 0.005;         % s
Tone = [];
RandomPhase = rand(1,1)*360;

% Generate the tone
TimeSamples = linspace(0,Duration,round(Duration*sF));
Tone = zeros(size(TimeSamples));
Tone = Tone + sin(2*pi*F*TimeSamples+RandomPhase);
% Ramp at onset:
ramp = hanning(round(RampDuration * sF*2));
ramp = ramp(1:floor(length(ramp)/2))';
Tone(1:length(ramp)) = Tone(1:length(ramp)) .* ramp;
Tone(end-length(ramp)+1:end) = Tone(end-length(ramp)+1:end) .* fliplr(ramp);
Tone = ScalingSPL*Tone/max(abs(Tone)) / 2;
Tone = Tone / (10^(-LvlDiff/20));

