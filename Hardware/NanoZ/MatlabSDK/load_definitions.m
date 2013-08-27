function result = load_definitions(filename)
% Given an electrode/adaptor '.ini' file, this
% function returns a Matlab structure with the
% mapping and associated meta-data for various
% nanoZ adaptors and electrodes. 

%   This file is a part of nanoZ Matlab SDK

result = [];                           
adaptor_name = '';
f = fopen(filename,'r');                % open file...
while ~feof(f)                          % and read until end
    s = strtrim(fgetl(f));              % remove leading/trailing spaces
    if isempty(s) || s(1)==';'  
        continue;                       % skip blank lines
    end
    if ( s(1)=='[' ) && (s(end)==']' )  % found adaptor or electrode
        adaptor_name = genvarname(s(2:end-1));
        result.(adaptor_name) = [];     % create new field
        if ~(strcmp(adaptor_name, 'KnownAdaptors') || strcmp(adaptor_name, 'KnownElectrodes'))
            result.(adaptor_name).ChMap = [];
        end
    else                                % this is not a section start
        if isempty(adaptor_name)
            continue                    % no sections found before. orphan value
        end
        [par,val] = strtok(s, '=');
        val = strtrim(val(2:end));      % strip space and '='
        [v isval] = str2num(val);
        if isval, val = v; end;         % convert to number, if applicable
        result.(adaptor_name).(genvarname(par)) = val;
        if strfind(s,'MUX')             % append to channel mapping vector
            ChMap = str2num(s(4:6));
            result.(adaptor_name).ChMap = [result.(adaptor_name).ChMap int32(ChMap)];
        else
            if strfind(s,'Site')        % append to site mapping vector
                ChMap = str2num(s(5:7));
                result.(adaptor_name).ChMap = [result.(adaptor_name).ChMap int32(ChMap)];
            end
        end
    end
end
fclose(f);
return;