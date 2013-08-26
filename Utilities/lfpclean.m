% function evp_out=lfpclean(evp_in,channel,unitdef,FORCERELOAD,verbose);
%
% remove spike-correlated components from LFP data
%
% created SVD 2009-07-01 based on Nico's code
%
function evp_out=lfpclean(evp_in,channel,unitdef,FORCERELOAD,verbose);

% clean test:
% evp_in='/auto/data/daq/Mars/mar036/mar036a05_p_BVT.evp'
% dirty test:
% evp_in='/auto/data/daq/Venus/v117/v117a11_p_PTD.evp'

FS_OUT=500;
IR_LEN=250;
SPIKE_FS=25000;

if ~exist('verbose','var'),
   verbose=0;
end

if verbose,
   disp('verbose: forcing reload');
   FORCERELOAD=1;
elseif ~exist('FORCERELOAD','var'),
   FORCERELOAD=0;
end

[pp,bb,ee]=fileparts(evp_in);
evp_out=fullfile(pp,'tmp',sprintf('%s.ch%d.cl%.1f.evp',bb,channel(1),unitdef));

if exist(evp_out,'file') && ~FORCERELOAD,
   return
end

%[SpikechannelCount,AuxChannelCount,TrialCount,Spikefs,Auxfs,...
% LFPChannelCount,LFPfs]=evpgetinfo(evp_in);

%  function [rS,STrialIdx,rA,ATrialIdx,rL,LTrialIdx]=evpread(filename,spikechans[=all],
%                                                    auxchans[=none],trials[=all]);
%[t1,t2,t3,t4,rL,LTrialIdx]=evpread(evp_in,[],[],1:TrialCount,channel);

mf=strrep(evp_in,'.evp','.m');

if length(channel)==1,
   lfp_channel=channel;
   spike_channel=channel;
else
   lfp_channel=channel(1)
   spike_channel=channel(2)
end

% load lfp signal
options.channel=lfp_channel;
options.tag_masks={'SPECIAL-TRIAL'};
options.rasterfs=FS_OUT;
options.lfp=1;
rL=loadevpraster(mf,options);

if unitdef<-1,
   unitdef=-unitdef;
   DUMBXC=1;
else
   DUMBXC=0;
end

if unitdef>1,
   fprintf('lfpclean: removing %.1f sigma events (channel %d)\n',...
           unitdef,spike_channel);
   options.rasterfs=FS_OUT;
   options.channel=spike_channel;
   options.lfp=0;
   options.sigthreshold=unitdef;
   rS=loadevpraster(mf,options);
elseif unitdef==1,
   fprintf('lfpclean: removing sorted spike events\n');
   
   % conservative: remove only "real" identified spikes from spk.mat file
   options.rasterfs=FS_OUT;
   options.channel=spike_channel;
   options.lfp=0;
   options.mua=2;
   [pp,bb,ee]=fileparts(mf);
   sbase=[bb '.spk.mat'];
   sf=fullfile(pp,'sorted',sbase);
   rS=loadspikeraster(sf,options);
   
elseif unitdef==0.2,  % Stark MUA definition
   FILTER_ORDER = 500;
   f_bp = firls(FILTER_ORDER,[0 550/SPIKE_FS 600/SPIKE_FS 3000/SPIKE_FS 3500/SPIKE_FS 1],[0 0 1 1 0 0]);
   f_lp = firls(FILTER_ORDER,[0 450/SPIKE_FS 500/SPIKE_FS 1],[1 1 0 0]);
   dsstep=SPIKE_FS./FS_OUT;
   
   % load raw spike waveform
   [s_all,strialidx]=evpread(evp_in,spike_channel);
   strialidx=[strialidx;length(s_all)+1];
   
   maxtriallen=ceil(max(diff(strialidx))./SPIKE_FS.*FS_OUT);
   trialcount=length(strialidx)-1;
   rS=zeros(maxtriallen,trialcount).*nan;
   
   for tt=1:trialcount,
      %tt
      s=s_all(strialidx(tt):(strialidx(tt+1)-1));
      
      rSmua = conv(s, f_bp);
      rSmua = rSmua(round(FILTER_ORDER/2)+1:round(FILTER_ORDER/2)+length(s));
      rSmua = rSmua.^2;
      rSmua = conv(rSmua, f_lp);
      rSmua = rSmua(round(FILTER_ORDER/2)+1:round(FILTER_ORDER/2)+length(s));
      rSmua = sqrt(abs(rSmua));
      
      rSmua=rSmua(round(dsstep./2:dsstep:length(rSmua)));
      rS(1:length(rSmua),tt)=rSmua;
      
   end
   
