function list=dbGenerateReport (animal,runclass,IsTrain,FileName,TBA)
% function nlist=dbGenerateReport (animal,runclass,IsTrain,FileName,TBA)
%
% this function generates a report for the specified parameters and returns
% them in an array and also write them in a file suitable for printing.
% animal: e.g.    'Jill'
% runclass: e.g.  'Clk'
% IsTrain: 1: training only, 0: physiology
% Filename: name of the report file, e.g: 'C:\Jill.txt'
% TBA: list the Torc data immediately before and after the file
%
% the output has the following info: full name of the file, # of channels
% in that penetration, number of trials, performance (discrimination rate
% if exists), and whether the file is sorted or not. DB sorted means the
% database indicate the file is sorted, File sorted means a spk.mat file
% exists for that experiment in the "sorted*" directory.
%
% exmaple:
%    list = dbGenerateReport ('Jill','CLK',0,'C:\Jill.txt',0);

% Nima, Jan2007

if nargin<5, TBA=0;end
Header = {'File name','# of channels','# Trials','Performance','Sorting'};
if exist('FileName','var') && ~isempty(FileName)
    fid = fopen(FileName,'w');
    fprintf(fid,'%s\t\t\t\t\t%s\t%s\t%s\t%s',Header{1},Header{2},Header{3},Header{4},Header{5});
    fprintf(fid,'\n---------------------------------------------------------------------------------------');
    FFlag=1;
else
    fid=0;
    FFlag=0;
end
n = dbFindFile(runclass,animal,IsTrain);
for cnt1 = 1:length(n)
    disp([num2str(cnt1) ' out of ' num2str(length(n))]);
    if FFlag, fprintf(fid,'\n');end
    if TBA
        [b a] = dbFindBeforeAfter (n(cnt1), 'TOR');
    else
        b=[];a=[];
    end
    if ~isempty(b)
        list(cnt1).before = addfile(fid,b,FFlag);
    end
    list(cnt1).site = addfile(fid,n(cnt1),FFlag);
    if ~isempty(a)
        list(cnt1).after = addfile(fid,a,FFlag);
    end
end
if FFlag, fclose(fid);end

%%%%%%%%%%%%%%%%%%%%%%%%%

function nn = addfile(fid,nn,FFlag)
if ~isempty(nn.resppath) && strcmpi(nn.resppath(1),'M') ...
        && exist([nn.resppath filesep nn.parmfile],'file')
    clear exptparams exptevetns globalparams;
    try
        LoadMFile([nn.resppath filesep nn.parmfile]);
        RPT = {[nn.resppath nn.parmfile],...
            num2str(globalparams.NumberOfElectrodes ),...
            num2str(exptparams.TotalTrials)};
        if isfield(exptparams,'Performance') & isfield(exptparams.Performance,'DiscriminationRate')
            RPT{4} = num2str(exptparams.Performance(end).DiscriminationRate);
            nn.corrtrials = exptparams.Performance(end).DiscriminationRate;
        else
            RPT{4} = '--';
        end
    catch
        RPT = {[nn.resppath nn.parmfile],...
            '--','--','--'};
    end
else
    RPT = {[nn.resppath nn.parmfile],...
        '--','--','--'};
end
% now get the sorting:
RPT{5}=[];
if ~isempty(nn.matlabfile), RPT{5}=[ RPT{5} 'DB'];end
temppath = fileparts(nn.resppath);
tmp = strfind(temppath,filesep);
mainpath = temppath(1:tmp(end)-1);
sortedpath = dir([mainpath filesep 'sort*']);
if isempty(sortedpath),
    sortedpath = dir([temppath filesep 'sort*']);
    if ~isempty(sortedpath), mainpath = temppath;end
end
if length(sortedpath)>0
    % its possible that more than one sorted directory exist. check them
    % all
    for cnt1 = 1:length(sortedpath)
        [t,fname]=fileparts(nn.parmfile);
        if exist([mainpath filesep sortedpath(cnt1).name filesep fname '.spk.mat'],'file'),
            RPT{5} = [RPT{5} ' File'];
            nn.matlabfile = [mainpath filesep sortedpath(1).name filesep fname '.spk.mat'];
            break
        end
    end
end
if isempty(RPT{5}), RPT{5}='--';end
if FFlag, fprintf(fid,'\n%s\t%s\t\t\t%s\t\t%s\t%s',RPT{1},RPT{2},RPT{3},RPT{4},RPT{5});end