function stat = dbCopyFiles (nlists,destdir,TBA,ExcludeSorted)
% function stat = dbCopyFiles (nlists,destdir,TBA,ExcludeSorted)
%
% nlist: list of sites
% destdir: destination directory
% ExcludeSorted: 0: copy everything, 1: only copy the files that have not
% been sorted
% TBA: also copy torc before and after
%
% stat: the status of each site. 0:fail 1:succeed -1:skipped
%
% Hint: nlist should be generated using dbGenerateReport, because it scans
% the sorted directories in addition to the database.

% Nima
if nargin<4, ExcludeSorted = 1;end
if nargin<3, TBA = 0; end
if ~exist(destdir,'dir')
    mkdir(destdir);
end
stat=[];
for cnt1 = 1:length(nlists)
    disp([num2str(cnt1) ' out of ' num2str(length(nlists))]);
    % this command works both for dbFindFile output and dbGenerateReport
    if ~isfield(nlists,'cellid'), nlist = nlists(cnt1).site;else nlist = nlists(cnt1);end
    if (~ExcludeSorted) || (ExcludeSorted && isempty(nlist.matlabfile))
        [t, filename, t] = fileparts(nlist.parmfile);
        stat(cnt1) = copyfile([nlist.resppath filename '.*'], destdir);
        if TBA
            [b a] = dbFindBeforeAfter (nlist, 'TOR');
            if ~isempty(b)
                [t, filename, t] = fileparts(b.parmfile);
                s=copyfile([b.resppath filename '.*'], destdir);
            end
            if ~isempty(a)
                [t, filename, t] = fileparts(a.parmfile);
                s=copyfile([a.resppath filename '.*'], destdir);
            end
        end
    else
        stat = double(stat);
        stat(cnt1)=-1;
    end
    switch stat(cnt1)
        case 1, disp('successful');
        case 0, disp('failed');
        case -1, disp('skipped');
    end
end