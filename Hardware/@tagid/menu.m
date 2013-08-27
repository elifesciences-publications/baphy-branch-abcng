function varargout = menu(varargin)
% menu(tag1,tag2,...) creates a menu for given list of tags
% menu gives output as tags
global RUNNING;
%menuCount = 0;
RUNNING = 0;
newline = sprintf('\n');
if nargout==nargin,
    for i = 1:nargin
        if isa(varargin{i},'tagid')
            for j = 1:length(varargin{i})
                [out,menuCount,menuPtr] = menuitems(varargin{i}(j),i,j);
                taglist = getTags(varargin{i}(j));
%                 for k = 1:length(taglist)
%                     tagval = get(varargin{i}(j),taglist{k});
%                     if iscell(tagval), tagval = tagval{1};end;
%                     menuCount = menuCount+1;
%                     menuPtr{menuCount} = [i,j,k];
%                     if isnumeric(tagval),
%                         out{menuCount} = sprintf('%s  %5.3f',...
%                             [' (',num2str(menuCount),') ',taglist{k},...
%                                 addblanks(40-length(taglist{k})),' : '],...
%                             tagval);
%                     elseif ischar(tagval),
%                         out{menuCount} = sprintf('%s  %s',...
%                             [' (',num2str(menuCount),') ',taglist{k},...
%                                 addblanks(40-length(taglist{k})),' : '],...
%                             tagval);
%                     elseif iscell(tagval)
%                         val = tagval{1};
%                         if isnumeric(val),
%                             out{menuCount} = sprintf('%s  %5.3f',...
%                                 [' (',num2str(menuCount),') ',taglist{k},...
%                                     addblanks(40-length(taglist{k})),' : '],...
%                                 val);
%                         elseif ischar(val),
%                             out{menuCount} = sprintf('%s  %s',...
%                                 [' (',num2str(menuCount),') ',taglist{k},...
%                                     addblanks(40-length(taglist{k})),' : '],...
%                                 val);
%                         end;
%                     end;
%                 end;
            end;
        end;
        varargout{i} = varargin{i};
    end;
    valid = 0;
    while ~valid,
        clear tmp;
        tmp(1:50) = '%';
        disp(tmp);
        tmp = [addblanks(10) 'Menu Interface'];
        disp(tmp);
        tmp(1:50) = '%';
        disp(tmp);
        disp(newline);
        for i = 1:length(out)
            disp(out{i});
        end;
        disp(newline);
        defstr{1} = sprintf('%s','Start using current values    (u)');
        defstr{2} = sprintf('%s','Exit the program              (x)');
        for i = 1:length(defstr)
            disp(defstr{i});
        end;
        disp(newline);
        chstr = input(['Enter your choice (1-',num2str(menuCount),',u,x) : '],'s');
        disp(tmp);
        clear tmp;
        switch chstr
        case {'u',''}                
            for i = 1:nargin
                varargout{i} = varargin{i};
            end;
            valid = 1;
            RUNNING = 1;
            return;
        case 'x'
            valid = 1;
            RUNNING = 0;
            return;
        otherwise
            
            choice = sscanf(chstr,'%d');
            if isempty(choice)|choice>menuCount|choice<0,
                disp('Incorrect choice, Try again');
            else
                i = menuPtr{choice}(1);
                j = menuPtr{choice}(2);
                k = menuPtr{choice}(3);
                
                taglist = getTags(varargin{i}(j));
                tagval = get(varargin{i}(j),taglist{k});
                if iscell(tagval),tagval = tagval{1};end;
                if ischar(tagval)|length(tagval)<=1|isnumeric(tagval),
                    if isnumeric(tagval),
                        inpstr = input(['Enter new value for ',taglist{k},' : ']);
                        tagformat = '%5.3f';
                        tmplen=length(inpstr);
                        inpstr=num2str(inpstr);
                        val = sscanf(inpstr,'%f',[1,tmplen]);
                        if isempty(val),val = tagval;end;
                    elseif ischar(tagval),
                        inpstr = input(['Enter new value for ',taglist{k},' : '],'s');
                        tagformat = '%s';
                        val = sscanf(inpstr,'%s');
                        if isempty(val),val = tagval;end;
                    end;
                    %varargout{i}(j) = set(varargin{i}(j),taglist{k},val);
                    varargin{i}(j)  = set(varargin{i}(j),taglist{k},val);
                else
                    disp(newline);
                    preset = sprintf('%s\n','Possible values : ');
                    disp(preset)
                    for tmp = 1:length(tagval)-1
                        if ischar(tagval{tmp+1})
                            disp([' (' num2str(tmp) ') ' tagval{tmp+1}]);
                            tagformat = '%s';
                        else
                            disp([' (' num2str(tmp) ') ' num2str(tagval{tmp+1})]);
                            tagformat = '%0.3f';
                        end;
                    end;
                    disp(newline);
                    inpstr = input(['Enter new value for ',taglist{k},...
                            ' (',num2str(1),'...',num2str(length(tagval)-1),') : '],'s');
                    inpval = sscanf(inpstr,'%d');
                    choiceflag = (inpval>0)&(inpval<=(length(tagval)-1));
                    if ~isempty(choiceflag)&(choiceflag)
                        val = tagval(inpval+1);
                        val = [val{:}];
                        %varargout{i}(j) = set(varargin{i}(j),taglist{k},val);
                        varargin{i}(j)  = set(varargin{i}(j),taglist{k},val);
                    else
                        val = tagval{1};
                    end;
                end;
                %                     out{choice} = sprintf(['%s  ',tagformat],...
                %                         [' (',num2str(choice),') ',taglist{k},...
                %                             addblanks(40-length(taglist{k})),' : '],...
                %                         val);
                [out,menuCount,menuPtr] = menuitems(varargin{i}(j),i,j);
            end;
        end;
    end;
else
    error('Number of inputs must be EQUAL to Number of outputs');
end;

function [out,menuCount,menuPtr] = menuitems(tag,i,j);

menuCount = 0;
taglist = getTags(tag);
for k = 1:length(taglist)
    tagval = get(tag,taglist{k});
    if iscell(tagval), tagval = tagval{1};end;
    menuCount = menuCount+1;
    menuPtr{menuCount} = [i,j,k];
    if isnumeric(tagval),
        out{menuCount} = sprintf('%s  %s',...
            [' (',num2str(menuCount),') ',taglist{k},...
                addblanks(40-length(taglist{k})),' : '],...
            num2str(tagval));
    elseif ischar(tagval),
        out{menuCount} = sprintf('%s  %s',...
            [' (',num2str(menuCount),') ',taglist{k},...
                addblanks(40-length(taglist{k})),' : '],...
            tagval);
    elseif iscell(tagval)
        val = tagval{1};
        if isnumeric(val),
            out{menuCount} = sprintf('%s  %5.3f',...
                [' (',num2str(menuCount),') ',taglist{k},...
                    addblanks(40-length(taglist{k})),' : '],...
                val);
        elseif ischar(val),
            out{menuCount} = sprintf('%s  %s',...
                [' (',num2str(menuCount),') ',taglist{k},...
                    addblanks(40-length(taglist{k})),' : '],...
                val);
        end;
    end;
end;
