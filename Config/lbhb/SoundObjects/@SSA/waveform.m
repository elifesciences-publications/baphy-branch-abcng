function [w, event]=waveform(o,index,IsRef)
% function w=waveform(t);
% this function is the waveform generator for object NoiseBurst
%
% created SVD 2015-03-05

%event = struct();
par=get(o);
Names=par.Names;

timesamples = (1 : round(par.Duration*par.SamplingRate))' / par.SamplingRate;
w=zeros(size(timesamples));

ToneSamples=round(par.PipDuration.*par.SamplingRate);
Pips=cell(length(par.Frequencies),1);
PipNames=cell(length(par.Frequencies),1);
rampon=linspace(0,1,round(par.SamplingRate.*0.005))';
rampoff=linspace(1,0,round(par.SamplingRate.*0.005))';
for ff=1:length(par.Frequencies),
    f0=par.Frequencies(ff);
    if par.Bandwidth>0,
        lf=round(2.^(log2(f0)-par.Bandwidth./2));
        hf=round(2.^(log2(f0)+par.Bandwidth./2));
        Pips{ff}=BandpassNoise(lf,hf,par.PipDuration,par.SamplingRate);
        Pips{ff)(1:length(rampon))=Pips{ff)(1:length(rampon)).*rampon;
        Pips{ff)((end-length(rampoff)+1):end)=...
            Pips{ff)((end-length(rampoff)+1):end).*rampoff;
    else
        ToneSamples=round(par.PipDuration.*par.SamplingRate);
        tt=(0:(ToneSamples-1))./par.SamplingRate;
        Pips{ff}=sin(2*pi*par.Frequencies(ff)*tt);
    end
    PipNames{ff}=num2str(f0);
end

SeqPerRate=ceil(par.MaxIndex./length(par.F1Rates));
Sequence=par.Sequences(:,index);
SeqNum=ceil(index/SeqPerRate);
PrePipSilence=par.PipInterval./2;
PostPipSilence=par.PipInterval./2;
currentoffset=0;
PipsPerTrial=floor(par.Duration./(par.PipDuration+par.PipInterval));
for ii=1:length(Sequence),
    w(currentoffset+round(PrePipSilence.*par.SamplingRate)+(1:ToneSamples))=Pips{Sequence(ii)};
    currenttime=par.PreStimSilence+currentoffset./par.SamplingRate;
    
    if ii==1,
        nn=sprintf('%s+ONSET',PipNames{Sequence(ii)});
    elseif Sequence(ii)==1,
        nn=sprintf('%s+%.2f',PipNames{Sequence(ii)},par.F1Rates(SeqNum));
    elseif Sequence(ii)==2,
        nn=sprintf('%s+%.2f',PipNames{Sequence(ii)},par.F1Rates(3-SeqNum));
    end
    
    % and generate the event structure:
    event((ii-1)*3+1) = struct('Note',['PreStimSilence , ' nn],...
        'StartTime',currenttime+0,'StopTime',currenttime+PrePipSilence,'Trial',[]);
    event((ii-1)*3+2) = struct('Note',['Stim , ' nn],...
        'StartTime',currenttime+PrePipSilence, 'StopTime', currenttime+PrePipSilence+par.PipDuration,'Trial',[]);
    event((ii-1)*3+3) = struct('Note',['PostStimSilence , ' nn],...
        'StartTime',currenttime+PrePipSilence+par.PipDuration, 'StopTime',currenttime+PrePipSilence+par.PipDuration+PostPipSilence,'Trial',[]);
    
    currentoffset=currentoffset+round((par.PipDuration+par.PipInterval).*par.SamplingRate);
end

% normalize min/max +/-5
w = 5 ./ max(abs(w(:))) .* w;

% Now, put it in the silence:
w = [zeros(par.PreStimSilence*par.SamplingRate,1) ; w(:) ;zeros(par.PostStimSilence*par.SamplingRate,1)];

% % and generate the event structure:
% event = struct('Note',['PreStimSilence , ' Names{index}],...
%     'StartTime',0,'StopTime',par.PreStimSilence,'Trial',[]);
% event(2) = struct('Note',['Stim , ' Names{index}],'StartTime'...
%     ,par.PreStimSilence, 'StopTime', par.PreStimSilence+par.Duration,'Trial',[]);
% event(3) = struct('Note',['PostStimSilence , ' Names{index}],...
%     'StartTime',par.PreStimSilence+par.Duration, 'StopTime',par.PreStimSilence+par.Duration+par.PostStimSilence,'Trial',[]);
