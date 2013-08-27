% function meska_loadtemplate(spikefile,cn);
%
% support code for m_mespca
%
% extracted from m_template.m SVD 2009-09-21
%
function meska_loadtemplate(spikefile,cn);

global UNITMEAN UNITSTD XAXIS UNITCOUNT SPKCOUNT UNITTOL SIGTHRESH SWEEPOUT

if exist(spikefile,'file') & cn>0,
   disp('loading full meskres template');
   spkdata=load(spikefile);
   if isfield(spkdata,'sortextras') & length(spkdata.sortextras)>=cn &...
          ~isempty(spkdata.sortextras{cn}),
      UNITMEAN=spkdata.sortextras{cn}.unitmean;
      UNITSTD=spkdata.sortextras{cn}.unitstd;
      UNITTOL=spkdata.sortextras{cn}.tolerance;
      
      % backward compatibility to pre-sweepout days
      if isfield(spkdata.sortextras{cn},'sweepout'),
         SWEEPOUT=spkdata.sortextras{cn}.sweepout;
      else
         SWEEPOUT=0;
      end
      if isfield(spkdata.sortextras{cn},'sigthreshold'),
          SIGTHRESH=spkdata.sortextras{cn}.sigthreshold;
      else
          SIGTHRESH=[];
      end
      oldXAXIS=spkdata.sortinfo{cn}{1}(1).xaxis;
      UNITCOUNT=size(UNITMEAN,2);
      SPKCOUNT=zeros(UNITCOUNT,1)
      for ii=1:spkdata.sortinfo{cn}{1}(1).Ncl,
         SPKCOUNT(ii)=size(spkdata.sortinfo{cn}{1}(ii).unitSpikes,2);
      end
   end
end

if oldXAXIS(2) < XAXIS(2),
    UNITMEAN((oldXAXIS(2)-oldXAXIS(1)):(XAXIS(2)-XAXIS(1)+1),:)=0;
    UNITSTD((oldXAXIS(2)-oldXAXIS(1)):(XAXIS(2)-XAXIS(1)+1),:)=0;
end
