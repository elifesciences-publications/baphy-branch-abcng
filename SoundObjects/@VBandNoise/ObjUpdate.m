function o = ObjUpdate (o)
% Update the changes of a Stream_AB object
% Pingbo, December 2005
% modified in Aprul, 2006

Type=lower(get(o,'Type'));
if strcmpi(Type(1),'s')
    o=set(o,'Type','SingleFreq');
elseif strcmpi(Type(1),'m')
    o=set(o,'Type','MultiFreq');
else
    error('Wrong Type!!! Stim Type must be: ''PsudoRand,Rand''');
end

fs = get(o,'SamplingRate');
Frequency = get(o,'CenterFrequency');
bw=get(o,'BandWidths');
probe=get(o,'Probe');   %probe bandwith
if ischar(probe)
    probe=str2num(probe);
end
if strcmpi(get(o,'Type'),'MultiFreq')
    range=get(o,'SemiToneRange');
    step=get(o,'SemiToneStep');
    step=[0:step:max(range) -step:-step:min(range)];
    step=step/12;   %converted in octaves
    Frequency=round(Frequency*2.^step);  %center frequency list
    tem0=[];
    tem1=[];  %for probe
    for i=1:length(Frequency)
        tem=bw(:);
        tem(:,2)=Frequency(i);
        tem0=[tem0;tem];
        
        if ~isempty(probe) && ~isnan(probe)
            tem=[probe Frequency(i)];
            tem1=[tem1;tem];
        end
    end
else
    tem0=bw(:);
    tem0(:,2)=Frequency;
    if ~isempty(probe) && ~isnan(probe)
        tem1=probe(:);
        tem1(:,2)=Frequency;
    end
end
Frequency=tem0(:,[2 1]);
Frequency(:,1)=ceil(Frequency(:,1));
mFrequency=max(Frequency(:,1))*2^(max(Frequency(:,2))/2/12);
if (mFrequency*3)>100000
    o=set(o,'SamplingRate',ceil(mFrequency*3/100)*100); 
elseif (mFrequency*3)>40000
    o=set(o,'SamplingRate',100000);
else
    o=set(o,'SamplingRate',40000);
end

MaxIndex=size(Frequency,1);
for i=1:MaxIndex
    Names{i}=num2str([Frequency(i,:) 0]);
end

if ~isempty(probe) && ~isnan(probe)
    probe=tem1(:,[2 1]);
    MaxIndex=MaxIndex+size(probe,1);
    for i=1:size(probe,1)
        Names{end+1}=num2str([probe(i,:) 1]);
    end
end
o = set(o,'Names',Names);
o = set(o,'MaxIndex',MaxIndex);
