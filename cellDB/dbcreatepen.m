% function penid=dbcreatepen(globalparams)
%
% created SVD 2005-11-21
%
function penid=dbcreatepen(globalparams)

dbopen;

sql=sprintf('SELECT * FROM gAnimal WHERE animal like "%s"',...
            globalparams.Ferret);
adata=mysql(sql);
if length(adata)==0,
   error('Ferret not found in cellDB!');
end
globalparams.animal=adata(1).animal;

sql=sprintf('SELECT * FROM gUserPrefs WHERE realname like "%%%s%%"',...
            globalparams.Tester);
udata=mysql(sql);
if length(udata)==0,
    sql=sprintf('SELECT * FROM gUserPrefs WHERE userid like "%%%s%%"',...
            globalparams.Tester);
    udata=mysql(sql);
end
if length(udata)==0,
   error('Tester not found in cellDB!');
end
globalparams.who=udata(1).userid;

sql=['SELECT max(id) as maxid FROM gPenetration' ...
     ' WHERE training in (0,1) AND animal="',globalparams.animal,'"'];
lastpendata=mysql(sql);

if isempty(lastpendata.maxid),
   
   warning('No penetrations exist for this animal. Guessing info from scratch.');
   
   if ~isfield(globalparams,'well'),
      globalparams.well=1;
   end
   globalparams.cellprefix=adata(1).cellprefix;
   globalparams.eye='';
   globalparams.mondist=0;
   globalparams.etudeg=0;
else
   
   sql=['SELECT gPenetration.*, gAnimal.cellprefix FROM gPenetration'...
        ' INNER JOIN gAnimal ON gAnimal.animal=gPenetration.animal'...
        ' WHERE gPenetration.id=',num2str(lastpendata.maxid)];
   lastpendata=mysql(sql);
   
   fprintf('Guessing info from pen %s\n', lastpendata.penname);

   if ~isfield(globalparams,'well'),
      globalparams.well=lastpendata.well;
   end
   globalparams.cellprefix=lastpendata.cellprefix;
   globalparams.eye=lastpendata.eye;
   globalparams.mondist=lastpendata.mondist * 1.0;
   globalparams.etudeg=lastpendata.etudeg * 1.0;
end

globalparams.numchans=globalparams.NumberOfElectrodes;
if strcmp(globalparams.Physiology,'No'),
    globalparams.training=1;
else
    globalparams.training=0;
end
globalparams.probenotes='';
globalparams.electrodenotes='';

% Log hardware setup-specific information
try
    HWSetupSpecs=BaphyMainGuiItems('HWSetupSpecs',globalparams);
    ff=fields(HWSetupSpecs);
    for ii=1:length(ff),
        globalparams.(ff{ii})=HWSetupSpecs.(ff{ii});
    end
