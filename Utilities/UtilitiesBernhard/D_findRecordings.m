function R = D_findRecordings(varargin)
 
P = parsePairs(varargin);
checkField(P,'Runclasses',{'TOR','PTD','CLK','TAD'});
checkField(P,'Animals','Avocado')
checkField(P,'Penetrations',{1:27});
checkField(P,'ActivePassive',1);

if ~iscell(P.Animals) P.Animals = {P.Animals}; end
if ~iscell(P.Runclasses) P.Runclasses = {P.Runclasses}; end
if ~iscell(P.Penetrations) P.Penetrations = {P.Penetrations}; end
if length(P.Animals) ~= length(P.Penetrations) 
  error('Length of Animals and Penetrations need to be matched.'); 
end
T = MD_animalIDs;

for iR=1:length(P.Runclasses)
  fprintf(['========= [ ',P.Runclasses{iR},' ] =========\n']);
  R(iR).RunClass = P.Runclasses{iR}; k=0;
  
  for iA = 1:length(P.Animals)
    fprintf(['---------------- [ ',P.Animals{iA},' ] --------------\n']);
    CellPrefix = T.A2P.(P.Animals{iA});
    % GET MORE PARAMETERS TO MAKE A DECISION OF WHICH TO SELECT
    tmp = mysql(['SELECT parmfile FROM gDataRaw '...
      'WHERE runclass="',R(iR).RunClass,'"'...
      ' AND parmfile like "',CellPrefix,'%"',...
      ' AND training=0 AND NOT(bad)']);
    
    % SELECT CORRECT RANGES OF PENETRATIONS
    [ParmFiles,SortInd] = sort({tmp.parmfile});
    for iF = 1:length(ParmFiles)
      cP = MD_I2S2I(struct('Identifier',ParmFiles{iF}(1:end-2)));
      if ismember(cP.Penetration,P.Penetrations{iA})
        k=k+1;
        R(iR).Identifiers{k} = ParmFiles{iF}(1:find(ParmFiles{iF}=='_')-1);
        R(iR).ParmFiles{k} = ParmFiles{iF};
        R(iR).P(k) = cP;
        fprintf([' => ',R(iR).Identifiers{k},'\n']);
      end
    end
    
    % LABEL RECORDINGS BY PASSIVE-ACTIVE-PASSIVE TRIPLES
    if P.ActivePassive
      % FIRST FIND THE ACTIVE RECORDINGS
      Behaviors = {R(iR).P.Behavior};
      ActiveInd = find(strcmp(Behaviors,'a'));
      
      if ~isempty(ActiveInd) 
        fprintf('Assigning Passive-Active-Passive Triples : \n');   
        % NEXT FIND THE NEIGHBORING PASSIVES
        for iB = 1:length(ActiveInd)
          R(iR).ActTriples(iB,:) = [ActiveInd(iB)] + [-1,0,1];    
          fprintf('  %d : \t%s\t%s\t%s \n',iB,R(iR).Identifiers{R(iR).ActTriples(iB,:)});        
        end
      end
    end
  end
end