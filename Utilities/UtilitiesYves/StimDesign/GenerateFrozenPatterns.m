FrozenAdress = [DBfolder filesep 'ABCng' filesep 'FrozenPatterns'];
FrozenPatternsNb = 16;
FrozenDuration = 2;   % s
GenerateFrozen = 1;
for FrozenNum = 1:FrozenPatternsNb
    o = TextureMorphing();
    o = set(o,'Inverse_D1D2','no');
    MaxIndex = get(o,'MaxIndex');
    Index = min([round(rand*MaxIndex)+1,8]); Global_TrialNb = FrozenNum;
    IsFef = []; Mode = []; [w,ev,o,FrozenToneMatrix] = waveformOutputToneMatrix(o,Index,IsFef,Mode,Global_TrialNb,GenerateFrozen);
    sF = get(o,'SamplingRate');
    FrozenPatterns{FrozenNum} = w(1:((FrozenDuration*sF)+1));
    FrozenToneMatrices{FrozenNum} = FrozenToneMatrix;
end
save([FrozenAdress filesep 'FrozenPatterns.mat'],'FrozenPatterns');
save([FrozenAdress filesep 'FrozenToneMatrices.mat'],'FrozenToneMatrices');
