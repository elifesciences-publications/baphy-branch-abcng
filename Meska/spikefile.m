function [featxtdir,sstr,ctag] = spikefile(fname);
% [spikedir,filebase,paradigm] = SPIKEFILE(fname)
%
% fname    : string containing the experiment and filename, in unix format,
%            for example '225/30a07.a1-.fea' or 
%                        '/software/daqsc/data/225/30a07.a1-.fea'
% spikedir : the directory where the spike data is kept
%            for example, '/a/tango/spikedata/' or 
%                         'spikedata200_230:' (on a mac)
% filebase : the subdirectory and filename base of the specific unit requested
%            for example, '225/30a07.a1-' or '225:30a07.a1-' (on a mac)
% paradigm : the paradigm type of the stimulus, e.g. 'a1-' or 't1-'
%

% if unix and ~ in name, replace ~ with $HOME
%if isunix & strcmp(fname(1),'~')
%  fname = fullfile(getenv('HOME'),fname(2:end));
%end

% file parts
fnamelocal = strrep(fname,'/',filesep);

% create list of trial directories to look for file
testdirlist = {};

% Break off anything before exp subdirectory
% Use it as trial directory, use remainder as fname 
dirseplocs = findstr(filesep,fnamelocal);
if length(dirseplocs) > 1
	testdirlist{end+1} =fnamelocal(1:dirseplocs(end-1));
	fnamelocal = fnamelocal(dirseplocs(end-1)+1:end);
end

% Add '' (essentially pwd) to directory list
testdirlist{end+1} = '';

% Add computer specific directories
if strcmp(computer,'SOL2') | strmatch('GLNX',computer),
	testdirlist{end+1} = '/dept/isr/labs/nsl/data/MEG3/';
	testdirlist{end+1} = '/dept/isr/labs/nsl/data/MEG2/sorted';
	testdirlist{end+1} = '/dept/isr/labs/nsl/data/MEG2/';
	testdirlist{end+1} = '/homes/daqsc/matlab/meska/sorted/';
	testdirlist{end+1} = '/tmp/nsldata/';
    testdirlist{end+1} = '/archive/djklein/nsldata/';
elseif strcmp(computer,'MAC2')
	macrootdirlist = sort(eval(strrep(applescript('GetMacDisks.as'),'"','''')));
	for mm = 1:length(macrootdirlist)
		testdirlist{end+1} = macrootdirlist{mm};
	end
elseif strcmp(computer,'PCWIN')
	testdirlist{end+1} = 'd:\';
	testdirlist{end+1} = 'e:\';	
	testdirlist{end+1} = 'f:\';
	testdirlist{end+1} = 'g:\';
end

% if no filetype extension (e.g. .spk, .evp, .inf, .m) assume .m

% These are known and returned (except for ext)
ctag = fnamelocal(end-6:end-4); % e.g. a1-
sstr = fnamelocal(1:end-4);     % e.g. 225/30a07.a1-
ext = fnamelocal(end-3:end);    % e.g. .m

if ~strcmp(ext,'.spk')|~strcmp(ext,'.evp')|~strcmp(ext,'.inf')|~strcmp(ext,'.m')
    fnamelocal = [fnamelocal,'.m'];
end

% File type determines which files to look for
if strcmp(ext,'.spk')
	testfnamelist = {[sstr, '.spk'], [sstr, '.spk.mat']};
elseif strcmp(ext,'.evp')
	testfnamelist = {[sstr, '.evp']};
else
	testfnamelist = {[sstr, '.m']};
end	

%testdirlist
%testfnamelist
% Check for existence of relevant file(s) in each directory
% and return if found
for mm=1:length(testdirlist)
	if (checkforfiles(testdirlist{mm},testfnamelist))
		featxtdir = testdirlist{mm};
		return
	end
end

% If not found in any of the likely spots, let user pick
% a file, and then cd to that directory for future use.
%
[uifile,uipath]=uigetfile('*', ['Please find ',sstr]);
if ~uifile, error('No file chosen'), end
cd(uipath)
cd ..
disp(['Current working directory changed to ',pwd])
seplocs = findstr(filesep,uipath);
if length(seplocs) > 0
	featxtdir = uipath(1:seplocs(end));
	fnamelocal = strrep(uifile,'.mat','');
	dotcount = length(findstr('.',fnamelocal));
	if dotcount < 2
		fnamelocal = [fnamelocal,'.m'];
	end
	ctag = fnamelocal(end-6:end-4); % e.g. a1-
	sstr = fnamelocal(1:end-4);     % e.g. 225/30a07.a1-
	ext = fnamelocal(end-3:end);    % e.g. .m
else
	featxtdir = '';
end

return

function result = checkforfiles(testdir,testfnamelist);
result = 0;
for mm = 1:length(testfnamelist)
	result = result|exist(fullfile(testdir,testfnamelist{mm}),'file');
end
