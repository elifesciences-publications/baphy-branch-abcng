function o = ObjUpdate(o)
% By Ling Ma, 3/2008

firstFreq = get(o,'FstFreq');
trainPhase = get(o,'TrainPhase');
trainRange = get(o,'TrainRange');
BurstCnt = get(o,'BurstCnt');
BurstcntPerTar = get(o,'BurstcntPerTar');
SndRelative = get(o,'SndRelative');
ShiftTime = get(o,'ShiftTime');
leng = length(BurstcntPerTar);
if get(o,'flagSym')==1 && get(o,'ShiftTime')~=0
    o=set(o,'ShiftTime',0); end

if trainPhase>=2
    stepsize=abs(SndRelative(1));
    if length(SndRelative)==2
        stepsize=SndRelative(2);
    end
end

if trainPhase == 2
    vecCount = trainRange(1):stepsize:trainRange(2);  %octave spacing
    firstFreq=round(firstFreq*2.^vecCount);
    if SndRelative > 0
        firstFreq = firstFreq(1:end-ceil(SndRelative(1)/stepsize));
    else
        firstFreq = firstFreq(ceil(SndRelative(1)/stepsize)+1:end);
    end
    
elseif trainPhase == 3
    stepsize = SndRelative;
    firstFreq = trainRange(1):stepsize:trainRange(2);
elseif trainPhase == 5 || trainPhase == 6 || trainPhase == 7
    stepsize = SndRelative;
    if length(stepsize)==1 || stepsize(2)==0   % for varing frequency spacing
        leftindex =  round(log2(-trainRange(1)/stepsize));
        rightindex = round(log2(trainRange(2)/stepsize));
        leftCount = -stepsize*2.^(leftindex:-1:0);
        rightCount = stepsize*2.^(0:rightindex);
        firstFreq = [leftCount 0 rightCount];
    else                       % for fixed frequency spacing (2nd element is increament)
        firstFreq=trainRange(1):stepsize(2):trainRange(2);
    end
end

if trainPhase == 5 || trainPhase == 6 || trainPhase == 7
    for j = 1:length(ShiftTime)
        for i = 1 : length(BurstCnt)
            for k = 1 : length(firstFreq)
                RandomFrequency = [BurstCnt(i)  firstFreq(k) ShiftTime(j)];
                Names{length(ShiftTime)*length(BurstCnt)*(k-1) + length(BurstCnt)*(j-1)+i} = num2str(RandomFrequency);
            end
        end
    end
elseif trainPhase == 4
    for j = 1:leng
        for i = 1 : length(BurstCnt)
            for k = 1 : length(ShiftTime)
                RandomFrequency = [BurstCnt(i) BurstcntPerTar(j) ShiftTime(k)];
                Names{leng*length(BurstCnt)*(k-1) + length(BurstCnt)*(j-1)+i} = num2str(RandomFrequency);
            end
        end
    end
else
    for j = 1:leng
        for i = 1 : length(BurstCnt)
            for k = 1 : length(firstFreq)
                RandomFrequency = [BurstCnt(i) BurstcntPerTar(j) firstFreq(k)];
                Names{leng*length(BurstCnt)*(k-1) + length(BurstCnt)*(j-1)+i} = num2str(RandomFrequency);
            end
        end
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

