function o = ObjUpdate (o)
%
% This function recalculate and update the fields of phoneme class and is
% called after any set command.
% Its a method of SoundObject, but that one does not do anything.

% Nima, november 2005
files = {};
SpeakerAll = get(o,'Speakers');
SNRall = get(o,'SNRs');
CVall = get(o,'Digits');
ExistingUtt = [1 2 3 4 6 9]; 
ObjUtt = get(o,'Utterances');
Utterances = ExistingUtt(1:min(ObjUtt,length(ExistingUtt)));

% because we want sham trials, we need to make sure the lenght of the
% utterances is at least 7
if length(Utterances)<7, 
    Utterances = repmat(Utterances,[1 ceil(7/length(Utterances))]);
    Utterances(8:end)=[];
end

cmind = strfind(CVall,',');
if ~isempty(cmind)
    cmind = [0 cmind 1+length(CVall)];
    for cnt1 = 1:length(cmind)-1
        CVs{cnt1} = CVall(cmind(cnt1)+1:cmind(cnt1+1)-1);
    end
else
    CVs = {CVall};
end
cmind = strfind(SpeakerAll,',');
if ~isempty(cmind)
    cmind = [0 cmind 1+length(SpeakerAll)];
    for cnt1 = 1:length(cmind)-1
        Speakers{cnt1} = SpeakerAll(cmind(cnt1)+1:cmind(cnt1+1)-1);
    end
else
    Speakers = {SpeakerAll};
end
cmind = strfind(SNRall,',');
if ~isempty(cmind)
    cmind = [0 cmind 1+length(SNRall)];
    for cnt1 = 1:length(cmind)-1
        SNRs{cnt1} = SNRall(cmind(cnt1)+1:cmind(cnt1+1)-1);
    end
else
    SNRs= {SNRall};
end

if isempty(CVs{1}) CVs = {'*'};end
if isempty(Speakers{1}) Speakers={'*'};end
if isempty(SNRs{1}) SNRs={'*'};end

object_spec = what('SingleDigits');
soundpath = [object_spec.path filesep 'Sounds'];
for cnt1 = 1:length(Speakers);
    for cnt2 = 1:length(SNRs)
        for cnt3 = 1:length(CVs)
            for utt = Utterances
                phfiles = dir([soundpath filesep Speakers{cnt1} '_SET' num2str(utt) ...
                    '_d' CVs{cnt3} '*.wav']);
                if ~isempty(phfiles)
                    phfiles = phfiles(1);
                    %             for cnt4 = 1:length(phfiles)
                    files{end+1} = phfiles.name;
                    %             end
                end
            end
        end
    end
end
o = set(o,'Names',files);
o = set(o,'MaxIndex', length(files));
