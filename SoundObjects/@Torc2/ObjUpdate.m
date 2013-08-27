function o = ObjUpdate (o);
%
% This function loads the file name and index numbers for specified torc
% rate and Higherst Frequency:

% Nima, november 2005
HighestFrequency = get(o,'FrequencyRange');
Rates = get(o,'Rates');
Rates= strtrim(Rates);
switch Rates
    case '2:2:16',
        RateName = '216';
    case '2:2:12',
        RateName = '212';
    case '4:4:24',
        RateName = '424';
    case '4:4:48',
        RateName = '448';
    case '8:8:48',
        RateName = '848';
    case '8:8:96',
        RateName = '896';
    case '1:1:8',
        RateName = 'SD';
end
% now the highest frequency:     
HighName = lower(HighestFrequency(1));
ModDepth=get(o,'ModDepth');

if ModDepth<=1,
   AF=1;
   ModDepth=0.9;
   DepthName='_LIN';
else
   AF=0;
   ModDepthdB=ModDepth;
   DepthName=['_L',num2str(ModDepthdB)];
end
% now make the generic file name for the corresponding category of torcs:
%disp(RateName)
FileNames = ['TORC_' RateName DepthName '_*' HighName '*.wav'];

% load the torc names into the name field:
object_spec = what(get(o,'descriptor'));
if length(object_spec) >1 
    error('There seems to be a conflict, more than one torc object exists which can be bacause you have old daqpc in the path!');
end
soundpath = [object_spec.path filesep 'Sounds'];
TorcFiles = dir([soundpath filesep FileNames]);
if 0,
    % screen out all files that have <RateName>_L
    keepidx=zeros(size(TorcFiles));
    for ii=1:length(TorcFiles),
        if isempty(findstr(TorcFiles(ii).name,[RateName,'_L'])),
            keepidx(ii)=1;
        end
    end
    TorcFiles=TorcFiles(find(keepidx));
end
if isempty(TorcFiles),
   TORCgenerator(get(o));
   TorcFiles = dir([soundpath filesep FileNames]);
end

[temp, fs] = wavread([soundpath filesep TorcFiles(1).name], 1);
for cnt1 = 1:length(TorcFiles),
    files{cnt1} = TorcFiles(cnt1).name(1:end-4);
    % Now load the parameters from the file and update the properties:
    % For torcs, it has a standard form:
    tempPar = caseread([soundpath filesep files{cnt1} '.txt']);
    % read the sampling frequency:
    Params(cnt1).SamplingFrequency = getvalue(tempPar(3,:));
    Params(cnt1).RipplePeak = getvalue(tempPar(4,:));
    Params(cnt1).LowestFrequency = getvalue(tempPar(5,:));
    Params(cnt1).HighestFrequency = getvalue(tempPar(6,:));
    Params(cnt1).NumberOfComponents = getvalue(tempPar(7,:));
    Params(cnt1).HarmonicallySpaced = getvalue(tempPar(8,:));
    Params(cnt1).HarmonicSpacing = getvalue(tempPar(9,:));
    Params(cnt1).SpectralPowerDecay = getvalue(tempPar(10,:));
    Params(cnt1).ComponentRandomPhase = getvalue(tempPar(11,:));;
    Params(cnt1).TimeDuration = getvalue(tempPar(12,:));
    Params(cnt1).RippleAmplitude = getvalue(tempPar(13,:));
    Params(cnt1).Scales = getvalue(tempPar(14,:));
    Params(cnt1).Phase =  getvalue(tempPar(15,:));
    Params(cnt1).Rates = getvalue(tempPar(16,:));
end

o = set(o,'Params',Params);
o = set(o,'Names',files);
o = set(o,'MaxIndex', length(files));
if HighName=='u',
  o = set(o,'SamplingRate', 100000);
end
% o = set(o,'SamplingRate', fs);

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
