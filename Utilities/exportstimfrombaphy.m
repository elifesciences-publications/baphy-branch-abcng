% function [stim,stimparam]=loadstimfrombaphy(parmfile,startbin,stopbin, 
%                   filtfmt,fsout[=1000],chancount[=30],forceregen[=0],randorder[=0]);
%
% inputs: 
%  parmfile - a baphy m-file
%  startbin/stopbin - cut out segments of final file between these
%                    bins (0,0) values return whole stimulus (for
%                    cellxcnodb compatibility)
%  filtfmt - currently can be 'wav' or 'specgram' or 'wav2aud'
%
% returns:
%  stim - spectrogram of Reference stimulus in baphy parameter
%         file, all stimuli are sorted according to their index and
%         concatenated into one large freq X time matrix.
%  stimparam - currently empty except for filtfmt=='specgram', when
%              it contains a vector of the frequency corresponding
%              to each channel in the stimulus spectrogram.
%
% created SVD 2006-08-17
%
function exportstimfrombaphy(parmfile,outpath);

if ~exist('outpath','var');
   outpath=[pwd filesep]
end

% check function parms and set defaults
filtfmt='wav';
chancount=1;

LoadMFile(parmfile);
if isfield(exptparams.TrialObject,'Torchandle'),
    RefObject=exptparams.TrialObject.Torchandle;
else
    RefObject=exptparams.TrialObject.ReferenceHandle;
end

dstr=RefObject.descriptor;
if strcmp(dstr,'Torc'),
   dstr=[dstr,'-',exptparams(1).TrialObject(1).RunClass];
end

fields=RefObject.UserDefinableFields;

frequency='';
for cnt1 = 1:3:length(fields)
   % include all parameter values, even defaults, in filename
   if isnumeric(RefObject.(fields{cnt1})),
      %if fields{cnt1+2}~=RefObject.(fields{cnt1}),
         dstr=[dstr '-' num2str(RefObject.(fields{cnt1}))];
      %end
   else
      %if ~strcmp(fields{cnt1+2},RefObject.(fields{cnt1})),
         dstr=[dstr '-' RefObject.(fields{cnt1})];
      %end
   end
   if strcmp(fields{cnt1},'FrequencyRange'),
      frequency=RefObject.(fields{cnt1});
   end
   dstr=strrep(dstr,':','');  % remove colons from torcs.
end

dstr=strrep(dstr,':','');  % remove colons from torcs.

dstr=[dstr '-' filtfmt '-fs' num2str(fsout) '-ch' ...
      num2str(chancount)];
dstr=strrep(dstr,' ','_');



preprocfile=[ppdir dstr '.mat'];
if strcmp(computer,'PCWIN'),
   preprocfile(3:end)=strrep(preprocfile(3:end),':','_');
end


   
   % create instance of object and set U.D.F.s to appropriate
   % values.
   fprintf('creating %s object\n',RefObject.descriptor);
   o=feval(RefObject.descriptor);
   fields=get(o,'UserDefinableFields');
   for cnt1 = 1:3:length(fields),
      try % since objects are changing,
         o = set(o,fields{cnt1},RefObject.(fields{cnt1}));
      catch
         warning(['property ' fields{cnt1} ' can not be found, using default']);
      end
   end
   
   fcount=get(o,'MaxIndex');
   fsin=get(o,'SamplingRate');
   
   % load globals for use by wav2aud
   fprintf('Filtering raw waveform: %s ',filtfmt);
   stimparam.tags=get(o,'names');
   
   if strcmp(filtfmt,'audspectrogram'),
      o=set(o,'SamplingRate',16000);
      if fsout==100,
         param = [10 10 0.25 0]; % 10ms samples, compression 0.25, 16K
      elseif fsout==200,
         param = [5 5 .25 0]; % 5ms samples, compression 0.25, 16K
      end
      aud = audspectrogram(o,param,4,1);  % decimate to 30 channels.
      stim = cat(3,aud{:});
      tstimparam=[];
   else
      for ii=1:fcount,
         fprintf('.');
         wav=waveform(o,ii);
         
         % ms per time bin
         tbinsize=1000/fsout;
         
         stdur=length(wav)./fsin;
         tbincount=stdur*fsout;
         
         f=fsin;
         if strcmp(filtfmt,'specgramnorm') & ...
               ~isempty(frequency) & frequency(1)=='V',
            fprintf(' (V-warping) ');
            [tstim,tstimparam]=...
                wav2spectral(wav,filtfmt,fsin./2,fsout./2,chancount);
            ffmult=2;
         elseif strcmp(filtfmt,'specgramv'),
            fprintf(' (forcing V-space) ');
            [tstim,tstimparam]=...
                wav2spectral(wav,filtfmt,fsin./2,fsout./2,chancount);
            ffmult=2;
         else
            [tstim,tstimparam]=...
                wav2spectral(wav,filtfmt,fsin,fsout,chancount);
            ffmult=1;
         end
         
         if ii==1,
            stim=zeros(size(tstim,1),size(tstim,2),fcount);
         end
         stim(:,:,ii)=tstim;
         
      end
      
      stim=permute(stim,[2,1,3]);
   end
   
   stimparam.tagidx=ones(1,fcount).*size(stim,2);
   stimparam.tagidx=[1 cumsum(stimparam.tagidx)+1];
   if isfield(tstimparam,'ff'),
      stimparam.ff=tstimparam.ff.*ffmult;
   end
   
   fprintf('\nsaving spectrograms to %s\n',preprocfile);
   save(preprocfile,'stim','stimparam');
end

if randorder,
   ff=shuffle(1:size(stim,3));
   stim=stim(:,:,ff);
end

if exist('startbin','var'),
   if startbin==0,
      startbin=1;
   end
   if ~exist('stopbin','var') | stopbin==0,
      stopbin=size(stim,2).*size(stim,3);
   elseif stopbin>size(stim,2).*size(stim,3),
      stopbin=size(stim,2).*size(stim,3);
   end
   stim=stim(:,startbin:stopbin);
end
