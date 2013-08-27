saveundo;
Ws=Ws(:,find(ismember(Wt,setdiff(Wt,St)))); 
Wt=setdiff(Wt,St);
Ss=Ws;
St=Wt;
hood=0;
meska;