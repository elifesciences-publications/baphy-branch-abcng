function t = getTags(a)
% Usage: t = gettags(a), where
% 'a' belongs to tagid
% 't' is a cell array of the tag names of 'a'

if isa(a,'tagid')
    t = a.tags;
else
    error([inputname(1) ' must be a valid tagid']);
end;