% function raster_online(mfile,channel,unit[1],h,options);
% 
% h - handle of figure where plot should be displayed(default, new figure)
%
% valid options fields
%    .rasterfs [=1000]
%    .sigthreshold [=4]
%    .datause [='Both'] % ie, all data, targets and references
%
function raster_online(mfile,channel,unit,h,options)

if ~exist('channel','var'),
    channel=1;
end
if ~exist('unit','var'),
    unit=1;
end
if ~exist('h','var'),
    h=figure;
    drawnow;
end
if ~exist('options','var'),
    options=[];
end
options.channel=channel;

fprintf('raster_online: Analyzing channel %d\n',channel);

if ~isempty(strfind(mfile,'DMS')),
    options.PreStimSilence=0.35;
    options.PostStimSilence=0.35;
elseif ~isempty(strfind(mfile,'MTS')),
    options.PreStimSilence=0.1;
    options.PostStimSilence=1;
end
% integrate this into gui someday:
%options.includeincorrect=1

[r,tags]=raster_load(mfile,channel,unit,options);

if ~isempty(strfind(mfile,'DMS')),
   %keyboard
end

raster_plot(mfile,r,tags,h,options);

