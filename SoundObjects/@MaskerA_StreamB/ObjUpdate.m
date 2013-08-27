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
% seeds = get(o,'Seed');
% if seeds==0
    seed = datenum(date);
    o = set(o,'Seed',seed);
% else
%     seed = seeds;
% end
rand('seed',seed);
%method 2
for j = 1:prozonenum
    factor = ceil(MskCmpNum*BurstCnt*StimListCnt/NMskFs(j));
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
    stimlen = (ToneDur+GapDur)*BurstCnt-GapDur;
    TotNumMsks = MskCmpNum*BurstCnt;
    TimeRange = (1:SF*stimlen)/SF; % in sec
    MskTime = shuffle(repmat(TimeRange,1,ceil(TotNumMsks/length(TimeRange))));
    MskTime = MskTime(1:TotNumMsks); % in sec
    o = set(o,'MskTime',MskTime);
%   Method 1  
%     ToneDur = get(o,'ToneDur');
%     GapDur = get(o,'GapDur'); % duration is second
%     stimlen = (ToneDur+GapDur)*BurstCnt-GapDur;
%     time = 0:(ToneDur+GapDur):stimlen;
%     MskGapDur = [];
%     for i = 1:MskCmpNum
%         idx0 = 0;  
%         jj = 1;
%         while ~isempty(idx0)
%             gaps = calculate_gapdur(BurstCnt,GapDur,time,ToneDur,stimlen);
%             idx0 = find(gaps<0);
%             jj = jj+1;
%         end
%         jj
%         MskGapDur = [MskGapDur,gaps];
%     end
%     o = set(o,'MskGapDur',MskGapDur);
end
% method-1
% seqence = randperm(MskCmpNum*BurstCnt*StimListCnt);
% index = mod(seqence, NMskFs)+1; 
% j = 1;
% for i = 1:StimListCnt*BurstCnt
%     cate = index((i-1)*MskCmpNum+1:i*MskCmpNum);
%     idx = repeatornot(cate);
%     if ~isempty(idx)
%         idx2 = (i-1)*MskCmpNum+idx;
%         diff = MskCmpNum-idx;
%         if idx2>StimListCnt*BurstCnt-MskCmpNum
%             if idx2~=StimListCnt*BurstCnt
%                 index = [index(1:idx2-1),index(j),index(idx2+1:end)];
%                 j = j+1;
%             else
%                 index = [index(1:idx2-1),index(j)];
%                 j = j+1;
%             end
%         else
%             index = [index(1:idx2-1),index(idx2+1:idx2+diff+2),...
%                 index(idx2),index(idx2+diff+3:end)];
%         end
%     end
% end


% type = get(o, 'Type');
% switch type
%     case 'reference'
         for k = 1:prozonenum
             for j = 1:StimListCnt
                 RandomFrequency = [ProtectZone(k) tarfreq(1) j];
                 Names{StimListCnt*(k-1)+j} = num2str(RandomFrequency);
             end
         end
%     case 'target'
%         for i=1:TarNum
%             for k = 1:prozonenum
%                 for j = 1:StimListCnt
%                     RandomFrequency = [ProtectZone(k) tarfreq(i)];
%                     Names{prozonenum*StimListCnt*(i-1)+StimListCnt*(k-1)+j} = num2str(RandomFrequency);
%                 end
%             end
%         end
% end
o = set(o,'Names',Names);
o = set(o,'MskFreqs',MskFs);
o = set(o,'IdxSeq',IdxSeq);
o = set(o,'MaxIndex',length(Names));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%HelperFunctions%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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