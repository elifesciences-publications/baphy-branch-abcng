function [exptparams] = RandomizeSequence (o, exptparams, globalparams, RepIndex, RepOrTrial)
% SVD 2012-10-19, generate sequences of References according to rules for
% sequences of repeated/varying targets/distracters
%

if nargin<3, RepIndex = 1;end
if nargin<4, RepOrTrial = 0;end   % default is its a trial call

% read the trial parameters
par = get(o);

TotalTrials=length(par.Sequences);
ThisRepIdx=shuffle(1:TotalTrials)';
o = set(o,'NumberOfTrials',TotalTrials);
o = set(o,'ThisRepIdx',ThisRepIdx);
o = set(o,'SequenceIdx',[par.SequenceIdx;ThisRepIdx]);

exptparams.TrialObject = o;
