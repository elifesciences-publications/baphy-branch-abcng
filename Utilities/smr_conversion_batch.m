% smrbatch

addpath /auto/data/code/son_Spike2_Matlab

triggerchannel=23;
pumpchannel=22;
lickchannel=21;
walkchannels=17:18;
datachannels=[7 20];
auxchannels=[lickchannel pumpchannel walkchannels];

smrpath='/auto/data/daq/McGinley/smr2/';
cd (smrpath);
cd evp

% not automated: 
% 1. generate siteid,
% 2. create path /auto/data/daq/McGinley/mcg<DATE>/
% 3. copy evp and parmfiles to that path.

parmfiles={'Mouse167_2013_10_23_TOR_9_cell1.m'};
smrfile=[smrpath '10_23_13_Mouse167_whole_cell1_5TORCs_some_silence_NICE_Vm_and_sound_response.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={'Mouse167_2013_10_24_TOR_5','Mous167_2013_10_24_TOR_6'};
smrfile=[smrpath '10_24_13_Mouse167_whole_cell2_5TORCs_all_TORCs_silence_Rm_excellent.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={'Mouse160_2013_11_25_TOR_1'};
smrfile=[smrpath 'Mouse160_11_25/11_25_13_Mouse160_whole_cell_long_low_Rs_silence_torcset_steps.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);



return

siteids={'mcg002a','mcg003a','mcg004a','mcg005a','mcg006a',...
         'mcg007a','mcg008a','mcg009a','mcg010a','mcg011a',...
         'mcg012a','mcg013a','mcg014a','mcg015a','mcg016a',...
         'mcg017a'};
sds={'mcg2013_04_29','mcg2013_04_30','mcg2013_05_01','mcg2013_05_03',...
     'mcg2013_05_06','mcg2013_05_07','mcg2013_06_04','mcg2013_06_05',...
     'mcg2013_06_07','mcg2013_10_23','mcg2013_10_24','mcg2013_11_25',...
    };

jj=12;
siteid=siteids{jj};
sd=sds{jj};
pth=['/auto/data/daq/McGinley/' sd '/']
dd=dir([pth '*.evp']);
for ii=1:length(dd),
    evpfile=[pth,dd(ii).name];
    parmfile=strrep(evpfile,'.evp','.m');
    dbManualAddRaw(siteid,parmfile,evpfile);
end

%
% Below here is old (out of date?)
%
addpath h:\code\Son_Spike2_Matlab\
baphy_set_path

triggerchannel=23;
pumpchannel=22;
lickchannel=21;
walkchannels=17:18;
datachannels=[7 20];
auxchannels=[lickchannel pumpchannel walkchannels];

smrpath='h:\daq\McGinley\smr2\';
cd (smrpath);
cd evp

parmfiles={'Mouse167_2013_10_24_TOR_5','Mous167_2013_10_24_TOR_6'};
smrfile=[smrpath '10_24_13_Mouse167_whole_cell2_5TORCs_all_TORCs_silence_Rm_excellent.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);





smrpath='g:\Work_computer_backups\Recording_rig\Recordings\';
cd g:\Work_computer_backups\Recording_rig\baphy_evp_analysis\


parmfiles={'Mouse126_2013_04_03_TOR_6','Mouse126_2013_04_03_PTD_7'};
smrfile=[smrpath '04_03_13_mouse_126_pre_passive_task_whole_cell_rambunctious_performance_no_sound_file.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={'Mouse124_2013_04_02_TOR_7','Mouse124_2013_04_02_PTD_8'};
smrfile=[smrpath '04_02_13_mouse_124_pre_passive_task_whole_cell_performance_late_in experiment_sound5.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={'Mouse119_2013_04_05_TOR_1','Mouse119_2013_04_05_PTD_2'};
smrfile=[smrpath '04_05_13_mouse_119_pre_passive_task_whole_cell_short_then_LFP_MUA__amazing_performance_stopped_short_sound1.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={'Mouse126_2013_04_04_TOR_4','Mouse126_2013_04_04_PTD_5'};
smrfile=[smrpath '04_04_13_mouse_126_pre_passive_task_whole_cell_performance_sound3.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={'Mouse124_2013_04_03_TOR_3','Mouse124_2013_04_03_PTD_4','Mouse124_2013_04_03_PTD_5'};
smrfile=[smrpath '04_03_13_mouse_124_pre_passive_task_whole_cell_almost_no_performance.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath '04_03_13_mouse_124_pre_passive_LFP_huge_no_sound_file.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={'Mouse126_2013_04_02_TOR_3','Mouse126_2013_04_02_PTD_4','Mouse126_2013_04_02_PTD_5'};
smrfile=[smrpath '04_02_13_mouse_126_pre_passive_task_whole_cell_a_little_performance.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath '03_29_13_mouse_121_whole_cell_pre_passive__lost_from_walking_sound3.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);


parmfiles={};
smrfile=[smrpath '03_29_13_mouse_123_dendrite_task_not_performing_weird_recording_sound2.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath '03_29_13_mouse_123_dendrite_pre_passive_sound1.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath '03_28_13_mouse_121_pre_passive_and_task_not performing_extracell_sound3.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath '03_28_13_mouse_121_task_whole_cell_not_performing_short_sound2.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath '03_26_13_mouse_130_extracell_unit_TORCs_16_channel_sound2.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath '03_28_13_mouse_123_task_whole_cell_not_performing.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath '03_28_13_mouse_123_task_whole_cell_not_performing(sound_issue_early).smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath '03_26_13_mouse_130_whole_cell_short_dendrite_TORCs_16_channel_sound1.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);


parmfiles={};
smrfile=[smrpath 'mouse122_pre_passive_sound1.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath 'mouse122_task_some_units_nice_LFP_sound2.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath 'mouse122_post_passive_sound3.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath 'mouse125_task_some_units&LFP_sound4.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath 'mouse125_pre-passive_sound3.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath 'mouse122_pre_passive_task_and_post_passive_swatting_sound2.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath 'mouse125_post_passive_sound3.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={};
smrfile=[smrpath 'mouse125_task_and_start_of_post_passive_sound2.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);



%%These are the one I emailed you about

parmfiles={'mouse125_2013_03_11_TOR_14'};
smrfile=[smrpath 'mouse125_passive_sound1.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={'Mouse109_2012_12_21_PTD_61'};
smrfile=[smrpath '12_21_12_mouse_109_16-ch_A1_UNIT_behavior_baphy61_sound2.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

parmfiles={'Mouse119_2013_03_08_TOR_1'};
smrfile=[smrpath '03_08_13_mouse_129_16_CHAN_TETRODE_cortex_16_chan_laminar_hippocampus_UNIT_with_TORCs.smr'];
evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

%%This is end of the ones I emailed about


03_08_13_mouse_129_16_CHAN_TETRODE_cortex_16_chan_laminar_hippocampus_UNIT!
12_21_12_mouse_115_16-ch_A1_WHOLE_CELL_behavior_baphy58_sound3
08_02_12_mouse_86_16_channel_A1_LFP_states4
08_02_12_mouse_86_16_channel_A1_LFP_states2
08_02_12_mouse_86_16_channel_A1_LFP_states1
08_16_12_mouse_90_16_ch_A1_LFP2_tones_silence_nice_LFP
08_02_12_mouse_86_16_channel_walking_states
07_18_12_mouse_71_whole_cell_tuned_hippocampus1a
05_01_12_mouse_62_1.6_hippo_A1_LFPs_tones_nice_responses_and_theta
12_21_12_mouse_115_16-ch_A1_WHOLE_CELL_behavior_baphy58_sound3

12_20_12_mouse_115_dual16_task…
12_19_12_mouse_109_dual16_task…
12_18_12_mouse_108_dual16_task…
12_12_12_mouse_107_dual16_1_GREAT_but_move_artifact…
08_10_12_mouse_88_whole_cell1_K_TORCs_Iclamp
08_17_12_mouse_91_16_ch_A1_whole_cell_good_Vm
08_10_12_mouse_88_whole_cell2_K_TORCs_VandI
05_28_12_mouse_69_IC_5MOhm_good_tone_LFP_UNITS_movement_loc2
03_02_12_mouse_54_location2_whole_cell_TUNED!!!_I_and_V_clamp
03_02_12_mouse_54_location1_LFP_tuned_movement_highFoscill_no_sound_period_EXCELLENT
08_01_12_mouse_77_16_whole_cell_16_channel

08_15_12_mouse_89_16_ch_A1_LFP_okay
07_19_12_mouse_72_whole_cell_tuned_hippocampus_nice_short
08_17_12_mouse_91_16_ch_A1_whole_cell2_good_Vm

