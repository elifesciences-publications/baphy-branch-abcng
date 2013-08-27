function [DiffSTRFs,Recs] = SC_computeDiffSTRF(varargin)

P = parsePairs(varargin);
checkField(P,'Recompute',1);
checkField(P,'Recs',[]);
checkField(P,'RunClasses',{'PTD'});
checkField(P,'Animals',{'Lemon','Avocado'});
checkField(P,'Penetrations',{ [1:21,23,25] , [1:27] });

if P.Recompute clear global R; end
global R;

if isempty(P.Recs)
  Recs = D_findRecordings('RunClasses',P.RunClasses,'Animals',P.Animals,'Penetrations',P.Penetrations);
else 
  Recs = P.Recs;
end

if isempty(R) | P.Recompute
  for iS = 1:length(Recs) % LOOP OVER STIMULI
    R{iS} = MD_batchAnalysis('Recordings',Recs(iS).Identifiers,'Analysis','STRF','RespType','MUA');
  end
end

for iS = 1:length(R) % LOOP OVER STIMULUS CLASSES
  % USE THE MATCH IN RECS TO FORM THE CORRESPONDING DIFF-STRFs
  for iB = 1:size(Recs(iS).ActTriples,1)
    PreInd = Recs(iS).ActTriples(iB,1);
    ActInd = Recs(iS).ActTriples(iB,2);
    PostInd = Recs(iS).ActTriples(iB,3);
    
    DiffSTRFs{iB} = computeDiffSTRF(...
      'Pre',R{iS}{PreInd}.Electrodes,...
      'Act',R{iS}{ActInd}.Electrodes,...
      'Post',R{iS}{PostInd}.Electrodes,...
      'IPre',R{iS}{PreInd}.I,...
      'IAct',R{iS}{ActInd}.I,...
      'IPost',R{iS}{PostInd}.I,...      
      'Target',Recs(iS).RunClass);
  end
end