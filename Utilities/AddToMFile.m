function AddToMFile(fname, StructName, data, writeidx, rec_flag)
% function AddToMFile(fname, StructName, data, writeidx)
%
% This function write the structure 'data' to the file specified in fid.
% fname     : name of the file the data is written to. Should be created
%               before using this command (so that baphy take care of
%               replacing, validation, etc...)
% StructName: the name of the variable that data is assigned to
% data      : the structure which is written to fid file.
% writeidx  : the index of data we want to write tot he file, default is
%             everything
%
% Note: This version can handle the fields that are numeric, string, cell array
%        , structures, and objects (through their get method) with arbitrary depth;

% Nima, Stephen , November 2005
% revised Stephen 2005-11-07: added writeidx in case we only want
%                             to append an existing m file
% revised Nima November 10, : handling of objects and multiple depth
%                             structures through recursive routines
%

% if no event, just return:
if isempty(data) return;end
% Is this recursion??
if nargin<5 rec_flag=0;end
% by default save all records
if nargin<4 writeidx=1:length(data);
elseif isempty(writeidx) writeidx = 1:length(data);end;

% m file should first be created by baphy, so that if it exist baphy ask
% the user for permission to overwrite, validation of name , database, etc.
% If it does not exist at this point, baphy had been unable to create it:
if ~exist(fname)
    error(sprintf('%s',['The file ' fname ' does not exist!']));
else
    fid = fopen(fname,'a');     % this might generate multiple handles but all point to the same file
end

if ~rec_flag % only first time
    fprintf(fid,'\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
    fprintf(fid,'%% ''%s'' is a %s: ',StructName, class(data));
    fprintf(fid,'\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
end
% if its an object, call recursively using get method:
if isobject(data)
    fclose (fid);
    AddToMfile (fname, [StructName], get(data),[],1);
    return;
end

fields = fieldnames(data);
fields = fields(~strcmp(fields,'MANTA')); % Field contains an object which cannot be saved
% if data is an array,
for cnt1 = writeidx,
  % fprintf(fid,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
  % write all the fields
  for cnt2 = 1:length(fields);
    switch class(data(cnt1).(fields{cnt2}))
      case {'char', 'double'}
        % for numbers and strings
        try,
          fprintf(fid,'%s(%d).%s = ', StructName, cnt1,fields{cnt2});
        catch,
          % reopen if closed for some reason
          fid = fopen(fname,'a');
          fprintf(fid,'%s(%d).%s = ', StructName, cnt1,fields{cnt2});
        end
        
        WriteToFile(fid,data(cnt1).(fields{cnt2}));
        fprintf(fid,';\n');
      case 'cell'          % for cells
        if ~isempty(data(cnt1).(fields{cnt2}))
          if isnumeric(data(cnt1).(fields{cnt2}){1}) | ischar(data(cnt1).(fields{cnt2}){1})
            fprintf(fid,'%s(%d).%s = {', StructName, cnt1, fields{cnt2});
            for cnt3=1:length(data(cnt1).(fields{cnt2}));
              WriteToFile(fid,data(cnt1).(fields{cnt2}){cnt3});
              if cnt3 < length(data(cnt1).(fields{cnt2}))
                fprintf(fid,', ');
              end
            end
            fprintf(fid,'};\n');
          elseif strcmp( class(data(cnt1).(fields{cnt2}){1}) , 'function_handle' )  % array of functions; Yves 2013/10
            % not saved
          else % this is a cell array of something else (structure, object, etc)
            for cnt3=1:length(data(cnt1).(fields{cnt2}))
              AddToMFile (fname, [StructName '(' num2str(cnt1) ').' fields{cnt2} ...
                '{' num2str(cnt3) '}'], data(cnt1).(fields{cnt2}){cnt3},[],1);
            end
          end
        else
          fprintf(fid,'%s(%d).%s = {};\n', StructName, cnt1, fields{cnt2});
        end
      case 'struct' % if its structure in structure, call recursively
        AddToMFile (fname, [StructName '(' num2str(cnt1) ').' fields{cnt2}], ...
          data(cnt1).(fields{cnt2}),[],1);
      case 'function_handle'   % Yves 2013/10; function not saved; I resynthetize them ad hoc        
      otherwise  % then it has to be a user defined object!!
        fprintf(fid, '\n%% %s(%d).%s = %s\n', StructName, cnt1, ...
          fields{cnt2}, ['handle of a ' class(data(cnt1).(fields{cnt2})) ' object']);
        AddToMFile (fname, [StructName '(' num2str(cnt1) ').' fields{cnt2}], ...
          get(data(cnt1).(fields{cnt2})),[],1);
        fprintf(fid,'\n');
    end
  end
end

try,
   fclose(fid);
catch
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function writes a string or a numeric to the file
function WriteToFile (fid,a)
if isnumeric(a)
    fprintf(fid,'%s',mat2string(a));
else
    fprintf(fid,'''%s''',a);
end

