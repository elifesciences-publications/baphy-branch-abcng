function [h p] = LickSigDiff(exptparams, ShockTar, fs)


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

TarDurs=[];
if ~isempty(exptparams.AllTarLick.Hist)
    TarDurs = get(get(exptparams.TrialObject,'TargetHandle'),'Duration');
    PossibleDurs =TarDurs(1):DurIncrement:TarDurs(2);
    TarIncrement =1:DurIncrement*fs:TarDurs(2).*fs;
    TarLick = [];
    for cnt1 = 1:length(TarIncrement)
        
        TempTarLick=[];
        for cnt2 = 1:length(exptparams.AllTarLick.Hist)
            if length(exptparams.AllTarLick.Hist{cnt2}) > TarIncrement(cnt1)
                TempTarLick = [TempTarLick exptparams.AllTarLick.Hist{cnt2}(TarIncrement(cnt1):TarIncrement(cnt1)+249,:)];
                
            end
        end
        
        if isempty(TempTarLick) == 0
            if size(TempTarLick,2) ~= 1
                TarLick = [TarLick; mean(TempTarLick,2) 2*sqrt(var(TempTarLick')./size(TempTarLick,2))'];
            else
                TarLick = [TarLick; TempTarLick zeros(size(TempTarLick))];
            end
        end
    end
    
    TarLick = unique(TarLick(:,1));
end

DisDurs=[];
if ~isempty(exptparams.AllDisLick.Hist)
    DisDurs = get(get(exptparams.TrialObject,'TargetHandle'),'Duration');
    PossibleDurs =DisDurs(1):DurIncrement:DisDurs(2);
    DisIncrement =1:DurIncrement*fs:DisDurs(2).*fs;
    DisLick = [];
    for cnt1 = 1:length(DisIncrement)
        
        TempDisLick=[];
        for cnt2 = 1:length(exptparams.AllDisLick.Hist)
            if length(exptparams.AllDisLick.Hist{cnt2}) > DisIncrement(cnt1)
                TempDisLick = [TempDisLick exptparams.AllDisLick.Hist{cnt2}(DisIncrement(cnt1):DisIncrement(cnt1)+249,:)];
                
            end
        end
        
        if isempty(TempDisLick)==0
            if size(TempDisLick,2) ~= 1
                DisLick = [DisLick; mean(TempDisLick,2) 2*sqrt(var(TempDisLick')./size(TempDisLick,2))'];
            else
                DisLick = [DisLick; TempDisLick zeros(size(TempDisLick))];
            end
        end
    end
    
    DisLick = unique(DisLick(:,1));
end

RefLick = unique(RefLick(:,1));
nexps = 1000;
if ShockTar < 3
    y = DisLick;
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
else
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
    
end
