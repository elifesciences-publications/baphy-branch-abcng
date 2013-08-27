function o = ObjUpdate (o);
%
% This function loads the file name and index numbers for specified torc
% rate and Higherst Frequency:

% Nima, november 2005
Rates = get(o,'Rates');
Rates= strtrim(Rates);
switch Rates
    case '4',
        RateName = '4';
    case '8',
        RateName = '8';
    case '16',
        RateName = '16';
    case '24',
        RateName = '24';
end

FileNames = ['TARC_' RateName '_*.wav'];

% load the tarc names into the name field:
object_spec = what('Tarc');
if length(object_spec) >1 
    error('There seems to be a conflict, more than one tarc object exists which can be bacause you have old daqpc in the path!');
end
soundpath = [object_spec.path filesep 'Sounds'];
TarcFiles = dir([soundpath filesep FileNames]);
[temp, fs] = wavread([soundpath filesep TarcFiles(1).name], 1);
for cnt1 = 1:length(TarcFiles)
    files{cnt1} = TarcFiles(cnt1).name(1:end-4);
    % Now load the parameters from the file and update the properties:
    % For tarcs, it has a standard form:
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
