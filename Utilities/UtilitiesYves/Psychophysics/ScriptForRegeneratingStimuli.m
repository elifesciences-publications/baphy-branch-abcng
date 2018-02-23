cd C:\Users\Booth1\Desktop\ReconstructStim
mFile = 'Test_2017_05_04_TMP_23.m';
DataRootFolder = 'C:\Data\Test\training2017\';
StimuliRootFolder = 'C:\Data\Stimuli\';
[Stimuli,ChangeTimes,options,Behavior] = ...
  TMG_ResynthesizeStim(mFile,'RootAdress',DataRootFolder);
Stimuli.ChangeTimes = ChangeTimes;
save([StimuliRootFolder mFile(1:end-2)],...
    '-struct','Stimuli','waveform','PreChangeToneMatrix','PostChangeToneMatrix','SoundStatistics','ChangeTimes');

%%
mFile = 'morbier027a01_p_TMG.m';
DistantRootFolder = 'M:\Morbier\morbier027\';
[Stimuli,ChangeTimes,options,Behavior] = ...
  TMG_ResynthesizeStim(mFile,'RootAdress','D:\Data\Morbier\morbier027\');
Stimuli.ChangeTimes = ChangeTimes;
save([DistantRootFolder mFile(1:end-2) '_ToneClouds.mat'],...
    '-struct','Stimuli','waveform','PreChangeToneMatrix','PostChangeToneMatrix','SoundStatistics','ChangeTimes');