catch
    % this information should be moved to <config>\<lab>\BaphyMainGuiItems
    % case 'HWSetupSpecs'
    switch globalparams.HWSetup,
        case 0,
            globalparams.racknotes='TEST MODE';
            globalparams.speakernotes='';
            globalparams.probenotes='';
            globalparams.ear='';
        case 1,
            globalparams.racknotes=sprintf('Soundproof room 1, pump cal: %.2f ml/sec',globalparams.PumpMlPerSec.Pump);
            globalparams.speakernotes='Etymotic earphone. Calibrated: Krohn-Hite filter, Rane equalizer, HP attenuator, Rane amplifier. (2007-09-24)';
            if ~globalparams.training,
                globalparams.probenotes=sprintf('%d-channel. Well position: XXX',globalparams.numchans);
                globalparams.electrodenotes='FHC: size, impendence not specified';
            end
            globalparams.ear='R';
        case 2,
            globalparams.racknotes=sprintf('Training rig 1, pump cal: %.2f ml/sec',globalparams.PumpMlPerSec.Pump);
            globalparams.speakernotes='Free field, front facing.  Crown amplifier. (2006-04-28)';
            globalparams.ear='B';
        case 3,
            globalparams.racknotes=sprintf('Soundproof room 2, pump cal: %.2f ml/sec',globalparams.PumpMlPerSec.Pump);
            globalparams.speakernotes='Etymotic earphone.  Calibrated: Krohn-Hite filter, Rane equalizer, HP attenuator, Radio Shack amplifier. (2006-04-28)';
            if ~globalparams.training,
                globalparams.probenotes=sprintf('%d-channel. Well position: XXX',globalparams.numchans);
                globalparams.electrodenotes='FHC: size, impendence not specified';
            end
            globalparams.ear='L';
        case 4,
            globalparams.racknotes=sprintf('Training rig 2, pump cal: %.2f ml/sec',globalparams.PumpMlPerSec.Pump);
            globalparams.speakernotes='Free field, front facing. Onkyo amplifier. (2006-04-28)';
            globalparams.ear='B';
        case 5,
            globalparams.racknotes=sprintf('Holder training booth 1, pump cal: %.2f ml/sec',globalparams.PumpMlPerSec.Pump);
            globalparams.speakernotes='Etymotic earphone.  Calibrated: Krohn-Hite filter, Rane equalizer, HP attenuator, Rane amplifier. (2007-02-10)';
            if ~globalparams.training,
                globalparams.probenotes=sprintf('%d-channel. Well position: XXX',globalparams.numchans);
                globalparams.electrodenotes='FHC: size, impendence not specified';
            end
            globalparams.ear='L';
        otherwise,
            globalparams.racknotes='UNKNOWN';
            globalparams.speakernotes='UNKNOWN';
            globalparams.ear='';
    end
end

sql=['SELECT * FROM gPenetration'...
     ' WHERE animal="',globalparams.animal,'"',...
     ' AND pendate="',globalparams.date,'" AND training=2'];
wdata=mysql(sql);

if length(wdata)>0,
   penid=wdata(1).id;
   sql=['UPDATE gPenetration SET',...
        ' penname="',globalparams.penname,'",',...
        'animal="',globalparams.animal,'",',...
        'well=',num2str(globalparams.well),',',...
        'pendate="',globalparams.date,'",',...
        'who="',globalparams.who,'",',...
        'fixtime="',datestr(now,'HH:MM'),'",',...
        'ear="',globalparams.ear,'",',...
        'numchans=',num2str(globalparams.numchans),',',...
        'rackid=',num2str(globalparams.HWSetup),',',...
        'racknotes="',globalparams.racknotes,'",',...
        'speakernotes="',globalparams.speakernotes,'",',...
        'probenotes="',globalparams.probenotes,'",',...
        'electrodenotes="',globalparams.electrodenotes,'",',...
        'training=',num2str(globalparams.training),',',...
        'addedby="',globalparams.who,'",',...
        'info="dbcreatepen.m"',...
        ' WHERE id=',num2str(penid)];
   mysql(sql);
   fprintf('updated gPenetration entry %d\n',penid);
else
   [aff,penid]=sqlinsert('gPenetration',...
                         'penname',globalparams.penname,...
                         'animal',globalparams.animal,...
                         'well',globalparams.well,...
                         'pendate',globalparams.date,...
                         'who',globalparams.who,...
                         'fixtime',datestr(now,'HH:MM'),...
                         'ear',globalparams.ear,...
                         'numchans',globalparams.numchans,...
                         'rackid',globalparams.HWSetup,...
                         'racknotes',char(globalparams.racknotes),...
                         'speakernotes',char(globalparams.speakernotes),...
                         'probenotes',char(globalparams.probenotes),...
                         'electrodenotes',char(globalparams.electrodenotes),...
                         'training',globalparams.training,...
                         'addedby',globalparams.who,...
                         'info','dbcreatepen.m');
   fprintf('added gPenetration entry %d\n',penid);
end
