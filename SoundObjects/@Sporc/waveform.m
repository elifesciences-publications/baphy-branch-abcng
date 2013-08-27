function [w,event]=waveform (o,index,IsRef);
% function w=waveform(o, index,IsRef);
% piggybacks on speech and torc waveform methods

ospeech=get(o,'speechobj');
sp=waveform(ospeech,index);

otorc=get(o,'torcobj');
[w,event]=waveform(otorc,index);

smoothwindow=0.003.*get(ospeech,'SamplingRate');
sp=gsmooth(abs(sp),smoothwindow);
%sp=smooth(abs(sp),smoothwindow.*2);
sp=sp./max(sp);
sp=resample(sp,get(otorc,'SamplingRate'),get(ospeech,'SamplingRate'));
if length(sp)<length(w),
    disp('trimming!!!');
    [length(sp) length(w)]
    w=w(1:length(sp));
elseif length(sp)>length(w),
    disp('trimming!!!');
    [length(sp) length(w)]
    sp=sp(1:length(w));
end
w=w.*sp;

Subsets = get(o,'Subsets');
for ii=1:length(event),
   event(ii).Note=strrep(event(ii).Note,'TORC',sprintf('SPORC-%d',Subsets));
end
