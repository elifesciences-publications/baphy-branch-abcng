function o = ObjUpdate (o);
% Update the changes of a MaskerA_StreamB object
% By Ling Ma, 10/2006
% added desynchrony maskers option by Ling Ma, 01/2007

tarfreq = get(o,'TarFreq');
TarNum=length(tarfreq);
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
StimListCnt = get(o,'StimListCnt');
MskCmpNum = get(o,'MskCmpNum');
BurstCnt = get(o,'BurstCnt');
seed = datenum(date);
o = set(o,'Seed',seed);

rand('seed',seed);
%method 2
for j = 1:prozonenum
    factor = ceil(MskCmpNum*sum(BurstCnt)*StimListCnt/NMskFs(j));
    sequence = [];
    for i = 1:factor
        sequence = [sequence, randperm(NMskFs(j))];
    end
    IdxSeq{j} = sequence;
end

SynorAsyn = get(o,'SynorAsyn');
SynorAsyn = deblank(SynorAsyn);
if strcmp(SynorAsyn, 'asynchrony')
%   Method 2 
    % Range of possible maskers time onsets
    SF = get(o,'SamplingRate');
    ToneDur = get(o,'ToneDur');
    GapDur = get(o,'GapDur'); % duration is second
    stimlen = (ToneDur+GapDur)*sum(BurstCnt)-GapDur;
    TotNumMsks = MskCmpNum*sum(BurstCnt);
    TimeRange = (1:SF*stimlen)/SF; % in sec
    MskTime = shuffle(repmat(TimeRange,1,ceil(TotNumMsks/length(TimeRange))));
    MskTime = MskTime(1:TotNumMsks); % in sec
    o = set(o,'MskTime',MskTime);
end

% for i=0:1%0:randomly varying multitones(A); 1:A+repeating tone(A+B);
%     for k = 1:prozonenum
%         for j = 1:StimListCnt
%             RandomFrequency = [ProtectZone(k) tarfreq(1) i];
%             Names{prozonenum*StimListCnt*i+StimListCnt*(k-1)+j} = num2str(RandomFrequency);
%         end
%     end
% end

    for k = 1:prozonenum
        for j = 1:StimListCnt
            RandomFrequency = [ProtectZone(k) tarfreq(1)];
            Names{StimListCnt*(k-1)+j} = num2str(RandomFrequency);
        end
    end

if ~exist('Names','var'); Names ={}; end
o = set(o,'Names',Names);
o = set(o,'MskFreqs',MskFs);
o = set(o,'IdxSeq',IdxSeq);
o = set(o,'MaxIndex',length(Names));

%%%%%%%%%%%%%%%%%%%%%%%%Helper Functions%%%%%%%%%%%%%%%%%%%%%%%%
function gaps = calculate_gapdur(BurstCnt,GapDur,time,ToneDur,stimlen)
timing = (0.5-rand(1,BurstCnt))*2*GapDur+time;
if timing(end)>stimlen-ToneDur % last position longer than target;
    timing(end) = stimlen-ToneDur;
end
if timing(1)<0 % negative starting point
    timing(1) = 0;
end
timing_end = timing+ToneDur;
timing(end+1) = stimlen;
gaps =[timing(1),timing(2:end)-timing_end];

%-----------------------------------------------
function oct = f2oct(freq, basefreq)
oct = log2(freq./basefreq);

%-----------------------------------------------
function freq = oct2f(oct,basefreq)
freq = basefreq*2.^(oct);

%-----------------------------------------------
function idx = repeatornot(vector)
for i = 1:length(vector)
    index = find(vector==vector(i));
    if length(index)>1
        idx = index(2);
        break;
    end
end

if ~exist('idx','var')
   idx = [];
end