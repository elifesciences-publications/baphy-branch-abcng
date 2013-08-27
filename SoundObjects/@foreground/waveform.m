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
Names = get(o,'Names');
tag = str2num(Names{index(1)});
BurstcntPerTar = tag(3);
burstcnt = tag(1);
tarfreq = tag(2);
tardB0 = tag(4);
MskCmpNum=get(o,'MskCmpNum');   % Number of frequency components in each masker burst
% Amp = 5/(MskCmpNum+1)*(10^(tardB0/20));
Amp = 5/12*(10^(tardB0/20));
% Sound waveform generation -----------------------------------------------
% Generating Target waveform;
% stimleng = round(((ToneDur+GapDur)*burstcnt-GapDur)*SamplingRate);% delete last gap;
stimleng = round(((ToneDur+GapDur)*burstcnt)*SamplingRate);% keep last gap;
TarWav=Amp*tone(tarfreq,ToneDur,RmpDur,SamplingRate);
GapWav=zeros(1,round(GapDur*SamplingRate));
TarWavs = [TarWav, GapWav]; 
padding_zero = zeros(1,length(TarWavs)*(BurstcntPerTar-1));
TarWavs = [TarWavs,padding_zero];
TarWavs = repmat(TarWavs,1,ceil(burstcnt/BurstcntPerTar));
TarWavs = TarWavs(1,1:stimleng);

TotStmWav=[]; 
TotStmWav = TarWavs;
w = [zeros(PreStimSilence*SamplingRate,1); TotStmWav(:) ;zeros(PostStimSilence*SamplingRate,1)];
maxw = max(abs(w));
if maxw>10
    display('Warning: max(waveform) > 10, waveform got clipped!');
end

% logging stim events;
ev=[]; 
ev = AddEvent(ev,[''],[],0,PreStimSilence);
% isigap = (ToneDur+GapDur)*(BurstcntPerTar-1);
for StmN=1:burstcnt    
   ev = AddEvent(ev,['STIM , B ' num2str(tarfreq)  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar) ', tardB ' num2str(tardB0)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
%    if StmN<burstcnt %---delete last gap;
       ev = AddEvent(ev,['GAP , B ' num2str(tarfreq)  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar) ', tardB ' num2str(tardB0)],[],ev(end).StopTime,ev(end).StopTime+GapDur);
%    end
end
[a,b,c,d,e] = ParseStimEvent(ev(2),0); % dont remove spaces
ev(1).Note = ['PreStimSilence , ' b ', ' c ', ' d ', ' e];
[a,b,c] = ParseStimEvent(ev(end),0); 
ev = AddEvent(ev,['PostStimSilence , ' b ', ' c ', ' d ', ' e],[],ev(end).StopTime,ev(end).StopTime+PostStimSilence);

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
% f = [up ones(1,length(s1)-2*pn) down]';
% s=s1(:).*f(:);
