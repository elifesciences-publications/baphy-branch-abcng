function varargout = mapread(mapfile,varargin)
% data = mapread(mapfile); Read data from all available analog channels
% and return it as a matrix. Reads the MAP file format of alpha omega
% using the neuroshare toolbox.
% Usage:
% data = mapread(mapfile,...
%       'Channels',{channel_names},...
%       'Samples',[start,end],...
%       'Format',datatype);
% data can be analog-data or event-data depending on the channel type
% fileinfo = mapread(mapfile,'fileinfo');
% entityinfo = mapread(mapfile,'entityinfo',entityid);
% datainfo = mapread(mapfile,'datainfo',entityid);
% datainfo = mapread(mapfile,'datainfo',channel_names);
% datainfo can be analog-info or event-info depending on the channel type
%


persistent NSdllPath;
global BAPHYHOME

% get the config file
% addpath(matlabroot) % to access the config file % taking too much time -
% 60 msec

% Initialize the alpha omega library (dll)
%ns = ns_SetLibrary('c:\Users\Shantanu\neuroread\nsAOLibrary');
if isempty(NSdllPath)
    NSdllPath = [BAPHYHOME filesep 'Utilities' filesep 'AlphaOmega'];
end;
ns = ns_SetLibrary(fullfile(NSdllPath,'nsAOLibrary'));
if ns<0
    [f,p] = uigetfile('*.dll','Neuroshare compatible library');
    if isempty(f)|~ischar(f)
        error('Neuroshare compatible library not found');
    else
        ns = ns_SetLibrary(fullfile(p,f));
        if ns<0
            error('Neuroshare compatible library not found');
        else
            NSdllPath = fullfile(p,f);
        end;
    end;
end;
% To parse the inputs, init the actions allowed to the user
actionlist = {'fileinfo','entityinfo','datainfo','data'};
defaultaction = 'data';

% Get action
if length(varargin)<1
    action = defaultaction;
else
    action = varargin{1};
    n = find(strcmpi(actionlist,action));
    if isempty(n)
        action = defaultaction;
    end;
end;

% open file
[ns,hf] = ns_OpenFile(mapfile);
% get file info
[ns,fileinfo] = ns_GetFileInfo(hf);
if strcmpi(action,'fileinfo')
    % close file
    ns_CloseFile(hf);
    varargout{1} = fileinfo;
    return;
end;
% % Read in EntityID. 
% Note: EntityID varies from 1 to EntityCount which is obtained from
% FileInfo


% init entity-id
entityid = [1:fileinfo.EntityCount];



% Read entity-info
for i = 1:length(entityid)
  [ns,eninfo(i)] = ns_GetEntityInfo(hf,entityid(i));
  enlabel{i} = eninfo(i).EntityLabel;
end;

for i = 1:length(enlabel)
  SnrLabels = findstr('SPK 001',enlabel{i});
  if SnrLabels == 1
    break
  end
end

if SnrLabels == 1
  enlabel_temp=[];
  for i = 1:length(enlabel)
    spaceindex =  findstr(enlabel{i},' ');
    zeroindex =  max(findstr(enlabel{i},'0'));
    enlabel_temp = [enlabel_temp {upper(enlabel{i}([1:spaceindex-1 zeroindex+1:end]))}];
  end
  enlabel = enlabel_temp;
end

if strcmpi(action,'entityinfo')
    if length(varargin)>=2
        if iscell(varargin{2})|ischar(varargin{2})
            [enlabel,entityid]=intersect(enlabel,varargin{2});            
        elseif isnumeric(varargin{2})
            entityid = intersect(entityid,varargin{2});            
        end
        if isempty(entityid)
            % close file
            ns_CloseFile(hf);
            % error
            error('No valid entity selected');
        end;
    end;
    % close file
    ns_CloseFile(hf);
    varargout{1} = eninfo(entityid);
    return;
