function o = ObjUpdate (o);
%
%
% pby, July 2009

Names0=get(o,'Names');
Tonenum=get(o,'ToneNumber');
Type=deblank(get(o,'Type'));
LowFrequency = ifstr2num(get(o,'LowFrequency'));
if ~any(strcmpi(Type,{'AMtone2','AMtone2a'}))   %AMtone2 set don't have multiple intensity feature
    newset1=strcmpi(Type,'tone') && length(LowFrequency)~=1;
    newset2=strcmpi(Type,'AMtone') && length(LowFrequency)~=2;
    if get(o,'maxIndex')>Tonenum && (newset1+newset2)==0          %deal with multiple intensity update from trialObject--3/05/2012 by pby
        rep=get(o,'maxIndex')/Tonenum;
        if mod(rep,1)==0 && rep>1        %multiple of total frequencies
            if length(Names0)~=get(o,'maxIndex')
                Names=[];
                for i=1:rep
                    Names=[Names;Names0(1:Tonenum)];
                end
                o = set(o,'Names',Names);
                o = set(o,'MaxIndex',length(Names));
            end
            return;
        end
    end
end


%NumFreqRange = ifstr2num(get(o,'NumFreqRange'));
PctSeparation = ifstr2num(get(o,'PctSeparation'));
ToneNumber = ifstr2num(get(o,'ToneNumber'));
%Duration=get(o,'Duration');
%TarRange=get(o,'TarRange');

% now, generate a list of all frequencies needed:
Freq = LowFrequency(1)*(1+PctSeparation/100).^(0:ToneNumber-1);
if ~any(strcmpi(Type,{'Tone','Amtone','AMtone2','AMtone2a','AMtone2c','Gaptone','Click','Harm','Mistuned'}))
    error('Wrong type!!! the stimulus type list: Tone, Click, Harm, Mistuned');
end
if strcmpi(Type,'mistuned')  %for mistuned hanoincs
    Freq=round(Freq(:));
    f0=round(((Freq(end)-Freq(1))/7)*1.2);  %Fundamental frequency
    Freq(:,2)=279;
    Freq=Freq(:,[2 1]);
else
    Freq=round(Freq(:));
    if any(strcmpi(Type,{'Amtone','AMtone2','AMtone2a','AMtone2c'}))  %for am tone
        amInc=round((60-4)/(ToneNumber-1));
        amFreq=[0:ToneNumber-1]*amInc+4;      %6 am freq
        Freq=[Freq(:) amFreq(:)];
    end
    if any(strcmpi(Type,{'AMtone2','AMtone2a'}))   %add AM stimulus set with noise carrior
        Freq0=Freq;
        Freq0(:,1)=0;    %0 meant WN carrior
        if strcmpi(Type,'AMtone2a')
            Freq(:,2)=0;     %0 meant no AM
        end
        Freq=[Freq;Freq0];
    elseif strcmpi(Type,'AMtone2c')  %combinations of AM and Tones
        for i=1:length(amFreq)
            for j=1:length(Freq)
                tem(length(Freq)*(i-1)+j,1:2)=[Freq(j) amFreq(i)];
            end
        end
        Freq=tem;
    end
end

Names=cellstr(num2str(Freq));
o = set(o,'Names',Names);
o = set(o,'MaxIndex',length(Names));
