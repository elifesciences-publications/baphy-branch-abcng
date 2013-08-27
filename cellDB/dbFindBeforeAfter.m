function [before after] = dbFindBeforeAfter(list, runclass)
% function nlist = dbFindBeforeAfter(list, runclass)
%
% find the immediate before and after files of the specified runclass
% list: should contain one neuron structure as returned from dbFindFile
%   command
% runclass: runclass of the desired before and after

% Nima, July 2006

before = [];
after = [];
a = dbgetsite(list.cellid);
b = cat(1,a.id);
index = find(b==list.id);
% find before:
bindex = [];
for cnt1 = index:-1:1
    if strcmpi(a(cnt1).runclass,runclass) && ~a(cnt1).bad
        bindex = cnt1;
        break;
    end
end
% after:
aindex = [];
for cnt1 = index:length(a)
    if strcmpi(a(cnt1).runclass,runclass) && ~a(cnt1).bad
        aindex = cnt1;
        break;
    end
end
if ~isempty(bindex), before=a(bindex);end
if ~isempty(aindex), after=a(aindex);end
% there are cases where the sorted file exists, but it hasn't been recorded
% in the database. For those cases, fill the matlabfile manually:

if ~isempty(bindex) % && isempty(before.matlabfile)
    OPath = fileparts(list.matlabfile);
    [t1,t2,t3]= fileparts(before.parmfile);
    sortedfile = [OPath filesep t2 '.spk.mat'];
    if ~exist(sortedfile,'file')
        sortedfile = [before.resppath 'sorted' filesep t2 '.spk.mat'];
    end
    if ~exist(sortedfile,'file')
        t1 = strfind(before.resppath,filesep);
        t1 = before.resppath(1:t1(end-1));
        sortedfile = [t1 'sorted' filesep t2 '.spk.mat'];
    end
    if exist(sortedfile,'file')
        before.matlabfile = sortedfile;
    end
end
if ~isempty(aindex) % && isempty(after.matlabfile)
    OPath = fileparts(list.matlabfile);
    [t1,t2,t3]= fileparts(after.parmfile);
    sortedfile = [OPath filesep t2 '.spk.mat'];
    if ~exist(sortedfile,'file')
        sortedfile = [after.resppath 'sorted' filesep t2 '.spk.mat'];
    end
    if ~exist(sortedfile,'file')
        t1 = strfind(after.resppath,filesep);
        t1 = after.resppath(1:t1(end-1));
        sortedfile = [t1 'sorted' filesep t2 '.spk.mat'];
    end
    if exist(sortedfile,'file')
        after.matlabfile = sortedfile;
    end
end
