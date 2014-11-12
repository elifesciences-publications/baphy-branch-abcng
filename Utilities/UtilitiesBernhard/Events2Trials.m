function T = Events2Trials(varargin)

P = parsePairs(varargin); %NAF 9/2: changed to varargin to allow for optional Runclass input.

checkField(P,'Events')
checkField(P,'Stimclass')
checkField(P,'Runclass','');
checkField(P,'TimeIndex',0)

Notes = lower({P.Events.Note});

%Index variables give the index in the event data for each index type
%specified in the variable name
TrialInd = find(strcmp('trialstart',Notes));
PreSilenceInd   = find(~cellfun(@isempty,strfind(Notes,'prestimsilence')));
PostSilenceInd = find(~cellfun(@isempty,strfind(Notes,'poststimsilence')));
OutcomeInd    = find(~cellfun(@isempty,strfind(Notes,'outcome')));
StimInd = find(~cellfun(@isempty,strfind(Notes,'stim ,')));

%Initialize trial vectors
T.NTrials = length(TrialInd);
T.Indices = cell(T.NTrials,1);
T.Durations = cell(T.NTrials,1);
T.Tags = cell(T.NTrials,1);
T.PreSilence = [P.Events(PreSilenceInd).StopTime];
T.PostSilence = [P.Events(PostSilenceInd).StopTime] - [P.Events(PostSilenceInd).StartTime];
T.DurationsTotal = [P.Events(PostSilenceInd).StopTime];

%Reassign Stimclass for Composite Runclasses
switch P.Runclass
  case 'TMG'; P.Stimclass = 'texturemorphing';
end

% ASSIGN TRIAL PROPERTIES BY STIMCLASS
if P.TimeIndex % RETURN INDICES BY TRIALNUMBER
    T.Indices = {1:length(TrialInd)};
    T.SortInd = [1:length(TrialInd)];
    [tmp,T.SortInd] = sort(cell2mat(T.Indices),'ascend');
