multFac= 10000;
clear spiketemp st Ws Wt Ss St;
for a= 1:floor(length(spkraw)/multFac)+1
    if a== floor(length(spkraw)/multFac)+1
        spkraw((a-1)*multFac+1:end)= -spkraw((a-1)*multFac+1:end);
    else
        spkraw((a-1)*multFac+1:a*multFac)= -spkraw((a-1)*multFac+1:a*multFac);
    end
end

if ~ONEFILE 
    clear spiketemp2 st2 Ws2 Wt2 Ss2 St2
    for b= 1:floor(length(spkraw2)/multFac)+1
        if b== floor(length(spkraw2)/multFac)+1
            spkraw2((b-1)*multFac+1:end)= -spkraw2((b-1)*multFac+1:end);
        else
            spkraw2((b-1)*multFac+1:b*multFac)= -spkraw2((b-1)*multFac+1:b*multFac);
        end
    end
end 
RECOMPUTE=1;
meska;


% Old version
% clear spiketemp st Ws Wt Ss St;
% spkraw(1:end) = -spkraw(1:end);
% if ~ONEFILE 
%     clear spiketemp2 st2 Ws2 Wt2 Ss2 St2
%     spkraw2(1:end) = -spkraw2(1:end);
% end 
% RECOMPUTE=1;
% meska;