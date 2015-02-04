% function [stim,stimparam]=wav2spectral(wav,filtfmt,fsin,fsout,chancount,minfreq);
%
% inputs: 
%  parmfile - a baphy m-file
%  startbin/stopbin - cut out segments of final file between these
%                    bins (0,0) values return whole stimulus (for
%                    cellxcnodb compatibility)
%  filtfmt - currently can be 'specgram' or 'wav2aud'
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
function [stim,stimparam]=wav2spectral(wav,filtfmt,fsin,fsout,chancount,minfreq);

disp(['running ' mfilename '(',filtfmt,') ...']);

% check function parms and set defaults
if ~exist('filtfmt','var'),
   filtfmt='none';
end
if ~exist('fsin','var'),
   fsin = 16000;
end
if ~exist('fsout','var'),
   fsout = 1000;
end
if ~exist('chancount','var'),
   chancount = 30;
end
if ~exist('minfreq','var'),
   minfreq = 125;
end

stdur=length(wav)./fsin;
tbincount=ceil(stdur*fsout);
adjwavlen=round(tbincount./fsout.*fsin);
wav(length(wav)+1:adjwavlen)=0;

tbinsize=1000./fsout;   % binsize in ms
saf=fsout;
f=fsin;
stimparam=[];
switch lower(filtfmt),
 case {'none','wav'},
  stim=resample(wav,saf,f);
 case {'specgram','specgramnorm','specgramv','specgram2','specgram2t',...
       'envelope'},

  %if strcmp(filtfmt,'envelope'),
  %   ff=find(wav(1:(end-1))==0 & wav(2:end)==0);
  %   wav(ff)=randn(size(ff)).*std(wav)./20;
  %end
  
  % downsample to 16000 Hz without resample, which barfs
  step=f./16000;
  
  if step>1,
     wav0=wav;
     NN=f./2;
     FILTER_ORDER = round(f./40);
     f_lp = firls(FILTER_ORDER,[0 15500/2/NN 15800/2/NN 1],[1 1 0 0]);
     wav = conv(wav, f_lp);
     wav = wav(round(FILTER_ORDER/2)+1:length(wav)-round(FILTER_ORDER/2));   
     
     if step<2 && round(f)==f,
        wav=resample(wav,16000,f);
     else
        %wav=wav(round(step./2:step:length(wav)));
        wav=interp1(1:length(wav),wav,step./2:step:length(wav),'linear')';
        wav(isnan(wav))=0;
     end
  else
    % pukes sometimes
    wav=resample(wav,16000,f);
  end  

  if 0,
     figure(1);clf
     pwelch(wav0,[],[],[],f);
     figure(2);clf
     pwelch(wav,[],[],[],16000);
     keyboard
  end
  
  f=16000;
  
  minfreq=250;  % chosen arbitrarily
  if f./minfreq>=256,
     nfft=f./minfreq;
  else
     nfft=256;
     minfreq=f./nfft;
  end
  %keyboard
  ftwinlen=256./f .*1000;
  winsize=nfft;
  noverlap=round((ftwinlen-tbinsize)./1000.*f);
  if noverlap<0,
     noverlap=round((ftwinlen-tbinsize./2)./1000.*f);
     wav=[zeros(noverlap/2,1); wav; zeros(noverlap/2,1)];
     [temp,ff,ttt]=specgram(wav,nfft,f,winsize,noverlap);
     temp=temp(:,1:2:end);
     
  else
     % pad to get correct number of time bins out
     wav=[zeros(noverlap/2,1); wav; zeros(noverlap/2,1)];
     [temp,ff,ttt]=specgram(wav,nfft,f,winsize,noverlap);
  end
  
  keepchanidx=find(ff>=minfreq & ff>100);
  temp=temp(keepchanidx,:,:);
  ff=ff(keepchanidx);
  
  temp=abs(temp);
  
  % sample spectrogram logarhithmically
  %chancount=48;
  if strcmp(filtfmt,'envelope'),
     chancount=16;
  end
  chanidx=round(exp(linspace(0,log(size(temp,1)),chancount)));
  linmax=chanidx(max(find(diff(chanidx)==0)))+1;
  
  chanidx=[1:linmax ...
           round(exp(linspace(log(linmax+1),log(size(temp,1)),...
                              chancount-linmax)))];
  ff=ff(chanidx);
  % dowsample frequency axis (columns)
  %temp1=resample(temp(4:128,:),1,4);
  temp1=(temp(chanidx,:));
  
  for ii=2:length(chanidx),
     if chanidx(ii)-chanidx(ii-1)>1,
        temp1(ii,:)=sum(temp(chanidx(ii-1)+1:chanidx(ii),:));
     end
  end
  
  temp1=sqrt(temp1);
  %temp1=log2(temp1+0.125);
  %temp1=log2(temp1+16)-5;
  
  % remove sub-zero (low-dB) output of log!!!
  temp1=max(0,temp1(:,1:tbincount));
  
  if strcmpi(filtfmt,'specgram2'),
     % take product of each spectral channel pair
     paircount=chancount.*(chancount+1)./2;
     temp2=zeros(paircount,tbincount);
     stimparam.ff=zeros(paircount,2);
     temp2(1:chancount,:)=temp1;
     stimparam.ff(1:chancount,:)=[ff(:) ff(:)];
     pidx=chancount;
     
     for p1=1:chancount,
        for p2=(p1+1):chancount,
           pidx=pidx+1;
           stimparam.ff(pidx,:)=[ff(p1) ff(p2)];
           temp2(pidx,:)=(temp1(p1,:)-mean(temp1(p1,:))).*(temp1(p2,:)-mean(temp1(p2,:)));
        end
     end
     
     stim=temp2';
  elseif strcmpi(filtfmt,'specgram2t'),
     % take product of each spectral channel pair
     paircount=chancount.*3;
     temp2=zeros(paircount,tbincount);
     stimparam.ff=zeros(paircount,2);
     
     
     temp2(1:chancount,:)=temp1;
     stimparam.ff(1:chancount,:)=[ff(:) zeros(size(ff(:)))];
     
     % diff between current frame and 1 back
     temp1=temp1-repmat(mean(temp1,2),[1 size(temp1,2)]);
     temp2((1:chancount)+chancount,2:end)=temp1(:,2:end).*temp1(:,1:(end-1));
     stimparam.ff((1:chancount)+chancount,:)=[ff(:) ones(size(ff(:)))];
     
     % diff between current frame and 2 back
     temp2((1:chancount)+chancount.*2,3:end)=temp1(:,3:end).*temp1(:,1:(end-2));
     stimparam.ff((1:chancount)+chancount.*2,:)=[ff(:) ones(size(ff(:))).*2];
     
     % diff between current frame and 4 back
     temp2((1:chancount)+chancount.*3,5:end)=temp1(:,5:end).*temp1(:,1:(end-4));
     stimparam.ff((1:chancount)+chancount.*3,:)=[ff(:) ones(size(ff(:))).*4];
     
     stim=temp2';
     
  elseif strcmp(filtfmt,'envelope'),
     stimparam.ff=1; %ff;
     stimparam.chanidx=1; %chanidx;
     %stim=sqrt(sum(temp1',2));  % sqrt seems to linearize ecog better
     stim=sum(temp1',2);  % skip sqrt
     
     %keyboard
     % remove slow oscillations<2 Hz.
     %sbak=stim;
     FILTER_ORDER=fsout.*4;
     NN=fsout./2;
     f_hp = firls(FILTER_ORDER,[0 2/NN 2.5/NN 1],[0 0 1 1]);
     %stim=filtfilt(f_hp,1,stim);
     %plot([stim(1000:2000) sbak(1000:2000)]);
  else
     stimparam.ff=ff;
     stimparam.chanidx=chanidx;
     stim=temp1';
  end
  
 case {'wav2aud','wav2auddc'},
  loadload;
  fs=16000;
  if f~=fs
     wav=resample(wav,fs,f);
  end
  
  temp=wav2aud(wav,[tbinsize tbinsize -2 log2(fs/16000)])';
  
  if 0,
     % DISABLED THIS FIX 2008-04-03 SVD TO HELP Nima DEBUG
     % apply fixed reverse time offset to deal with lag that gets
     % added to low frequency channels by wav2aud
     p=[0.0020   -0.4080   21.2532];
     poffset=floor((p(3)+p(2).*(1:128)+p(1).*(1:128).^2)./tbinsize);
     poffset(100:end)=0;
     
     for pp=1:size(temp,1),
        if poffset(pp)>0
           temp(pp,:)=[temp(pp,(poffset(pp)+1):end) zeros(1,poffset(pp))];
        end
     end
  end
  
  % this seems to be necessary to get binning to align correctly.
  temp(:,1:end-1)=temp(:,2:end);
  
  % dowsample frequency axis (columns)
  % skip lowest 5 frequencies because they're way below torcs??
  temp1=resample(temp(6:end,:),chancount,128-5);
  
  stim=max(0,temp1(:,1:tbincount)');
  if strcmp(lower(filtfmt),'wav2auddc');
     stim(:,1)=1;
  end
  
  ff=[];%round(resample(ff,chancount,128-5));
  stimparam.ff=ff;
  
  
 case 'lyonpassiveear',
  tempdecimationfactor=f./saf;
  if chancount==30,
     olap=.7;
  elseif chancount==15,
           olap=1.35;
  end
  %keyboard
  ts=LyonPassiveEar(wav,f,tempdecimationfactor,8,olap);
  %ts=LyonPassiveEar(wav,f,10);
  %keyboard
  
  stim=ts';
 
  case 'gamma',
    [gamma_bms, gamma_envs, ~, ~, cfs] = ...
        gammatonebank(wav,200,20000,chancount,f,false);
    smfilt=ones(1,round(fsin/fsout))./round(fsin/fsout);
    gamma_envs=conv2(gamma_envs,smfilt,'same');
    stim=gamma_envs(:,round((fsin/fsout./2):(fsin/fsout):size(gamma_envs,2)))';
  
    stimparam.ff=cfs;
  case 'ozgf',
    % One Zero Gammatone-like Filter (Lyon et al)
    if fsin<40000,
       wav=resample(wav,40000,fsin);
       fsin=40000;
    end
    [stim, cfs, Qs] = ozgf_filterbank(wav,200,20000,chancount, fsin, fsout, false);
    stimparam.ff = cfs;
    stimparam.Q_factors = Qs;    
  case 'gamma264',
    [gamma_bms, gamma_envs, ~, ~, cfs] = ...
        gammatonebank(wav,2000,64000,chancount,f,false);
    smfilt=ones(1,round(fsin/fsout))./round(fsin/fsout);
    gamma_envs=conv2(gamma_envs,smfilt,'same');
    stim=gamma_envs(:,round((fsin/fsout./2):(fsin/fsout):size(gamma_envs,2)))';
    stimparam.ff=cfs;
    
 case 'logfsgram',
  %function [Y,MX] = logfsgram(X, N, SR, WIN, NOV, FMIN, BPO)
  error(sprintf('filtfmt %s not implemented yet\n',filtfmt));
  
  
 otherwise,
  error(sprintf('unknown filtfmt %s\n',filtfmt));
        
end

% threshold stim....
% don't know if this is ALWAYS the right thing to do:
%
if ~strcmp(filtfmt,'wav') && ~strcmp(filtfmt,'envelope'),
   stim=max(0,stim);
end

