% function dbSaveBaphyData(globalparams,exptparams);
% called by RefTarScript and/or by flush_data_to_server for any files where
% baphy crashed before RefTarScript completed.
%
function dbSaveBaphyData(globalparams,exptparams)

global DB_USER

if globalparams.rawid>0 && dbopen,
   [Parameters, Performance] = PrepareDatabaseData ( globalparams, exptparams);
   dbWriteData(globalparams.rawid, Parameters, 0, 0);  % this is parameter and dont keep previous data
   dbWriteData(globalparams.rawid, Performance, 1, 0); % this is performance and dont keep previous data
   
   globalparams.rawfilecount=exptparams.TotalTrials;
   if isfield(exptparams,'RepetitionCount'),
      RepCount=exptparams.RepetitionCount;
   elseif isfield(exptparams,'TotalRepetitions'),
      RepCount=exptparams.TotalRepetitions;
   elseif isfield(exptparams,'repcount'),
      RepCount=exptparams.repcount;
   else
      RepCount=0;
   end
   sql=['UPDATE gDataRaw SET trials=',...
      num2str(globalparams.rawfilecount),',',...
      ' reps=',num2str(RepCount),...
      ' WHERE id=',num2str(globalparams.rawid)];
   mysql(sql);
   if isfield(Performance,'HitRate') && isfield(Performance,'Trials')
      sql=['UPDATE gDataRaw SET corrtrials=',num2str(round(Performance.HitRate*Performance.Trials)),',',...
         ' trials=',num2str(Performance.Trials),' WHERE id=',num2str(globalparams.rawid)];
      mysql(sql);
   elseif isfield(Performance,'Hit') && isfield(Performance,'FalseAlarm')
      sql=['UPDATE gDataRaw SET corrtrials=',num2str(Performance.Hit(1)),',',...
         ' trials=',num2str(Performance.FalseAlarm(2)),' WHERE id=',num2str(globalparams.rawid)];
      mysql(sql);
   end

  % also, if 'water' is a field, make it accumulative:
  if isfield(exptparams, 'Water') && exptparams.Water>0,
    %%%%%%%%%%%%%% new water:
    sql=['SELECT gAnimal.id as animal_id,gHealth.id,gHealth.water'...
      ' FROM gAnimal LEFT JOIN gHealth ON gHealth.animal_id=gAnimal.id'...
      ' WHERE gAnimal.animal like "',globalparams.Ferret,'"',...
      ' AND date="',globalparams.date,'"'...
      ];
    hdata=mysql(sql);
    if ~isempty(hdata),
      % gHealth entry already exists, update
      if isempty(hdata.water) hdata.water = 0; end
      swater=sprintf('%.2f',hdata.water+exptparams.Water);
      sql=['UPDATE gHealth set schedule=1,trained=1,water=',...
        swater,' WHERE id=',num2str(hdata.id)];
    else
      % create new gHealth entry
      sql=['SELECT * FROM gAnimal WHERE animal like "',globalparams.Ferret,'"'];
      adata=mysql(sql);
      sql=['INSERT INTO gHealth (animal_id,animal,date,water,trained,schedule,addedby,info) VALUES'...
        '(',num2str(adata.id),',"',globalparams.Ferret,'",',...
        '"',datestr(now,29),'",'...
        num2str(exptparams.volreward),',1,1,"',DB_USER,'","dms_run.m")'];
    end
    mysql(sql);
  end
end