% function [cellfiledata,cellids,cellfileids]=dbgetscellfile([field,filter],...)
%
% return the cellfiledata and cellfileids masked by filter specified
% by parameters. parameter format is ('field',value).
%
% PARAMETERS:
% 'rawid' - id in gDataRaw table (select a single data file)
% 'cellid' - name of cell, can be partial. eg, 'R' will return all
%            cells with the name "R*" (R110A, R210A, R225C, etc)
% 'runclass' - 3-letter code for runclass (TOR, VOC, PTD, etc
% 'runclassid' - numeric code (or vecotr of codes) for runclass
% 'respfmtcode' - response format
%                 0: PSTH (binned in time 14 or 16 ms)
%                 1: PFTH (fixation aligned response)
% 'area' - match area field in sCellFile (% is the wildcard) so
%          'area','A1%' will return data for all cells whose area
%          field begins with 'A1'
% <field_name> - find all instances of gData.name=field_name with
%                value matching filter value
% 'well' - match gPenetration.well, craniotomy number
% 'speed' - speed of stimulus in Hz (old)
% 'fmt' - file of preprocessed stimulus (old)
%
% EXAMPLES:
% dbgetscellfile('cellid','R110A') - return all data for cell R110A.
% dbgetscellfile('cellid','R110A','runclass','TOR') 
%                - return all data for cell R110A from TOR runclass
% dbgetscellfile('cellid','sir028c-a1','runclass','SPC','Ref_SNR',0) 
%                - find Speech data for cell sir028c-a1 with SNR 0
%
% RETURNS (example):
% cellfiledata( ).id: 795                         % id in sCellFile
%             cellid: 'R110A'
%           masterid: 82                          % id of cell in gCellMaster
%              rawid: 209                         % id in gDataRaw
%         celldataid: 183
%         runclassid: 1                              % ie, gratrev
%               path: '/auto/k5/david/data/R110A/'   % path to respfile
%            resplen: 21467
%           repcount: 1
%           respfile: 'R110A.gratsize.1.all.d-svsizemult1.0-.psth.neg_flag'
%        respvarname: 'R110A'
%       respfiletype: 1
%             nosync: 0
%        respfilefmt: '14ms PSTH'
%        respfmtcode: 0
%           stimfile: 'dat.R110A.gratrev.imsm'
%       stimfiletype: 1
%       stimiconside: '32,32'
%        stimfilecrf: 2
%     stimwindowsize: 32
%        stimfilefmt: 'pixel'                    % 'fmt' name
%        stimfmtcode: 0
%            addedby: 'david'
%               info: 'dbcrap.m - from tCellFile'
%            lastmod: '20030220152821'
%           stimpath: '/auto/k5/david/data/R110A/'   % path to stimfile
%        stimspeedid: 0
%             spikes: 13270
%            multrep: 0
% cellids: cell array of unique cellids matched in search
%
% CREATED SVD 2/28/03
%
function [cellfiledata,cellids,cellfileids]=dbgetscellfile(varargin)

dbopen;

narg = 1;
wherestr='WHERE 1';
require_gData=0;
while narg <= length(varargin)
   switch varargin{narg}
    case 'rawid'
     rawids = varargin{narg + 1};
     srawid='(';
     for ii=1:length(rawids),
        srawid=[srawid,num2str(rawids(ii)),','];
     end
     srawid(end)=')';
     wherestr=[wherestr,' AND sCellFile.rawid in ',srawid];
     
    case 'cellid'
     wherestr=[wherestr,' AND sCellFile.cellid like "',varargin{narg + 1},'%"'];

    case 'fmt'
     wherestr=[wherestr,' AND sCellFile.stimfilefmt="',varargin{narg + 1},'"'];

    case 'runclass'
     % SVD aug 2005 -- added gRunClass lookup so strings can be
     % used
     tsql=['SELECT * FROM gRunClass WHERE name = "',upper(varargin{narg+1}),'"'];
     rcdata=mysql(tsql);
     wherestr=[wherestr,' AND sCellFile.runclassid=',num2str(rcdata(1).id)];
     
    case 'runclassid'
     % BW mar 2005 -- altered to take a vector of runclassids
     if length(varargin{narg + 1})==1
       wherestr=[wherestr,' AND sCellFile.runclassid=',num2str(varargin{narg + 1})];
     else
       wherestr=[wherestr,' AND sCellFile.runclassid in ('];
       for ii=1:length(varargin{narg+1}),
	 wherestr=[wherestr,num2str(varargin{narg + 1}(ii)),','];
       end
       wherestr(end)=')';
     end
       
    case 'stimsnr'
     if varargin{narg + 1}>=100,
        wherestr=[wherestr ' AND stimsnr>=',num2str(varargin{narg + 1})];
     else
        wherestr=[wherestr ' AND stimsnr=',num2str(varargin{narg + 1})];
     end
     
    case 'speedgt'
     wherestr=[wherestr,' AND sCellFile.stimspeedid>=',...
               num2str(varargin{narg+1})];
     
    case 'speed'
     % BW mar 2005 -- altered to take a vector of speeds
     if length(varargin{narg + 1})==1
       wherestr=[wherestr,' AND sCellFile.stimspeedid=',...
                 num2str(varargin{narg + 1})];
     else
       wherestr=[wherestr,' AND sCellFile.stimspeedid in ('];
       for ii=1:length(varargin{narg+1}),
	 wherestr=[wherestr,num2str(varargin{narg + 1}(ii)),','];
       end
       wherestr(end)=')';
     end
    
    case 'respfmtcode'
     wherestr=[wherestr,' AND sCellFile.respfmtcode=',num2str(varargin{narg + 1})];
    case 'stimfmtcode'
     wherestr=[wherestr,' AND sCellFile.stimfmtcode=',num2str(varargin{narg + 1})];
    case 'respfmt'
     wherestr=[wherestr,' AND sCellFile.respfilefmt="',varargin{narg + 1},'"'];
    
    case 'area'
     wherestr=[wherestr,' AND sCellFile.area in (''',(varargin{narg + 1}),''')'];
    case 'behavior'
     if varargin{narg + 1}~=0,
        wherestr=[wherestr,' AND gDataRaw.behavior="active"'];
     else
        wherestr=[wherestr,' AND gDataRaw.behavior<>"active"'];
     end
     
    case 'lfp',
     if varargin{narg + 1},
        wherestr=[wherestr,...
                  ' AND not(gPenetration.animal in ("jill","coral","topaz","opal"))'];
     end
    % added BW mar 2005 - takes a scalar/vector of well numbers
    case 'well'
     if length(varargin{narg + 1})==1
       wherestr=[wherestr,' AND gPenetration.well=',num2str(varargin{narg + 1})];
     else
       wherestr=[wherestr,' AND gPenetration.well in ('];
       for ii=1:length(varargin{narg+1}),
	 wherestr=[wherestr,num2str(varargin{narg + 1}(ii)),','];
       end
       wherestr(end)=')';
     end
     
    otherwise
     require_gData=require_gData+1;
     tname=['gData',num2str(require_gData)];
     if isnumeric(varargin{narg+1}),
        %fprintf('guessing %s option: %s = %d\n', ...
        %        tname,varargin{narg},varargin{narg+1});
        wherestr=[wherestr,' AND ',tname,'.name="',varargin{narg},'"',...
                  ' AND ',tname,'.value=',num2str(varargin{narg+1})];
     elseif ismember(varargin{narg+1}(1),{'=','>','<'}),
        %fprintf('guessing %s option: %s %s\n', ...
        %        tname,varargin{narg},varargin{narg+1});
        wherestr=[wherestr,' AND ',tname,'.name="',varargin{narg},'"',...
                  ' AND ',tname,'.value',varargin{narg+1}];
     elseif strcmpi(varargin{narg+1}(1:4),'like'),
        %fprintf('guessing %s option: %s %s\n', ...
        %        tname,varargin{narg},varargin{narg+1});
        wherestr=[wherestr,' AND ',tname,'.name="',varargin{narg},'"',...
                  ' AND ',tname,'.svalue ',varargin{narg+1}];
     else
        %fprintf('guessing %s option: %s = %s\n', ...
        %        tname,varargin{narg},varargin{narg+1});
        wherestr=[wherestr,' AND ',tname,'.name="',varargin{narg},'"',...
                  ' AND ',tname,'.svalue="',varargin{narg+1},'"'];
     end
     
   end
   narg = narg + 2;
end

gdstr='';
for gg=1:require_gData,
   tname=['gData',num2str(gg)];
   gdstr=[gdstr, ' INNER JOIN gData ',tname,' ON ',...
          tname,'.rawid=sCellFile.rawid '];
end

sql=['SELECT sCellFile.*,gDataRaw.bad,gDataRaw.behavior,gDataRaw.reps,',...
     'gPenetration.animal,gPenetration.well,gSingleRaw.isolation,',...
     '(repcount>2) as multrep',...
     ' FROM ((sCellFile INNER JOIN gDataRaw ON sCellFile.rawid=gDataRaw.id)',...
     ' INNER JOIN gSingleCell ON sCellFile.singleid=gSingleCell.id) ',...
     ' INNER JOIN gSingleRaw ON (sCellFile.singleid=gSingleRaw.singleid',...
     ' AND sCellFile.rawid=gSingleRaw.rawid)',...
     ' INNER JOIN gPenetration ON gSingleCell.penid=gPenetration.id '...
     gdstr,wherestr,...
     ' AND not(gDataRaw.bad) AND not(gSingleCell.crap)',...
     ' ORDER BY cellid,respfile'];
     %' ORDER BY cellid,stimspeedid,repcount,resplen DESC,respfile'];
cellfiledata=mysql(sql);
cellfileids=cat(1,cellfiledata.id);

for ii=1:length(cellfiledata),
    if cellfiledata(ii).reps>cellfiledata(ii).repcount,
        cellfiledata(ii).repcount=cellfiledata(ii).reps;
        cellfiledata(ii).multrep=double(cellfiledata(ii).reps>1);
    end
end


cellids={cellfiledata.cellid};
cellids=unique(cellids);

return

sql=['SELECT DISTINCT sCellFile.cellid',...
     ' FROM (sCellFile',...
     ' INNER JOIN gSingleCell ON sCellFile.singleid=gSingleCell.id) ',...
     ' INNER JOIN gPenetration ON gSingleCell.penid=gPenetration.id '...
     gdstr,wherestr,' ORDER BY cellid'];
celliddata=mysql(sql);
cellids={celliddata.cellid};

