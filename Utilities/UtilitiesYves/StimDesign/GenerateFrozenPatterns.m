% FrozenAdress = [DBfolder filesep 'ABCng' filesep 'FrozenPatterns'];
% FrozenAdress = 'F:\scripts';
FrozenAdress = 'C:\Code\baphy\Utilities\UtilitiesYves\FrozenPatterns';
FrozenPatternsNb = 16;
GenerateFrozen = 1;
ChordDuration = 0.03;
FrozenDuration = 1;   % s
FrozenDuration = round(FrozenDuration/ChordDuration)*ChordDuration;
IsFef = []; Mode = []; 
for FrozenNum = 1:FrozenPatternsNb
    o = TextureMorphing();
    o = set(o,'Inverse_D0Dbis','no');
    o = set(o,'PreStimSilence',0);
    o = set(o,'MinToC',num2str(ceil(2*FrozenDuration)));
    o = set(o,'MaxToC',num2str(ceil(3*FrozenDuration)));
    o = set(o,'FrequencyRange',[500 20000]);
    o = ObjUpdate(o);
    MaxIndex = get(o,'MaxIndex');
    Index = min(randi(MaxIndex,1)); Global_TrialNb = FrozenNum;
    [ w , ev , o , D0 , ChangeD , Parameters] = waveform(o,Index,IsFef,Mode,Global_TrialNb);
    sF = get(o,'SamplingRate');
    
    FrozenPatterns{FrozenNum} = w(1:((FrozenDuration*sF)+1));
    FrozenToneMatrices{FrozenNum} = Parameters.ToneMatrix{1}(:,1:(FrozenDuration/ChordDuration));
end
save([FrozenAdress filesep 'FrozenPatterns.mat'],'FrozenPatterns');
save([FrozenAdress filesep 'FrozenToneMatrices.mat'],'FrozenToneMatrices');
