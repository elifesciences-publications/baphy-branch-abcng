function R = LoadSpikeTimesNSL(varargin)

P = parsePairs(varargin);
checkField(P,'File');
checkField(P,'Electrodes',1);
checkField(P,'Units',1);
checkField(P,'Sorting','SUA');
checkField(P,'Format','Times');
checkField(P,'SR',1000);


% LOAD FILE
D = load(P.File);

% BREAK BY TRIAL
switch P.Sorting
  case 'MUA';
     NTrials = 1;
    for i=1
    end
    
  case 'SUA';
    NTrials = 1;
    for i=1
    end
end

switch P.Format
  case 'Times'; 
  case 'Raster';
  otherwise error()
end