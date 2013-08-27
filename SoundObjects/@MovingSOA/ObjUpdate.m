function o = ObjUpdate (o);
% Update the changes of a Stream_AB object
% Ling Ma modified from Stream_AB(Pingbo), Jun. 2006

BF = get(o,'BF');
Step_num = get(o,'Step_num')-1;
Width_oct = get(o,'Width_oct');
ToneDur= get(o,'ToneDur');
ToneGap = get(o,'ToneGap');
SOA = get(o,'SOA');
L2 = length(SOA);
L1 = Step_num+1;
ComplexNum = get(o,'ComplexNum');
index = 1;

for cnt1 = 1:length(Width_oct)
    ToneB = round(BF*2.^[0:Width_oct(cnt1)/Step_num:Width_oct(cnt1)]);
    ToneA = round(ToneB.*2^(-Width_oct(cnt1)));
    for cnt2=1:L1%step_num
        for cnt3 = 1:L2%soa
            RandomFrequency = [ToneA(cnt2) ToneB(cnt2) index SOA(cnt3)];
            Names{L1*L2*(cnt1-1)+L2*(cnt2-1)+cnt3} = num2str(RandomFrequency);
            index = index+1;
        end
    end
end

o = set(o,'Names',Names);
o = set(o,'MaxIndex',length(Names));