else % PARSE INDICES BY STIMCLASS
  switch lower(P.Stimclass)
    case {'torcs','torc','clickdiscrim'};
      switch P.Runclass
        case {'TOR',''};
          for i=1:length(TrialInd)
            Inds = find(Notes{StimInd(i)}==',');
            T.Tags{i} = Notes{StimInd(i)}(Inds(1)+2:Inds(2)-2);
            cInd = find(T.Tags{i}=='_');
            T.Indices{i} = str2num(T.Tags{i}(cInd(2)+1:cInd(3)-1));
            T.Durations{i} = P.Events(StimInd(i)).StopTime - P.Events(StimInd(i)).StartTime;
          end
          [tmp,T.SortInd] = sort(cell2mat(T.Indices),'ascend');
        otherwise % BEHAVIOR CONDITIONS (REQUIRES MORE PARSING OF THE SUBCONDITIONS)
          % MAKE INDICES A CELL, IN ORDER TO SIGNAL UPSTREAM THAT THERE
          % HAS TO BE SUBPARSING... or mmake this the general format?
          TrialInd = [TrialInd,inf]; T.SortInd = cell(0);
          for iT=1:length(TrialInd)-1
            cStimInd = StimInd(logical((StimInd>TrialInd(iT)).*(StimInd<TrialInd(iT+1))));
            for iS=1:length(cStimInd)
              Pos = find(Notes{cStimInd(iS)}==',');
              cStimTag = Notes{cStimInd(iS)}(Pos(1)+2:Pos(2)-2);
              if strcmp(cStimTag(1:min([end,4])),'torc')
                Pos = find(cStimTag=='_');
                cIndex = str2num(cStimTag(Pos(2)+1:Pos(3)-1));
                T.Indices{iT}(iS) = cIndex;
                cStart = P.Events(cStimInd(iS)).StartTime;
                cStop = P.Events(cStimInd(iS)).StopTime;
                T.Times{iT}(iS,1:2) = [cStart,cStop];
                T.Durations{iT}(iS) = cStop-cStart;
                T.Tags{iT}{iS} = cStimTag;
                if length(T.SortInd)<cIndex T.SortInd{cIndex} = []; end
                T.SortInd{cIndex}(end+1,1:2) = [iT,iS];
              end
            end
          end
      end
      
	case 'optosilence'
        T.Durations = [P.Events(PostSilenceInd).StartTime] - [P.Events(PreSilenceInd).StopTime];
        for iT = 1:length(TrialInd)
             T.Tags{iT} = Notes{TrialInd(iT)+2};
             if strcmp(T.Tags{iT}(find(T.Tags{iT}==',',1,'last')+2:end),'reference+light')
                 T.Indices{iT} = 1;
             elseif strcmp(T.Tags{iT}(find(T.Tags{iT}==',',1,'last')+2:end),'reference+nolight')
                 T.Indices{iT} = 2;
             else
                 disp('tag not recognized');
             end
        end
      
    case 'texturemorphing'
      TargetStimInd = StimInd(~cellfun(@isempty,strfind(Notes(StimInd),', target')));
      Vars = {'Index','Global_TrialNb','ChangedD_Num','MorphingNum','DifficultyNum','FrozenPatternNum','ToC'};
       for iT=1:length(TrialInd)
         cNote = Notes{TargetStimInd(iT)};
         SpaceInds = find(cNote==' ');
         CommaInds = find(cNote==',');
         DashInds = find(cNote=='-'); DashInds = [SpaceInds(3)-1,DashInds,CommaInds(2)];
         switch cNote(SpaceInds(2)+1:SpaceInds(3)-1)
           case 'S0Sbis'; T.SOrder{iT} =  1;
           case 'SbisS0'; T.SOrder{iT} =  -1;
         end
         for iV = 1:length(Vars)
           T.(Vars{iV}){iT} = str2num(cNote(DashInds(iV)+2:DashInds(iV+1)-2)); 
         end
         if T.FrozenPatternNum{iT}~=0  % FrozenPatterns were used
           T.Indices{iT} = T.FrozenPatternNum{iT};
         else
           T.Indices{iT} = T.Index{iT};
         end
         T.Times{iT} = [P.Events(StimInd(iT)).StartTime,P.Events(TargetStimInd(iT)).StopTime];
         T.Tags{iT} = cNote(CommaInds(1)+1:CommaInds(2)-1);
         T.Durations{iT} = diff(T.Times{iT}); 
       end
      
    case {'pure tones','randomtone','amtone'};
      for i=1:length(TrialInd)
        Inds = find(Notes{StimInd(i)}==',');
        T.Tags{i} = Notes{StimInd(i)}(Inds(1)+2:Inds(2)-2);
        T.Frequencies(i) = str2num(P.Events(StimInd(i)).Note(Inds(1)+1:Inds(2)-1));
        T.Durations{i} = P.Events(StimInd(i)).StopTime - P.Events(StimInd(i)).StartTime;
      end
      [tmp,T.SortInd] = sort(T.Frequencies);
      [tmp,tmp,IndicesLoc] = unique(T.Frequencies);
      IndicesSet = [1:length(tmp)];
      T.Indices = mat2cell(IndicesSet(IndicesLoc),1,ones(1,length(IndicesLoc)));
      T.FrequenciesByIndex = unique(T.Frequencies);
      
    case 'tuningfast'; % although multiple stimuli are within one trial, here only the indices are returned
      error('Not tested or seriously implemented yet');
      for i=1:length(TrialInd)     k=0; Found = 0;
        if i<length(TrialInd) NextInd = TrialInd(i+1)-1; else NextInd = length(P.Events); end;
        while k+TrialInd(i) <= NextInd
          tmp = strfind(P.Events(TrialInd(i)+k).Note,'Tone');
          if ~isempty(tmp) Found = 1; break; else k=k+1; end;
        end
        FirstStimTag = P.Events(TrialInd(i)+k).Note;
        cInd = find(FirstStimTag==' ');
        T.Indices(i) = str2num(FirstStimTag(cInd(3)+1:cInd(4)-1));
        T.Tags{i} = FirstStimTag(cInd(2)+1:cInd(4)-1);
      end
      [tmp,T.SortInd] = sort(T.Indices,'ascend');
      
    case 'biasedshepardpair';
      for i=1:length(TrialInd)     k=0; Found = 0;
        if ~isempty(OutcomeInd)
          T.Outcomes{i} = Notes{OutcomeInd(i)}(9:end);
          switch T.Outcomes{i}
            case 'match'; T.OutcomesNum(i) = 1;
            case 'miss';   T.OutcomesNum(i) = 0;
            case 'early';   T.OutcomesNum(i) = -1;
            case 'vearly'; T.OutcomesNum(i) = -2;
          end
        end
        if i<length(TrialInd) NextInd = TrialInd(i+1)-1; else NextInd = length(P.Events); end;
        while k+TrialInd(i) <= NextInd
          tmp = strfind(P.Events(TrialInd(i)+k).Note,'ShepardTone');
          if ~isempty(tmp) Found = 1; break; else k=k+1; end;
        end
        if Found
          FirstStimTag = P.Events(TrialInd(i)+k).Note;
          cInd = find(FirstStimTag==' ');
          T.Indices{i} = str2num(FirstStimTag(cInd(3)+1:cInd(4)-1));
          T.Tags{i} = FirstStimTag(cInd(2)+1:cInd(4)-1);
          % T.Durations(i) = P.Events(PostSilenceInd(i)).StartTime ...
          %- P.Events(PreSilenceInd(i)).StopTime;
        else
          T.Indices{i} = NaN;
          T.Tags{i} = '';
          T.Durations(i) = NaN;
        end
      end
      [tmp,T.SortInd] = sort(cell2mat(T.Indices),'ascend');
      if ~isfield(T,'OutcomesNum') T.OutcomesNum = ones(size(T.Indices)) ; end
      
    case 'shepardtuning';
      for i=1:length(TrialInd)     k=0; Found = 0;
        if i<length(TrialInd) NextInd = TrialInd(i+1)-1; else NextInd = length(P.Events); end;
        while k+TrialInd(i) <= NextInd
          tmp = strfind(P.Events(TrialInd(i)+k).Note,'ShepardTone');
          if ~isempty(tmp) Found = 1; break; else k=k+1; end;
        end
        FirstStimTag = P.Events(TrialInd(i)+k).Note;
        cInd = find(FirstStimTag==' ');
        T.Indices(i) = str2num(FirstStimTag(cInd(3)+1:cInd(4)-1));
        T.Tags{i} = FirstStimTag(cInd(2)+1:cInd(4)-1);
      end
      [tmp,T.SortInd] = sort(T.Indices,'ascend');
      
    case 'biasedshepardtuning'
      for i=1:length(TrialInd)  k=0; Found = 0;
        if i<length(TrialInd) NextInd = TrialInd(i+1)-1; else NextInd = length(P.Events); end;
        while k+TrialInd(i) <= NextInd
          tmp = strfind(P.Events(TrialInd(i)+k).Note,'ShepardTone');
          if ~isempty(tmp) Found = 1; break; else k=k+1; end;
        end
        FirstStimTag = P.Events(TrialInd(i)+k).Note;
        cInd = find(FirstStimTag==' ');
        T.Indices(i) = str2num(FirstStimTag(cInd(3)+1:cInd(4)-1));
        T.Tags{i} = FirstStimTag(cInd(2)+1:cInd(4)-1);
      end
      [tmp,T.SortInd] = sort(T.Indices,'ascend');
      
    case 'ferretvocal'
      for i=1:length(TrialInd)
        Inds = find(Notes{StimInd(i)}==',');
        T.Tags{i} = Notes{StimInd(i)}(Inds(1)+2:Inds(2)-2);
        T.Durations(i) = P.Events(StimInd(i)).StopTime - P.Events(StimInd(i)).StartTime;
      end
      [tmp,SortInd] = sort(T.Tags); % Generate unique order for the tags
      T.Indices = SortInd;
      [tmp,T.SortInd] = sort(T.Indices,'ascend');
      
    case 'tstuning'
      for i=1:length(TrialInd)
        Inds = find(Notes{StimInd(i)}==',');
        T.Tags{i} = Notes{StimInd(i)}(Inds(1)+2:Inds(2)-2);
        cInd = find(Notes{StimInd(i)}=='-');
        if isempty(cInd) % only one attenuation used
          cInd = Inds(2)-1;
          T.Attenuations{i}  = 0;
        else
          T.Attenuations{i} = str2num(P.Events(StimInd(i)).Note(cInd:Inds(2)-1));
        end
        T.Frequencies{i} = str2num(P.Events(StimInd(i)).Note(Inds(1)+1:cInd-1));
        
        T.Durations{i} = P.Events(StimInd(i)).StopTime - P.Events(StimInd(i)).StartTime;
      end
      T.FrequenciesUnique = unique(cell2mat(T.Frequencies));
      T.AttenuationsUnique = unique(cell2mat(T.Attenuations));
      i=0;
      for iF=1:length(T.FrequenciesUnique)
        for iA = 1:length(T.AttenuationsUnique)
          i=i+1;
          T.ParametersByIndex(i,:) =  [T.FrequenciesUnique(iF),T.AttenuationsUnique(iA)];
        end
      end
      T.TrialsByParameters = cell(length(T.FrequenciesUnique),length(T.AttenuationsUnique));
      for i=1:length(TrialInd)
        for j=1:length(TrialInd)
          if T.ParametersByIndex(j,1) == T.Frequencies{i}  ...
              && T.ParametersByIndex(j,2) == T.Attenuations{i}
            break;
          end
        end
        T.Indices{i} = j;  % Indices By Trials
        iF = find(T.Frequencies{i}==T.FrequenciesUnique);
        iA = find(T.Attenuations{i}==T.AttenuationsUnique);
        T.TrialsByParameters{iF,iA}(end+1) = i;
      end
      T.FrequenciesByIndex = T.ParametersByIndex(:,1);
      
      [tmp,T.SortInd] = sort(cell2mat(T.Indices),'ascend');
      
    case 'speechlong'
      for i=1:length(TrialInd)
        cStimInd = StimInd(find(StimInd>TrialInd(i),1,'first'));
        StartInd = find(Notes{cStimInd}==':')+1;
        StopInd = find(Notes{cStimInd}=='+')-1;
        T.Loudnesses(i) = str2num(Notes{cStimInd}(StartInd:StopInd));
      end
      T.Loudnesses(isnan(T.Loudnesses)) = inf;
      Loudnesses = sort(unique(T.Loudnesses));
      
      for i=1:length(Loudnesses)
        T.Indices(T.Loudnesses == Loudnesses(i)) = i;
      end
      [tmp,T.SortInd] = sort(cell2mat(T.Indices),'ascend');
      
    case 'rhythm'
      for i=1:length(TrialInd)
        Inds = find(Notes{StimInd(i)}==',');
        T.Tags{i} = Notes{StimInd(i)}(Inds(1)+2:Inds(2)-2);
        cInd = find(T.Tags{i}==' ');
        T.Indices(i) = str2num(T.Tags{i}(cInd(1)+1:end));
        T.Durations(i) = P.Events(StimInd(i)).StopTime - P.Events(StimInd(i)).StartTime;
      end
      [tmp,T.SortInd] = sort(T.Indices,'ascend');
      
    case 'monauralhuggins'
      for i=1:length(TrialInd)
        StartInd = strfind(Notes{StimInd(i)},'huggins')+8;
        StopInd = find(Notes{StimInd(i)}=='-')-1;
        T.Indices{i} = str2num(Notes{StimInd(i)}(StartInd:StopInd));
      end
      [tmp,T.SortInd] = sort(cell2mat(T.Indices),'ascend');
      
    case 'spnoise'
      [UNotes,tmp,Inds] = unique(Notes(StimInd));
      for iI=1:length(UNotes)
        T.Indices(find(Inds==iI)) = iI;
      end
      [tmp,T.SortInd] = sort(T.Indices,'ascend');
      
    case 'psycholinguisticstimuli'
      Tags = {'a1','a2','a3',...
        'a_speaker_blocked1','a_speaker_blocked2','a_speaker_blocked3',...
        't1','t2','t3',...
        't_speaker_blocked1','t_speaker_blocked2','t_speaker_blocked3'};
      for i=1:length(TrialInd)
        cStimInd = StimInd(find(StimInd>TrialInd(i),1,'first'));
        StartInd = find(Notes{cStimInd}==',',1,'first')+2;
        StopInd = find(Notes{cStimInd}=='.')-1;
        cTag = Notes{cStimInd}(StartInd:StopInd);
        T.Indices{i} = find(strcmp(cTag,Tags));
      end
      
    otherwise
      warning('Stimclass not implemented!');
      T.SortInd = [1:length(TrialInd)];
      
    end
end

T.UIndices = unique(cell2mat(T.Indices));
T.NIndices = sum(T.UIndices>0);
warning on all;
if T.NIndices ~=  T.UIndices(end) fprintf('WARNING (Events2Trials) : # Indices |= maximal Index\n'); end