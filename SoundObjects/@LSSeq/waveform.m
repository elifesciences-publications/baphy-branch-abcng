function [w, ev]=waveform (o,index);
% function w=waveform(t);
% this function is the waveform generator for object MaskerA_StreamB
%
% By Ling Ma, 10/2006

%parameters ---------------------------------------------------------------
RmpDur=0.01; % Duration of each tone ramp (s) (rising+falling)

maxindex = get(o,'MaxIndex');
SamplingRate = get(o,'SamplingRate');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');

% if index<=maxindex
    % stimulus parameters -------------------------------------------------
    SynorAsyn = get(o,'SynorAsyn');
    SynorAsyn = deblank(SynorAsyn);
    ToneDur = get(o,'ToneDur');
    GapDur = get(o,'GapDur'); % duration is second
    Names = get(o,'Names');
    tag = str2num(Names{index(1)});
    BurstcntPerTar = get(o,'BurstcntPerTar');
    CateNum = index(1);
    stimlistcnt = get(o,'StimListCnt');
    list = mod(CateNum,stimlistcnt);
    if list==0
        list = stimlistcnt;
    end
    tarfreq = tag(2);
    burstcnt = get(o,'burstcnt'); %burstcnt(1):reference1; burstcnt(2):target; burstcnt(3):reference2;
    RelMskL=get(o,'dBAtten'); % Level of acoustic stimuli (dB)

    DynamicorStatic = 1;%always dynamic;

    MskCmpNum=get(o,'MskCmpNum');   % Number of frequency components in each masker burst
    Amp = 5/(MskCmpNum+1);
    % Amp=3/sqrt(MskCmpNum+1);
    ProtectZoneInSemitone = get(o,'ProtectZoneInSemitone');
    protectzone = tag(1);
%     tarorref = tag(3); %1:tar; 0:ref;
    whichprotectzone = find(ProtectZoneInSemitone==protectzone);
    MskFreqs = get(o,'MskFreqs'); MskFs = MskFreqs{whichprotectzone};
    IdxSequence = get(o,'IdxSeq'); IdxSeq = IdxSequence{whichprotectzone};
    % MskGapDur = get(o,'MskGapDur');
    MskTime = get(o,'MskTime');

    % Sound waveform generation ------------------------------------------------------------------------------------------------------------
    % Generating Target waveform;
    stimleng = round(((ToneDur+GapDur)*sum(burstcnt)-GapDur)*SamplingRate);
    TarWav=Amp*tone(tarfreq,ToneDur,RmpDur,SamplingRate);% TarWav=tone(tarfreq,ToneDur,RmpDur,SamplingRate);
    GapWav=zeros(1,round(GapDur*SamplingRate));
    TarWavs = [TarWav, GapWav]; 
    padding_zero = zeros(1,length(TarWavs)*(BurstcntPerTar-1));
    TarWavs = [TarWavs,padding_zero];
    TarWavs = repmat(TarWavs,1,ceil(burstcnt(2)/BurstcntPerTar));
    TarWavs = [zeros(1,round((ToneDur+GapDur)*burstcnt(1)*SamplingRate)),TarWavs,zeros(1,round((ToneDur+GapDur)*burstcnt(3)*SamplingRate))];
    TarWavs = (10^(-RelMskL/20))*TarWavs(1,1:stimleng);% delete last gap;

    TotStmWav=[]; ev=[]; w = [];
    ev = AddEvent(ev,[''],[],0,PreStimSilence);
    switch SynorAsyn
        case 'synchrony'
             for StmN=1:sum(burstcnt)    
                if DynamicorStatic|StmN == 1 % 1:dynamic
                    MskWav=zeros(1,round(ToneDur*SamplingRate));
                    for MskN=1:MskCmpNum
                        MskWav=MskWav+Amp*(10^(-RelMskL/20))*tone(MskFs(IdxSeq((list-1)*sum(burstcnt)*MskCmpNum+(StmN-1)*MskCmpNum+MskN)),ToneDur,RmpDur,SamplingRate);
                    end
                end
                StmWav=MskWav; 
                ev = AddEvent(ev,['STIM , B ' num2str(tarfreq) ', ProtectZone ' num2str(protectzone) ', A ' num2str(CateNum)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
                if StmN<sum(burstcnt)
                    ev = AddEvent(ev,['GAP , B ' num2str(tarfreq) ', ProtectZone ' num2str(protectzone)  ', A ' num2str(CateNum)],[],ev(end).StopTime,ev(end).StopTime+GapDur);
                    TotStmWav=[TotStmWav StmWav GapWav]; 
                else
                    TotStmWav=[TotStmWav StmWav];
                end
             end
%              if tarorref
                    TotStmWav = MskWavs+TarWavs;
%              else
%                     TotStmWav = MskWavs;
%              end
             
        case 'asynchrony'
            %       Method 2  
            % gernerating stim waveform;
            MskWavs = zeros(1,stimleng+round(SamplingRate*ToneDur));;
            for StmN = 1:sum(burstcnt)
                if DynamicorStatic|StmN == 1 % 1:dynamic
                    MskWav = Amp*(10^(-RelMskL/20))*tone(MskFs(IdxSeq(((list-1)*sum(burstcnt)*MskCmpNum+(StmN-1)*MskCmpNum+(1:MskCmpNum)))),ToneDur,RmpDur,SamplingRate);
                    for MskN = 1:MskCmpNum
                        % get time onset
                        ToneOnset = round(SamplingRate*MskTime(MskCmpNum*(StmN-1)+MskN)); % sample number
                        % Add to overall background sequence
                        MskWavs(ToneOnset:ToneOnset+size(MskWav,2)-1) = MskWavs(ToneOnset:ToneOnset+size(MskWav,2)-1)+MskWav(MskN,:);
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
            MskWavs = MskWavs(1:stimleng);
%              if tarorref
                    TotStmWav = MskWavs+TarWavs;
%              else
%                     TotStmWav = MskWavs;
%              end
            % logging stim events;
            for StmN=1:sum(burstcnt)
                ev = AddEvent(ev,['STIM , B ' num2str(tarfreq) ', ProtectZone ' num2str(protectzone) ', A ' num2str(CateNum)],[],ev(end).StopTime,ev(end).StopTime+ToneDur);
                if StmN<sum(burstcnt)
                    ev = AddEvent(ev,['GAP , B ' num2str(tarfreq) ', ProtectZone ' num2str(protectzone)  ', A ' num2str(CateNum)],[],ev(end).StopTime,ev(end).StopTime+GapDur);
                end
            end
        [a,b,c,d] = ParseStimEvent(ev(2),0); % dont remove spaces
        ev(1).Note = ['PreStimSilence , ' b ', ' c ', ' d];
        [a,b,c,d,e] = ParseStimEvent(ev(end),0); 
        ev = AddEvent(ev,['PostStimSilence , ' b ', ' c ', ' d],[],ev(end).StopTime,ev(end).StopTime+PostStimSilence);
    end

TotStmWav = rmpcos2(TotStmWav,RmpDur,SamplingRate);
w = [zeros(PreStimSilence*SamplingRate,1); TotStmWav(:) ;zeros(PostStimSilence*SamplingRate,1)];
maxw = max(abs(w));
if maxw>10
    display('Warning: max(waveform) > 10, waveform got clipped!');
end


%%%%%%%%%%%%%%%%%%%%%%%%Helper Functions%%%%%%%%%%%%%%%%%%%%%%%%
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
