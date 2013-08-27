St = setdiff(Wt,St);
Ss = Ws(:,find(ismember(Wt,St)));
if ~ONEFILE
    St2 = setdiff(Wt2,St2);
    Ss2 = Ws2(:,find(ismember(Wt2,St2)));
end
spikeselect;