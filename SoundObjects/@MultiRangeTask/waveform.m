function [w, ev]=waveform (o,index, IsRef);
% function w=waveform(t);
% this function is the waveform generator for object MultiRangeTask

Duration=get(o,'Duration');
Names = get(o,'Names');
Frequency = ifstr2num(Names{index});
SamplingRate=get(o,'SamplingRate');
PreStimSilence=get(o,'PreStimSilence');
PostStimSilence=get(o,'PostStimSilence');
Type=deblank(get(o,'Type'));
batten=get(o,'BackgroundNoise');  %dB attnuation
if ~strcmpi(Type,'tone') && ~strcmpi(Type,'mistuned')     
    period=1/Frequency(1);  %period in second
    period=round(period*SamplingRate);       %coverted into samples
    w=zeros(round(Duration(1)*SamplingRate),1);    
end
switch lower(Type)
    case {'amtone','amtone2','amtone2a','amtone2c'}
        t=0:1/SamplingRate:Duration(1);
        if Frequency(1)==0   %wn as carrior
            rand('seed',datenum(date));  %use forzen white niose
            w=rand(1,length(t))-0.5;
        else
            w=sin(2*pi*Frequency(1)*t);
        end
        lowF=get(o,'LowFrequency');
        if length(lowF)==1
            amdepth=100; else            
            amdepth=lowF(2);
        end
        amdepth=100-amdepth;
        if Frequency(2)>0   %0- no AM
            am=(100-amdepth)*sin(2*pi*Frequency(2)*t-pi/2)+100+amdepth;
            w=w.*am/100;
        end
    case {'tone','harm','gaptone'}  %for pure tone or harmonic (first 7th)
        t=0:1/SamplingRate:Duration(1);
        w=sin(2*pi*Frequency(1)*t);
        if strcmpi(Type,'harm')
            for i=2:7
                w=[w;sin(2*pi*Frequency(1)*i*t);];
            end
            w=mean(w,1);
        end
    case 'click' %fixed interval click train same polarity       
        w(1:period:end,1)=1;
        %w(2:period:end,1)=1;  %two sample width
    case 'mistuned'   %mistuned harmonics
        f0=Frequency(1);        %fundamental
        mistuned=Frequency(2);  %mistuned frequency
        N=get(o,'MaxIndex');    %harnomic#
        t=0:1/SamplingRate:Duration;
        w=[];
        for i=1:15
            if i==round(mistuned/f0)
              w(i,:)=sin(2*pi*(mistuned)*t);
            else
                w(i,:)=sin(2*pi*f0*(i)*t); 
            end
        end
        w=mean(w,1);
end
if batten>=-60 && Frequency(1)~=0  %add background noise
    bnoise=rand(size(w))-0.5;
    rms1=sqrt(mean(w.^2));
    rms2=sqrt(mean(bnoise.^2));
    w=w/rms1; bnoise=bnoise/rms2;  %normalized to same RMS
    bnoise=bnoise*10^(batten/20);  %noise attnuation in dB
    w=w+bnoise;
end

% 10ms ramp at onset:
w = w(:);
ramp = hanning(round(.01 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
Gap=0;
if strcmpi(Type,'gaptone')
    if length(Duration)==1
        Gap=0.1; else
        Gap=Duration(2);
    end
    w1=w(1:round(0.1*SamplingRate));               %frist 100 msec
    w2=w(round(0.1*SamplingRate)+1:end);           %the rest after gap
    w1(1:length(ramp)) = w1(1:length(ramp)) .* ramp;
    w1(end-length(ramp)+1:end) = w1(end-length(ramp)+1:end) .* flipud(ramp);
    w2(1:length(ramp)) = w2(1:length(ramp)) .* ramp;
    w2(end-length(ramp)+1:end) = w2(end-length(ramp)+1:end) .* flipud(ramp);
    w=[w1(:); zeros(round(Gap*SamplingRate),1);w2(:)];
else
    w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
    w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);
end
% Now, put it in the silence:
w = [zeros(round(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(round(PostStimSilence*SamplingRate),1)];
% and generate the event structure:
if any(strcmpi(Type,{'amtone','amtone2','amtone2a','amtone2c'}))
    ev = struct('Note',['PreStimSilence , ' num2str(Frequency)],...
        'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
    ev(2) = struct('Note',['Stim , ' num2str(Frequency)],'StartTime'...
        ,PreStimSilence, 'StopTime', PreStimSilence+Duration(1),'Trial',[]);
    ev(3) = struct('Note',['PostStimSilence , ' num2str(Frequency)],...
        'StartTime',PreStimSilence+Duration(1), 'StopTime',PreStimSilence+Duration(1)+PostStimSilence,'Trial',[]);
else
    ev = struct('Note',['PreStimSilence , ' num2str(Frequency(1))],...
        'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
    ev(2) = struct('Note',['Stim , ' num2str(Frequency(1))],'StartTime'...
        ,PreStimSilence, 'StopTime', PreStimSilence+Duration(1)+Gap,'Trial',[]);
    ev(3) = struct('Note',['PostStimSilence , ' num2str(Frequency(1))],...
        'StartTime',PreStimSilence+Duration(1)+Gap, 'StopTime',PreStimSilence+Duration(1)+Gap+PostStimSilence,'Trial',[]);
end
w = 5 * w/max(abs(w));

