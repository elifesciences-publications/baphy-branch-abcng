function [w, events] = waveform(o,index,IsRef)
%
% Nima, dec 2005
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
if length(PostStimSilence)>1
    PostStimSilence = PostStimSilence(1) + diff(PostStimSilence) * rand(1);
end
Names = get(o,'Names');
%
duration        = get(o,'Duration');
width           = get(o,'ClickWidth');
rate            = str2num(Names{index});
SamplingRate    = get(o,'SamplingRate');
%
w           = zeros(1, round(duration * SamplingRate));
rateSamples = SamplingRate / rate;
Cindex       = 1:rateSamples:length(w);
OnSamples   = width * SamplingRate / 2;
flag = 1;
for cnt1    = 1:length(Cindex)
    if flag==1; flag =-1;else flag = 1;end
    w( ceil(max(1,Cindex(cnt1)-OnSamples) : min(Cindex(cnt1)+OnSamples,length(w))) )=flag;
end
% Now, put it in the silence:
Names = Names(index);
w = [zeros(PreStimSilence*SamplingRate,1) ; w(:) ;zeros(PostStimSilence*SamplingRate,1)];
% and generate the event structure:
events = struct('Note',['PreStimSilence , ' Names{:}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
events(2) = struct('Note',['Stim , ' Names{:}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+duration,'Trial',[]);
events(3) = struct('Note',['PostStimSilence , ' Names{:}],...
    'StartTime',PreStimSilence+duration, 'StopTime',PreStimSilence+duration+PostStimSilence,'Trial',[]);
if max(abs(w))>0
    w = 5 * w/max(abs(w));
end
