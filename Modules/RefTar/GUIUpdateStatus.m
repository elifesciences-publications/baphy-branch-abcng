function exptparams = GUIUpdateStatus (globalparams, exptparams, TrialIndex, TrialInThisRep);
% Display information on RefTarGui including globalparams, status, current
% job

% RepetitionIndex, TrialIndex, cnt2, exptparams,globalparams,UpdateWhat)
% This function update the status box in the gui

% Nima, november 2005
if nargin<2 exptparams = [];end


% First, show the globalparams here:
fields = [];
fieldNames = {'Tester','Ferret','Physiology','SiteID','NumberOfElectrodes','mfilename','evpfilename'};
% where do we want them on the gui:
pos = BaphyRefTarGuiItems ('GlobalparamsPosition');
for cnt1 = 1:length(fieldNames)
    if cnt1==6
        pos = pos + [160 70];
    end
    if isfield(globalparams, fieldNames{cnt1})
        fieldValue = getfield(globalparams, fieldNames{cnt1});
        exptparams = ShowOnGui (exptparams,  [ fieldNames{cnt1} ' : '], [pos-[130 15*(cnt1-1)] 130 20], ...
            fieldValue, [pos-[0 15*(cnt1-1)] max(100,length(fieldValue)*6.2) 20]);
    end
end
% Now show the status:
if isfield(exptparams,'TrialObject')
    if ~isempty(exptparams.TrialObject)
        totalTrials = get(exptparams.TrialObject, 'NumberOfTrials');
        cnt2 = TrialInThisRep;
        pos = BaphyRefTarGuiItems('StatusPosition');
        fields{1} = 'Trials left in this Rep: ';
        fields{end+1} = totalTrials-TrialInThisRep;
        %
        fields{end+1} = 'Current Repetition: ';
        fields{end+1} = exptparams.TotalRepetitions + 1;
        %
        fields{end+1} = 'Trial Number: ';
        fields{end+1} = TrialIndex;
        %
        fields{end+1} = 'This Trial: ';
        if isfield(get(exptparams.TrialObject),'TargetIndices')
            indices = (get(exptparams.TrialObject, 'TargetIndices'));
            if isempty(indices) | strcmp(indices,'[]')
                fields{end+1} = 'Sham';
            elseif isempty(indices{cnt2}) || strcmp(indices{cnt2},'[]') || (indices{cnt2}==0)
                fields{end+1} = 'Sham';
            else
                fields{end+1} = 'Stim';
            end
        else
            fields{end+1} = 'Stim';
        end
        fields{end+1} = '# of References: ';
        if isfield(get(exptparams.TrialObject),'ReferenceIndices')
            numofRef = get(exptparams.TrialObject,'ReferenceIndices');
            if ~isempty(numofRef{cnt2})
                fields{end+1} = length(numofRef{cnt2});
            else
                fields{end+1} = 0;
            end
        else
            fields{end+1} = '--';
        end
        % If performance exists, also show that on the gui:
        if isfield(exptparams,'Performance')
            fields{end+1} = '---------Performance----';
            fields{end+1} = '-------';
            PerfFields = fieldnames(exptparams.Performance(end));
            for cnt1 = 1:length(PerfFields)
                fields{end+1} = [PerfFields{cnt1} ': '];
                if strcmpi(fields{end},'ThisTrial: ')
                    fields{end} = 'LastTrial: ';
                end
                value = exptparams.Performance(end).(PerfFields{cnt1});
                if isnumeric(value)
                    fields{end+1} = value(1);
                    if isnumeric(fields{end}) % limit it to 2 deciaml points:
                        fields{end} = floor(100*fields{end})/100;
                    end
                    if length(value)>1
                        fields{end} = [num2str(fields{end}) '/' num2str(value(2))];
                    end
                else
                    fields{end+1} = value;
                end
            end
        end
        %
        for cnt1 = 1:length(fields)/2   % length(fields) should be always a multiple of 2, because it
            % had the field name, its style
            field = fields((cnt1-1)*2+1:cnt1*2);
            exptparams = ShowOnGui (exptparams, field{1}, [pos-[135 19*(cnt1-1)+0] 125 15], ...
                field{2}, [pos-[0 19*(cnt1-1)] 50 15]);
        end
    end
end
drawnow;


function exptparams = ShowOnGui(exptparams, fieldName, POS1, fieldValue, POS2)
if isfield(exptparams,'TempDisp')
    a = cell(length(exptparams.TempDisp),1);
    [a{:}] = deal(exptparams.TempDisp.text);
    index = find(strcmp(a,fieldName));
    if isempty(index) % its the first time,
        uicontrol(exptparams.FigureHandle,'Style','text','string',fieldName, 'FontWeight','bold',...
            'HorizontalAlignment','right','position',POS1);
        handle = uicontrol(exptparams.FigureHandle,'Style','text','string',fieldValue, 'FontWeight','bold',...
            'HorizontalAlignment','left','position',POS2,'ForegroundColor',[0 0 .7]);
        exptparams.TempDisp(end+1).text = fieldName;
        exptparams.TempDisp(end).handle = handle;
    else % it has been show once, only change the value:
        set(exptparams.TempDisp(index).handle, 'string', fieldValue);
    end
else
    uicontrol(exptparams.FigureHandle,'Style','text','string',fieldName, 'FontWeight','bold',...
        'HorizontalAlignment','right','position',POS1);
    handle = uicontrol(exptparams.FigureHandle,'Style','text','string',fieldValue, 'FontWeight','bold',...
        'HorizontalAlignment','left','position',POS2, 'ForegroundColor',[0 0 .7]);
    exptparams.TempDisp.text = fieldName;
    exptparams.TempDisp.handle = handle;
end