function [Stimulus,ToneMatrix] = AssemblyTones(FrequencySpace,Distribution,X,Duration,sF,PlotMe,LineName,Rgenerator,Par)
if nargin <=6 || not(PlotMe); LineName = []; end
if nargin <8 || isempty(Rgenerator); Rgenerator = RandStream('mt19937ar'); end
reset(Rgenerator)
% Duration in s / F1 in Hz / [x,Distribution from <DrawDistribution>
Stimulus = zeros(1,ceil(Duration*sF));
ChordDuration = Par.ToneDuration; % s    %Rabinowitsch or also Maria Cheit
TonesPerOctave = Par.TonesPerOctave; % s    %Rabinowitsch or also Maria Cheit
% Parameters
ChordTimeSamples = linspace(0,ChordDuration,round(ChordDuration*sF));
ChordNb = Duration/ChordDuration;    % should be integer for D0 because ToC is rounded in <waveform.m>
AverageNbTonesChord = round(TonesPerOctave*log(FrequencySpace(end)/FrequencySpace(1))/log(2));    % Average of 2 tones per octave (cf. Ahrens 2008)
XPoisson = 0:(AverageNbTonesChord*2);                                                % Decrease to *2 because of saturation suspicion (cracks in the headphones)
CumDistriPoisson = poisscdf(XPoisson,AverageNbTonesChord);
if nargout>1; ToneMatrix=zeros(length(FrequencySpace),floor(ChordNb));  end;         % ChordNb could be not integer only for DbisDuration

N = round(3*AverageNbTonesChord*ChordNb);   % More than needed
CumDistri = cumsum(Distribution(X));
CumDistri = CumDistri/max(CumDistri);

% Added for accounting to the following: the increment brings down the other bins to 0
X = X(max(1,find(CumDistri>0,1,'first')-1):end);
CumDistri = CumDistri(max(1,find(CumDistri>0,1,'first')-1):end);
% Remove doublons in the CumDistri to allow interpolation
% and avoid boundary effects
[FirstCumDistri,FirstUniIndex] = unique(CumDistri,'first');
[LastCumDistri,LastUniIndex] = unique(CumDistri,'last');
MidIndex = round(length(LastUniIndex)/2);
UniIndex(1:MidIndex) = max([FirstUniIndex(1:MidIndex) ; LastUniIndex(1:MidIndex)]);
UniIndex(MidIndex+1:length(LastUniIndex)) = min([FirstUniIndex(MidIndex+1:length(LastUniIndex)) ; LastUniIndex(MidIndex+1:length(LastUniIndex))]);
UniX = X(UniIndex);
CumDistri = CumDistri(UniIndex);
CumDistri(1) = 0;
ToneFrequencies = interp1(CumDistri,UniX,Rgenerator.rand(1,N));
TonePhases = Rgenerator.randi(360,[1 N])-1;   % Phase belongs to [0 359]
% Tones are replaced in binned frequency axis (<FrequencySpace> binnned by <Par.ToneInterval>)
[mimi,MinInd] = min( abs( repmat(FrequencySpace',1,size(ToneFrequencies,2))-repmat(ToneFrequencies,size(FrequencySpace,2),1) ) ,[], 1 );
ToneFrequencies = FrequencySpace(MinInd');

if PlotMe
    na = hist(ToneFrequencies,FrequencySpace); 
    plot( log2(FrequencySpace),Distribution(FrequencySpace),'k-','DisplayName',['Theoretic distribution ' LineName]); 
    plot( log2(FrequencySpace),na/trapz(log2(FrequencySpace),na),'x-','DisplayName',['D samples' LineName]);
    xlim(log2(FrequencySpace([1 end])));
    xlabel('Freq. (oct.)')
end
Lvl = 0; PreviousRandomChordNum = 0;
for ChordNum = 1:ChordNb
    [CumDistriPoisson,UniIndex] = unique(CumDistriPoisson);
    UniXPoisson = XPoisson(UniIndex);
    CumDistriPoisson(1) = 0; CumDistriPoisson(end) = 1;
    if ~isfield(Par,'SingleTone') || ~Par.SingleTone
        NbTonesChord = round(interp1(CumDistriPoisson,UniXPoisson,Rgenerator.rand(1,1)));
    else % only 1 tone at a time [for instance key-change tone sequence]
        NbTonesChord = 1;
    end
    
    Chord = zeros(size(ChordTimeSamples));
    TrialTonesF = ToneFrequencies((PreviousRandomChordNum+1):(PreviousRandomChordNum+NbTonesChord));
    % When keeping tones in incremented channels for monitoring loudness (see section below)
%     TrialTonesF(TrialTonesF>=602.8)=[]; NbTonesChord = length(TrialTonesF);
%     TrialTonesF(TrialTonesF<1277)=[]; NbTonesChord = length(TrialTonesF);
    % 15/03/25-YB: constant phases for overlapping tones
    TrialTonesPhase = TonePhases((PreviousRandomChordNum+1):(PreviousRandomChordNum+NbTonesChord));
    [Ctemp,ia,ic] = unique( TrialTonesF );
    TrialTonesPhase = TrialTonesPhase(ic);
    PreviousRandomChordNum = PreviousRandomChordNum+NbTonesChord;
    if ~isempty(TrialTonesF)
      Chord = SingleChord(TrialTonesF,Lvl,sF,ChordDuration,TrialTonesPhase);
    end
    Stimulus((ChordNum-1)*length(ChordTimeSamples)+1 : ChordNum*length(ChordTimeSamples)) = Chord;
    
    if nargout>1         % Matrix of tones for simulations  
        IndToneFreq = [];
        for ToneNum = 1:NbTonesChord
            IndToneFreq = find(TrialTonesF(ToneNum)==FrequencySpace);
            ToneMatrix(IndToneFreq,ChordNum) = ToneMatrix(IndToneFreq,ChordNum)+1;     % Could be several tones in the same frequency bin
        end
    end
end

%% COMPUTE LOUDNESS IN EACH OF THE 3 OR CHANGE CHANNELS ~8dB for humans, +80% || ~10dB +110%
% TMG_TaskStimFIG; % 1st section
if 0
o = set(o,'DifficultyLvl_D1','110'); o = ObjUpdate(o);
RepNb = 500;
for iR = 1:RepNb
    [ w , ev , O , D0 , ChangeD , Parameters] = waveform(o,4,[],[],iR*3);
    ChangeIdx = round(get(o,'SamplingRate')*Parameters.ToC);
    w1 = w(1:ChangeIdx); w2 = w(ChangeIdx + (1:round(get(o,'SamplingRate')*str2num(get(o,'StimulusBisDuration')))));
    LvlIncrease(iR) = 20*log10(sqrt(mean(w2.^2))/sqrt(mean(w1.^2)));
end
end


