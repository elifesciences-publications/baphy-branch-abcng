

SamplingRate=40000;
SamplingRateFinal=2000;
smoothwindow=0.003.*SamplingRate;

subsetcount=5;
s=Speech;
s=set(s,'SamplingRate',SamplingRate);

clear Env;
for subidx=1:subsetcount,
   s=set(s,'Subsets',subidx);
   imax=get(s,'MaxIndex')
   emtx=zeros(round(get(s,'Duration').*SamplingRateFinal),imax);
   for idx=1:imax,
      sp=waveform(s,idx);
      
      sp=gsmooth(abs(sp),smoothwindow);
      sp=sp./max(sp);
      
      emtx(:,idx)=resample(sp,SamplingRateFinal,SamplingRate);
   end
   
   Env(subidx).emtx=emtx;
   Env(subidx).fs=SamplingRateFinal;
   Env(subidx).Duration=get(s,'Duration');
   Env(subidx).Names=get(s,'Names');
   Env(subidx).Phonemes=get(s,'Phonemes');
   Env(subidx).MaxIndex=get(s,'MaxIndex');
   
end

save Speech_Env.mat Env


subsetcount=5;
s=FerretVocal;
s=set(s,'SamplingRate',SamplingRate);

clear Env;
for subidx=1:subsetcount,
   s=set(s,'Subsets',subidx);
   imax=get(s,'MaxIndex')
   emtx=zeros(round(get(s,'Duration').*SamplingRateFinal),imax).*nan;
   for idx=1:imax,
      sp=waveform(s,idx);
      
      sp=gsmooth(abs(sp),smoothwindow);
      sp=sp./max(sp);
      sp=resample(sp,SamplingRateFinal,SamplingRate);
      
      if length(sp)>size(emtx,1),
         emtx=cat(1,emtx,ones(length(sp)-size(emtx,1),imax).*nan);
      end
      emtx(1:length(sp),idx)=sp;
   end
   Env(subidx).emtx=emtx;
   Env(subidx).fs=SamplingRateFinal;
   Env(subidx).Duration=get(s,'Duration');
   Env(subidx).Names=get(s,'Names');
   Env(subidx).Phonemes={};
   Env(subidx).MaxIndex=get(s,'MaxIndex');
   
end

save FerretVocal_Env.mat Env
