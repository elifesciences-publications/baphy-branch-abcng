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
    P.TargetIndices = P.TargetIndices(RandInd);
    P.TrialTags = P.TrialTags(RandInd);
    
  case 0 % TRIAL CALL (MODIFY SET BASED ON PERFORMANCE)
    switch P.ReinsertTrials
      case 0; % nothing needs to be done
      case -1; % when you do not want to change TrialIndexLst (e.g. MemoClicks)
        CurrentTrial = Counter;
        TrialIndex = exptparams.TotalTrials;
        if strcmpi(exptparams.Performance(end).Outcome,'EARLY')    % 2014/02-YB: SNOOZE is not considered
          % REPEAT LAST INDEX AT RANDOM POSITION IN THE REMAINING
          R = RandStream('mt19937ar','Seed',CurrentTrial);
          RemInd = CurrentTrial:P.NumberOfTrials;
          Inds = [1:CurrentTrial,RemInd(R.randperm(length(RemInd)))];
          if length(Inds) ~= P.NumberOfTrials+1 warning('Check reinsertion of correction trials'); end
          P.ReferenceIndices =  P.ReferenceIndices(Inds);
          P.TargetIndices = P.TargetIndices(Inds);
          P.TrialTags = P.TrialTags(Inds);
          P.NumberOfTrials = P.NumberOfTrials + 1;
        end        
      otherwise;
        TrialIndex = exptparams.TotalTrials;
        if strcmpi(exptparams.Performance(end).Outcome,'EARLY')    % 2014/02-YB: SNOOZE is not considered
          % 2014/02-YB: reinsertion (in the next 8) of TrialIndex sent to <waveform> (in order to re-generate the same ToC)
%           P.TrialIndexLst(TrialIndex+randi(8,1)) =P.TrialIndexLst(TrialIndex);
          P.TrialIndexLst(TrialIndex+P.ReinsertTrials) =P.TrialIndexLst(TrialIndex);
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