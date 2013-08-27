function [w, ev, o]=waveform (o,index)
% By Ling Ma, 3/2008
% User-defined parameters --------------------------------------------------------------------------------------------------------------
RmpDur=0.01; % Duration of each tone ramp (s) (rising+falling)
index = index(1);
% stimulus parameters -------------------------------------------------------------------------
SamplingRate = get(o,'SamplingRate');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
Freqcnt = get(o,'Freqcnt');
TrainPhase = get(o,'TrainPhase');
flagSym = get(o,'flagSym');
ShiftLastTone = get(o,'ShiftLastTone');
ToneDur = get(o,'ToneDur');
GapDur = get(o,'GapDur'); % duration is second

Names = get(o,'Names');
tag = str2num(Names{index(1)});
% in TrainPhase 4, ShiftTime is a variable
if TrainPhase < 4
  ShiftTime = get(o,'ShiftTime');
end
% in TrainPhase 1 2 4, frequency gap is fixed
% in TrainPhase 3, frequency gap is a variable
if TrainPhase == 1 || TrainPhase == 2
  firstFreq = tag(3);
  sndRelative = get(o,'SndRelative');
elseif TrainPhase == 3
  firstFreq = get(o,'FstFreq');
  sndRelative = tag(3);
elseif TrainPhase == 4
  firstFreq = get(o,'FstFreq');
  sndRelative = get(o,'SndRelative');
  ShiftTime = tag(3);
  flagSym = ~ceil(ShiftTime);
elseif TrainPhase == 5 || TrainPhase == 6 || TrainPhase == 7
  firstFreq = get(o,'FstFreq');
  sndRelative = get(o,'SndRelative');
  if length(sndRelative) == 1 || sndRelative(2) == 0  %varying spacing
    sndRelative = tag(2);
  else                                                %fixed spacing
    firstFreq = round(firstFreq*2^tag(2));
  end
  ShiftTime = tag(3);
  flagSym = ~ceil(ShiftTime);
end
% in TrainPhase 2, sndRelative could be 2 dimensional
% 1st is frequency gap, 2nd is the shift of firstFreq
secondFreq =round(firstFreq*2^sndRelative(1));
% fristFreq is low frequency
tarfreq = [firstFreq, secondFreq];

if Freqcnt == 3
  tdRelative = get(o,'TdRelative');
  thirdFreq = oct2f(tdRelative,firstFreq);
  tarfreq = [tarfreq, thirdFreq];
end

BurstcntPerTar = tag(2);
burstcnt = tag(1);

Amp = 5/12;
% make tones of sine wave for certain frequencies
TarWav = Amp*tone(tarfreq,ToneDur,RmpDur,SamplingRate);
% append silent gap after tone
TarWav = [TarWav,zeros(length(tarfreq),GapDur*SamplingRate)];


% add for trainphase 6 (Jun, 2012) and trainphase 7(Jun, 2012)
BurstCnts = get(o,'BurstCnt');
minCnt = min(BurstCnts);
% has not fixed for more than two tones

if flagSym == 1
  stimleng = ceil(((ToneDur+GapDur)*burstcnt + ShiftLastTone)*SamplingRate);
  stimwav = zeros(1, stimleng);
  if Freqcnt == 2
    tmpwav = repmat(TarWav,1,burstcnt);
    if TrainPhase == 6 && burstcnt ~= minCnt
      tmpwav(2,1:size(TarWav,2)*minCnt) = 0;
    elseif TrainPhase == 7 && burstcnt ~= minCnt
      tmpwav(1,1:size(TarWav,2)*minCnt) = 0;
    end
    tarwav = sum(tmpwav);
    stimwav(1:length(tarwav)) = tarwav;
  else
    tmpwav = repmat(TarWav,1,burstcnt - 1);
    if TrainPhase == 6 && burstcnt ~= minCnt
      tmpwav([1,3],1:size(TarWav,2)*minCnt) = 0;
    end
    tarwav = sum(tmpwav);
    stimwav(1:length(tarwav)) = tarwav;
    stimwav(length(tarwav)+1:length(tarwav)+ size(TarWav,2)) = ...
      stimwav(length(tarwav)+1:length(tarwav)+ size(TarWav,2)) + sum(TarWav([1,3],:));
    stimwav(length(tarwav)+ round(ShiftLastTone*SamplingRate) + 1: length(tarwav)+ round(ShiftLastTone*SamplingRate) + size(TarWav,2)) = ...
      stimwav(length(tarwav)+ round(ShiftLastTone*SamplingRate) + 1: length(tarwav)+ round(ShiftLastTone*SamplingRate) + size(TarWav,2)) + ...
      TarWav(2,:);
  end
