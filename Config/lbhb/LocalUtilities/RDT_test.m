

spikefile='/auto/data/daq/Oyster/oys017/sorted/oys017b03_p_RDT.spk.mat';
parmfile='/auto/data/daq/Oyster/oys017/oys017b03_p_RDT.m';

spikefile='/auto/data/daq/Oyster/oys017/sorted/oys017b04_a_RDT.spk.mat';
parmfile='/auto/data/daq/Oyster/oys017/oys017b04_a_RDT.m';

options.rasterfs=40;
options.channel=1;
options.unit=1;

[r,params]=load_RDT_by_trial(parmfile,spikefile,options); 

for ii=1:3,
    targetidx=params.TargetIdx(ii);
    figure; 
    plot(squeeze(params.r_avg(:,targetidx,:))); 
    legend('ref','tar');
    title(sprintf('%s cell %d-%d targetid: %d',...
                  basename(parmfile),options.channel,options.unit,...
                  targetidx),'Interpreter','none');
end

