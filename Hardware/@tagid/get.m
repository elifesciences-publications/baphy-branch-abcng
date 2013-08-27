function val = get(a,varargin)
% GET Get tagid properties from the specified object
% val = GET(a,prop_name1,prop_name2,...)
%   a -> an object from the class - tagid
%   prop_name can take on the following values

if isa(a,'tagid')
    if nargin==1
        for i = 1:length(a.tags)
            if isnumeric(a.tagval{i})
                valstr = num2str(a.tagval{i});
            elseif iscell(a.tagval{i})
                valstr = a.tagval{i}{1};
                if ~ischar(valstr),valstr = num2str(valstr);end;
            else
                valstr = a.tagval{i};
            end;
            out=['Tag#' num2str(i-1) ' : ' a.tags{i} ' = ' valstr];
            disp(out);
        end;
    elseif nargin>=2
        if nargin==2
            n = find(strcmpi(a.tags(:),varargin{1}));
            if ~isempty(n),
                if iscell(a.tagval{n})
                    val{1} = a.tagval{n};   % If you take this out i.e.
                                            % val = a.tagval{n};                    
                                            % also remove all references to
                                            % tagval{1}{1} when you call
                                            % get i.e.
                                            % val = val{1}{1}; to
                                            % val = val{1};
                                            
                elseif ~isempty(a.tagval{n})
                    val = a.tagval{n};
                end;
            end;
        else
            for i = 1:nargin-1
                n = find(strcmpi(a.tags(:),varargin{i}));
                if ~isempty(n),
                    if iscell(a.tagval{n})
                        val{i} = a.tagval{n};
                    elseif ~isempty(a.tagval{n})
                        val{i} = a.tagval{n};
                    end;
                end;
            end;
        end;
    end;
else
    error('input object does not belong to tagid class');
end;