else
  % in alternation, the gap of last tone is trimmerd
  stimleng = ceil(((ToneDur+GapDur)*burstcnt + ShiftTime + ShiftLastTone)*SamplingRate);
  % make the length of the whole stimulum same with the synchrony case
  stimleng2 = ceil(((ToneDur+GapDur)*burstcnt + ShiftLastTone)*SamplingRate);
  stimwav = zeros(1, stimleng);
  if Freqcnt == 2
    tarwav1 = repmat(TarWav(2,:),1,burstcnt);
    if TrainPhase == 6 && burstcnt ~= minCnt
      tarwav1(1,1:size(TarWav,2)*minCnt) = 0;
    end
    stimwav(1:length(tarwav1)) = tarwav1;
    
    if TrainPhase == 7 && burstcnt ~= minCnt
      stimwav(round(ShiftTime*SamplingRate)+1:round(ShiftTime*SamplingRate)+length(tarwav1)) = ...
        stimwav(round(ShiftTime*SamplingRate)+1:round(ShiftTime*SamplingRate)+length(tarwav1)) + ...
        [zeros(1, size(TarWav,2)*minCnt), repmat(TarWav(1,:),1,burstcnt - minCnt)];
    else
      stimwav(round(ShiftTime*SamplingRate)+1:round(ShiftTime*SamplingRate)+length(tarwav1)) = ...
        stimwav(round(ShiftTime*SamplingRate)+1:round(ShiftTime*SamplingRate)+length(tarwav1)) + ...
        repmat(TarWav(1,:),1,burstcnt);
    end
    % trim the last gap
    stimwav2 = stimwav(1 : stimleng2);
    stimwav = stimwav2;
  else
    tarwav2 = repmat(TarWav,1,burstcnt - 1);
    if TrainPhase == 6 && burstcnt ~= minCnt
      tarwav2([1,3] ,1:size(TarWav,2)*minCnt) = 0;
    end
    stimwav(1:size(tarwav2,2)) = tarwav2(2,:);
    stimwav(round(ShiftTime*SamplingRate)+1:round(ShiftTime*SamplingRate)+size(tarwav2,2)+size(TarWav,2)) = ...
      stimwav(round(ShiftTime*SamplingRate)+1:round(ShiftTime*SamplingRate)+size(tarwav2,2)+size(TarWav,2)) + ...
      [sum(tarwav2([1,3],:)), sum(TarWav([1,3],:))];
    stimwav(round((ShiftTime + ShiftLastTone)*SamplingRate)+size(tarwav2,2)+1:round((ShiftTime + ShiftLastTone)*SamplingRate)+size(tarwav2,2) + size(TarWav,2)) = ...
      stimwav(round((ShiftTime + ShiftLastTone)*SamplingRate)+size(tarwav2,2)+1:round((ShiftTime + ShiftLastTone)*SamplingRate)+size(tarwav2,2) + size(TarWav,2)) + ...
      TarWav(2,:);
  end
end

w = [zeros(PreStimSilence*SamplingRate,1); stimwav(:); zeros(PostStimSilence*SamplingRate,1)];

maxw = max(abs(w));

if maxw>10
  display('Warning: max(waveform) > 10, waveform got clipped!');
