% function evpwrite(filename,spikedata,auxdata,fs,fsaux);
%
% write/append EVP V3 file
%
% spikedata should be a sample X channel matrix for a single trial
% auxdata is auxsamples X auxchannels matrix for same trial
%
% fs and faux should be supplied the first time to store sampling
%   rate for spike and aux data, respectively, in the main evp header
% 
% error if number of spike or aux channels doesn't match header
% when trying to append existing file
% 
% created SVD 2005-11-07
%
function evpwrite(filename,spikedata,auxdata,fs,fsaux,trialnumber);

if isempty(filename),
    disp('not saving evp data');
    return
end

EVPVERSION=3;

[spikesampcount,spikechancount]=size(spikedata);
[auxsampcount,auxchancount]=size(auxdata);

if ~exist(filename,'file'),
   if exist('trialnumber','var') & trialnumber>1,
      error('first trial must be numbered 1');
   else
      trialnumber=1;
   end
   if ~exist('fsaux','var'),
      error('must specify fs and fsaux');
   end
   
   % new file: create main header
   [fid,sError]=fopen(filename,'w','l');
   disp(['Creating file ',filename,'... ',sError]);
   
   % save parms ... start with two 0's to identify it as small format
   header=[EVPVERSION spikechancount auxchancount fs fsaux 0 ...
          0 0 0 0];
   count=fwrite(fid,header,'uint32');
   
else
   [fid,sError]=fopen(filename,'r+','l');
   header=fread(fid,10,'uint32');
   if length(header)<10 | header(1)~=EVPVERSION | sum(header(7:10))>0,
      error('incorrect evp version');
   end
   if header(2)~=spikechancount,
      error('spike channel count mismatch');
   end
   if header(3)~=auxchancount,
      error('aux channel count mismatch');
   end
   trialcount0=header(6);
   if ~exist('trialnumber','var'),
      trialnumber=trialcount0+1;
   elseif trialnumber~=trialcount0+1,
      error('trial number mismatch');
   end
   
   if 1, % QUICK MODE
       fseek(fid,0,1); % go to end of file
   else
       % step through every trial
       for tt=1:trialcount0,
           trhead=fread(fid,2,'uint32');
           %     jump to start of next trial
           fseek(fid,(trhead(1)*spikechancount+trhead(2)*auxchancount)*2,0);
       end
   end
end

% write trial header
hcount=fwrite(fid,[spikesampcount auxsampcount],'uint32');
scount=0;
acount=0;
for ii=1:spikechancount,
   scount=fwrite(fid,spikedata(:,ii),'short');
end
for ii=1:auxchancount,
   acount=fwrite(fid,auxdata(:,ii),'short');
end

fseek(fid,0,-1);  % go to beginning of file
header(6)=trialnumber;
count=fwrite(fid,header,'uint32');
fclose(fid);
fprintf('wrote trial %d, %d X %d spike shorts, %d X %d aux shorts\n',...
        trialnumber,scount,spikechancount,acount,auxchancount);
