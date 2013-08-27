cd c:\data\matt\converted_data

%parmfiles={'Mouse124_2013_04_03_TOR_3','Mouse124_2013_04_03_PTD_4','Mouse124_2013_04_03_PTD_5'};
parmfiles={'Mouse126_2013_04_02_TOR_3','Mouse126_2013_04_02_PTD_4','Mouse126_2013_04_02_PTD_5'};


options=struct;
options.channel=2;
options.rasterfs=1000;
options.lfp=1;
%options.trialrange=1:;   % all trials by default
options.includeincorrect=1;  % zero by default
options.includeprestim=1;

r=loadevpraster(parmfiles{1},options);

figure;
plot(nanmean(r(:,:),2));
title('average response to all torcs');



LoadMFile(parmfiles{1});
options.includeprestim=0;
rtorc=loadevpraster(parmfiles{1},options);
TorcObject=exptparams.TrialObject.ReferenceHandle;
includefirsttorccycle=0;
[strfest,snr,StimParam]=strf_est_core(r,TorcObject,options.rasterfs,includefirsttorccycle);
stplot(strfest,StimParam.lfreq,StimParam.basep,1,StimParam.octaves);