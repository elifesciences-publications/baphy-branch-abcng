function t = removeTag(t,varargin)
% Usage: t = removeTag(t,prop_name),
% where t belongs to tagid, prop_name is a string. 
% this function removes the specified tag from the tag list

if nargin>=2,
    if isa(t,'tagid'),
        for i = 1:nargin-1,
            prop_name = varargin{i};
            n = find(strcmpi(t.tags(:),prop_name));
            if isempty(n),
                disp(['Sorry. ' prop_name ' is not a valid tag']);
            else
                t.tags(n) = '';
                t.tagval(n) = [];
%                 if (n>1)&(n<size(t.tags)),
%                     
%                     tmptag1 = t.tags(1:n-1);
%                     tmptag2 = t.tags(n+1:end);
%                     t.tags = [];
%                     t.tags = [tmptag1 tmptag2];
%                     clear tmptag1 tmptag2;
%                     tmptag1 = t.tagval(1:n-1);
%                     tmptag2 = t.tagval(n+1:end);
%                     t.tagval = [];
%                     t.tagval = [tmptag1 tmptag2];
%                     
%                 elseif ~(n>1),
%                     
%                     tmptag2 = t.tags(n+1:end);
%                     t.tags = [];
%                     t.tags = [tmptag2];
%                     clear tmptag1 tmptag2;
%                     tmptag2 = t.tagval(n+1:end);
%                     t.tagval = [];
%                     t.tagval = [tmptag2];
%                     
%                 elseif ~(n<size(t.tags))
%                     
%                     tmptag1 = t.tags(1:n-1);
%                     t.tags = [];
%                     t.tags = [tmptag1];
%                     clear tmptag1 tmptag2;
%                     tmptag1 = t.tagval(1:n-1);
%                     t.tagval = [];
%                     t.tagval = [tmptag1];
%                     
%                 end;
            end;
        end;
    else
        error([inputname(1) ' must be tagid']);
    end;
else
    error('Atleast two inputs required: 1:"tagid",2:"PropertyName"');
end;
            