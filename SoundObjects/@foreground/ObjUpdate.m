function o = ObjUpdate (o);
% By Ling Ma, 3/2008

tarfreq = get(o,'TarFreq');
BurstCnt = get(o,'BurstCnt');
BurstcntPerTar = get(o,'BurstcntPerTar');
tardB = get(o,'tardB');
dBnum = length(tardB);
leng = length(BurstcntPerTar);
% stimuli names
for k = 1:dBnum
    for j = 1:leng
        RandomFrequency = [BurstCnt tarfreq BurstcntPerTar(j) tardB(k)];
        Names{leng*(k-1)+j} = num2str(RandomFrequency);
    end
end

o = set(o,'Names',Names);
o = set(o,'MaxIndex',length(Names));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%HelperFunctions%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------
function oct = f2oct(freq, basefreq)
oct = log2(freq./basefreq);

%-----------------------------------------------
function freq = oct2f(oct,basefreq)
freq = basefreq*2.^(oct);

