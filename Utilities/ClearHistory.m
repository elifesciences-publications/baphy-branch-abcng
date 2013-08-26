function ClearHistory;
% this function clears the history of baphy, 
global BAPHYHOME;
% including:
% guis:
delete([BAPHYHOME filesep 'config' filesep 'baphy.mat']);
delete([BAPHYHOME filesep 'config' filesep 'BaphyHwSetup.mat']);
delete([BAPHYHOME filesep 'config' filesep 'BaphyMainGuiSettings.mat']);
delete([BAPHYHOME filesep 'config' filesep 'BaphyRefTarGuiSettings.mat']);
% Sound objects:
d=dir([BAPHYHOME filesep 'SoundObjects\@*']);
for cnt1 = 1:length(d)
    delete([BAPHYHOME filesep 'SoundObjects' filesep d(cnt1).name filesep '*.mat']);
end
d=dir([BAPHYHOME filesep 'TrialObjects\@*']);
for cnt1 = 1:length(d)
    delete([BAPHYHOME filesep 'TrialObjects' filesep d(cnt1).name filesep '*.mat']);
end
