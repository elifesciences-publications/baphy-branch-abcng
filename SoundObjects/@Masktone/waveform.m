function [w, ev]=waveform (o,index_m,isref)

if nargin == 2
  isref = 1;
end
% By Ling Ma, 3/2008
if nargin == 2
    isref = 1;
end
index = index_m(1);
% User-defined parameters --------------------------------------------------------------------------------------------------------------
RmpDur=0.01; % Duration of each tone ramp (s) (rising+falling)

% stimulus parameters -------------------------------------------------------------------------
SamplingRate = get(o,'SamplingRate');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
ToneDur = get(o,'ToneDur');
GapDur = get(o,'GapDur'); % duration is second

Names = get(o,'Names');
tag = str2num(Names{index(1)});
BurstcntPerTar = get(o,'BurstcntPerTar');
burstcnts = get(o,'burstcnt');
trlen = length(burstcnts);
% RelMskL=get(o,'dBAtten_M2T'); % Level of masker components relative to the signal (dB)
% (e.g. 10 means that each masker component will be 10 dB below the signal level)
% type = deblank(get(o,'Type'));
DynamicorStatic = get(o,'DynamicorStatic');
MskCmpNum=get(o,'MskCmpNum');   % Number of frequency components in each masker burst
tardB0 = tag(2);
tarfreq = get(o,'FstFreq');
Amp = 5/12*(10^(tardB0/20));
%Amp = 5/12;%(MskCmpNum+1);
firstfreq = get(o,'FstFreq');
FreqRangeInOct = get(o,'FreqRangeInOct');
Step = get(o,'StepInSemitone');

MskSemitones = FreqRangeInOct(1)*12:Step:FreqRangeInOct(2)*12;
currentfreNum = length(MskSemitones);
modifiedCount = ceil(currentfreNum / MskCmpNum);
modifiedNum = modifiedCount * MskCmpNum;
MskSemitones = [MskSemitones,(MskSemitones(end)+Step):Step:(MskSemitones(end)+Step*(modifiedNum-currentfreNum))];

MskFs = round(oct2f(MskSemitones/12,firstfreq));


% IdxSeq = get(o,'IdxSeq');
% MskFs = get(o,'MskFs');
SF = get(o,'SamplingRate');
partlen = (ToneDur+GapDur);
TimeRange = (1:SF*partlen/MskCmpNum)/SF; % in sec
IdxSeq = [];
MskTime = [];

if DynamicorStatic == 0
    currentseed = round(datenum(date))+ index_m(2);
else
    currentseed = round(sum(100*clock));
end
rand('seed',currentseed);

repeatNum = ceil(burstcnts / modifiedCount);
frePerm = zeros(MskCmpNum, repeatNum*modifiedCount);
for i = 1: MskCmpNum
    frePermvec = [];
for j = 1 : repeatNum
    frePermvec = [frePermvec, randperm(modifiedCount)];
end
frePerm(i,:) =  frePermvec;
end

for i = 1 : burstcnts
    frePermvec = randperm(MskCmpNum);
    for j = 1 : MskCmpNum
        IdxSeq((i-1)*MskCmpNum + j) = MskFs((frePermvec(j)-1)*modifiedCount+frePerm(frePermvec(j),i));
    end
end
    


for i = 1 : max(burstcnts)
    for j = 1 : MskCmpNum    
        timePerm = randperm(length(TimeRange));
        MskTime = [MskTime,TimeRange(timePerm(1)) + partlen*(i - 1) + partlen/MskCmpNum*(j - 1)];
    end
end

id = mod(index(1),trlen);
if id==0
    id = trlen;
end

if length(index)>1
    dBAttr2t = index(2);
else
    dBAttr2t = 0;
end

