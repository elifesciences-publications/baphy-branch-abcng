%function evpfiles=smr2evp(,smrfile,triggerchannel,datachannels,auxchannels);
%
%
function evpfiles=smr2evp(parmfiles,smrfile,triggerchannel,datachannels,auxchannels);

dataFsOut=20000;
lfpFsOut=2000;
auxFsOut=1000;
baphyfilecount=length(parmfiles);
evpfiles={};
filesexist=0;
TrialCount=zeros(baphyfilecount,1);
for baphyidx=1:baphyfilecount,
   % don't really need much information from the parameter file to do the
   % conversion.  Just the number of trials.
   LoadMFile(parmfiles{baphyidx});
   TrialCount(baphyidx)=globalparams.rawfilecount;
   
   % check to see if output evp files already exist
   evpfiles{baphyidx}=[strrep(parmfiles{baphyidx},'.m','') '.evp'];
   if exist(evpfiles{baphyidx},'file'),
      filesexist=filesexist+1;
   end
end
if filesexist,
   disp('evp file(s) already exist for this data set. skipping. delete evp files to regenerate.');
   return
end
   
figure(1);
drawnow

%% Read from smr file
fprintf('opening %s\n',smrfile);

fid=fopen(smrfile);

fprintf('loading trigger channel\n');
[triggerdata,triggerhdr]=SONGetChannel(fid,triggerchannel);

triggerthreshold=27000;
triggerdata(triggerdata<triggerthreshold)=0;
triggerdata(triggerdata>=triggerthreshold)=1;
triggerbins=find(diff(triggerdata)>0);
triggeroffbins=find(diff(triggerdata)<0);

triggertimes=triggerbins.*triggerhdr.sampleinterval;
triggerofftimes=triggeroffbins.*triggerhdr.sampleinterval;
clear triggerdata

firsttriggertime=triggertimes(1)-0.5;
triggertimes=triggertimes-firsttriggertime;
triggerofftimes=triggerofftimes-firsttriggertime;

% load data channels. don't resample yet.  Leave in native integer format
% to conserve memory.  Also to save some memory, trim all data in traces before
% baphy actually began.
datachannelcount=length(datachannels);
data=cell(datachannelcount,1);
dataFs=zeros(datachannelcount,1);

for ddidx=1:length(datachannels),
   fprintf('loading data channel %d\n',ddidx);
   [data{ddidx},datahdr]=SONGetChannel(fid,datachannels(ddidx));
   firstdatabin=round(firsttriggertime./datahdr.sampleinterval);
   fprintf('trimming %d/%d bins prior to first baphy trigger\n',...
      firstdatabin,length(data{ddidx}));
   data{ddidx}=data{ddidx}(firstdatabin:end);
   dataFs(ddidx)=1./datahdr.sampleinterval;
end

% load auxchannels, resample to auxFsOut
auxchannelcount=length(auxchannels);
aux=cell(auxchannelcount,1);
auxFs=zeros(auxchannelcount,1);

for ddidx=1:length(auxchannels),
   fprintf('loading aux channel %d\n',ddidx);
   [taux,auxhdr]=SONGetChannel(fid,auxchannels(ddidx));
   taux=single(taux);
   firstauxbin=round(firsttriggertime./auxhdr.sampleinterval);
   fprintf('trimming %d/%d bins prior to acquisition\n',firstauxbin,...
      length(taux));
   taux=taux(firstauxbin:end);
   newinterval=1./auxFsOut;
   maxt=length(taux).*auxhdr.sampleinterval;
   t2=single((0:newinterval:maxt)./auxhdr.sampleinterval);
   aux{ddidx}=interp1(taux,t2,'nearest');
   auxFs(ddidx)=auxFsOut;
end

fclose(fid);

%% Output to evp files

% trigger counter.  This is a kludge.  Assume there are exactly the number
% of recorded triggers as in the baphy parameter files and that the baphy
% parm files are in the order that the data was collected
lasttrigger=0;
for baphyidx=1:baphyfilecount,
   lasttrigger
   for trialidx=1:TrialCount(baphyidx),
      fprintf('%s trial %d ',basename(parmfiles{baphyidx}),trialidx);
      lasttrigger=lasttrigger+1;
      r=[];
      rlfp=[];
      raux=[];
      for ddidx=1:length(dataFs),
         startbin=round((triggertimes(lasttrigger)-0.1).*dataFs(ddidx));
         stopbin=round((triggerofftimes(lasttrigger)+0.1).*dataFs(ddidx));
         trialbins=stopbin-startbin+1;
         
         tr=double(data{ddidx}(startbin+(1:trialbins))');
         tr=resample(tr,dataFsOut,round(dataFs(ddidx)));
         tr=tr(round(0.1*dataFsOut+1):(end-round(0.1.*dataFsOut)));
         tlfp=resample(medfilt1(tr,300),lfpFsOut,dataFsOut);

         % trim stray mistmatched bins due to resampling from different
         % dataFs values.
         if size(r,1)>length(tr),
            r=r(1:length(tr),:);
         end
         r=[r tr];
         if size(rlfp,1)>length(tlfp),
            rlfp=rlfp(1:length(tlfp));
         end
         rlfp=[rlfp tlfp];
         fprintf('.');
      end
      for ddidx=1:length(auxFs),
         startbin=round(triggertimes(lasttrigger).*auxFs(ddidx));
         stopbin=round(triggerofftimes(lasttrigger).*auxFs(ddidx));
         trialbins=stopbin-startbin+1;
         
         tr=double(aux{ddidx}(startbin+(1:trialbins))');
         raux=[raux tr];
         fprintf('.');
      end
      
      sfigure(1);
      clf
      subplot(3,1,1);
      plot(r);
      subplot(3,1,2);
      plot(rlfp);
      subplot(3,1,3);
      plot(raux);
      
      drawnow;
      
      evpwrite(evpfiles{baphyidx},r,raux,dataFsOut,auxFs(1),rlfp,lfpFsOut);
   end
end

  