function varargout = ObjLoadSaveDefaults (o, action, index)
% function ObjUpdate (o, action, index)
%
% ObjLoadSaveDefaults is a method of class SoundObject and can be used to
% store and load the properties of object o from a file. Multiple profiles
% can be saved and retrieved using index. The defaults are saved in the
% directory of the object o, under the name LastValues.mat
% o: Object
% action: 'r' for read, 'w' for write
% index: index of profile, default is 1

% Nima, november 2005
if nargin<3 , index = 1;end
if nargin<2 , action = 'r';end
if nargout>0 , varargout{1} = o;end
%
object_spec = what(class(o));
fname = [object_spec(1).path filesep 'LastValues.mat'];
try
    if exist(fname,'file')
        load (fname);
    else
        values = [];
    end
    fields = get(o,'UserDefinableFields');
    if strcmp(action, 'w')
        % get the values first
        cnt2 = 1;
        for cnt1 = 1:length(fields)/3 % fields have name, type and default values.
            values {cnt1,index} = get(o, fields{cnt2});
            cnt2 = cnt2+3;
        end
        save (fname, 'values');
    elseif ~isempty(values)
        % load the values to the object. if the requested index does not
        % exist, use the first index
        if size(values,2) < index; index = 1; end
        cnt2 = 1;
        for cnt1 = 1:length(fields)/3
            if ~isempty(values{cnt1,index})
                % delete the spaces at the end:                 
                if ischar(values{cnt1,index}) && strcmpi(values{cnt1,index}(end),' '), values{cnt1,index} = strtok(values{cnt1,index});end
                o = set(o,fields{cnt2}, values{cnt1,index});
            else
                o = set(o,fields{cnt2}, get(o,fields{cnt2}));
            end
            cnt2 = cnt2 + 3;
        end
        varargout{1} = o;
    end
catch
    delete(fname);
end