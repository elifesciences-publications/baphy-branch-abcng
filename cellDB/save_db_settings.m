function save_db_settings;

global CELLDB_USER CELLDB_ANIMAL CELLDB_SITEID CELLDB_RUNCLASS
global CELLDB_CHANNEL CELLDB_SIGMA CELLDB_GLOBAL_SIGMA CELLDB_PENID
global USECOMMONREFERENCE
global BAPHYHOME

% load existing settings
configfile=[BAPHYHOME filesep 'Config' filesep 'MeskaSettings.mat'];

usersettings.animal=CELLDB_ANIMAL;
usersettings.siteid=CELLDB_SITEID;
usersettings.runclass=CELLDB_RUNCLASS;
usersettings.channel=CELLDB_CHANNEL;
usersettings.sigma=CELLDB_SIGMA;
usersettings.global_sigma=CELLDB_GLOBAL_SIGMA;
usersettings.common_reference=USECOMMONREFERENCE;
if isempty(CELLDB_PENID),
    usersettings.penid=CELLDB_SITEID(1:(end-1));
else
    usersettings.penid=CELLDB_PENID;
end

if exist(configfile,'file'),
   load(configfile);
else
   settings=[];
end

settings.lastuser=CELLDB_USER;
settings=setfield(settings,CELLDB_USER,usersettings);


disp('saving settings');
save(configfile,'settings');
