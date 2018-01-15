function [w, events] = waveform(o,index,IsRef);
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
IrregularCT     = get(o,'IrregularCT');
IrregularCT(find(IrregularCT==' ',1,'first'):end) = [];
%
w           = zeros(1, round(duration * SamplingRate));
rateSamples = SamplingRate / rate;
switch IrregularCT
    case 'no'
        Cindex = 1:rateSamples:length(w);
    case 'uniform'
        MinICI = get(o,'MinICI');
        ClickNb = ceil(length(w)/rateSamples)-1;
        Cindex = [1 ; randsample(length(w),ClickNb)];
        while any(diff(sort(Cindex))<round(MinICI*SamplingRate))
            Cindex = [1 ; randsample(length(w),ClickNb)];
        end
end
OnSamples = width * SamplingRate / 2;
flag = 1;
for cnt1    = 1:length(Cindex)
    if flag==1; flag =-1;else flag = 1;end
    w( ceil(max(1,Cindex(cnt1)-OnSamples) : min(Cindex(cnt1)+OnSamples,length(w))) )=flag;
end
% Now, put it in the silence:
Names = Names(index);
w = [zeros(round(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(round(PostStimSilence*SamplingRate),1)];
% and generate the event structure:
events = struct('Note',['PreStimSilence , ' Names{:}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[],'Rove',[]);
events(2) = struct('Note',['Stim , ' Names{:}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+duration,'Trial',[],'Rove',Cindex);
events(3) = struct('Note',['PostStimSilence , ' Names{:}],...
    'StartTime',PreStimSilence+duration, 'StopTime',PreStimSilence+duration+PostStimSilence,'Trial',[],'Rove',[]);
if max(abs(w))>0
    w = 5 * w/max(abs(w));
end
