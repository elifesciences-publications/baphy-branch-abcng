% function [stim,stimparam]=loadstimfrombaphy(parmfile,startbin,stopbin, 
%                   filtfmt,fsout[=1000],chancount[=30],forceregen[=0],includeprestim[=0],repcount[=1]);
%
% inputs: 
%  parmfile - a baphy m-file
%  startbin/stopbin - cut out segments of final file between these
%                    bins (0,0) values return whole stimulus (for
%                    cellxcnodb compatibility)
%  filtfmt - currently can be 'wav' or 'specgram' or 'wav2aud' or
%            'audspectrogram' or 'envelope' (collapsed over frequency)
%  fsout - output sampling rate
%  chancount - output number of channels
%  forceregen - regenerate cached stimulus file from raw waveform
%
% returns:
%  stim - spectrogram or otherwise formatted Reference stimulus in
%         baphy parameter file, all stimuli are sorted according to
%         their index and concatenated into one large freq X time
%         matrix.
%  stimparam - currently empty except for filtfmt=='specgram', when
%              it contains a vector of the frequency corresponding
%              to each channel in the stimulus spectrogram.
%
% created SVD 2006-08-17
%
function [stim,stimparam]=loadstimfrombaphy(parmfile,startbin,stopbin,filtfmt,fsout,chancount,forceregen,includeprestim,repcount);

global FORCESAMPLINGRATE

% check function parms and set defaults
if ~exist('startbin','var'),
   startbin=0;
end
if ~exist('stopbin','var'),
   stopbin=0;
end
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
if ~exist('includeprestim','var'),
   includeprestim = 0;
end
if ~exist('randorder','var'),
   randorder = 0;
end
if ~exist('repcount','var'),
   repcount = 1;
end

if strcmp(filtfmt,'wav') || strcmp(filtfmt,'none'),
   % force chancount to 1 for wav format
   chancount=1;
end

%
% start backwards compatibility section for pre-baphy data. blech.
if ~isobject(parmfile),
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
                chancount,forceregen,includeprestim);
        end
        return
    end
    % end backwards compatibility stuff.
    %
    
    if isfield(exptparams.TrialObject,'Torchandle'),
        RefObject=exptparams.TrialObject.Torchandle;
    else
        RefObject=exptparams.TrialObject.ReferenceHandle;
    end
    
    dstr=RefObject.descriptor;
    if strcmp(dstr,'Torc'),
        if isfield(exptparams(1).TrialObject(1),'RunClass'),
            dstr=[dstr,'-',exptparams(1).TrialObject(1).RunClass];
        else
            dstr=[dstr,'-TOR'];
        end
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
    if isfield(exptparams.TrialObject,'OveralldB'),
        OveralldB=exptparams.TrialObject.OveralldB;
        dstr=[dstr '-' num2str(OveralldB) 'dB'];
        scalelevel=10.^(-(80-OveralldB)./20);
    else
        OveralldB=0;
        scalelevel=1;
    end
    
    dstr=[dstr '-' filtfmt '-fs' num2str(fsout) '-ch' num2str(chancount)];
    if includeprestim,
        dstr=[dstr,'-incps1'];
    end
    dstr=strrep(dstr,' ','_');
    
    if strcmp(computer,'PCWIN'),
        ppdir=tempdir;
    elseif exist('/auto/data/tmp/tstim/','dir')
        ppdir=['/auto/data/tmp/tstim/'];
    else
        ppdir=['/tmp/'];
    end
    
    preprocfile=[ppdir dstr '.mat'];
    if strcmp(computer,'PCWIN'),
        preprocfile(3:end)=strrep(preprocfile(3:end),':','_');
    end
    savepreproc=1;
else
    RefObject=get(parmfile);
    forceregen=1;
    savepreproc=0;
    preprocfile='';
    OveralldB=0;
    scalelevel=1;
end

if ~forceregen && exist(preprocfile,'file')
   
    %fprintf('loading saved stimulus spectrograms from %s\n',basename(preprocfile));
   
   % load pregenerated stim
   load(preprocfile);
   
