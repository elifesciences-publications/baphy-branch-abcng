
cd([BAPHYHOME '/SoundObjects/@FerretVocal']);


gapsize=0.25;
finallen=3;

dd=dir(['Sounds_set4_aux/*wav']);
ss=[];
for ii=1:length(dd),
   ff=['Sounds_set4_aux/',dd(ii).name];
   [w,fs,nbits]=wavread(ff);
   fprintf('%s: %.2f sec %.2f SR\n',dd(ii).name,...
           length(w)./fs,fs);
   
   if fs~=48000,
      w=resample(w,44100,fs);
      fs=48000;
   end
   
   lastbin=max(find(abs(w)>0));
   if ~isempty(lastbin),
      if lastbin./2>floor(lastbin./2),
         lastbin=lastbin-1;
      end
      w=w(1:lastbin);
   end
   if length(w)>finallen*fs,
      w=w(1:round(finallen*fs));
   end
   
   rampl=200;
   ramp=(0:(rampl-1))'./rampl;
   w(1:rampl)=w(1:rampl).*ramp;
   w((end-rampl+1):end)=w((end-rampl+1):end).*flipud(ramp);
   
   
   fw=fft(w);
   ff=(0:(length(fw)./2))./length(fw).*fs;
   ff=[ff fliplr(ff(2:(end-1)))]';
   f_hp=ones(size(ff));
   hp=75;
   f_hp(ff<hp)=(ff(ff<hp)./25)-3;
   f_hp(f_hp<0)=0;
   fw=fw.*f_hp;
   t=real(ifft(fw));
   t(1:rampl)=t(1:rampl).*ramp;
   t((end-rampl+1):end)=t((end-rampl+1):end).*flipud(ramp);
   t=t./max(abs(t));
   
   if size(ss,1)<length(t),
      ss=cat(1,ss,ones(length(t)-size(ss,1),size(ss,2)).*nan);
   end
   ss(:,ii)=nan;
   ss(1:length(w),ii)=t;
end

slen=sum(~isnan(ss));
savailable=ones(size(slen));
sidx=1;

widx=0;
wset=[];
exptevents=[];
while sum(savailable)>0,
   w=[];
   widx=widx+1;
   for sidx=find(savailable(:))',
      if length(w)+slen(sidx)<=finallen*fs,
         wstart=length(w);
         w=[w;ss(1:slen(sidx),sidx);zeros(round(fs*gapsize),1)];
         savailable(sidx)=0;
         ecount=length(exptevents)+1;
         exptevents(ecount).Idx=widx;
         exptevents(ecount).Name=['Stim , ' dd(sidx).name(1:(end-4))];
         exptevents(ecount).StartTime=wstart./fs;
         exptevents(ecount).StopTime=(wstart+slen(sidx))./fs;
      end
   end
   if length(w)>finallen*fs,
      w=w(1:(finallen*fs));
   else
      w=[w;zeros(finallen*fs-length(w),1)];
   end
   wset(:,widx)=w;
end
wcount=widx;
wset(:,[1 42])=wset(:,[42 1]);

for widx=1:wcount,
   fout=sprintf('Sounds_set4/ferretmixed%02d.wav',widx)
   wavwrite(wset(:,widx),fs,16,fout);
end

