function SC_computeCSD
% COMPUTES CSDS FOR ALL SELECTED RECORDINGS AND PUTS THEM IN THE CELLDB

R = D_findRecordings('Runclasses',{'FTC'},'Animals',{'Lemon'},'Penetrations',{23:25});
MD_batchAnalysis('Recordings',R(1).Identifiers,'Analysis','CSD');