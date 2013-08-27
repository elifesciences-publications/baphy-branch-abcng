function o = ObjUpdate (o);
% Update the changes of a Stream_AB object
% Pingbo, December 2005
ToneA = get(o,'ToneA');
ToneB = get(o,'ToneB');
ToneDur= get(o,'ToneDur');
ToneGap = get(o,'ToneGap');
ComplexNum = get(o,'ComplexNum');
L1=length(ToneA);
L2=length(ToneB);
tardB = get(o,'tardB');
lev = length(tardB);
num = length(ComplexNum);

for dd = 1:lev
    for cnt1 = 1:num
        for i=1:L1
            for j=1:L2
                RandomFrequency = [ToneA(i) ToneB(j) ComplexNum(cnt1) tardB(dd)];
                Names{num*L1*L2*(dd-1)+L1*L2*(cnt1-1)+L2*(i-1)+j} = num2str(RandomFrequency);
            end
        end
    end
end
o = set(o,'Names',Names);
o = set(o,'MaxIndex',length(Names));