end

% following code taken from Nico's infer_spikes_lfp.m
trialcount=size(rS,2);
LTrialIdx=zeros(trialcount,1);
L0=[];
S=[];
for ii=1:trialcount,

   LTrialIdx(ii)=length(L0)+1;
   
   out_thistrial=rL(:,ii);
   out_thistrial=out_thistrial(~isnan(out_thistrial));
   NN=IR_LEN./2;
   f_bp = firls(IR_LEN,[0 57./NN 59./NN 61./NN 63./NN 1],[1 1 0 0 1 1]);
   out2 = conv(out_thistrial, f_bp);
   %out_thistrial = out2(round(IR_LEN/2)+1:round(IR_LEN/2)+length(out_thistrial));
   
   spike_thistrial=rS(:,ii);
   spike_thistrial=spike_thistrial(~isnan(out_thistrial));
   
   L0 = cat(1,L0,out_thistrial);
   S = cat(1,S,spike_thistrial);
end

if 0,
   % TEST DATA
   t=(1:10000)'./FS_OUT;
   Ltrue=sin(2.*pi.*40.*t);
   S=(rand(size(t))>0.99);
   L0=S+Ltrue;
end


fprintf('computing cross-corr...\n');
bootcount=16;
bootstep=length(L0)./bootcount;
xc=zeros(IR_LEN.*2+1,bootcount);
ac=zeros(IR_LEN.*2+1,bootcount);
for bb=1:bootcount,
   bidx=[1:round((bb-1).*bootstep) round(bb.*bootstep+1):length(L0)];
   
   xc(:,bb)=xcov(L0(bidx),S(bidx),IR_LEN,'unbiased');
   ac(:,bb)=xcov(S(bidx),S(bidx),IR_LEN,'unbiased');
end

if DUMBXC,
   disp('(dumb method)');
   boot_h=xc;
   h_re=mean(xc,2);
else
   
   fft_xc = fft(xc);
   fft_ac = fft(ac);
   
   h_fft_re = fft_xc./fft_ac;
   mm=abs(mean(h_fft_re,2));
   ee=abs(std(h_fft_re,0,2)).*sqrt(bootcount-1);
   
   boot_h=fftshift(real(ifft(h_fft_re)));
   %mm=(mean(boot_h,2));
   %ee=(std(boot_h,0,2)).*sqrt(bootcount-1);
   
   h_fft_re=mean(h_fft_re,2);
   if unitdef<1,
      h_fft_re(mm./ee<1.5,:)=0;
   else
      h_fft_re(mm./ee<1.5,:)=0;
   end

   h_re = fftshift(real(ifft(h_fft_re)));
   %h_re = h_re - mean(h_re);
   h_re = h_re .* hann(IR_LEN*2+1);
   %h_re = h_re-mean(h_re);
   
   %h = resample(h_re, fs, IR_LEN);
   %h = h * IR_LEN / fs;
   
   %keyboard
end

disp('cross-validated cleaning');

LS=zeros(size(S));
for bb=1:bootcount,
   bidx=round((bb-1).*bootstep+1):round(bb.*bootstep);
   tLS=conv(S(bidx),boot_h(:,bb));
   LS(bidx)=tLS(round(length(h_re)/2):length(tLS)-round(length(h_re)/2)+mod(length(h_re),2));
end   
%LS = conv(S, h_re);
%LS= LS(round(length(h_re)/2):length(LS)-round(length(h_re)/2)+mod(length(h_re),2));
L1 = L0 - LS;

if exist(evp_out,'file'),
   delete(evp_out);
end
fprintf('saving to %s...\n',evp_out);
for ii=1:trialcount,
   if ii<trialcount,
      L1_thistrial=L1(LTrialIdx(ii):(LTrialIdx(ii+1)-1));
   else
      L1_thistrial=L1(LTrialIdx(ii):end);
   end
   
   evpwrite(evp_out,[],[],1000,1000,L1_thistrial,FS_OUT);
end


