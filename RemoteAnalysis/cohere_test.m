baphy_set_path
codepath='F:\Users\alphaomega\code\';
addpath([codepath,'chronux_1_1'],[codepath,'chronux_1_1/continuous'],...
        [codepath,'chronux_1_1/helper'],[codepath,'chronux_1_1/hybrid'],...
        [codepath,'chronux_1_1/pointbinned']);
 
h=1;
mset={'/auto/data/daq/Mercury/mer086/mer086b02_p_TOR.m',...
      '/auto/data/daq/Mercury/mer086/mer086b04_a_MTS.m'};
 
h=2;
mset={'/auto/data/daq/Mercury/mer086/mer086c02_a_TOR.m',...
      '/auto/data/daq/Mercury/mer086/mer086c03_a_MTS.m'};
 

channel=1;
tag_masks={'TORC'}
 
%lfp_spectrum(mset,channel,h,tag_masks,200);
 
%channels=[2 5 6 7];
channels=[2 5 6];
lfp_cohere(mset,channels,h,tag_masks,200);

mset={'W:\Sirius\sir202\sir202e04_a_PTD.m',...
      'W:\Sirius\sir202\sir202e06_p_PTD.m',...
      'W:\Sirius\sir202\sir202e07_a_PTD.m'};
options.h=figure;
options.channels=[3 5 6 7 8];
options.tag_masks={'Target'};
options.rasterfs=200;
options.startwin=0.1;
options.stopwin=1.1;

lfp_cohere(mset,options);

mset={'W:\Electra\ele070\ele070b02_p_TOR.m',...
      'W:\Electra\ele070\ele070b04_a_DMS.m',...
      'W:\Electra\ele070\ele070b06_p_TOR.m'};
options.h=figure;
options.channels=[1 2 3 4];
options.tag_masks={'TORC'};
options.rasterfs=200;
options.startwin=0.1;
options.stopwin=0.6;

lfp_cohere(mset,options);

mset={'W:\Electra\ele070\ele070c03_a_DMS.m',...
      'W:\Electra\ele070\ele070c07_p_TOR.m',...
      'W:\Electra\ele070\ele070c09_a_DMS.m'};
options.h=figure;
.2
options.channels=[1 2 3 4];
options.tag_masks={'TORC'};
options.rasterfs=200;
options.startwin=0.1;
options.stopwin=0.6;

lfp_cohere(mset,options);






codepath='F:\Users\alphaomega\code\';
addpath([codepath,'chronux_1_1'],[codepath,'chronux_1_1/continuous'],...
        [codepath,'chronux_1_1/helper'],[codepath,'chronux_1_1/hybrid'],...
        [codepath,'chronux_1_1/pointbinned']);

mset={'W:\Mercury\mer119\mer119a03_a_TOR.m',...
      'W:\Mercury\mer119\mer119a05_a_MTS.m',...
      'W:\Mercury\mer119\mer119a06_a_TOR.m'};
%       'W:\Mercury\mer120\mer120b06_a_MTS.m',...
%       'W:\Mercury\mer120\mer120b07_a_TST.m'};
options.h=figure;
drawnow;
options.channels=[1 2 3 4];
%options.tag_masks={'SPECIAL-COLLAPSE-REFERENCE'};
options.tag_masks={'TORC'};
options.rasterfs=200;
options.startwin=0.0;
options.stopwin=0.5;

lfp_cohere(mset,options);




mset={'W:\Electra\ele072\ele072a03_p_TOR.m',...
      'W:\Electra\ele072\ele072a07_a_DMS.m',...
      'W:\Electra\ele072\ele072a13_a_DMS.m',...
      'W:\Electra\ele072\ele072a19_a_DMS.m',...
      'W:\Electra\ele072\ele072a21_p_TOR.m'};
options.h=figure;
options.channels=[1 2 3 4];
options.tag_masks={'TORC'};
options.rasterfs=200;
options.startwin=0.1;
options.stopwin=0.6;

lfp_cohere(mset,options);

mset={'W:\Persephone\per020\per020a04_a_TOR.m',...
      'W:\Persephone\per020\per020a05_a_PTD.m',...
      'W:\Persephone\per020\per020a07_a_TOR.m',...
      'W:\Persephone\per020\per020a08_a_PTD.m'};
options.h=figure;
options.channels=[1 2 3 4];
options.tag_masks={'TORC'};
options.rasterfs=200;
options.startwin=0.1;
options.stopwin=1.0;

lfp_cohere(mset,options);



