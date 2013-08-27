function exptparams = RandomizeSequence (O, exptparams, globalparams, Counter, RepOrTrial)
% RandomizeSequence provides random or pseudo-random sequences of Trials
% Inputs:
%  Counter       : Current Repetition (RepOrTrial = 1) or Trial (RepOrTrial = 0)
%  RepOrTrial  : Repetition or Trial Randomization
%
% STRATEGY
% - define the number of slots (TarIndices * distribution of RefLengths)
% - fill slots from an even distribution of the RefIndices
% - In the case when the reference depends on the target, the connected indices
%   should be in the target and there needs to be communication between reference and target
% - Create an Index (String) which uniquely identifies a combination of References and Targets
% - some randomness is sacrificed for being able to analyze better
%
% BE 2010/7

% ARGUMENTS
if nargin<4 RepOrTrial = 0; end % Default : Trial Call
P = get(O); % Get parameters

switch RepOrTrial
  case 1 % REPETITION CALL (GENERATE FULL INITIAL SET)
    CurrentRepetition = Counter;   
    if ~isnumeric(P.NumberOfRefDistrib(1))
      error('Incorrect Entry for NumberOfRefDistrib!');
    else
      if P.NumberOfRefDistrib(1)<0
        % only 1 reference slot, length chosen by reference object, all indices included per rep
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
        
      else % distribution of reference slots, ref. object provided 'atomic' stimuli, indices randomly selected
        LengthDist = P.NumberOfRefDistrib; % Distribution over lengths (Default e.g. [3,2,1,1,1,...])
        NumberOfLengths = sum(LengthDist);
        TotalReferences = sum(LengthDist)*P.TargetMaxIndex;
        ReferenceIndices = cell(1,TotalReferences); TargetIndices = ReferenceIndices;
        % ASSIGN ALL REFERENCES TO TARGETS WITH GIVEN LENGTH OF REFERENCE-SEQUENCE
        k=0; tmp = cell(P.TargetMaxIndex*NumberOfLengths,1);
        P.TrialTags = tmp; P.ReferenceIndices = tmp; P.TargetIndices = tmp;
        for iT = 1:P.TargetMaxIndex % keep low to avoid larger NumberOfTrials (8 for BSP)
          for iLength = 1:NumberOfLengths    k=k+1;
            cNReferences = find(iLength<=cumsum(LengthDist),1,'first');
            cIndices = randint(1,cNReferences,[1,P.ReferenceMaxIndex]);
            [P.ReferenceIndices{k},P.TrialTags{k}] = LF_addIndex('R',P.TrialTags{k},cIndices);
            [P.TargetIndices{k},P.TrialTags{k}]      = LF_addIndex('T',P.TrialTags{k},iT);
            P.TrialTags{k} = P.TrialTags{k}(1:end-1);
          end
        end
      end
    end
    P.NumberOfTrials = k;
      
    % RANDOMIZE ORDER OF THE TRIALS USING THE CURRENT REPETITION
    R = RandStream('mt19937ar','Seed',CurrentRepetition);
    RandInd = R.randperm(TotalReferences);
    P.ReferenceIndices = P.ReferenceIndices(RandInd);
    P.TargetIndices = P.TargetIndices(RandInd);
    P.TrialTags = P.TrialTags(RandInd);
    
    % TEMPORARY TRAINING PARADIGM (SUPPORTS ONLY 2 TARGETS)
%     warning('Block based design interjected in RandomizeSequence!');
%     NBlock = 3; P.NumberOfTrials = NBlock;
%     P = rmfield(P,{'TargetIndices','ReferenceIndices','TrialTags'});
%     for i=1:NBlock 
%       P.ReferenceIndices{i} = 1;
%       P.TargetIndices{i} = mod(CurrentRepetition,2)+1;
%       P.TrialTags{i} = ['R1_T',n2s(P.TargetIndices{i})];
%     end
    
  case 0 % TRIAL CALL (MODIFY SET BASED ON PERFORMANCE)
    CurrentTrial = Counter;
    if ~strcmpi(exptparams.Performance(end).Outcome,'HIT') 
      % REPEAT LAST INDEX AT RANDOM POSITION IN THE REMAINING
      R = RandStream('mt19937ar','Seed',CurrentTrial);
      RemInd = [CurrentTrial:P.NumberOfTrials];
      Inds = [1:CurrentTrial,RemInd(R.randperm(length(RemInd)))];
      if length(Inds) ~= P.NumberOfTrials+1 warning('Check reinsertion of correction trials'); end
      P.ReferenceIndices =  P.ReferenceIndices(Inds);
      P.TargetIndices = P.TargetIndices(Inds);
      P.TrialTags = P.TrialTags(Inds);
      P.NumberOfTrials = P.NumberOfTrials + 1;
    end
    
  otherwise error('Unknown Option for ''RepOrTrial''!');
end
% SET VARIABLES FOR REFTAR
O = set(O,'ReferenceIndices',P.ReferenceIndices);
O = set(O,'TargetIndices',P.TargetIndices);
O = set(O,'NumberOfTrials',P.NumberOfTrials);
O = set(O,'TrialTags',P.TrialTags);
exptparams.TrialObject = O;


function [cIndices,cTag] = LF_addIndex(Kind,cTag,cIndices);
for i=1:length(cIndices) cTag = [cTag,sprintf('%s%d_',Kind,cIndices(i))]; end