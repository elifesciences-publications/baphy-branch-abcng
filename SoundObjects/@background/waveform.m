function [w, ev]=waveform (o,index);
% By Ling Ma, 3/2008

% User-defined parameters --------------------------------------------------------------------------------------------------------------
RmpDur=0.01; % Duration of each tone ramp (s) (rising+falling)

% stimulus parameters -------------------------------------------------------------------------
SamplingRate = get(o,'SamplingRate');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
ToneDur = get(o,'ToneDur');
GapDur = get(o,'GapDur'); % duration is second
SynorAsyn = get(o,'SynorAsyn');
SynorAsyn = deblank(SynorAsyn);
Names = get(o,'Names');
tag = str2num(Names{index(1)});
BurstcntPerTar = get(o,'BurstcntPerTar');
burstcnts = get(o,'burstcnt');
trlen = length(burstcnts);
tarfreq = tag(3);
% RelMskL=get(o,'dBAtten_M2T'); % Level of masker components relative to the signal (dB)
% (e.g. 10 means that each masker component will be 10 dB below the signal level)
% type = deblank(get(o,'Type'));
DynamicorStatic = get(o,'DynamicorStatic');
MskCmpNum=get(o,'MskCmpNum');   % Number of frequency components in each masker burst
Amp = 5/12;%(MskCmpNum+1);
% Amp=3/sqrt(MskCmpNum+1);
ProtectZoneInSemitone = get(o,'ProtectZoneInSemitone');
protectzone = tag(1);
whichprotectzone = find(ProtectZoneInSemitone==protectzone);
MskFreqs = get(o,'MskFreqs'); MskFs = MskFreqs{whichprotectzone};
IdxSequence = get(o,'IdxSeq'); IdxSeq = IdxSequence{whichprotectzone};
% MskGapDur = get(o,'MskGapDur');
MskTimes = get(o,'MskTime');
id = mod(index(1),trlen);
if id==0
    id = trlen;
end
MskTime = MskTimes{id};
if length(index)>1
    dBAttr2t = index(2);
else
    dBAttr2t = 0;
end

% Sound waveform generation -----------------------------------------------
burstcnt = tag(2);
% stimleng = round(((ToneDur+GapDur)*burstcnt-GapDur)*SamplingRate);% delete last gap;
stimleng = round((ToneDur+GapDur)*burstcnt*SamplingRate);% keep last gap;
TotStmWav=[]; ev=[]; w = [];
ev = AddEvent(ev,[''],[],0,PreStimSilence);
MskWavs = zeros(1,stimleng+round(SamplingRate*ToneDur));  
GapWav=zeros(1,round(GapDur*SamplingRate));

switch SynorAsyn
    case 'synchrony'
          MskWavs = [];
          for StmN=1:burstcnt    
            if DynamicorStatic|StmN == 1 % 1:dynamic
                MskWav=zeros(1,round(ToneDur*SamplingRate));
                for MskN=1:MskCmpNum
                    MskWav=MskWav+Amp*tone(MskFs(IdxSeq((StmN-1)*MskCmpNum+MskN)),ToneDur,RmpDur,SamplingRate);
                end
            end
            MskWavs=[MskWavs MskWav GapWav]; 
          end
     case 'asynchrony' 
        for StmN = 1:burstcnt
            if DynamicorStatic|StmN == 1 % 1:dynamic
               MskWav = Amp*(tone(MskFs(IdxSeq((StmN-1)*MskCmpNum+(1:MskCmpNum))),ToneDur,RmpDur,SamplingRate));
               for MskN = 1:MskCmpNum
                    % get time onset
                    ToneOnset = round(SamplingRate*MskTime(MskCmpNum*(StmN-1)+MskN)); % sample number
                    % Add to overall background sequence
                    MskWavs(ToneOnset:ToneOnset+length(MskWav)-1) = MskWavs(ToneOnset:ToneOnset+length(MskWav)-1)+MskWav(MskN,:);
               end
             else %frozen
                for MskN = 1:MskCmpNum
                    % get time onset
                    ToneOnset = round(SamplingRate*MskTime(MskCmpNum*(StmN-1)+MskN)); % sample number
                    % Add to overall background sequence
                    MskWavs(ToneOnset:ToneOnset+length(MskWav)-1) = MskWavs(ToneOnset:ToneOnset+length(MskWav)-1)+MskWav(MskN,:);
                 end
              end
        end
end

type = deblank(get(o,'Type'));
if strcmp(type,'reftar')
    stimleng = round((ToneDur+GapDur)*burstcnt*SamplingRate);% keep last gap;
    MskWavs = MskWavs(1:stimleng);
    TarWav=Amp*tone(tarfreq,ToneDur,RmpDur,SamplingRate);% TarWav=tone(tarfreq,ToneDur,RmpDur,SamplingRate);
%     GapWav=zeros(1,round(GapDur*SamplingRate));
    TarWavs = [TarWav, GapWav]; 
    padding_zero = zeros(1,length(TarWavs)*(BurstcntPerTar-1));
    TarWavs = [TarWavs,padding_zero];
