cd C:\Users\Booth1\Desktop\ReconstructStim
mFile = 'Test_2017_05_04_TMP_23.m';
DataRootFolder = 'C:\Data\Test\training2017\';
StimuliRootFolder = 'C:\Data\Stimuli\';
[Stimuli,ChangeTimes,options,Behavior] = ...
  TMG_ResynthesizeStim(mFile,'RootAdress',DataRootFolder);
save([StimuliRootFolder mFile(1:end-2)],'Stimuli','ChangeTimes','options');