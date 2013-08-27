function s = disptag(a,tagnum)
% s = disptag(tagid,tagnum); 
% where,
%   a = TAGID obj
%   tagnum = number of the tag in the taglist (numeric)
%   s = output formatted string (char)
% Also,
% s = disptag(tagid,tagname);
% where, tagname = name of the tag (char)
%
% disptag returns tagval in the appropriate display format. The tag in 
% question is the tagnum'th tag of tagid object a. 
% It assumes that format if available will be saved in 'display' field
% of the helper structure for that tag. If no such  display info exists, 
% it assumes '%s' for string/char arrays, '%3.3f' for numeric arrays. If tagval is
% is any other type eg cell array,structure or another object, it will call the
% display routine of the tagval to return the appropriate string

taglist = getTags(a);
if nargin<2
    tagnum = 1;
elseif ischar(tagnum)
    tagstr = tagnum;
    tagnum  = find(strcmpi(taglist(:),tagstr));
    if isempty(tagnum)
        error(['No such tag ''',tagstr,'''']);
    end;
elseif isnumeric(tagnum)
    if (tagnum<0)|(tagnum>length(getTags(a)))
        error('tagnum out of range');
    end;
end;

try
    tagval = get(a,taglist{tagnum});
    if iscell(tagval),tagval = tagval{1}{1};end;
    s = sprintf(propdisplay(tagval),tagval);
catch 
    s = '';
end;