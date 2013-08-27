function nlist = dbFindFile(runclass, animal, IsTrain, startdate, SortPriority,extrafields)
% function nlist = dbFindFile(runclass, animal, IsTrain, startdate, SortPriority,extrafields)
%
% nlist: list of sites
% runclass: ex: 'TOR'
% animal: ex: 'Luna'
% IsTrain: 0: physiology   1: training only
% startdate: only use data after date 'yyyy-mm-dd'
% SortPriority: if its 1, look in the Animal/Sorted for the sorted spike file
% first, if its 0, look in the original location of the file for the sorted
% spike file. Its useful specially when sorting many files of an animal
% that has files all over the place (e.g. Jill);
% extrafields: can be any other field that user wants to specify. I
% contains even number of strings in the 'field' 'value' format

% Nima, 2006 July
if ~exist('SortPriority','var'),
    SortPriority = 0;
end
if ~exist('extrafields','var')
    extrafields = [];
end
dbopen;
sql=['select gDataRaw.* from gDataRaw,gCellMaster,gPenetration where' ...
    ' gDataRaw.masterid=gCellMaster.id AND gCellMaster.penid=gPenetration.id' ...
    ' AND not(gDataRaw.bad) AND runclass="' runclass '"'];

if exist('animal','var') && ~isempty(animal)
    sql = [sql ' and gPenetration.animal="' animal '"'];
end
if exist('IsTrain','var')
    if IsTrain==0
        sql = [sql ' and not(gDataRaw.training)'];
    else
        sql = [sql ' and gDataRaw.training'];
    end
end
if exist('startdate','var') && ~isempty(startdate);
    sql=[sql ,' AND pendate>="' startdate '"'];
end
sql=[sql ' ORDER BY pendate,gDataRaw.id'];
if ~isempty(extrafields)
    for cnt1 = 1:2:length(extrafields)
        sql = [sql ' and ' extrafields{cnt1} '=' extrafields{cnt1+1}];
    end
end
nlist = mysql(sql);
% there are cases where the sorted file exists, but it hasn't been recorded
% in the database. For those cases, fill the matlabfile manually:
for cnt1 = 1:length(nlist)
    if isempty(nlist(cnt1).matlabfile)
        [t1,t2,t3]= fileparts(nlist(cnt1).parmfile);
        if SortPriority == 0
            sortedfile = [nlist(cnt1).resppath 'sorted' filesep t2 '.spk.mat'];
            if ~exist(sortedfile,'file')
                t1 = strfind(nlist(cnt1).resppath,filesep);
                t1 = nlist(cnt1).resppath(1:t1(end-1));
                sortedfile = [t1 'sorted' filesep t2 '.spk.mat'];
            end
            if exist(sortedfile,'file')
                nlist(cnt1).matlabfile = sortedfile;
            end
        else
            t1 = strfind(nlist(cnt1).resppath,filesep);
            t1 = nlist(cnt1).resppath(1:t1(2));
            sortedfile = [t1 animal filesep 'sorted' filesep t2 '.spk.mat']; %#ok<NASGU>
            if ~exist(sortedfile,'file')
                [t1,t2,t3]= fileparts(nlist(cnt1).parmfile);
                sortedfile = [nlist(cnt1).resppath 'sorted' filesep t2 '.spk.mat'];
            end
            if exist(sortedfile,'file')
                nlist(cnt1).matlabfile = sortedfile;
            end
        end
    end
end