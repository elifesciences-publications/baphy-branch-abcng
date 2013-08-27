function [w, event]=waveform (o,index,IsRef);
% function w=waveform(t);
% this function is the waveform generator for object Tone

% compatibility issue: make new Tone object (with index) compatible witht
% the rest:
if ~exist('index','var') || isempty(index)
    index = 1;
end

event = [];
% the parameters of tone object
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
Frequencies = get(o,'Frequencies');
Names = get(o,'Names');
Names = Names{1};
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');

par = get(o);
ExpType = par.ExpType;

switch ExpType
    
    case 'CDD'
        FMorTone = get(o,'FMorTone');
        
        if length(PostStimSilence)>1
            PostStimSilence = PostStimSilence(1) + diff(PostStimSilence) * rand(1);
        end
        
        if FMorTone == 2
            timesamples = (1 : Duration*SamplingRate) / SamplingRate;
            w=zeros(size(timesamples));
            
            w = w + sin(2*pi*Frequencies*timesamples);
            % 10ms ramp at onset:
            w = w(:);
            ramp = hanning(round(.01 * SamplingRate*2));
            ramp = ramp(1:floor(length(ramp)/2));
            w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
            w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);
            % Now, put it in the silence:
            w = [zeros(round(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(round(PostStimSilence*SamplingRate),1)];
            
            % and generate the event structure:
            event = struct('Note',['PreStimSilence , ' Names],...
                'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
            event(2) = struct('Note',['Stim , ' Names],'StartTime'...
                ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
            event(3) = struct('Note',['PostStimSilence , ' Names],...
                'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
            w = 5 * w./max(abs(w));
        elseif FMorTone == 1
            % generate the tone
            StartFrequency = Frequencies(1);
            EndFrequency = Frequencies(2);
            
            timesamples = (1 : Duration*SamplingRate) / SamplingRate;
            w = chirp(timesamples,StartFrequency,timesamples(end),EndFrequency);
            % 10ms ramp at onset:
            w = w(:);
            ramp = hanning(round(.01 * SamplingRate*2));
            ramp = ramp(1:floor(length(ramp)/2));
            w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
            w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);
            % Now, put it in the silence:
            w = [zeros(round(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(round(PostStimSilence*SamplingRate),1)];
            
            % and generate the event structure:
            event = struct('Note',['PreStimSilence , ' Names],...
                'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
            event(2) = struct('Note',['Stim , ' Names],'StartTime'...
                ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
            event(3) = struct('Note',['PostStimSilence , ' Names],...
                'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
            w = 5 * w./max(abs(w));
            
            
        end
        
    case {'PRD','FDL'}
        FMorTone = get(o,'FMorTone');
        
        if length(PostStimSilence)>1
            PostStimSilence = PostStimSilence(1) + diff(PostStimSilence) * rand(1);
        end
        
        if FMorTone == 2
            timesamples = (1 : Duration*SamplingRate) / SamplingRate;
            w=zeros(size(timesamples));
            
            w = w + sin(2*pi*Frequencies*timesamples);
            % 10ms ramp at onset:
            w = w(:);
            ramp = hanning(round(.01 * SamplingRate*2));
            ramp = ramp(1:floor(length(ramp)/2));
            w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
            w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);
            % Now, put it in the silence:
            w = [zeros(round(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(round(PostStimSilence*SamplingRate),1)];
            
            % and generate the event structure:
            event = struct('Note',['PreStimSilence , ' Names],...
                'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
            event(2) = struct('Note',['Stim , ' Names],'StartTime'...
                ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
            event(3) = struct('Note',['PostStimSilence , ' Names],...
                'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
            w = 5 * w./max(abs(w));
        elseif FMorTone == 1
            % generate the tone
            StartFrequency = Frequencies(1);
            EndFrequency = Frequencies(2);
            
            timesamples = (1 : Duration*SamplingRate) / SamplingRate;
            w = chirp(timesamples,StartFrequency,timesamples(end),EndFrequency);
            % 10ms ramp at onset:
            w = w(:);
            ramp = hanning(round(.01 * SamplingRate*2));
            ramp = ramp(1:floor(length(ramp)/2));
            w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
            w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);
            % Now, put it in the silence:
            w = [zeros(round(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(round(PostStimSilence*SamplingRate),1)];
            
            % and generate the event structure:
            event = struct('Note',['PreStimSilence , ' Names],...
                'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
            event(2) = struct('Note',['Stim , ' Names],'StartTime'...
                ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
            event(3) = struct('Note',['PostStimSilence , ' Names],...
                'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
            w = 5 * w./max(abs(w));
            
            
        end
        
        
end




