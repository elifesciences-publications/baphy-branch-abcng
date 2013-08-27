function [h p] = SDWMLickSigDiff(o, exptparams, fs)


x = get(exptparams.TrialObject,'rovedurs');
DurIncrement = x(1,2);
RefDurs = get(get(exptparams.TrialObject,'ReferenceHandle'),'Duration');
PossibleDurs =RefDurs(1):DurIncrement:1;
BoundPosDurs = PossibleDurs;
RefIncrement =1:DurIncrement*fs:1.*fs;
RefLick = [];
TarLick=[];
DisLick=[];
for cnt1 = 1:length(RefIncrement)
    
    TempRefLick=[];
    for cnt2 = 1:length(exptparams.AllRefLick.Hist)
        if length(exptparams.AllRefLick.Hist{cnt2}) > RefIncrement(cnt1)
            TempRefLick = [TempRefLick exptparams.AllRefLick.Hist{cnt2}(RefIncrement(cnt1):RefIncrement(cnt1)+249,:)];
            
        end
    end
    
    if isempty(TempRefLick)==0
        if size(TempRefLick,2) ~= 1
            RefLick = [RefLick; mean(TempRefLick,2) 2*sqrt(var(TempRefLick')./size(TempRefLick,2))'];
        else
            RefLick = [RefLick; TempRefLick zeros(size(TempRefLick))];
        end
    end
end

TempTarLick=[];
for cnt2 = 1:size(exptparams.AllTarLick.Hist,2)
    TempTarLick = [TempTarLick exptparams.AllTarLick.Hist];
    
end

if size(TempTarLick,2) ~= 1
    TarLick = [mean(TempTarLick,2) 2*sqrt(var(TempTarLick')./size(TempTarLick,2))'];
else
    TarLick = [TempTarLick zeros(size(TempTarLick))];
end

TarLick = unique(TarLick(:,1));
RefLick = unique(RefLick(:,1));
nexps = 1000;
y = RefLick;
x = TarLick;

t = abs(mean(y) - mean(x));
null = [x; y];

that=[];
for i =1:nexps
    xhat = randsample(null,length(x),'true');
    yhat = randsample(null,length(y),'true');
    that = [that; abs(mean(yhat) - mean(xhat))];
    
end

h=0;
p = sum(that>t)./nexps;
if p < 0.05
    h = 1;
    
    
end
