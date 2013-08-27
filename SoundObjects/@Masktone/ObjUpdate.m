function o = ObjUpdate(o)
% By Ling Ma, 3/2008

firstfreq = get(o,'FstFreq');
FreqRangeInOct = get(o,'FreqRangeInOct');
Step = get(o,'StepInSemitone');
tardB = get(o,'tardB');
dBnum = length(tardB);

MskSemitones = FreqRangeInOct(1)*12:Step:FreqRangeInOct(2)*12;
MskFs = round(oct2f(MskSemitones/12,firstfreq));

MskCmpNum = get(o,'MskCmpNum');
BurstCnts = get(o,'BurstCnt');
trleng = length(BurstCnts);
seed = datenum(date);
o = set(o,'Seed',seed);
rand('seed',seed);

SF = get(o,'SamplingRate');
ToneDur = get(o,'ToneDur');
GapDur = get(o,'GapDur'); % duration is second
partlen = (ToneDur+GapDur);
TimeRange = (1:SF*partlen)/SF; % in sec
IdxSeq = [];
MskTime = [];
for i = 1 : max(BurstCnts)
    frePerm = randperm(length(MskFs));
    timePerm = randperm(length(TimeRange));
    IdxSeq = [IdxSeq,MskFs(frePerm(1:MskCmpNum))];
    MskTime = [MskTime,TimeRange(timePerm(1:MskCmpNum)) + partlen*(i - 1)];
end

o = set(o,'MskFs',MskFs);

% stimuli names
for i = 1 : dBnum
    for j = 1:trleng
        RandomFrequency = [BurstCnts(j) tardB(i)];
        Names{trleng*(i - 1) + j} = num2str(RandomFrequency);
    end
end

o = set(o,'Names',Names);
o = set(o,'IdxSeq',IdxSeq);
o = set(o,'MaxIndex',length(Names)); % globalparams

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%HelperFunctions%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------
function oct = f2oct(freq, basefreq)
oct = log2(freq./basefreq);

%-----------------------------------------------
function freq = oct2f(oct,basefreq)
freq = basefreq*2.^(oct);

