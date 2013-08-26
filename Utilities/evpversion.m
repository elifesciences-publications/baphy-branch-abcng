% function ver=evpversion(filename);
%
% displays evp file version
% 1=oldest
% 2=new daqpc
% 3=baphy
% 4=baphy with LFP support
% 5=MANTA
%
% returns -1 if file not found
%
% created SVD 2006-01-12
%
function ver=evpversion(filename,allowremap);

if ~exist('allowremap','var'),
    allowremap=1;
end

if allowremap,
    [pp,bb,ee]=fileparts(filename);
    bbpref=strsep(bb,'_');
    bbpref=bbpref{1};
    checkrawevp=[pp filesep 'raw' filesep bbpref filesep bb '.001.1' ee];
    if exist(checkrawevp,'file'),
        filename=checkrawevp;
    end
    checktgzevp=[pp filesep 'raw' filesep bbpref '.tgz'];
    if exist(checktgzevp,'file'),
        filename=checktgzevp;
    end
end

% adding evp extension if not there
if strcmpi(filename(end-3:end),'.tgz'),
   [bb,pp]=basename(filename);
   hfilename=[strrep(pp,'raw','tmp') strrep(bb,'.tgz','*.evp.head')];
   dd=dir(hfilename);
   if ~isempty(dd),
      hfilename=[strrep(pp,'raw','tmp') dd(1).name];
      filename=hfilename;
   else
      filename=evpmakelocal(filename);
   end
elseif ~strcmpi(filename(end-3:end),'.evp'),
    filename=[filename '.evp'];
end

if ~exist(filename,'file'),
   [bb,pp]=basename(filename);
   hfilename=[pp 'tmp' filesep bb '.head'];
   if ~exist(hfilename,'file'),
      if exist([filename,'.gz'],'file'),
         filename=evpmakelocal(filename);
      end
   else
      filename=hfilename;
   end
end

[fid,sError]=fopen(filename,'r','l');

if fid<1,
    warning('file not found');
    ver=-1;
    return
end

header3=fread(fid,10,'uint32');
fclose(fid);

[fid,sError]=fopen(filename,'r','b');
header2=fread(fid,1,'int');
doffset = fread(fid, 4, 'long');
fclose(fid);

%v3:
%   header=[EVPVERSION spikechancount auxchancount fs fsaux 0 ...
%          0 0 0 0];
%v2 header=[# chans] (1 or 2 always?)
%v1: other
if header3(1)==5,
    ver=5;
elseif header3(1)==4 & sum(abs(header3(9:10)))==0,
    ver=4;
elseif header3(1)==3 & sum(abs(header3(7:10)))==0,
    ver=3;
elseif ismember(header2(1),[1 2 3 4]),
    ver=2;
else
    ver=1;
end

