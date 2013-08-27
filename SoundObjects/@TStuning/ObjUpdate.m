function o = ObjUpdate (o);
%

% Nima, november 2005
BaseFrequency = ifstr2num(get(o,'BaseFrequency'));
SemiToneRange = ifstr2num(get(o,'SemiToneRange'));
SemiToneStep = ifstr2num(get(o,'SemiToneStep'));
ToneNumber = ifstr2num(get(o,'ToneNumber'));
ToneGap = get(o,'ToneGap');
dbr=get(o,'dBattenRange');  %attenuation range
dbs=get(o,'dBattenStep');
% now, generate a list of all frequencies needed:
if BaseFrequency(1)==0   %default for shepard tone
    Freq=0:11;
else
    Freq = min(SemiToneRange):SemiToneStep:max(SemiToneRange);
    Freq = Freq/12;  %convert semitone to ocatve
    Freq = round(BaseFrequency(1) * 2.^Freq);
end
N=length(Freq);
%
if ToneNumber==0 || ToneNumber==2
        if length(ToneGap)==1   %2 tone tuning at all combination at fixed ISI
            for cnt1 = 1:N
                for cnt2=1:N
                    Names{(cnt1-1)*N+cnt2} = num2str([Freq(cnt1) Freq(cnt2)]);
                end
            end
        else         %2 tone tone around BF with variable ISIs
            ToneGap=[0:ToneGap(1):ToneGap(2)];
            for cnt1 = 1:N
                for cnt2=1:length(ToneGap)
                    Names{(cnt1-1)*length(ToneGap)+cnt2} = num2str([BaseFrequency Freq(cnt1) ToneGap(cnt2)]);
                end
            end
        end
elseif ToneNumber==1
        for cnt1 = 1:N
                Names{cnt1} = num2str([Freq(cnt1)]);
        end
else
        disp('not ready yet!');
end
if dbr>0 && ToneNumber==1
    dbr=0:dbs:dbr;
    for i=1:length(dbr)
        for j=1:length(Names)
            tem{(i-1)*length(Names)+j}=[Names{j} ' ' num2str(dbr(i))];
        end
    end
    Names=tem;
end
o = set(o,'Names',Names);
o = set(o,'MaxIndex',length(Names));
mFreq=max(Freq);
if length(BaseFrequency)==2 && BaseFrequency(2)<=48 && ToneNumber==1
    mFreq=mFreq*2^(BaseFrequency(2)/12/2);
end

if mFreq>=20000
    mFreq=max([100000 mFreq]);
end
if mFreq>get(o,'SamplingRate')
    o=set(o,'SamplingRate',mFreq);
end
