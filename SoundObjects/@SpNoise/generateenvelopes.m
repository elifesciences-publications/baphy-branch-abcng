

SamplingRate=40000;
SamplingRateFinal=2000;
smoothwindow=0.003.*SamplingRate;

subsetcount=5;
s=Speech;
s=set(s,'SamplingRate',SamplingRate);

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
   
   clear Env;
   Env.emtx=emtx;
   Env.fs=SamplingRateFinal;
   Env.Duration=get(s,'Duration');
   Env.Names=get(s,'Names');
   Env.Phonemes=get(s,'Phonemes');
   Env.MaxIndex=get(s,'MaxIndex');
   
   outfile=['envelope/Speech.subset',num2str(subidx),'.mat'];
   save(outfile,'Env');
end



subsetcount=5;
s=FerretVocal;
s=set(s,'SamplingRate',SamplingRate);

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
   
   clear Env
   Env.emtx=emtx;
   Env.fs=SamplingRateFinal;
   Env.Duration=get(s,'Duration');
   Env.Names=get(s,'Names');
   Env.Phonemes={};
   Env.MaxIndex=get(s,'MaxIndex');
   outfile=['envelope/FerretVocal.subset',num2str(subidx),'.mat'];
   save(outfile,'Env');
   
end
