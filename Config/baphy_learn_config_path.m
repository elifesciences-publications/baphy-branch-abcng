dd=dir([BAPHYHOME filesep 'Config']);

labpaths={};
configfiles={};
labcount=0;
for ii=1:length(dd),
    if dd(ii).isdir && dd(ii).name(1)~='.',
        ConfigFile=[BAPHYHOME filesep 'Config' filesep dd(ii).name ...
            filesep 'BaphyConfigPath.' dd(ii).name '.m'];
        if exist(ConfigFile,'file'),
            labcount=labcount+1;
            labpaths{labcount}=dd(ii).name;
            configfiles{labcount}=ConfigFile;
        end
    end
end
[s,v] = listdlg('PromptString',{'Baphy lab not set. Choose a lab','or cancel for defaults.'},...
    'Name','Choose Lab',...
    'ListSize',[200 100],...
    'SelectionMode','single',...
    'ListString',labpaths);
if v,
    [res,msg] = copyfile(configfiles{s},[BAPHYHOME filesep 'Config' filesep 'BaphyConfigPath.m']);
    BaphyConfigPath;
end
