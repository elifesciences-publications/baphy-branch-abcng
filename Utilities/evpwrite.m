% function evpwrite(filename,spikedata,auxdata,fs,fsaux,lfpdata,fslfp);
%
% write/append EVP V4 file
%
% spikedata should be a sample X channel matrix for a single trial
% auxdata is auxsamples X auxchannels matrix for same trial
%
% fs and faux and fslfp should be supplied the first time to store sampling
%   rate for spike and aux data, respectively, in the main evp header
% 
% EVP V4: if not supplied, lfpdata=[] and fslfp=0 for backward compatibility
%
% error if number of spike, aux, or lfp channels doesn't match header
% when trying to append existing file
% 
% created SVD 2005-11-07
% modified SVD 2006-08-01 : EVP V4 includes optional LFP data
%
function evpwrite(filename,spikedata,auxdata,fs,fsaux,lfpdata,fslfp);

if isempty(filename),
    disp('not saving evp data');
    return
end

EVPVERSION=4;

if ~exist('lfpdata','var'),
    lfpdata=[];
    fslfp=0;
end

[spikesampcount,spikechancount]=size(spikedata);
[auxsampcount,auxchancount]=size(auxdata);
[lfpsampcount,lfpchancount]=size(lfpdata);

if ~exist(filename,'file'),
   drawnow;
   checkone=1;
else
   checkone=0;
end
if checkone && ~exist(filename,'file'),
   if exist('trialnumber','var') & trialnumber>1,
      error('first trial must be numbered 1');
   else
      trialnumber=1;
   end
   if ~exist('fsaux','var'),
      error('New evp: must specify fs and fsaux');
   end
   
   % new file: create main header
   [fid,sError]=fopen(filename,'w','l');
   disp(['Creating file ',filename,'... ',sError]);
   
   % save parms ... start with two 0's to identify it as small format
   header=[EVPVERSION spikechancount auxchancount fs fsaux 0 ...
       lfpchancount fslfp 0 0];
   count=fwrite(fid,header(1:7),'uint32');
   count=fwrite(fid,header(8:10),'single');
else
   [fid,sError]=fopen(filename,'r+','l');
   header=fread(fid,10,'uint32');
   if length(header)<10 | header(1)~=EVPVERSION | sum(header(9:10))>0,
       if header(1)==3,
           evpwrite3(filename,spikedata,auxdata,fs,fsaux);
           return
       else
          error('incorrect evp version');
       end
   end
   if header(2)~=spikechancount,
      error('spike channel count mismatch');
   end
   if header(3)~=auxchancount,
      error('aux channel count mismatch');
   end
   if header(7)~=lfpchancount
     if sum(abs(lfpdata))==0 lfpdata =  zeros(1,lfpchancount);
     else
      error('LFP channel count mismatch');
     end
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
           trhead=fread(fid,3,'uint32');
           %     jump to start of next trial
           fseek(fid,(trhead(1)*spikechancount+trhead(2)*auxchancount+...
               trhead(3)*lfpchancount)*2,0);
       end
   end
end

% write trial header
hcount=fwrite(fid,[spikesampcount auxsampcount lfpsampcount],'uint32');
scount=0;
acount=0;
lcount=0;
for ii=1:spikechancount,
   scount=fwrite(fid,spikedata(:,ii),'short');
end
for ii=1:auxchancount,
   acount=fwrite(fid,auxdata(:,ii),'short');
end
for ii=1:lfpchancount,
   lcount=fwrite(fid,lfpdata(:,ii),'short');
end

fseek(fid,0,-1);  % go to beginning of file
header(6)=trialnumber;
count=fwrite(fid,header(1:7),'uint32');
fclose(fid);

fprintf('wrote trial %d, %d X %d spike, %d X %d aux, %d X %d lfp samples\n',...
        trialnumber,scount,spikechancount,acount,auxchancount,...
        lcount,lfpchancount);