end;
% If we have come so far then the action must be read channel specific
% data or info (i.e. [event|analog,info|data]

% % Read in chanid:
% Note: chanid can be given as either the EntityLabel or the
% EntityID. If given as EntityLabel, it will converted to the appropriate
% EntityID.

% init chanid
chanid = 'SPK1';
samples = [];
format = 'int16';


if length(varargin)>=2
    if strcmpi(action,'data') 
        for i = 1:2:length(varargin)
            switch lower(varargin{i})
                case 'channels'
                    chanid = varargin{i+1};
                case 'samples'
                    if length(varargin{i+1})~=2
                        warning('Incorrect Sample Index - Resetting to default');
                    else
                        samples = varargin{i+1};
                    end;
                case 'dataformat'
                    format = varargin{i+1};
            end;      
        end;
    elseif strcmpi(action,'datainfo') 
        chanid = varargin{2};
    end;
end;
% select valid chanid and convert from label to id if necessary
if isnumeric(chanid)
    chanid = intersect(entityid,chanid);
elseif iscell(chanid)|ischar(chanid)
    % convert from label to id
    [anlabel,chanid] = intersect(enlabel,chanid);
end;
if isempty(chanid)
    % close file
    ns_CloseFile(hf);
    % error
    error('No valid chanid selected');
end;
% Read Info for given entities
if length(chanid)==1 % Return a structure with info
    if eninfo(chanid).EntityType==1 % Event Channel
        [ns,chaninfo] = ns_GetEventInfo(hf,chanid);
    elseif eninfo(chanid).EntityType==2 % Analog Channel
        [ns,chaninfo] = ns_GetAnalogInfo(hf,chanid);
    end;
else
    % Return a cell array of the info structures
    for i = 1:length(chanid)
        if eninfo(chanid(i)).EntityType==1 % Event Channel
            [ns,chaninfo{i}] = ns_GetEventInfo(hf,chanid(i));
        elseif eninfo(chanid(i)).EntityType==2 % Analog Channel
            [ns,chaninfo{i}] = ns_GetAnalogInfo(hf,chanid(i));
        end;
    end;
end;
   
% If info is required, return
if strcmpi(action,'datainfo') 
    varargout{1} = chaninfo;
    % close file
    ns_CloseFile(hf);
    return;
end;
    

% % If we have reached this point, we are reading the data
if length(chanid)==1 % Return an array with data
    if isempty(samples)
        samples = [1,eninfo(chanid).ItemCount];
    else
        samples = round(samples);
        if samples(1)<1|samples(1)>eninfo(chanid).ItemCount
            disp('Start index incorrect - resetting to default')
            samples(1) = 1;
        end;
        if samples(2)<1|samples(1)>eninfo(chanid).ItemCount
            disp('End index incorrect - resetting to default')
            samples(2) = eninfo(chanid).ItemCount;
        end;
    end;
    startindex = samples(1);
    itemcount = samples(2)-samples(1)+1;
    if eninfo(chanid).EntityType==1 % Event Channel
        for indx = 1:itemcount
            [ns,data(indx)] = ns_GetEventData(hf,chanid,startindex+indx-1);
        end;
    elseif eninfo(chanid).EntityType==2 % Analog Channel
        [ns,cc,data] = ns_GetAnalogData(hf,chanid,startindex,itemcount);
        % data right now is int16 (but saved as double)
        % Change to appropriate format
        switch lower(format)
            case {'int16','native'}
                data = int16(data);
            case 'double'                
                [ns,datainfo] = ns_GetAnalogInfo(hf,chanid);
                data = data*datainfo.Resolution;                
        end;
                
    end;
else  % Return a cell array of the data vectors
    for i = 1:length(chanid)
        if isempty(samples)
            samples = [1,eninfo(chanid(i)).ItemCount];
        else
            samples = round(samples);
            if samples(1)<1|samples(1)>eninfo(chanid(i)).ItemCount
                disp('Start index incorrect - resetting to default')
                samples(1) = 1;
            end;
            if samples(2)<1|samples(1)>eninfo(chanid(i)).ItemCount
                disp('End index incorrect - resetting to default')
                samples(2) = eninfo(chanid(i)).ItemCount;
            end;
        end;
        startindex = samples(1);
        itemcount = samples(2)-samples(1)+1;            
        if eninfo(chanid(i)).EntityType==1 % Event Channel
            for indx = 1:itemcount
                [ns,data{i}(indx)] = ...
                    ns_GetEventData(hf,chanid(i),startindex+indx-1);
            end;
        elseif eninfo(chanid(i)).EntityType==2 % Analog Channel
            [ns,cc{i},data{i}] = ...
                ns_GetAnalogData(hf,chanid(i),startindex,itemcount);
            % data right now is int16 (but saved as double)
            % Change to appropriate format
            switch lower(format)
                case {'int16','native'}
                    data{i} = int16(data{i});
                case 'double'                    
                    [ns,datainfo] = ns_GetAnalogInfo(hf,chanid(i));
                    data{i} = data{i}*datainfo.Resolution;                    
            end;
        end;
    end;
end;
% close file
ns_CloseFile(hf);
varargout{1} = data;
return;