% Sound waveform generation -----------------------------------------------
burstcnt = tag(1);
% stimleng = round(((ToneDur+GapDur)*burstcnt-GapDur)*SamplingRate);% delete last gap;
stimleng = round((ToneDur+GapDur)*burstcnt*SamplingRate);% keep last gap;
TotStmWav=[]; ev=[]; w = [];
ev = AddEvent(ev,[''],[],0,PreStimSilence);
MskWavs = zeros(1,stimleng+round(SamplingRate*ToneDur));
GapWav=zeros(1,round(GapDur*SamplingRate));

for StmN = 1:burstcnt
%     if DynamicorStatic == 1 % 1:dynamic
        MskWav = Amp*(tone(IdxSeq((StmN-1)*MskCmpNum+(1:MskCmpNum)),ToneDur,RmpDur,SamplingRate));
        for MskN = 1:MskCmpNum
            % get time onset
            ToneOnset = round(SamplingRate*MskTime(MskCmpNum*(StmN-1)+MskN)); % sample number
            % Add to overall background sequence
            MskWavs(ToneOnset:ToneOnset+length(MskWav)-1) = MskWavs(ToneOnset:ToneOnset+length(MskWav)-1)+MskWav(MskN,:);
        end
%     else %frozen
%         for MskN = 1:MskCmpNum
%             % get time onset
%             ToneOnset = round(SamplingRate*MskTime(MskCmpNum*(StmN-1)+MskN)); % sample number
%             % Add to overall background sequence
%             MskWavs(ToneOnset:ToneOnset+length(MskWav)-1) = MskWavs(ToneOnset:ToneOnset+length(MskWav)-1)+MskWav(MskN,:);
%         end
%     end
end
% end

% type = deblank(get(o,'Type'));
% if strcmp(type,'reftar')
stimleng = round(((ToneDur+GapDur)*burstcnt + ToneDur)*SamplingRate);% keep last gap;
TotStmWav = MskWavs(1:stimleng);
% TarWav=Amp*tone(tarfreq,ToneDur,RmpDur,SamplingRate);% TarWav=tone(tarfreq,ToneDur,RmpDur,SamplingRate);
% %     GapWav=zeros(1,round(GapDur*SamplingRate));
% TarWavs = [TarWav, GapWav];
% padding_zero = zeros(1,length(TarWavs)*(BurstcntPerTar-1));
% TarWavs = [TarWavs,padding_zero];
% %     TarWavs = repmat(TarWavs,1,ceil(burstcnt/BurstcntPerTar/2));
% %     TarWavs = [zeros(1,stimleng-length(TarWavs)),TarWavs];
% TarWavs = repmat(TarWavs,1,ceil(burstcnt/BurstcntPerTar));
% TarWavs = TarWavs(1,1:stimleng);
% TotStmWav = MskWavs+TarWavs;
% logging stim events;
for StmN=1:burstcnt
    ev = AddEvent(ev,['STIM , ' num2str(currentseed) ', r2t ' num2str(dBAttr2t)],...
        [],ev(end).StopTime,ev(end).StopTime+ToneDur);
    ev = AddEvent(ev,['GAP , ' num2str(currentseed) ', r2t ' num2str(dBAttr2t)],...
        [],ev(end).StopTime,ev(end).StopTime+GapDur);
end
% else
%     MskWavs = MskWavs(1:stimleng);
%     TotStmWav = MskWavs;
%         % logging stim events;
%     for StmN=1:burstcnt
%         ev = AddEvent(ev,['STIM , B ' num2str(tarfreq) ', ProtectZone ' num2str(protectzone) ', A ' num2str(burstcnt) ', D/S ' num2str(DynamicorStatic) ', r2t ' num2str(dBAttr2t) ', synorasyn ' SynorAsyn],...
%         [],ev(end).StopTime,ev(end).StopTime+ToneDur);
% %        if StmN<burstcnt %---delete last gap;
%            ev = AddEvent(ev,['GAP , B ' num2str(tarfreq) ', ProtectZone ' num2str(protectzone)  ', A ' num2str(burstcnt) ', D/S ' num2str(DynamicorStatic) ', r2t ' num2str(dBAttr2t) ', synorasyn ' SynorAsyn],...
%                [],ev(end).StopTime,ev(end).StopTime+GapDur);
% %        end
%     end
% end

