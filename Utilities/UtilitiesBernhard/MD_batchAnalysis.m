function R = MD_batchAnalysis(varargin)
%% USAGE EXAMPLES
% BiasedShepardPair: 
% R = mysql('SELECT * FROM gData WHERE svalue="BiasedShepardPair"'); k=0; 
% for i=1:length(R) 
%   Res = mysql(['SELECT * FROM gDataRaw WHERE cellid REGEXP "dnb" AND (runclass="TOR" OR runclass="BSP") AND id=',n2s(R(i).rawid)]); 
%   if ~isempty(Res); k=k+1; R2(k) = Res; end; 
% end
% MD_batchAnalysis('Recordings',Recordings,'Analysis','raster','Print',1,'Compact',1)
%
% TORC:
% R = mysql('SELECT parmfile,id FROM gDataRaw WHERE runclass="TOR" AND parmfile REGEXP "dnb"');
% for i=1:length(R) Recordings{i} = R(i).parmfile(1:9); end
% MD_batchAnalysis('Recordings',Recordings,'Analysis','STRF','Print',1,'Compact',1)
%
% FTC:
% R = mysql('SELECT parmfile,id FROM gDataRaw WHERE runclass="FTC" AND parmfile REGEXP "dnb"');
% for i=1:length(R) Recordings{i} = R(i).parmfile(1:9); end
% MD_batchAnalysis('Recordings',Recordings,'Analysis','Raster','Print',1,'Compact',0)

%% PARSE PARAMETERS
P = parsePairs(varargin);
checkField(P,'Recordings');
checkField(P,'Analysis','Raster');
checkField(P,'Print',0);
checkField(P,'RespType','MUA');
checkField(P,'Compact',1)
checkField(P,'Channels',[1:32]);
checkField(P,'Trials',[1:100]);
checkField(P,'FIG',1);

figure(P.FIG); AH =gca;

%% RUN ANALYSIS OVER RECORDINGS
for iR=1:length(P.Recordings)

  % MAKE LOCAL
  DataMakeLocal('Selector',P.Recordings{iR});
  
  % GET EXTENDED RECORDING INFO
  I = getRecInfo('Identifier',P.Recordings{iR}); R{iR}.I = I;
      
  % RUN ANALYSIS
  switch P.Analysis
    case 'CSD';
      if I.NumberOfChannels>=10 % DETECT LAMINAR PROBE (SWITCH TO ARRAY?)
        R{iR} = MD_computeCSD('Identifier',P.Recordings{iR},'Trials',P.Trials,'FIG',P.FIG);
        baphy_remote_figsave(P.FIG,[],I.globalparams,'csd');
      else
        fprintf('Skipping for CSD analysis, since it does not appear to be a depth probe\n\n');
      end
      
    case 'STRF';
      
      for iE=1:I.NumberOfChannels
        R{iR}.Electrodes(iE) = MD_computeSTRF('Identifier',P.Recordings{iR},'Electrode',iE,...
          'Plotting',1,'FIG',AH,'RespType',P.RespType);
        % DEPTH located at R{iR}.I.Electrodes(iE).DepthBelowSurface;
        drawnow;
      end
      
    case 'PlotSTRF';
      global BATCH_FIGURE_HANDLE; BATCH_FIGURE_HANDLE = P.FIG;
      options = struct('datause','Reference Only','channels',P.Channels,...
        'compact',P.Compact,...
        'runclass',I.Runclass,'ReferenceClass',I.Runclass,'usesorted',0);
      
      online_batch(I.MFile,'strf',options);
      FileName = [I.IdentifierFull,'_',P.Analysis];
  end
  
 % if P.Print printer('Path',['D:\Results\'],'FileName',FileName,'Format','pdf');  end
  
  drawnow; 
end