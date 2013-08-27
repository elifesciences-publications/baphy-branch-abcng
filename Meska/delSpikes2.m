saveundo;

Ws2=Ws2(:,find(ismember(Wt2,setdiff(Wt2,St2))));
Wt2=setdiff(Wt2,St2);
Ss2=Ws2;
St2=Wt2;
hood2=0;
meska;