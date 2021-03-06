function o = ObjUpdate (o)
% Update the changes of a Stream_AB object
% Pingbo, December 2005
% modified in Aprul, 2006

Type=lower(get(o,'Type'));
if strcmpi(Type(1:2),'si') || strcmpi(Type,'single')  
    o=set(o,'Type','Single');       %fixed pair
elseif strcmpi(Type(1:2),'ml') || strcmpi(Type,'multi-L')   
    o=set(o,'Type','Multi-L');   %varied low frequency components
elseif strcmpi(Type(1:2),'mh') || strcmpi(Type,'multi-H')
    o=set(o,'Type','Multi-H');   %varied high frequency components
elseif strcmpi(Type(1:2),'ms') || strcmpi(Type,'multi-step')
    o=set(o,'Type','Multi-Step');   %multiple steps
elseif strcmpi(Type(1:2),'mu') || strcmpi(Type,'multiple')   
    o=set(o,'Type','Multiple');     %multiple pairs with fixed step
elseif strcmp(Type(1:2),'sh');  
    o=set(o,'Type','Shepard');
    Frequency=get(o,'Frequency');
    if length(Frequency)==2  %initializing para for Shepard tone
        o=set(o,'Frequency',[1 11 100 1]); %1-2: 2nd tone interval range, 3-F0, 4- perceive dirction in sequence (1-same, 0-diff)
    end
else
    error('Wrong Type!!! Stim Type must be: ''Single,Multiple, Multi-L,Multi-H or Multi-Step''');
end
Type=get(o,'Type');
Frequency = get(o,'Frequency');
if ~strcmpi(Type,'Shepard')
%     if length(Frequency)>2 && Frequency(1)<20
%         o=set(o,'Frequency',[500 800]); %initializing para for tone
%     end
    fs = get(o,'SamplingRate');
    if strcmpi(Type,'Single')
        octaverange=0; else
        octaverange=get(o,'OctaveRange');
        if length(octaverange)==1
            octaverange=[-octaverange octaverange];
        end
        octavestep = get(o,'OctaveStep'); end
    if fs<(max(Frequency)*2)*2^(max(octaverange))
        o=set(o,'SamplingRate',ceil((max(Frequency)*4)*2^(max(octaverange)))); end
end
NoteDur= get(o,'NoteDur');
NoteGap = get(o,'NoteGap');

if strcmpi(lower(Type),'single')
    MaxIndex=1;
    Names{1}=num2str([Frequency]);
elseif strcmpi(lower(Type),'multi-step')
    tp=[0 4;0 3;0 2;0 1;3 4;2 4;1 4];
    tp=[tp;tp-4]*octavestep;   %14 upward-step pairs 
    if Frequency(2)<Frequency(1)
        tp=tp(:,[2 1]);        %14 downward-step pairs
    end
    Names=cellstr(num2str(round(min(Frequency)*2.^tp)));  %computing based on first Frequency
    MaxIndex=length(Names);
    o=set(o,'OctaveRange',[-4 4]*octavestep);
elseif strcmpi(Type,'Shepard')
    Names=[Frequency(1):Frequency(2)]';
    Names(:,2)=Frequency(4);               %(1-standard first, 0-comparison first)
    Names(Names(:,1)>6,2)=1-Frequency(4);  %
    amb_pair=Names(Names(:,1)==6,:);
    amb_pair(:,2)=1-amb_pair(:,2);    %for ambigous pair, add reverse pair
    Names=[Names;amb_pair];
    Names=cellstr(num2str(Names));
    MaxIndex=length(Names);
else
    %step=0:octavestep:max(octaverange);
    step=min(octaverange):octavestep:max(octaverange);
    switch Type(end)
        case 'L'   %isolate Low frequency note
            steptemp=zeros(1,length(Frequency));         %modified @8/14/2008
            steptemp(find(Frequency==min(Frequency)))=1;
            %steptemp=ones(1,length(Frequency));
            %steptemp(find(Frequency==min(Frequency)))=-1;
        case 'H'   %isolate High frequency note
            steptemp=zeros(1,length(Frequency));         %modified @8/14/2008
            steptemp(find(Frequency==max(Frequency)))=1;
            %steptemp=-ones(1,length(Frequency));
            %steptemp(find(Frequency==max(Frequency)))=1;
        otherwise  %vary both Low and High together           
            steptemp=ones(1,length(Frequency));            
    end
    MaxIndex=length(step);
    for i=1:MaxIndex
        tem=zeros(1,length(Frequency))+2.^(steptemp*step(i));
        Names{i}=num2str(round(Frequency.*tem));
    end
end
o = set(o,'Names',Names);
o = set(o,'MaxIndex',MaxIndex);
