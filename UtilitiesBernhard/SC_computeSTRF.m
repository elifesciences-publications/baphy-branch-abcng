function SC_computeSTRF
% COMPUTES STRFS FOR ALL SELECTED RECORDINGS AND PUTS THE GRAPHS IN THE
% CELLDB

R = D_findRecordings('RunClasses',{'TOR','PTD','CLK','TAD'});
for iR = 1:length(R)
  MD_batchAnalysis('Recordings',R(iR).Identifiers,'Analysis','STRF');
end