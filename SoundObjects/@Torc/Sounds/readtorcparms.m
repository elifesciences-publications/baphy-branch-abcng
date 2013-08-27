function TorcObject=readtorcparms(basename,count)
    
referencecount=count;
    
for ii=1:count,
    parfile=strrep(basename,'%d',sprintf('%02d',ii));
    
    tempPar = caseread(parfile);
    % read the sampling frequency:
    TorcObject.Params(ii).SamplingFrequency = getvalue(tempPar(3,:));
    TorcObject.Params(ii).RipplePeak = getvalue(tempPar(4,:));
    TorcObject.Params(ii).LowestFrequency = getvalue(tempPar(5,:));
    TorcObject.Params(ii).HighestFrequency = getvalue(tempPar(6,:));
    TorcObject.Params(ii).NumberOfComponents = getvalue(tempPar(7,:));
    TorcObject.Params(ii).HarmonicallySpaced = getvalue(tempPar(8,:));
    TorcObject.Params(ii).HarmonicSpacing = getvalue(tempPar(9,:));
    TorcObject.Params(ii).SpectralPowerDecay = getvalue(tempPar(10,:));
    TorcObject.Params(ii).ComponentRandomPhase = getvalue(tempPar(11,:));;
    TorcObject.Params(ii).TimeDuration = getvalue(tempPar(12,:));
    TorcObject.Params(ii).RippleAmplitude = getvalue(tempPar(13,:));
    TorcObject.Params(ii).Scales = getvalue(tempPar(14,:));
    TorcObject.Params(ii).Phase =  getvalue(tempPar(15,:));
    TorcObject.Params(ii).Rates = getvalue(tempPar(16,:));
end

TorcObject.SamplingRate=TorcObject.Params(1).SamplingFrequency;
TorcObject.Duration=TorcObject.Params(1).TimeDuration;
TorcObject.MaxIndex=count;



if 0
    
    a1infodata = paramsfromfile(parfile);
    
    if ii==1,
        dur=geta1val(a1infodata,'Time duration');
        rasterfs=geta1val(a1infodata,'Sampling frequency');
        
        TorcObject.Duration=dur;
        TorcObject.MaxIndex=count;
        TorcObject.SamplingRate=rasterfs;
        
        
     
    
    
    TorcObject.Params(1).LowestFrequency = ...
        geta1val(a1infodata,'Lower frequency component');
    TorcObject.Params(1).HighestFrequency = ...
        geta1val(a1infodata,'Upper frequency component');
 
    
    
        StimParam.numrecs   = referencecount; %get(t,'Index');
        StimParam.mf        = rasterfs/1000; % config('mf');
        StimParam.ddur      = round(1000*dur);
        StimParam.stdur     = round(1000*dur);
        StimParam.stonset   = 0;
        
        StimParam.lfreq = geta1val(a1infodata,'Lower frequency component');
        StimParam.hfreq = geta1val(a1infodata,'Upper frequency component');
        StimParam.octaves=log2(StimParam.hfreq/StimParam.lfreq);
        StimParam.ba = geta1val(a1infodata,'Base Amplitude');
        StimParam.v = geta1val(a1infodata,'Voltage at 50dB');
        StimParam.rp = geta1val(a1infodata,'Ripple peak');
        StimParam.nc = geta1val(a1infodata,'Number of components');
        StimParam.chs = geta1val(a1infodata,'Components harmonically spaced');
        StimParam.hs = geta1val(a1infodata,'Harmonic spacing');
        StimParam.spd = geta1val(a1infodata,'Spectral Power Decay');
        StimParam.crp = geta1val(a1infodata,'Components random phase');
        StimParam.td = geta1val(a1infodata,'Time duration');
        
        StimParam.a1am   = {};
        StimParam.a1rf   = {};
        StimParam.a1ph   = {};
        StimParam.a1rv   = {};
    end
    StimParam.a1am{ii} = geta1vec(a1infodata,'Ripple amplitudes');
    StimParam.a1rf{ii} = geta1vec(a1infodata,'Ripple frequencies');
    StimParam.a1ph{ii} = geta1vec(a1infodata,'Ripple phase shifts');
    StimParam.a1rv{ii} = geta1vec(a1infodata,'Angular frequencies');
end


function v = getvalue (text);
% this function returns the numeric value after '=' in text:
tempStart = findstr(text,'=');
IsParan = findstr(text,'(');
tempEnd = findstr(text(1,tempStart:end),' ');
if isempty(IsParan)
    tempEnd = tempEnd(2);
else
    tempStart = IsParan;
    tempEnd = findstr(text(tempStart:end),')')-1;
end
v = ifstr2num(text(1+tempStart:tempStart+tempEnd-1));
