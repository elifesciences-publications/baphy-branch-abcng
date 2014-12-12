function load_db_settings

global CELLDB_USER CELLDB_ANIMAL CELLDB_SITEID CELLDB_RUNCLASS
global CELLDB_CHANNEL CELLDB_SIGMA CELLDB_GLOBAL_SIGMA CELLDB_PENID CELLDB_ALLANIMALS
global USECOMMONREFERENCE
global BAPHYHOME

configfile=[BAPHYHOME filesep 'Config' filesep 'MeskaSettings.mat'];
CELLDB_ALLANIMALS=0;
if exist(configfile,'file'),
    fprintf('loading %s\n',configfile);
    
    load(configfile);

    if isempty(CELLDB_USER),
        CELLDB_USER=settings.lastuser;
    end
    if isfield(settings,CELLDB_USER),
        usersettings=getfield(settings,CELLDB_USER);
        CELLDB_ANIMAL=usersettings.animal
        CELLDB_SITEID=usersettings.siteid;
        if isfield(usersettings,'penid'),
            CELLDB_PENID=usersettings.penid;
        else
            CELLDB_PENID=CELLDB_SITEID(1:(end-1));
        end
        CELLDB_RUNCLASS=usersettings.runclass;
        CELLDB_CHANNEL=usersettings.channel;
        CELLDB_SIGMA=usersettings.sigma;
        if isfield(usersettings,'global_sigma'),
            CELLDB_GLOBAL_SIGMA=usersettings.global_sigma;
        else
            CELLDB_GLOBAL_SIGMA=0;
        end
        CELLDB_ALLANIMALS=getparm(usersettings,'all_animals',0);
        if isfield(usersettings,'common_reference'),
            USECOMMONREFERENCE=usersettings.common_reference;
        end
    end
end
if isempty(CELLDB_USER),
    CELLDB_USER='david';
end
if isempty(CELLDB_ANIMAL),
    %sql='SELECT * from gAnimal order by animal limit 1';
    sql=['SELECT gAnimal.* FROM gAnimal,gCellMaster',...
      ' WHERE gAnimal.animal=gCellMaster.animal',...
      ' GROUP BY gAnimal.id ORDER BY animal LIMIT 1'];
    animaldata=mysql(sql);
    CELLDB_ANIMAL=animaldata.animal;
    CELLDB_SITEID='%';
    CELLDB_PENID='%';
    CELLDB_RUNCLASS={'ALL'};
    CELLDB_CHANNEL=1;
    CELLDB_SIGMA=4;
    CELLDB_GLOBAL_SIGMA=0;
end
