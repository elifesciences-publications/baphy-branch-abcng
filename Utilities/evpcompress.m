% function gzevpfile=evpcompress(evpfile);
%
% gzip an evp file but save header information in temp directory
% first to speed up header checks.
%
% created SSVD 2009-01-19
%
function gzevpfile=evpcompress(evpfile)

global BAPHY_LAB

% adding evp extension if not there
if ~exist(evpfile,'file') && ~strcmpi(evpfile(end-3:end),'.evp'),
   evpfile=[evpfile '.evp'];
end

gzevpfile=[evpfile,'.gz'];
if exist(gzevpfile,'file')
   disp('zipped file already exists. skipping');
   return
end

% save header
[bb,pp]=basename(evpfile);
if ~exist([pp 'tmp'],'dir'),
   mkdir(pp,'tmp');
end
hfilename=[pp 'tmp' filesep bb '.head'];

[pp,bb,ee]=fileparts(evpfile);
bbpref=strsep(bb,'_');
bbpref=bbpref{1};
checkrawevp=[pp filesep 'raw' filesep bbpref filesep bb '.001.1' ee];
if exist(checkrawevp,'file'),
  evpfile=checkrawevp;
end

if ~exist(evpfile,'file')
   warning('evp file not found.');
   return
end

EVPVersion=evpversion(evpfile);
[spikechancount,auxchancount,trialcount,spikefs,auxfs,lfpchancount,lfpfs]=evpgetinfo(evpfile);

% save OLD version header even for evp version 5!
if EVPVersion>=5,
   disp('saving header data in pre evp version 5 format');
end
header3=[EVPVersion spikechancount auxchancount spikefs auxfs trialcount lfpchancount lfpfs 0 0];

%[fid,sError]=fopen(evpfile,'r','l');
%header3=fread(fid,10,'uint32');
%fclose(fid);

[fid,sError]=fopen(hfilename,'w','l');
%fwrite(fid,header3,'uint32');
fwrite(fid,header3(1:7),'uint32');
fwrite(fid,header3(8:10),'single');
fclose(fid);

sigthreshold=4;
if 0,
    disp('skipping evpcompress');
elseif spikechancount>0,
  fprintf('pre-caching sigma threshold events for %d channels.\n',spikechancount);
  for channel=1:spikechancount,
    if spikechancount<=8,
      cachefile=cacheevpspikes(evpfile,channel,sigthreshold,2);
    elseif strcmpi(BAPHY_LAB,'lbhb'),
      % also cache with threshold of 3.7 for array recordings.
      cachefile=cacheevpspikes(evpfile,channel,unique([sigthreshold -4 4 -3.8 3.8 -3.5 3.5]));
    else
      % also cache with threshold of 3.7 for array recordings.
      cachefile=cacheevpspikes(evpfile,channel,unique([sigthreshold 4 3.7]));
    end
  end
else
  % maybe this is evp version 5? check for evps in raw directory:
  [pp,bb,ee]=fileparts(evpfile);
  rawevp=[pp filesep 'raw' filesep bb '.001.*.evp'];
  dd=dir(rawevp);
  ok=zeros(length(dd),1);
  for ii=1:length(dd),
    if isempty(findstr(dd(ii).name,'.mean.')),
      ok(ii)=1;
    end
  end
  dd=dd(find(ok));
  spikechancount=length(dd);
  fprintf('pre-caching sigma threshold events for %d channels (in raw).\n',spikechancount);
  for channel=1:spikechancount,
    revp=[pp filesep 'raw' filesep dd(1).name];
    cachefile=cacheevpspikes(revp,channel,sigthreshold,2);
  end
  
end

gzip(evpfile);
