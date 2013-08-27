function o = ObjUpdate (o);
% By Ling Ma, 3/2008

tarfreq = get(o,'TarFreq');
% get possible masker freqencies
ProtectZone=get(o,'ProtectZoneInSemitone'); % Width of protected region around signal frequency in # of semitone
% (e.g. 2 means that there will be two empty semitone below and above the
% signal)
FreqRangeInOct = get(o,'FreqRangeInOct');
Step = get(o,'StepInSemitone');
prozonenum = length(ProtectZone);
NMskFs = [];
for i = 1:prozonenum
    MskSemitones{i}=[ceil(FreqRangeInOct(1)*12):Step:-ProtectZone(i), ProtectZone(i):Step:floor(FreqRangeInOct(2)*12)];
    MskFs{i}=round(oct2f(MskSemitones{i}/12,tarfreq));
    NMskFs=[NMskFs, length(MskFs{i})];
end
MskCmpNum = get(o,'MskCmpNum');
BurstCnts = get(o,'BurstCnt');

seed = datenum(date);
o = set(o,'Seed',seed);
rand('seed',seed);

% for j = 1:prozonenum
%     factor = ceil(MskCmpNum*max(BurstCnts)/NMskFs(j));
%     sequence = [];
%     for i = 1:factor
%         sequence = [sequence, randperm(NMskFs(j))];
%     end
%     IdxSeq{j} = sequence;
% end

% Range of possible maskers time onsets
SF = get(o,'SamplingRate');
ToneDur = get(o,'ToneDur');
GapDur = get(o,'GapDur'); % duration is second
stimlen = (ToneDur+GapDur)*BurstCnts-GapDur;
TotNumMsks = MskCmpNum*BurstCnts;
trleng = length(BurstCnts);
MskTime = {};

partlen = (ToneDur+GapDur);
TimeRange = (1:SF*partlen)/SF; % in sec

MskTimeWhole = [];
for i = 1 : max(BurstCnts)   
    timePerm = randperm(length(TimeRange));   
    MskTimeWhole = [MskTimeWhole,TimeRange(timePerm(1:MskCmpNum)) + partlen*(i - 1)];
end

for j = 1:prozonenum
    IdxSeqWhole = [];    
    for i = 1 : max(BurstCnts)     
        frePerm = randperm(length(MskFs{j}));
        IdxSeqWhole = [IdxSeqWhole,frePerm(1:MskCmpNum)];
    end
    IdxSeq{j} = IdxSeqWhole;
end

for i = 1:length(stimlen)
    MskTime = [MskTime; MskTimeWhole(1:TotNumMsks(i))]; % in sec
end
o = set(o,'MskTime',MskTime);

% stimuli names
for k = 1:prozonenum
    for j = 1:trleng
        RandomFrequency = [ProtectZone(k) BurstCnts(j) tarfreq];
        Names{trleng*(k-1)+j} = num2str(RandomFrequency);
    end
end

o = set(o,'Names',Names);
o = set(o,'MskFreqs',MskFs);
o = set(o,'IdxSeq',IdxSeq);
o = set(o,'MaxIndex',length(Names));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%HelperFunctions%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------
function oct = f2oct(freq, basefreq)
oct = log2(freq./basefreq);

%-----------------------------------------------
function freq = oct2f(oct,basefreq)
freq = basefreq*2.^(oct);

