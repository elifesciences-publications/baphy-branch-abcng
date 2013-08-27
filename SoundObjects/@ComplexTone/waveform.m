function [w,event]= waveform(o,index,IsRef)
% function w=waveform(t);
% This function is the waveform generator for object ComplexTone
%
% Mai December 2008

% Get parameters of ComplexTone object
SamplingRate= get(o,'SamplingRate');
PreStimSilence= get(o,'PreStimSilence');
PostStimSilence= get(o,'PostStimSilence');

ComplexToneDur= get(o,'ComplexToneDur'); % duration in seconds
GapDur= get(o,'GapDur'); % duration in seconds
AnchorFrequency= get(o,'AnchorFrequency');
ComponentsNumber= get(o,'ComponentsNumber');

ComponentRatios= get(o,'ComponentRatios');
FrequencyOrder= get(o,'FrequencyOrder');
Names= get(o,'Names');

% Calculate stimulus parameters
AMFrequency= 4; % Message frequency in Herz for AM modulation

GapSamples= round(GapDur*SamplingRate);
ComplexToneSamples= round(ComplexToneDur*SamplingRate);
prestim=zeros(round(PreStimSilence*SamplingRate),1);
poststim=zeros(round(PostStimSilence*SamplingRate),1);

% Generat complex tone sequence

% First complex tone
ComplexTone= createTone(AnchorFrequency,FrequencyOrder(index),...
             ComponentRatios(:,index),rand(1,ComponentsNumber),...
             ComplexToneDur,SamplingRate);
ComplexTone= addenv(ComplexTone.*(2+sin(2*pi*AMFrequency*...
            (0:ComplexToneSamples-1)'/SamplingRate)), SamplingRate);
% Add complex tone and gap to the stimulus
w=[ComplexTone(:); zeros(GapSamples,1)];

% create event structure
event= struct('Note',['PreStimSilence , ' Names{index}],...
      'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2)= struct('Note',['Stim , ' Names{index}],'StartTime',...
          PreStimSilence, 'StopTime', PreStimSilence+ComplexToneDur,'Trial',[]);
event(3)= struct('Note',['PostStimSilence , ' Names{index}],...
         'StartTime',PreStimSilence+ComplexToneDur,'StopTime',PreStimSilence+...
         ComplexToneDur+GapDur,'Trial',[]);

w = 5 * w/max(abs(w));
% Add pre- and post-stimulus silence:
w = [prestim ; w ;poststim];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Internal Functions  %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s= createTone(fa,fn,ratios,phase,dur,fs)

s= zeros(round(dur*fs),1);
td= ((1:round(dur*fs))-1)/fs ;
ph= phase(:)*pi/180;
rs= [1; ratios];
r= cumprod(rs(1:fn));
r= r(end);
f0= fa/r;
freqs= f0*cumprod(rs);
ph= repmat(ph',length(td),1);

for cnt1= 1:length(freqs)
    s= s+sin(2*pi*freqs(cnt1)*td(:)+ph(:,cnt1));
end

% s= zeros(length(td),length(freqs));
% freqs= repmat(freqs, length(td),1);
% td=repmat(td(:),1,length(phase));
% 
% s(:,1:end)= sin(2*pi*freqs(:,1:end).*td(:,1:end)+ph(:,1:end));
% s= sum(s,2);


%add 5 ms rise/fall time ===================================
function s=addenv(s1,fs);
f=ones(size(s1));
pn=round(fs*0.005);    % 5 ms rise/fall time
up = sin(2*pi*(0:pn-1)/(4*pn)).^2;   %add sinramp
down = sin(2*pi*(pn+1:2*pn)/(4*pn)).^2;
f = [up ones(1,length(s1)-2*pn) down]';
s=s1(:).*f(:);


