function o = ObjUpdate (o);
%
% This function recalculate and update the fields of speech class.

% Nima, november 2005
Subsets = get(o,'Subsets');
% Define the filenames for different subsets:
Subset{1} = {'si464','si516','si530','si567','si590','si664','si748','si756','si860','si919',...
    'si920','si953','si1079','si1105','si1112','si1138','si1230','si1377','si1742','si1798',...
    'si1824','si1889','si1908','si2004','si2016','si2077','si2180','si2196','si2260','si2262'};
Subset{2} = {'si521','si531','si600','si615','si616','si620','si658','si667','si691','si701',...,
    'si702','si705','si785','si805','si848','si902','si932','si985','si1018','si1054','si1087',...
    'si1097','si1142','si1163','si1172','si1177','si1202','si1222','si1225','si2187'};
Subset{3} = {'si1207','si1239','si1250','si1255','si1259','si1263','si1278','si1300','si1305',...
    'si1311','si1317','si1372','si1380','si1392','si1411','si1417','si1422','si1461','si1472',...
    'si1616','si1712','si1726','si1741','si1752','si1776','si1784','si1840','si1957','si2054',...
    'si2159'};
Subset{4} = {'falk0_sa1','falr0_sa1','fcag0_sa1','fcmm0_sa1','feac0_sa1','fgcs0_sa1','fjkl0_sa1',...
    'fjxp0_sa1','flhd0_sa1','fljd0_sa1','fmmh0_sa1','fntb0_sa1','fpaz0_sa1','fsak0_sa1','fskl0_sa1',...
    'maeb0_sa1','mcdr0_sa1','mdbp0_sa1','mesg0_sa1','mgrp0_sa1','mjee0_sa1','mjjj0_sa1','mjpm1_sa1',...
    'mjrh0_sa1','mjws0_sa1','mmdm0_sa1','mprt0_sa1','mrab1_sa1','msms0_sa1','mtrt0_sa1'};
Subset{5} = {'falk0_sa1','maeb0_sa1'};

%%%%%%%%%%%%%
%
object_spec = what('Speech');
soundpath = [object_spec.path filesep 'Sounds'];
Names = [];
PreStim = get(o,'PreStimSilence');
if ~isempty(Subsets) & (length(get(o,'Names'))~=1)
    for cnt1 = 1:5  % check all subsets:
        if ~isempty(find(Subsets==cnt1))  % User requested this subset, add it to the names:
            Names = [Names Subset{cnt1}];
        end
    end
else
    Names = get(o,'Names');
end
Phonemes = {};
Words = {};
Sentences = {};
if ~isempty(Names)
%     fs =get(o,'samplingRate'); % since all the files have the same sampling frequency.
    % Now, add phonemes, words and sentences:
    for cnt1 = 1:length(Names)
        [Samples, fs] = wavread([soundpath filesep Names{cnt1} '.wav'], 'SIZE');
        % first, phonemes:
        ph = [];
        f = fopen([soundpath filesep Names{cnt1} '.phn'],'r');
        s = fgetl(f);
        while s~=-1
            spaces = strfind(s,' ');
            ph(end+1).Note = strrep(s(spaces(2):end),' ','');
            ph(end).Note   = strrep(ph(end).Note, '''', '"');
            ph(end).StartTime = PreStim + str2num(s(1:spaces(1))) / fs;
            ph(end).StopTime = PreStim + str2num(s(spaces(1):spaces(2))) / fs;
            if ph(end).StopTime > (PreStim+(Samples(1)/fs)) break;end
            s = fgetl(f);
        end
        fclose(f);
        % second, words:
        wr = [];
        f = fopen([soundpath filesep Names{cnt1} '.wrd'],'r');
        s = fgetl(f);
        while s~=-1
            spaces = strfind(s,' ');
            wr(end+1).Note = strrep(s(spaces(2):end),' ','');
            wr(end).Note   = strrep(wr(end).Note, '''', '"');
            wr(end).StartTime = PreStim + str2num(s(1:spaces(1))) / fs;
            wr(end).StopTime = PreStim + str2num(s(spaces(1):spaces(2))) / fs;
            if wr(end).StopTime>(PreStim+(Samples(1)/fs)) break;end
            s = fgetl(f);
        end
        fclose(f);
        % and last, the sentece:
        f = fopen([soundpath filesep Names{cnt1} '.txt'],'r');
        s = fgetl(f);
        fclose(f);
        spaces = strfind(s,' ');
        se.Note = s(spaces(2)+1:end);
        se.Note = strrep(se.Note, '''', '"');
        se.StartTime = [];
        se.StopTime = [];
        %%
        Phonemes{cnt1} = ph;
        Words{cnt1} = wr;
        Sentences{cnt1} = se;
    end
end
o = set(o,'Names',Names);
o = set(o,'Phonemes',Phonemes);
o = set(o,'Words',Words);
o = set(o,'Sentences',Sentences);
o = set(o,'MaxIndex', length(Names));
% o = set(o,'SamplingRate', fs);