% function [r,tags,trialset,exptevents]=raster_load(mfile,channel,unit[1],options);
% 
% returns:
%  r - raster time X rep X stimid
%  tags - cell array with string describing each stimid
%  trialset - rep X stimid matrix that identifies the trial when r occurred
%
% valid options fields
%    .rasterfs [=1000]
%    .sigthreshold [=4]
%    .datause [='Both'] % ie, all data, targets and references
%    .lfp[=0]
%    .usesorted[=0]
%
function [r,tags,trialset,exptevents]=raster_load(mfile,channel,unit,options);

if ~exist('options','var'),
    options=[];
end
if ~exist('channel','var'),
    options.channel=1;
else 
     options.channel = channel;
end
if ~exist('unit','var'),
    options.unit=1;
else 
  options.unit = unit;
end
if ~isfield(options,'RejShock'),
    RejShock=0;
else
    RejShock = options.RejShock;
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
if ~isfield(options,'includeincorrect'),
    options.includeincorrect=0;
end
if isfield(options,'verbose')
  verbose = options.verbose;
else
  verbose =1;
end

rasterfs=options.rasterfs;
sigthreshold=options.sigthreshold;
datause=options.datause;
if options.lfp,
    % must calculate average ("psth"), since lfp doesn't give rasters
    options.psth=1;
end

if verbose 
  fprintf('Loading raster for channel %d (rasterfs %d, sigthresh %.1f)\n',...
        options.channel,rasterfs,sigthreshold);
else fprintf('%d ',channel); 
end
switch datause,
    case 'Ref Only',
        options.tag_masks={'Ref'};
    case 'Reference Only',
        options.tag_masks={'Ref'};
    case {'Target Only'},
        options.tag_masks={'Targ'};
    case {'Trial by trial'},
        options.tag_masks={'SPECIAL-TRIAL'};
    case {'Collapse reference'},
        options.tag_masks={'SPECIAL-COLLAPSE-REFERENCE'};
    case {'Collapse target'},
        options.tag_masks={'SPECIAL-COLLAPSE-TARGET'};
    case {'Collapse both'},
        options.tag_masks={'SPECIAL-COLLAPSE-BOTH'};
    case {'Collapse keep order','Collapse first ref'},
        options.tag_masks={'SPECIAL-COLLAPSE-ORDER'};
    case {'Collapse/split errors'},
        options.tag_masks={'SPECIAL-COLLAPSE-SPLIT'};
    case {'All licks'},
        options.tag_masks={'SPECIAL-LICK-ALL'};
    case {'First lick'},
        options.tag_masks={'SPECIAL-LICK-FIRST'};
    case {'Last lick'},
        options.tag_masks={'SPECIAL-LICK-LAST'};
    case {'Per trial'},
        options.tag_masks={'SPECIAL-TRIAL'};
    otherwise,
        % just pass on datause
        options.tag_masks={datause};
end

tic;

if isfield(options,'PreStimSilence'),
   options.includeprestim=[options.PreStimSilence options.PostStimSilence];
else
   options.includeprestim=1;  % try to figure it out automatically
end

if ~options.usesorted,
    if verbose disp('Loading EVP...'); end
    [r,tags,trialset,exptevents]=loadevpraster(mfile,options);
else
    disp('Loading spikes...');
    if isfield(options,'spikefile'),
       spkfile=options.spikefile;
    else
       [pp,bb,ee]=fileparts(mfile);
       spkfile=[pp filesep 'sorted' filesep bb '.spk.mat'];
    end
    options.psthonly=-1;
    [r,tags,trialset,exptevents]=loadspikeraster(spkfile,options);
end

if isfield(options,'MaxStimDuration'),
   
   postbins=round(options.PostStimSilence.*options.rasterfs);
   ss=sum(isnan(r(:,:,1)),1);
   if sum(abs(ss-mean(ss)))==0,
      % fixed duration stim, easy
      % don't do anything
   else
      for ii=1:(size(r,2)*size(r,3)),
         if sum(~isnan(r(:,ii)))>0 && isnan(r(end,ii)),
            maxnotnan=max(find(~isnan(r(:,ii))));
            r((end-postbins+1):end,ii)=r((maxnotnan-postbins+1):maxnotnan,ii);
            r((maxnotnan-postbins+1):(end-postbins+1),ii)=nan;
         end
      end
   end
   
   if size(r,1)>round((options.PreStimSilence+options.MaxStimDuration+...
                       options.PostStimSilence).*options.rasterfs);
      keeprange=[1:round((options.PreStimSilence+options.MaxStimDuration).*...
                         options.rasterfs) ...
                 (size(r,1)-round(options.PostStimSilence.*options.rasterfs)):size(r,1)];
      r=r(keeprange,:,:);
   end
end

if verbose fprintf('%s time: %.1f sec\n',mfilename,toc); end
