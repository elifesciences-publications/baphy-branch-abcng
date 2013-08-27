function [w, events] = waveform(o,index,IsRef);
%

PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
if length(PostStimSilence)>1
    PostStimSilence = PostStimSilence(1) + diff(PostStimSilence) * rand(1);
end
Names = get(o,'Names');
Count = get(o,'Count');
ICI = get(o,'ICI');
Level = get(o,'Level');
width = get(o,'ClickWidth');
Duration = get(o,'Duration');
SamplingRate = get(o,'SamplingRate');

%
w = zeros(1, Duration * SamplingRate);

nanbins=find([nan isnan(ICI) nan])-1;
icistartbin=nanbins(index)+1;
icistopbin=nanbins(index+1)-1;
useici=ICI(icistartbin:icistopbin);

%If rhythm contains less beats, start repeating to fill-in 
if length(useici)<Count,
    mult=ceil(Count./length(useici));
    useici=repmat(useici,[1 mult]);
end

Cindex=zeros(Count,1);
Cindex(1)=1;
counter=0;
for ii=1:(Count-1),
    counter=counter+useici(ii);
    Cindex(ii+1)=round(counter.*SamplingRate);
end

OnSamples   = width * SamplingRate / 2;
WidthSamples   = round(width * SamplingRate);
flag = 1;
for cnt1    = 1:length(Cindex)
    if flag==1; flag =-1;else flag = 1;end
    w(max(1,Cindex(cnt1)):min(Cindex(cnt1)+WidthSamples,length(w)))=flag;
end

% normalize min/max +/-5
w = 5 ./ max(abs(w(:))) .* w;

% Now, put it in the silence:
w = [zeros(PreStimSilence*SamplingRate,1) ; w(:) ;zeros(PostStimSilence*SamplingRate,1)];

% and generate the event structure:
events = struct('Note',['PreStimSilence , ' Names{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
events(2) = struct('Note',['Stim , ' Names{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
events(3) = struct('Note',['PostStimSilence , ' Names{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
if max(abs(w))>0
    w = 5 * w/max(abs(w));
end
