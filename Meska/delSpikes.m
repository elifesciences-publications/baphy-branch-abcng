saveundo;
Ws=Ws(:,find(ismember(Wt,setdiff(Wt,St)))); 
Wt=setdiff(Wt,St);
Ss=Ws;
St=Wt;
hood=0;

if ~ONEFILE
    Ws2=Ws2(:,find(ismember(Wt2,setdiff(Wt2,St2))));
    Wt2=setdiff(Wt2,St2);
    Ss2=Ws2;
    St2=Wt2;
    hood2=0;
end
meska;