function str = textrecord(tag,classname,outputname)
% str = textrecord(tag); % writes the definition of the tag as string 'str'
% In other words,
% if tag is a TAGID object with tags 'Name','Age' and the values are
% 'John Doe' and 21 respectively, then
% str = ['t = tagid; % Init the TAGID structure',newline,...
%       't = set(t,''Name'',''John Doe'',...',newline,...
%       '   ''Age'',21);']
% Alternatively, if tag inherits from TAGID then you can pass the
% classname (instead of tagid). One can also choose the outputname
% instead of 't'.
% Ex.
%   str = textrecord(tag,'torc','out');
% If a display of the units are required
%  str = textrecord(tag,classname,outputname);

if nargin<1|~isa(tag,'tagid')
    error('Atleast one input required. First input must belong to TAGID');
end;

% Parse through input arguments
newline = sprintf('\n');
if nargin<2
    classname = 'tagid';
    outputname = 't';
elseif nargin<3
    outputname = 't';
end;
if isempty(classname),classname = 'tagid';end;
if isempty(outputname),outputname = 't';end;

% Init str
str = [outputname,' = ',classname,';',newline,newline]; % t = TAGID;

% Start setting the various tags of the object
list = getTags(tag);
if length(list)>1
    str = [str,outputname,' = set(',outputname,',...',newline];% t = set(t,...
end
for j = 1:length(list)
    str = [str,'    ''',list{j},''','];
    val = get(tag,list{j});
    if ischar(val)
        str = [str,'''',val,''''];
    elseif isnumeric(val)
        if length(val)==1
            str = [str,disptag(tag,j)];
        else
            str = [str,'[',disptag(tag,j),']'];
        end;
    else
        str = [str,disptag(tag,j)];
    end;
    str = [str,',...',newline];
end;
if length(list)>1
    str(end-4:end) = ''; % Remove the trailing [',...',newline]
    str = [str,');'];   % End the definition
end