function exptparams = RandomizeSequence (O, exptparams, globalparams, Counter, RepOrTrial)
% RandomizeSequence provides random or pseudo-random sequences of Trials
% Inputs:
%  Counter       : Current Repetition (RepOrTrial = 1) or Trial (RepOrTrial = 0)
%  RepOrTrial  : Repetition or Trial Randomization
%
% STRATEGY
% - TargetObject controls essentially everything, also the length of the Reference
% - ReferenceObject can be used before the Target
% - If ReferenceObject has more than one index, the number of trials multiplies
% - Create an Index (String) which uniquely identifies a combination of References and Targets
%
% BE 2013/10
% YB 2014/02

% ARGUMENTS
if nargin<4 RepOrTrial = 0; end % Default : Trial Call
P = get(O); % Get parameters

switch RepOrTrial
  case 1 % REPETITION CALL (GENERATE FULL INITIAL SET)
    CurrentRepetition = Counter;
    k=0; tmp = cell(P.TargetMaxIndex*P.ReferenceMaxIndex,1);
    P.TrialTags = tmp; P.ReferenceIndices = tmp; P.TargetIndices = tmp;
    for iT = 1:P.TargetMaxIndex
      for iR = 1:P.ReferenceMaxIndex       k=k+1;
        [P.ReferenceIndices{k},P.TrialTags{k}] = LF_addIndex('R',P.TrialTags{k},iR);
        [P.TargetIndices{k},P.TrialTags{k}]      = LF_addIndex('T',P.TrialTags{k},iT);
        P.TrialTags{k} = P.TrialTags{k}(1:end-1);
      end
    end
    TotalReferences = k; P.NumberOfTrials = k;
    
    % RANDOMIZE ORDER OF THE TRIALS USING THE CURRENT REPETITION
    R = RandStream('mt19937ar','Seed',CurrentRepetition);
    RandInd = R.randperm(TotalReferences);
    P.ReferenceIndices = P.ReferenceIndices(RandInd);
    if ~isempty( get(O,'ReplaySession') )
      PreviousSessionIndex = get(O,'PreviousSessionIndex');
      if isfield(exptparams,'TotalTrials'); ElapsedTrialNb = exptparams.TotalTrials; else ElapsedTrialNb = 0; end
      P.TargetIndices = mat2cell(PreviousSessionIndex(ElapsedTrialNb + (1:P.NumberOfTrials))',ones(1,P.NumberOfTrials),1);
    else
      P.TargetIndices = P.TargetIndices(RandInd);
    end
    P.TrialTags = P.TrialTags(RandInd);
    
  case 0 % TRIAL CALL (MODIFY SET BASED ON PERFORMANCE)
    if P.ReinsertTrials~=0
      switch P.ReinsertTrials<0
        case 1 % when you do not want to change TrialIndexLst (e.g. MemoClicks)
          InNextTrialNb = -(P.ReinsertTrials);
          CurrentTrial = Counter;
          TrialIndex = exptparams.TotalTrials;
          if strcmpi(exptparams.Performance(end).Outcome,'EARLY') ||... % 2014/02-YB: SNOOZE was not considered
              strcmpi(exptparams.Performance(end).Outcome,'SNOOZE')
            % REPEAT LAST INDEX AT RANDOM POSITION IN THE REMAINING
            R = RandStream('mt19937ar','Seed',CurrentTrial);
            RemInd = CurrentTrial:P.NumberOfTrials;
            while length(RemInd)<InNextTrialNb
              RemInd = [RemInd 1:P.NumberOfTrials];
            end
            Inds = [1:CurrentTrial,RemInd(R.randperm(length(RemInd)))];
            P.ReferenceIndices =  P.ReferenceIndices(Inds);
            P.TargetIndices = P.TargetIndices(Inds);
            P.TrialTags = P.TrialTags(Inds);
            P.NumberOfTrials = length(Inds);
          end
        case 0
          TrialIndex = exptparams.TotalTrials;
          R = RandStream('mt19937ar','Seed',TrialIndex);
          if strcmpi(exptparams.Performance(end).Outcome,'EARLY')    % 2014/02-YB: SNOOZE is not considered
            % 2014/02-YB: reinsertion (in the next <P.ReinsertTrials>) of TrialIndex sent to <waveform> (in order to re-generate the same ToC)
            RndNextInd = R.randperm(P.ReinsertTrials);
            P.TrialIndexLst(TrialIndex+RndNextInd(1)) = P.TrialIndexLst(TrialIndex);
            
            CurrentTrial = Counter;
            P.ReferenceIndices(CurrentTrial+RndNextInd) =  P.ReferenceIndices(CurrentTrial);
            P.TargetIndices(CurrentTrial+RndNextInd) = P.TargetIndices(CurrentTrial);
            P.TrialTags(CurrentTrial+RndNextInd) = P.TrialTags(CurrentTrial);
            P.NumberOfTrials(CurrentTrial+RndNextInd) = length(CurrentTrial);
            
          end
      end
    end
  otherwise error('Unknown Option for ''RepOrTrial''!');
end

% SET VARIABLES FOR REFTAR
O = set(O,'ReferenceIndices',P.ReferenceIndices);
O = set(O,'TargetIndices',P.TargetIndices);
O = set(O,'NumberOfTrials',P.NumberOfTrials);
O = set(O,'TrialTags',P.TrialTags);
O = set(O,'TrialIndexLst',P.TrialIndexLst);
exptparams.TrialObject = O;


function [cIndices,cTag] = LF_addIndex(Kind,cTag,cIndices);
for i=1:length(cIndices) cTag = [cTag,sprintf('%s%d_',Kind,cIndices(i))]; end