%     TarWavs = repmat(TarWavs,1,ceil(burstcnt/BurstcntPerTar/2));
%     TarWavs = [zeros(1,stimleng-length(TarWavs)),TarWavs];
    TarWavs = repmat(TarWavs,1,ceil(burstcnt/BurstcntPerTar));
    TarWavs = TarWavs(1,1:stimleng);
    TotStmWav = MskWavs+TarWavs;
    % logging stim events;
    for StmN=1:burstcnt    
        ev = AddEvent(ev,['STIM , B ' num2str(tarfreq) ', ProtectZone ' num2str(protectzone) ', A ' num2str(burstcnt) ', D/S ' num2str(DynamicorStatic) ', r2t ' num2str(dBAttr2t) ', synorasyn ' SynorAsyn],...
            [],ev(end).StopTime,ev(end).StopTime+ToneDur);
        ev = AddEvent(ev,['GAP , B ' num2str(tarfreq) ', ProtectZone ' num2str(protectzone)  ', A ' num2str(burstcnt) ', D/S ' num2str(DynamicorStatic) ', r2t ' num2str(dBAttr2t) ', synorasyn ' SynorAsyn],...
            [],ev(end).StopTime,ev(end).StopTime+GapDur);
    end
else
    MskWavs = MskWavs(1:stimleng);
    TotStmWav = MskWavs;
        % logging stim events;
    for StmN=1:burstcnt    
        ev = AddEvent(ev,['STIM , B ' num2str(tarfreq) ', ProtectZone ' num2str(protectzone) ', A ' num2str(burstcnt) ', D/S ' num2str(DynamicorStatic) ', r2t ' num2str(dBAttr2t) ', synorasyn ' SynorAsyn],...
        [],ev(end).StopTime,ev(end).StopTime+ToneDur);
%        if StmN<burstcnt %---delete last gap;
           ev = AddEvent(ev,['GAP , B ' num2str(tarfreq) ', ProtectZone ' num2str(protectzone)  ', A ' num2str(burstcnt) ', D/S ' num2str(DynamicorStatic) ', r2t ' num2str(dBAttr2t) ', synorasyn ' SynorAsyn],...
               [],ev(end).StopTime,ev(end).StopTime+GapDur);
%        end
    end
end
bindfreq = get(o,'BindingFreq');
bindsynalt = deblank(get(o,'Binding'));
% %---if randomize binding frequency;
% bind_list = -4:4;
% bindfreq_all=round(oct2f(bind_list/12,bindfreq));
% list = [randperm(length(bind_list)),randperm(length(bind_list)),randperm(length(bind_list)),randperm(length(bind_list))];
% list = repmat(list,1,3);
% BindWav=Amp*tone(bindfreq_all,ToneDur,RmpDur,SamplingRate);
% GapWav=zeros(1,round(GapDur*SamplingRate));
% BindWavs = [];
% for ii = 1:ceil(burstcnt/BurstcntPerTar)
%     tmp_wav = [BindWav(list(ii),:), GapWav]; 
%     padding_zero = zeros(1,length(tmp_wav)*(BurstcntPerTar-1));
%     if strcmp(bindsynalt,'syn')
%         BindWavs = [BindWavs,tmp_wav,padding_zero];
%     elseif strcmp(bindsynalt,'alt')
%         BindWavs = [BindWavs,padding_zero,tmp_wav];
%     end
% end
% BindWavs = BindWavs(1,1:stimleng);
% TotStmWav = TotStmWav+BindWavs;

%----one single binding tone;
BindWav=Amp*tone(bindfreq,ToneDur,RmpDur,SamplingRate);
GapWav=zeros(1,round(GapDur*SamplingRate));
BindWavs = [BindWav, GapWav]; 
padding_zero = zeros(1,length(BindWavs)*(BurstcntPerTar-1));
if strcmp(bindsynalt,'syn')
    BindWavs = [BindWavs,padding_zero];
elseif strcmp(bindsynalt,'alt')
    BindWavs = [padding_zero,BindWavs];
end
BindWavs = repmat(BindWavs,1,ceil(burstcnt/BurstcntPerTar));
BindWavs = BindWavs(1,1:stimleng);
TotStmWav = TotStmWav+BindWavs;

TotStmWav = rmpcos2(TotStmWav,RmpDur,SamplingRate);

w = [zeros(PreStimSilence*SamplingRate,1); TotStmWav(:) ;zeros(PostStimSilence*SamplingRate,1)];
maxw = max(abs(w));
if maxw>10
    display('Warning: max(waveform) > 10, waveform got clipped!');
end
[a,b,c,d,e,f,g] = ParseStimEvent(ev(2),0); % dont remove spaces
ev(1).Note = ['PreStimSilence , ' b ', ' c ', ' d ', ' e ', ' f ', ' g];
[a,b,c,d,e,f,g] = ParseStimEvent(ev(end),0); 
ev = AddEvent(ev,['PostStimSilence , ' b ', ' c ', ' d ', ' e ', ' f ', ' g],[],ev(end).StopTime,ev(end).StopTime+PostStimSilence);

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
%-----------------------------------------------
function freq = oct2f(oct,basefreq)
freq = basefreq*2.^(oct);

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
% f = [up ones(1,length(s1)-2*pn) down]';
% s=s1(:).*f(:);