function [path, fname, extension,version] = pcfileparts(name)
%PCFILEPARTS PC Filename parts.
%   [PATHSTR,NAME,EXT,VERSN] = PCFILEPARTS(FILE) returns the path, 
%   filename, extension and version for the specified PC file. 
%   PCFILEPARTS is platform independent.
%
%   Lighltly modifed from the builtin function FILEPARTS
%   
%   See also FILEPARTS, FULLFILE, PATHSEP, FILESEP.

path = '';
fname = '';
extension = '';
version = '';

if isempty(name), return, end

% Nothing but a row vector should be operated on.
[m,n] = size(name);
if (m > 1)
  error('Input cannot be a padded string matrix.');
end

if strncmp(name, 'built-in', size('built-in',2))
    fname = 'built-in';
    return;
end

orig_name = name;

% Convert all / to \ on PC
name = strrep(name,'/','\');
ind = find(name == '\' | name == ':');
if isempty(ind)
    fname = name;
else
    %special case for drive
    if name(ind(end)) == ':'
        path = orig_name(1:ind(end));
    elseif isequal(ind,[1 2]) ...
            && name(ind(1)) == '\' && name(ind(2)) == '\'
        %special case for UNC server
        path = 	orig_name;
        ind(end) = length(orig_name);
    else 
        path = orig_name(1:ind(end)-1);
    end
    if ~isempty(path) && path(end)==':'
        path = [path '\'];
    end
    fname = name(ind(end)+1:end);
end

if isempty(fname), return, end

% Look for EXTENSION part
ind = max(find(fname == '.'));

if isempty(ind)
    return
else
    extension = fname(ind:end);
    fname(ind:end) = [];
end
