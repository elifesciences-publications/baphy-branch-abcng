% Import pre-sorted spikes

%[a,b] = uigetfile(['*' direc '_' fname '.spk.mat'],'Import File...');


[a,b] = uigetfile(['*.spk.mat'],'Import File...');
ind =findstr(a,'.spk.mat');
af=a(1:ind-1);
if af == fname
    clear st spiketemp 
    [Ws, Wt, Ss, St, st, spiketemp, spktemp]=importfile_new(a,b,ts,spkraw,classtot,str2num(chanNum), REGORDER1);
    spk(:,1)=spktemp;
elseif af ==f2name
    clear st2 spiketemp2 
    [Ws2, Wt2, Ss2, St2, st2, spiketemp2,spktemp]=importfile(a,b,ts,spkraw2, classtot,str2num(chanNum),REGORDER2 );
    spk(:,2)=spktemp;
end
meska
classrefresh