if verbose,
   disp('Loading raw spike waveforms...');
   cachefile=cacheevpspikes(evp_in,spike_channel,unitdef);
   spikedata=load(cachefile);
   
   switch unitdef,
    case 4,
     fg=[0 1 0];
     bg=[0.7 1 0.7];
    case 3,
     fg=[0 0 1];
     bg=[0.7 0.7 1];
    case 0.2,
     fg=[1 0 0];
     bg=[1 0.7 0.7];
    otherwise
     fg=[0 0 0];
     bg=[0.7 0.7 0.7];
   end
   
   hf=figure;
   
   GAIN=12000;
   RESOLUTION=1.5259e-004;
   uvfactor=RESOLUTION.*1000000./GAIN;
   
   subplot(2,2,1);
   tt=(-IR_LEN:IR_LEN)'./FS_OUT;
   mh=(mean(boot_h,2)).*uvfactor.* hann(IR_LEN*2+1);
   eh=(std(boot_h,0,2)).*sqrt(bootcount-1).*uvfactor.* hann(IR_LEN*2+1);
   
   errorshade(tt,mh,eh,fg,bg);
   if unitdef>1,
      axis([-IR_LEN./FS_OUT IR_LEN./FS_OUT -30 30]);
   elseif unitdef==0.2,
      axis([-IR_LEN./FS_OUT IR_LEN./FS_OUT -0.025 0.025]);
   end
   title(sprintf('%s-%d - L-S filter',basename(evp_in),lfp_channel),...
         'Interpreter','none');
   xlabel('time (sec)');
   if unitdef<1,
      ylabel('microvolts LFP/microvolts MUA');
   else
      ylabel('microvolts/spike');
   end
   
   chronux_addpath
   
   subplot(2,2,3);
   params=[];
   params.Fs=FS_OUT;
   [ffh,f]=mtspectrumc(mh,params);
   semilogx(f,abs(ffh));
   
   
   if unitdef>1,
      if ~exist('s_all','var'),
         [s_all,strialidx]=evpread(evp_in,spike_channel);
         strialidx=[strialidx;length(s_all)+1];
      end
      SP_LEN=100;  % = IR_LEN
      
      
      sb=spikedata.spikebin;
      tb=spikedata.trialid;
      %sb=spikedata.spikebin(round((1:100)+1000));
      %tb=spikedata.trialid(round((1:100)+1000));
      mm=zeros(1+2.*SP_LEN,1);
      ee=zeros(1+2.*SP_LEN,1);
      count=0;
      spike_examples=zeros(1+2.*SP_LEN,100);
      
      for tt=1:max(tb)
         s=s_all(strialidx(tt):(strialidx(tt+1)-1));
         
         trialset=sb(tb==tt)';
         for ii=trialset,
            if (ii>SP_LEN && ii<length(s)-SP_LEN),
               ts=s(ii+(-SP_LEN:SP_LEN));
               ts=ts-mean(ts);
               mm=mm+ts;
               ee=ee+ts.^2;
               count=count+1;
               ii0=1000 % or 1300; % or 1000
               if count>=ii0 && count<=ii0+100,
                  spike_examples(:,count-ii0+1)=ts(:);
               end
            end
         end
      end
      mm=mm./count;
      ee=sqrt((ee./count)-mm.^2);
      
      sfigure(hf);
      subplot(2,2,2);
      cla
      tt2=(-SP_LEN:SP_LEN)'./SPIKE_FS;
      plot(tt2,spike_examples,'k-');
      %errorshade(tt2,mm.*uvfactor,ee.*uvfactor);
      %axis([-SP_LEN./SPIKE_FS SP_LEN./SPIKE_FS -50 50]);
      xlabel('time (sec)');
      ylabel('microvolts');
      title(sprintf('spike waveform (%d sigma)',unitdef));
      
      
      subplot(2,2,3);
      cla
      params=[];
      params.Fs=FS_OUT;
      [ffh,f]=mtspectrumc(mh,params);
      semilogx(f,abs(ffh));
      params=[];
      params.Fs=SPIKE_FS;
      
      [ffs,f]=mtspectrumc(mm,params);
      hold on
      semilogx(f,abs(ffs)./max(abs(ffs)).*max(abs(ffh)),'r');
      
      semilogx([1 1].*FS_OUT./2,[0 1],'b--');
      semilogx([1 1].*SPIKE_FS./2,[0 1],'r--');
      
      hold off
      
      
      keyboard
   end
   
   drawnow
   
end

return

sfigure(1);
f=(1:length(fft_xc)).*FS_OUT./IR_LEN./2;
plot(f,abs(fft_xc));


f=(1:length(f_bp)).*FS_OUT./IR_LEN./2;
plot(f,abs(fft(f_bp)))


if ((exist('verbose','var') ~= 0) && (verbose == 1))
    figure(2);
    hold off;
    plot(xcov(output,input,fs*2,'unbiased'));
    hold on;
    plot(xcov(input,output_clean,fs*2,'unbiased'),'g');

    figure(1)
    plot(h);
end