else
   
   if ~exist(preprocfile,'file')
      fprintf('saved stimulus spectrogram does not exist: %s\n',...
              basename(preprocfile));
   end
   
   % create instance of object and set U.D.F.s to appropriate
   % values.
   FORCESAMPLINGRATE=RefObject.SamplingRate;
   if strcmpi(RefObject.descriptor,'SpNoise') && ...
         ~isfield(RefObject,'TonesPerOctave'),
      RefObject.TonesPerOctave=RefObject.TonesPerBurst./...
          log2(RefObject.HighFreq./RefObject.LowFreq);
      fprintf('Fixing TonesPerOctave=%.2f\n',RefObject.TonesPerOctave);
   end
   
   fprintf('creating %s object\n',RefObject.descriptor);
   o=feval(RefObject.descriptor);
   fields=get(o,'UserDefinableFields');
   for cnt1 = 1:3:length(fields),
      try % since objects are changing,
         o = set(o,fields{cnt1},RefObject.(fields{cnt1}));
      catch
          if strcmp(fields{cnt1},'UseBPNoise'),
              % special case, for old data use non-default value
              disp('Setting UseBPNoise=0 for backwards compatability');
              o = set(o,fields{cnt1},0);
          else
              disp(['property ' fields{cnt1} ' not found, using default']);
          end
      end
   end
   
   % make sure that SamplingRate matches that actually imposed by baphy
   o=set(o,'SamplingRate',RefObject.SamplingRate);
   fcount=get(o,'MaxIndex');
   fsin=get(o,'SamplingRate');
   
   % load globals for use by wav2aud
   fprintf('Filtering raw waveform: %s ',filtfmt);
   stimparam.tags=get(o,'names');
   
   if strcmp(filtfmt,'audspectrogram'),
      fsadjust=log2(get(o,'SamplingRate')/16000);
      
      if fsout==100,
         param = [10 10 0.25 fsadjust]; % 10ms samples, compression 0.25
      elseif fsout==200,
         param = [5 5 .25 fsadjust]; % 5ms samples, compression 0.25
      end
      aud = audspectrogram(o,param,4,1);  % decimate to 30channels.
      
      % make sure all idxs have same duration
      maxlen=0;
      for ii=1:length(aud),
         if size(aud{ii},2)>maxlen,
            maxlen=size(aud{ii},2);
         end
      end
      for ii=1:length(aud),
         if size(aud{ii},2)<maxlen,
            ldiff=maxlen-size(aud{ii},2);
            aud{ii}=cat(2,aud{ii},zeros(size(aud{ii},1),ldiff));
         end
      end
      
      stim = cat(3,aud{:});
      tstimparam=[];
   elseif strcmp(filtfmt,'envelope'),
      stim=[];
      smfilt=ones(round(fsin/fsout),1)./round(fsin/fsout);
      
      if chancount~=1 && isfield(RefObject,'LowFreq'),
          bandcount=max(length(RefObject.LowFreq), ...
                        length(RefObject.HighFreq));
          bandnames=cell(bandcount,1);
          FilterParms=cell(bandcount,1);
          for bb=1:bandcount,
              if ~ismethod(o,'env'),
                 f1 = RefObject.LowFreq(bb)/RefObject.SamplingRate*2;
                 f2 = RefObject.HighFreq(bb)/RefObject.SamplingRate*2;
                 [b,a] = ellip(4,.5,20,[f1 f2]);
                 FilterParams{bb} = [b;a];
               end
              bandnames{bb}=sprintf('%d-%d',round(RefObject.LowFreq(bb)),...
                                   round(RefObject.HighFreq(bb)));
          end
      else
          bandcount=1;
          bandnames={sprintf('%d-%d',round(RefObject.LowFreq(1)),...
                             round(RefObject.HighFreq(1)))}
      end
      
      for ii=1:fcount,
          if ismethod(o,'env'),
              fprintf('.');
              w2=env(o,ii).*scalelevel;
              w3=conv2(w2,smfilt,'same');
              tstim=w3(round((fsin/fsout./2):(fsin/fsout):length(w3)),:);
              tstim=tstim';
          else
              fprintf('.');
              wav0=waveform(o,ii).*scalelevel;
              tstim=[];
              for bb=1:bandcount,
                  if bandcount>1,
                      wav=filtfilt(FilterParams{bb}(1,:),...
                                   FilterParams{bb}(2,:),wav0);
                  else
                      wav=wav0;
                  end
                  
                  zb=unique([1; min(find(abs(wav)>0))-1]);
                  za=unique([max(find(abs(wav)>0))+1; length(wav)]);
                  zb=zb(zb>0);
                  za=za(za<=length(wav));
                  
                  w2=abs(wav);
                  [pos,val]=findLocalExtrema(w2,'max');
                  pos=[zb;pos;za];
                  val=[zeros(size(zb));val;zeros(size(za))];
                  val=sqrt(val);
                  
                  w2=interp1(pos,val,1:length(wav),'linear')';
                  
                  % trying out various compressive NLs
                  %w2=log(abs(hilbert(wav)).^2);
                  %w2=sqrt(abs(hilbert(wav)));
                  
                  w3=conv2(w2,smfilt,'same');
                  w3=w3(round((fsin/fsout./2):(fsin/fsout):length(w3)));
                  %w3(w3<-10)=-10;
                  %w3=w3+10;
                  %w2=resample(w2,fsout,fsin);
                  %stepsize=fsin./fsout;
                  %wav=wav(round(stepsize./2:stepsize:end));
                  %wav=resample(wav,fsout,fsin);
                  
                  tstim=cat(1,tstim,w3');
              end
          end
          % force non-negative envelope in case something
          % negative snuck in.  not sure how that would happen...
          tstim(tstim<0)=0;
          
          stim=cat(3,stim,tstim);
      end
      
      stimparam.channames=bandnames;
      tstimparam.ff=zeros(1,bandcount);
      stimparam.flo=zeros(1,bandcount);
      stimparam.fhi=zeros(1,bandcount);
      for bb=1:bandcount,
          stimparam.flo(bb)=RefObject.LowFreq(bb);
          stimparam.fhi(bb)=RefObject.HighFreq(bb);
          tstimparam.ff(bb)=...
              round(2.^mean(log2([RefObject.LowFreq(bb) RefObject.HighFreq(bb)])));
      end
      ffmult=1;
   elseif strcmp(filtfmt,'parm') && ...
           strcmpi(RefObject.descriptor,'PipSequence'),
       bandcount=get(o,'BandCount');
       duration=get(o,'Duration');
       trialbins=round(duration.*fsout);
       stimcount=get(o,'MaxIndex');
       PipSet=get(o,'PipSet');
       pipdur=get(o,'PipDuration');
       
       stim=zeros(bandcount,trialbins,stimcount);
       for stimidx=1:stimcount,
           ff=find(PipSet(:,1)==stimidx);
           for ii=1:length(ff),
               startb=round(PipSet(ff(ii),2).*fsout)+1;
               stopb=round((PipSet(ff(ii),2)+pipdur).*fsout);
               pipid=PipSet(ff(ii),3);
               piplevel=10.^(-PipSet(ff(ii),4)./20);
               stim(pipid,startb:stopb,stimidx)=piplevel;
           end
       end
       prebins=round(fsout.*RefObject.PreStimSilence);
       postbins=round(fsout.*RefObject.PostStimSilence);
       stim=cat(2,zeros(bandcount,prebins,stimcount),...
                stim,zeros(bandcount,postbins,stimcount));
       stimparam.ff=get(o,'Frequencies');
       tstimparam=[];       
       
   elseif strcmp(filtfmt,'parm'),
      % currently this ONLY WORKS FOR SNS!  Should adapt easily to
      % work with TORCs.
      IdxSet=get(o,'IdxSet');
      stimparam.IdxSet=IdxSet;
      stimparam.SampleDuration=get(o,'SampleDuration');
      samplebins=stimparam.SampleDuration.*fsout;
      samplecount=get(o,'Count');
      
      % generate the spectrograms for each sample
      stimparam.StimSpecgram=[];
      for ii=1:samplecount,
         tspect=specgram(o,ii);
         tbins=size(tspect,2);
         bandcount=size(tspect,1);
         
         nspect=zeros(bandcount,samplebins);
         for jj=1:bandcount,
            nspect(jj,:)=resample(tspect(jj,:),samplebins,tbins);
         end
         stimparam.StimSpecgram=cat(3,stimparam.StimSpecgram,nspect);
      end
      
      % combine samples into streams that were actually presented.
      sequencecount=size(IdxSet,1);
      silentbins=fsout.*...
          (RefObject.PreStimSilence+RefObject.PostStimSilence);
      stim=zeros(bandcount,samplebins.*sequencecount+silentbins,fcount);
      for ii=1:fcount,
         for jj=1:sequencecount,
            os=(jj-1).*samplebins+RefObject.PreStimSilence.*fsout;
            stim(:,os+(1:samplebins),ii)=...
                stimparam.StimSpecgram(:,:,IdxSet(jj,1,ii))+...
                stimparam.StimSpecgram(:,:,IdxSet(jj,2,ii));
         end
      end
      lo_lim=get(o,'LowFreq');
      hi_lim=get(o,'HighFreq');
      N=40;
      
      lo_erb = 9.265*log(1+lo_lim./(24.7*9.265));
      hi_erb = 9.265*log(1+hi_lim./(24.7*9.265));
      cutoffs = ([lo_erb : (hi_erb-lo_erb)/(N) : hi_erb]);
      freq = 24.7*9.265*(exp(cutoffs/9.265)-1);
      stimparam.ff=freq(1:N);
      tstimparam=[];
   else
      for ii=1:fcount,
         fprintf('.');
         wav=waveform(o,ii).*scalelevel;
         
         % ms per time bin
         tbinsize=1000/fsout;
         
         stdur=length(wav)./fsin;
         tbincount=stdur*fsout;
         
         f=fsin;
         
         for kk=1:size(wav,2),
             if strcmp(filtfmt,'specgramnorm') & ...
                     ~isempty(frequency) & frequency(1)=='V',
                 fprintf(' (V-warping) ');
                 [tstim,tstimparam]=...
                     wav2spectral(wav(:,kk),filtfmt,fsin./2,fsout./2,chancount);
                 ffmult=2;
             elseif strcmp(filtfmt,'specgramv'),
                 fprintf(' (forcing V-space) ');
                 [tstim,tstimparam]=...
                     wav2spectral(wav(:,kk),filtfmt,fsin./2,fsout./2,chancount);
                 ffmult=2;
             elseif strcmp(filtfmt,'envelope'),
                 if fsin>16000,
                     [tstim,tstimparam]=...
                         wav2spectral(wav(:,kk),'specgramv',fsin./2,fsout./2,16);
                 else
                     [tstim,tstimparam]=...
                         wav2spectral(wav(:,kk),'specgram',fsin,fsout,16);
                 end
                 tstim=sum(tstim,2);
                 if 1|| fsout==100,
                     disp('shifting back envelope stim by one bin');
                     tstim=shift(tstim,[-1 0]);
                 else
                     disp('shifting back envelope stim by two bins');
                     tstim=shift(tstim,[-2 0]);
                 end
                 
                 tstimparam.ff=round(mean([get(o,'LowFreq') get(o,'HighFreq')]));
                 ffmult=1;
             else
                 %if fsin>16000,
                 %    wav=resample(wav,16000,fsin);
                 %    fsin=16000;
                 %end
                 [tstim,tstimparam]=...
                     wav2spectral(wav(:,kk),filtfmt,fsin,fsout,chancount);
                 ffmult=1;
             end
             
             if ii==1 && kk==1,
                 stim=zeros(size(tstim,1),size(tstim,2),fcount,size(wav,2));
             elseif size(tstim,1)>size(stim,1),
                 ldiff=size(tstim,1)-size(stim,1);
                 stim=cat(1,stim,zeros(ldiff,size(stim,2),size(stim,3),size(wav,2)));
             elseif size(tstim,1)<size(stim,1),
                 ldiff=size(stim,1)-size(tstim,1);
                 tstim=cat(1,tstim,zeros(ldiff,size(tstim,2)));
             end
             stim(:,:,ii,kk)=tstim;
         end
      end
      
      stim=permute(stim,[2,1,3,4]);
   end
   
   stimparam.tagidx=ones(1,fcount).*size(stim,2);
   stimparam.tagidx=[1 cumsum(stimparam.tagidx)+1];
   if isfield(tstimparam,'ff'),
      stimparam.ff=tstimparam.ff.*ffmult;
   end
   
   % remove pre/post silence by default because they get
   % trimmed out in loadspikeraster!!!!
   if includeprestim==0,
      ss=round(RefObject.PreStimSilence.*fsout)+1;
      ee=round(size(stim,2)-RefObject.PostStimSilence.*fsout);
      stim=stim(:,ss:ee,:);
      %keyboard
   end
   
   if savepreproc,
       fprintf('\nsaving spectrograms to %s\n',preprocfile);
       save(preprocfile,'stim','stimparam');
   end
end

if randorder,
   ff=shuffle(1:size(stim,3));
   stim=stim(:,:,ff,:);
end

if ~exist('startbin','var') || isempty(startbin),
   return
end
stim=permute(stim,[1 4 2 3]);
stim=reshape(stim,size(stim,1)*size(stim,2),size(stim,3)*size(stim,4));
if repcount>1,
   stim=repmat(stim,[1 exptparams.TotalRepetitions]);
end

if exist('startbin','var'),
   if isempty(startbin) || startbin==0,
      startbin=1;
   end
   if ~exist('stopbin','var') || isempty(stopbin) || stopbin==0,
      stopbin=size(stim,2).*size(stim,3);
   elseif stopbin>size(stim,2).*size(stim,3),
      stopbin=size(stim,2).*size(stim,3);
   end
   stim=stim(:,startbin:stopbin);
end
