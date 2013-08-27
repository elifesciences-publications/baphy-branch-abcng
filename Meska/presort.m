% presort based on data envelope parameters
[a,b] = uigetfile(['*.spk.mat'],'Presort File...');
eval(['load ' fullfile(b,a) ' env xaxis Ncl']);
clear neck
for u = 1:Ncl,	
	neck(u) = min(abs(diff(env{u}(2:3,:))));
end

spk = cell(classtot,1);
ts = xaxis(1):xaxis(2);
clear spiketemp
spiketemp = spkraw(min(max((ts'*ones(1,length(st)))+(ones(length(ts),1)*st'),1),length(spkraw)));
temp3 = spiketemp;
temp4 = st;
[dummy,ind] = sort(neck);
for i = ind,
 i
 [temp1,spk{i},temp3,temp4] = windiscr(temp3,temp4,env{i});
 length(temp3)
end

Ws = temp3; Wt = temp4; Ss = Ws; St = Wt;
justin
classrefresh

