% function [r,PreStimSilence,PostStimSilence]=get_raster(mfile,channel,unit[1],options);
% 
% valid options fields
%    .rasterfs [=1000]
%    .sigthreshold [=4]
%    .datause [='Both'] % ie, all data, targets and references
%    .lfp[=0]
%    .usesorted[=0]
%
function [r,PreStimSilence,PostStimSilence]=...
    get_raster(mfile,channel,unit,options);

if ~exist('channel','var'),
    channel=1;
end
if ~exist('unit','var'),
    unit=1;
end
if ~exist('options','var'),
    options=[];
end
if ~isfield(options,'rasterfs'),
    options.rasterfs=1000;
end
if ~isfield(options,'sigthreshold'),
    options.sigthreshold=4;
end
if ~isfield(options,'datause'),
    options.datause='Both';
end
if ~isfield(options,'psth'),
    options.psth=0;
end
if ~isfield(options,'psthfs'),
    options.psthfs=20;
end
if ~isfield(options,'lfp'),
    options.lfp=0;
end
if ~isfield(options,'usesorted'),
    options.usesorted=0;
end

rasterfs=options.rasterfs;
sigthreshold=options.sigthreshold;
datause=options.datause;
if options.lfp,
    % must calculate average ("psth"), since lfp doesn't give rasters
    options.psth=1;
end

fprintf('Loading raster for channel %d (rasterfs %d, sigthresh %.1f)\n',...
        channel,rasterfs,sigthreshold);

switch datause,
    case 'Reference Only',
        tag_mask={'Reference'};
    case {'Target Only'},
        tag_mask={'Target'};
    case {'Collapse reference'},
        tag_mask={'SPECIAL-COLLAPSE-REFERENCE'};
    case {'Collapse target'},
        tag_mask={'SPECIAL-COLLAPSE-TARGET'};
    case {'Collapse both'},
        tag_mask={'SPECIAL-COLLAPSE-BOTH'};
    case {'All licks'},
        tag_mask={'SPECIAL-LICK-ALL'};
    case {'Last lick'},
        tag_mask={'SPECIAL-LICK-LAST'};
    otherwise,
        % do nothing
        tag_mask={};
end

tic;
if ~options.usesorted,
    disp('Loading EVP...');
    [r, tags,PreStimSilence,PostStimSilence]=loadevpraster(mfile,channel,rasterfs,sigthreshold,...
                            1,tag_mask,options.lfp);
else
    disp('Loading spikes...');
    [pp,bb,ee]=fileparts(mfile);
    
    spkfile=[pp filesep 'sorted' filesep bb '.spk.mat'];
    [r,tags,PreStimSilence,PostStimSilence]=loadspikeraster(spkfile,channel,unit,rasterfs,1,tag_mask,-1);
end

toc