end

% logging stim events;
ev=[];
ev = AddEvent(ev,[''],[],0,PreStimSilence);

% modifiy events for trainphase 6
% the priming tone sequence only has one frequency note, the other one is
% noted as 0 to keep the consistence with previous training phase.

for StmN=1:burstcnt
  if flagSym == 1   %for synchrony
    if TrainPhase == 6 && burstcnt ~= minCnt && StmN <= minCnt
      ev = AddEvent(ev,['STIM , B ' num2str([tarfreq(1), 0])  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
      %    if StmN<burstcnt %---delete last gap;
      ev = AddEvent(ev,['GAP , B ' num2str([tarfreq(1), 0])  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+GapDur);
    elseif TrainPhase == 7 && burstcnt ~= minCnt && StmN <= minCnt
      ev = AddEvent(ev,['STIM , B ' num2str([0, tarfreq(2)])  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
      %    if StmN<burstcnt %---delete last gap;
      ev = AddEvent(ev,['GAP , B ' num2str([0, tarfreq(2)])  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+GapDur);
    else
      ev = AddEvent(ev,['STIM , B ' num2str(tarfreq)  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
      %    if StmN<burstcnt %---delete last gap;
      ev = AddEvent(ev,['GAP , B ' num2str(tarfreq)  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+GapDur);
      %    end
    end
  else  %Alternation
    tshift = ShiftTime;
    if TrainPhase == 6 && burstcnt ~= minCnt && StmN <= minCnt
      
      ev = AddEvent(ev,['STIM , B ' num2str(tarfreq(1))  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
      %    if StmN<burstcnt %---delete last gap;
      ev = AddEvent(ev,['GAP , B ' num2str(tarfreq(1))  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+tshift-ToneDur);
      ev = AddEvent(ev,['STIM , B ' num2str(0)  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
      %    if StmN<burstcnt %---delete last gap;
      ev = AddEvent(ev,['GAP , B ' num2str(0)  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+GapDur-tshift);
      
    elseif TrainPhase == 7 && burstcnt ~= minCnt && StmN <= minCnt
      ev = AddEvent(ev,['STIM , B ' num2str(0)  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
      %    if StmN<burstcnt %---delete last gap;
      ev = AddEvent(ev,['GAP , B ' num2str(0)  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+tshift-ToneDur);
      ev = AddEvent(ev,['STIM , B ' num2str(tarfreq(2))  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
      %    if StmN<burstcnt %---delete last gap;
      ev = AddEvent(ev,['GAP , B ' num2str(tarfreq(2))  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+GapDur-tshift);
    else
      
      ev = AddEvent(ev,['STIM , B ' num2str(tarfreq(1))  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
      %    if StmN<burstcnt %---delete last gap;
      ev = AddEvent(ev,['GAP , B ' num2str(tarfreq(1))  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+tshift-ToneDur);
      ev = AddEvent(ev,['STIM , B ' num2str(tarfreq(2))  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
      %    if StmN<burstcnt %---delete last gap;
      ev = AddEvent(ev,['GAP , B ' num2str(tarfreq(2))  ', A ' num2str(burstcnt) ', BurstFreq ' num2str(BurstcntPerTar)],[],ev(end).StopTime,ev(end).StopTime+GapDur-tshift);
    end
  end
end

[a,b,c,d] = ParseStimEvent(ev(2),0); % dont remove spaces
ev(1).Note = ['PreStimSilence , ' b ', ' c ', ' d];
[a,b,c,d] = ParseStimEvent(ev(end),0);
ev = AddEvent(ev,['PostStimSilence , ' b ', ' c ', ' d],[],ev(end).StopTime,ev(end).StopTime+PostStimSilence);


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


function oct = f2oct(freq, basefreq)
oct = log2(freq./basefreq);

%-----------------------------------------------
function freq = oct2f(oct,basefreq)
freq = basefreq*2.^(oct);

