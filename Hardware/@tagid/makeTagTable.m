function out = makeTagTable(name,idfunction,tagnames,varargin)

% This function collects the Tags from the objects given as input
% and assembles them in a lookup table. It is assumed that all the
% tags included in the input have the same tag names/
% Usage: out = makeTagTable(name,idfunction,tagnames,tag1,tag2,tag3);
%   where,  name: Name for the table
%           idfunction is the name of the function which applies on the
%                   the input tags to makeup the 'ID' Column
%           tagnames are the name of the basis for the table
%                   tagnames has to be a cell array
%           tag1,tag2,... are objects of tagid
% out belongs to class tagTable. It has three fields
%       descriptor: Name of the table
%       tags: list of tags for table
%       table: table of values for tags chosen



if nargin<4,
    error('sorry, need more arguments');
end;
tmp.descriptor = name;
tmp.tags = [tagnames];


if isa(varargin{i},'tagid')
    if ~isa(idfunction,'function_handle'),
        idfunction = str2func(idfunction);
    end;
    count = 0;
    for i = 1:length(varargin),
        handle = varargin{i};
        for j = 1:length(handle)
            count = count+1;
            for k = 1:length(tmp.tags),
                if count ==1,
                    t.table{k} = feval(rel,handle(j),t.tags{k});
                else
                    t.table{k}=[t.table{k} feval(rel,handle(j),t.tags{k})];
                end;
            end;
        end;
    end;
end;

out = tagTable(tmp.descriptor,tmp.tags,tmp.table);

    
        