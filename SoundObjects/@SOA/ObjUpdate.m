function o = ObjUpdate (o);
% Update the changes of a Stream_AB object
% Ling Ma modified from Stream_AB(Pingbo), Jun. 2006

ToneA = get(o,'ToneA');
ToneB = get(o,'ToneB');
ToneDur= get(o,'ToneDur');
ToneGap = get(o,'ToneGap');
ComplexNum = get(o,'ComplexNum');
SOA = get(o,'SOA');
ToneA_alone = get(o,'ToneA_alone');
ToneB_alone = get(o,'ToneB_alone');
L1=length(ToneA);
L2=length(ToneB);
L3=length(ComplexNum);
for cnt2 = 1:length(SOA)
    for cnt1 = 1:length(ComplexNum)
        for i=1:L1
            for j=1:L2
                RandomFrequency = [ToneA(i) ToneB(j) ComplexNum(cnt1) SOA(cnt2)];
                Names{L1*L2*L3*(cnt2-1)+L1*L2*(cnt1-1)+L2*(i-1)+j} = num2str(RandomFrequency);
            end
        end
    end
end
if strcmp(ToneA_alone,'yes')
    for i = 1:L1
    	Names{end+1} = num2str([ToneA(i) 0 max(ComplexNum) 0]);
    end
end
if strcmp(ToneB_alone,'yes')
    for i = 1:length(ToneB)
        Names{end+1} = num2str([0 ToneB(i) max(ComplexNum) 0]);
    end
end

o = set(o,'Names',Names);
o = set(o,'MaxIndex',length(Names));