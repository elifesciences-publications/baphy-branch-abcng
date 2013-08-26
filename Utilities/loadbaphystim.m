% function [stim,stimparam]=loadstimfrombaphy(parmfile 
%                   filtfmt,fsout[=1000],chancount[=30],forceregen[=0]);
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
function [stim,stimparam]=loadbaphystim(parmfile,filtfmt,fsout,chancount,forceregen);

% check function parms and set defaults
if ~exist('filtfmt','var'),
   filtfmt='none';
end
if ~exist('fsout','var'),
   fsout = 1000;
end
if ~exist('chancount','var'),
   chancount = 30;
end
if ~exist('forceregen','var'),
   forceregen = 0;
end
if strcmp(filtfmt,'wav') || strcmp(filtfmt,'none'),
   % force chancount to 1 for wav format
   chancount=1;
end

% start backwards compatibility section. blech.
OLDFMT=0;
if strcmpi(parmfile((end-3):end),'.par'),
   OLDFMT=1;
else
   LoadMFile(parmfile);
   if ~exist('exptparams','var'),
      OLDFMT=1;
   end
end

if OLDFMT,
   if ~isempty(findstr(upper(parmfile),'TOR')),
      [stim,stimparam]=loadtorcfromwfm(parmfile,startbin,stopbin, ...
                                       filtfmt,fsout,chancount,forceregen);
   else
      [stim,stimparam]=loadspeech(parmfile,startbin,stopbin,filtfmt,fsout, ...
                                  chancount,forceregen);
   end
   return
end
% end backwards compatibility stuff.


if isfield(exptparams.TrialObject,'Torchandle'),
    RefObject=exptparams.TrialObject.Torchandle;
else
    RefObject=exptparams.TrialObject.ReferenceHandle;
end

dstr=RefObject.descriptor;
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

dstr=[dstr '-' filtfmt '-fs' num2str(fsout) '-ch' ...
      num2str(chancount)];
dstr=strrep(dstr,' ','_');

if strcmp(computer,'PCWIN'),
    ppdir=tempdir;
else
    ppdir=[getenv('HOME') '/data/tstim/'];
end

preprocfile=[ppdir dstr '.mat'];
if strcmp(computer,'PCWIN'),
    preprocfile(3:end)=strrep(preprocfile(3:end),':','_');
end


if exist(preprocfile,'file') && ~forceregen
   
   fprintf('loading saved stimulus spectrograms from %s\n',basename(preprocfile));
   
   % load pregenerated stim
   load(preprocfile);
   
else
   
   if ~exist(preprocfile,'file')
      fprintf('saved stimulus spectrogram does not exist: %s\n',...
              basename(preprocfile));
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
   if isfield(exptparams,'fs'),
       fsin=exptparams.fs;
   end
   
   % load globals for use by wav2aud
   fprintf('Filtering raw waveform: %s ',filtfmt);
   stimparam.tags=get(o,'names');
   for ii=1:fcount,
      fprintf('.');
      wav=waveform(o,ii);
      
      % ms per time bin
      tbinsize=1000/fsout;
      
      stdur=length(wav)./fsin;
      tbincount=round(stdur*fsout);
      
      if ii==1,
         stim=zeros(tbincount,chancount,fcount);
      end
      
      f=fsin;
      if strcmp(filtfmt,'specgramnorm') & ...
            ~isempty(frequency) & frequency(1)=='V',
         fprintf(' (V-warping) ');
         [stim(:,:,ii),tstimparam]=...
             wav2spectral(wav,filtfmt,fsin./2,fsout./2,chancount);
         ffmult=2;
      elseif strcmp(filtfmt,'specgramv'),
         [stim(:,:,ii),tstimparam]=...
             wav2spectral(wav,filtfmt,fsin./2,fsout./2,chancount);
         ffmult=2;
      else
         [stim(:,:,ii),tstimparam]=...
             wav2spectral(wav,filtfmt,fsin,fsout,chancount);
         ffmult=1;
      end         
   end
   
   stim=permute(stim,[2,1,3]);
   stimparam.tagidx=ones(1,fcount).*size(stim,2);
   stimparam.tagidx=[1 cumsum(stimparam.tagidx)+1];
   if isfield(tstimparam,'ff'),
      stimparam.ff=tstimparam.ff.*ffmult;
   end
   
   fprintf('\nsaving spectrograms to %s\n',preprocfile);
   save(preprocfile,'stim','stimparam');
end

