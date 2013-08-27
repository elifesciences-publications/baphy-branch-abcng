function dms_save_parms(var1,exptparams)

if ~isstruct(var1),
   % must be the name of the parmfile ... load it.
   mfile=var1;
   fprintf('loading parameter file %s\n',basename(mfile));
   LoadMFile(mfile);
else
   globalparams=var1;
end

disp('saving performance/parameter data to cellDB...');

% code morphed from Nima's PrepareDatabaseData
Parameters  = [];
Performance = [];
RefHandle = exptparams.TrialObject.ReferenceHandle;
if ~isempty(RefHandle)
   Parameters.Reference = '______________';
   Parameters.ReferenceClass = RefHandle.descriptor;
   field_names = RefHandle.UserDefinableFields;
   for cnt1 = 1:3:length(field_names)
      Parameters.(['Ref_' field_names{cnt1}]) = getfield(RefHandle, field_names{cnt1});
   end
end
TarHandle = exptparams.TrialObject.TargetHandle;
if ~isempty(TarHandle)
   Parameters.Target = '______________';
   Parameters.TargetClass = TarHandle.descriptor;
   field_names = TarHandle.UserDefinableFields;
   for cnt1 = 1:3:length(field_names)
      Parameters.(['Tar_' field_names{cnt1}]) = getfield(TarHandle, field_names{cnt1});
   end
end
field_names = fieldnames(Parameters);
for cnt1 = 1:length(field_names)
   if ischar(Parameters.(field_names{cnt1}))
      Parameters.(field_names{cnt1}) = strrep(Parameters.(field_names{cnt1}),'<','^<');
      Parameters.(field_names{cnt1}) = strrep(Parameters.(field_names{cnt1}),'>','^>');
   end
end

Parameters.NoLickSilence=exptparams.nolicksilence;
Parameters.Ref_Len_Mean=exptparams.refmean;
Parameters.Ref_Len_Std=exptparams.refstd;
Parameters.Trial_Len_Mean=exptparams.nolick;
Parameters.Trial_Len_Std=exptparams.nolickstd;
Parameters.Ref_Atten_Start=exptparams.dist_atten;
Parameters.Ref_Atten_Final=exptparams.dist_atten_final;
Parameters.Repeat_Single_Ref=exptparams.single_dist;
Parameters.Ref_After_Tar=exptparams.ref_after_target;
Parameters.Tar_Rep_Count=exptparams.targ_rep_count;
Parameters.Block_Size=exptparams.blocksize;
Parameters.RespWin_Start=exptparams.startwin;
Parameters.RespWin_Len=exptparams.respwin;
Parameters.PREward_Duration=exptparams.startrwdur;
Parameters.Reward_Duration=exptparams.rwdur;
Parameters.Punish_Atten=exptparams.punishvol;
Parameters.Punish_Timeout=exptparams.timeout;
Parameters.ITI=exptparams.isi;
Parameters.Cue_Trial_Count=exptparams.cuecount;
Parameters.Use_Lick=exptparams.use_lick;
Parameters.Use_Light=exptparams.use_light;
Parameters.Avg_Trial_Len=mean(exptparams.res(:,1));
Parameters.HWSetup=globalparams.HWSetup;
Parameters.Tar_Atten=exptparams.targ_atten;
Parameters.Overlay_Ref_Tar=exptparams.overlay_reftar;
Parameters.Use_Catch=exptparams.use_catch;

Parameters.jitter_db=exptparams.jitter_db;
Parameters.rwfrac=exptparams.rwfrac;
Parameters.tonecount=exptparams.tonecount;
%Parameters.targidx0=exptparams.targidx0;
% nolickstd/2 for uniform distribution
% nolickstd for gamma
%Parameters.freqs=exptparams.freqs;
%Parameters.freqe=exptparams.freqe;
%Parameters.toneamp=exptparams.toneamp;
%Parameters.modfreq=exptparams.modfreq;

dbWriteData(globalparams.rawid,Parameters,0,0);

tperf=[];
tperf.Ref_Rep_Count=exptparams.repcount;
tperf.Ref_Valid_Time=sum(exptparams.res((exptparams.res(:,2)==0),1));
tperf.trials=size(exptparams.res,1);
ccount=sum(exptparams.res(:,2)==0);
tperf.hit=ccount;
tperf.early=sum(exptparams.res(:,2)==1);
tperf.miss=sum(exptparams.res(:,2)==2);
tperf.snooze=sum(exptparams.res(:,2)==3);
tperf.water=exptparams.volreward;
dbWriteData(globalparams.rawid,tperf,1,0);
