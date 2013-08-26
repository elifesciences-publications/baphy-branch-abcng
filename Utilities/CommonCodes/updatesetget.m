% update set and get for all classes
% This function copies the set and get from getsetparent to all parent
% classes and from getsetchild to all child classes:

% startup;
global BAPHYHOME;
% get and set to all Soundobjects
cpath = [BAPHYHOME filesep 'Utilities' filesep 'CommonCodes'];
files = {'get.m', 'set.m'};
for cnt2 = 1:length(files)
    % get set for sound objects
    d=dir([BAPHYHOME filesep 'SoundObjects\@*']);
    for cnt1=1:length(d)
        cmd = ['copy ' cpath filesep files{cnt2} ' ' BAPHYHOME filesep 'SoundObjects' filesep d(cnt1).name];
        system(cmd);        
    end
    % get set for trial objects
    d=dir([BAPHYHOME filesep 'Modules' filesep 'RefTar' filesep 'TrialObjects' filesep '@*']);
    for cnt1=1:length(d)
        cmd = ['copy ' cpath filesep files{cnt2} ' ' BAPHYHOME filesep 'Modules' filesep 'RefTar' filesep 'TrialObjects' filesep d(cnt1).name]
        system(cmd);
    end
    % get set for behavior objects
    d=dir([BAPHYHOME filesep 'Modules' filesep 'RefTar' filesep 'BehaviorObjects' filesep '@*']);
    for cnt1=1:length(d)
        cmd = ['copy ' cpath filesep files{cnt2} ' ' BAPHYHOME filesep 'Modules' filesep 'RefTar' filesep 'BehaviorObjects' filesep d(cnt1).name];
        system(cmd);
    end
end
% ObjLoadSaveDefaults only to parent objects:
cmd = ['copy ' cpath filesep 'Obj*.m ' BAPHYHOME filesep 'SoundObjects' filesep '@SoundObject'];
system(cmd);
d=dir([BAPHYHOME filesep 'Modules' filesep 'RefTar' filesep 'TrialObjects' filesep '@*']);
for cnt1=1:length(d)
    cmd = ['copy ' cpath filesep 'Obj*.m ' BAPHYHOME filesep 'Modules' filesep 'RefTar' filesep 'TrialObjects' filesep d(cnt1).name];
    system(cmd);
end
d=dir([BAPHYHOME filesep 'Modules' filesep 'RefTar' filesep 'BehaviorObjects' filesep '@*']);
for cnt1=1:length(d)
    cmd = ['copy ' cpath filesep 'Obj*.m ' BAPHYHOME filesep 'Modules' filesep 'RefTar' filesep 'BehaviorObjects' filesep d(cnt1).name];
    system(cmd);
end