TotStmWav = rmpcos2(TotStmWav,RmpDur,SamplingRate);

w = [zeros(PreStimSilence*SamplingRate,1); TotStmWav(:) ;zeros(PostStimSilence*SamplingRate,1)];

% % % test reconstruction
% % savefile = ['D:\maktest\makT', num2str(index),'.mat'];
% % save(savefile, 'w');


maxw = max(abs(w));
if maxw>10
    display('Warning: max(waveform) > 10, waveform got clipped!');
end
[a,b,c] = ParseStimEvent(ev(2),0); % dont remove spaces
ev(1).Note = ['PreStimSilence , ' b ', ' c];
[a,b,c] = ParseStimEvent(ev(end),0);
ev = AddEvent(ev,['PostStimSilence , ' b ', ' c],[],ev(end).StopTime,ev(end).StopTime+PostStimSilence);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%HelperFunctions%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%tone%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function s=tone(frq,dur,rmpdur,SamplingRate)
% s=rmpcos2(sin(2*pi*frq/SamplingRate*[1:round(dur*SamplingRate)]),rmpdur,SamplingRate);
function s = tone(frq,dur,rmpdur,SF)

% s = tone(frq,dur,rmpdur,SF)
%
% frq: vector of frequency values (in Hz)
% dur: value of tone duration (in sec)
% rmpdur: value of ramp
% SF: sampling frequency

if eq(size(frq,1),1)
    frq = frq';
end

timevec = repmat([1:round(dur*SF)],length(frq),1);
s = rmpcos2(sin(2*pi*repmat(frq,1,size(timevec,2)).*timevec/SF),rmpdur,SF);


%%%%%%%%%%%%%%%%%%%%%%%%%rmpcos2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rampedsig = rmpcos2(sig,rmpdur,SF)

% rampedsig = rmpcos2(sig,rmpdur,SF)
%
% sig: a matrix of (N x dur); N is number of signals
% rmpdur: duration of cosine ramp (in sec)
% SF: Sampling Frequency (in Hz)

[numsig,signpts] = size(sig);

rmpnpts = round(rmpdur*SF);
rmp = (1-(cos([1:rmpnpts]*pi/rmpnpts)+1)/2).^2;
rmp = repmat(rmp,numsig,1);
rampedsig = sig;
rampedsig(:,1:rmpnpts) = rampedsig(:,1:rmpnpts).*rmp;
rampedsig(:,signpts-rmpnpts+1:signpts) = rampedsig(:,signpts-rmpnpts+1:signpts).*fliplr(rmp);


% function rampedsig=rmpcos2(sig,rmpdur,SamplingRate)
%
% rmpnpts=round(rmpdur*SamplingRate);
% signpts=length(sig);
% rmp=(1-(cos([1:rmpnpts]*pi/rmpnpts)+1)/2).^2;
% rampedsig=sig;
% rampedsig(1:rmpnpts)=rampedsig(1:rmpnpts).*rmp;
% rampedsig(signpts-rmpnpts+1:signpts)=rampedsig(signpts-rmpnpts+1:signpts).*fliplr(rmp);

%add 5 ms rise/fall time ===================================
% function s=addenv(s1,fs);
% f=ones(size(s1));
% pn=round(fs*0.005);    % 5 ms rise/fall time
% up = sin(2*pi*(0:pn-1)/(4*pn)).^2;   %add sinramp
% down = sin(2*pi*(pn+1:2*pn)/(4*pn)).^2;
% f = [up ones(1,length(s1)-2*pn) down]';0787   `
% s=s1(:).*f(:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%HelperFunctions%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------
function oct = f2oct(freq, basefreq)
oct = log2(freq./basefreq);

%-----------------------------------------------
function freq = oct2f(oct,basefreq)
freq = basefreq*2.^(oct);