

spikefile='/auto/data/daq/Oyster/oys010/sorted/oys010b04_p_RDT.spk.mat';
parmfile='/auto/data/daq/Oyster/oys010/oys010b04_p_RDT.m';

options.rasterfs=100;
options.channel=3;
options.unit=1;

[r,params]=load_RDT_by_trial(parmfile,spikefile); 

figure; plot(squeeze(params.r_avg(:,10,:))); legend('ref','tar');
figure; plot(squeeze(params.r_avg(:,11,:))); legend('ref','tar');
figure; plot(squeeze(params.r_avg(:,12,:))); legend('ref','tar');
