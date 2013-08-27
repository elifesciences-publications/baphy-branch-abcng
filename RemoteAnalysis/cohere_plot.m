%function cohere_plot(rprocessed,filenames,Fs,sprocessed,channels)
%
% rprocessed{fileidx}: time X rep X channel matrix of LFP
%    (one entry in cell array per file)
% filenames{fileidx}: corresponding filename
% Fs: sampling rate
% channels: (default 1:size(rprocessed{1},3)) labels for channels
% sprocessed{fileidx}: same size as rprocessed but with multi-unit
%     activity instead of LFP
%
% created SVD 2008-05-01
%
function cohere_plot(rprocessed,filenames,Fs,sprocessed,channels)

codepath='F:\Users\alphaomega\code\';
addpath([codepath,'chronux_1_1'],[codepath,'chronux_1_1/continuous'],...
        [codepath,'chronux_1_1/helper'],[codepath,'chronux_1_1/hybrid'],...
        [codepath,'chronux_1_1/pointbinned']);

global ES_LINE 

lcol=ES_LINE;

if ~exist('sprocessed','var'),
   sprocessed={};
end
if ~exist('channels','var'),
   channels=1:size(rprocessed{1},3);
end

chancount=length(channels);
params.Fs=Fs;
params.err=[1 0.01];
params.trialave=1;
params.fpass=[0 Fs./2];

figure;
for ii=1:chancount,
   for jj=ii:chancount,
      c1=ii;
      c2=jj;
      
      for midx=1:length(filenames),
         if c1~=c2,
            fprintf('Coherence Ch %d v %d: %s\n',...
                    channels(c1),channels(c2),filenames{midx});
            
            % different channels: compute lfp-lfp coherence
            sig1=rprocessed{midx}(:,:,c1);
            sig2=rprocessed{midx}(:,:,c2);
            %sig1=randn(size(sig1));
            %sig2=shift(sig1,[1 0]);
            [C1,phi1,S12,S1a,S1b,f,confC,phierr]=coherencyc(sig1,sig2,params);
            
            % different channels: compute spike-lfp coherence
            sig1=sprocessed{midx}(:,:,c1);
            sig2=rprocessed{midx}(:,:,c2);
            
            [Cb]=coherencycpb(sig2,sig1,params);
            %[Cb]=coherencypb(sig2,sig1,params);
            
            % convert phase to ms
            % negative phase means c1 precedes c2
            
            fpf=min(find(f>=10));
            %os1p=mod(phi1(fpf:end)+pi,2.*pi)./f(fpf:end)'.*1000;
            %os1n=(mod(phi1(fpf:end)+pi,2.*pi)-2.*pi)./f(fpf:end)'.*1000;
            os1p=phi1(fpf:end)./f(fpf:end)'.*1000;
            os1n=(mod(phi1(fpf:end),2.*pi)-pi)./f(fpf:end)'.*1000;
            
            subplot(chancount,chancount,(ii-1)*chancount+jj);
            hold on
            plot(f,[C1],'Color',lcol{midx},'LineWidth',2);
            %title(sprintf('coherence chan %d v %d...\n',channels(c1),channels(c2)));
            %ylabel('coherence');
            set(gca,'XTickLabel',[],'YTickLabel',[]);
            hold off
            if midx==length(filenames),
               aa=axis;
               text(aa(1),aa(4),num2str(aa(4)),'VerticalAlignment','top',...
                    'HorizontalAlignment','Left');
               text(aa(2),aa(3),num2str(aa(2)),'VerticalAlignment','bottom',...
                    'HorizontalAlignment','right');
               text(aa(2),aa(4),sprintf('%dv%d',channels(c1),channels(c2)),...
                    'VerticalAlignment','top',...
                    'HorizontalAlignment','right');
            end
            
            subplot(chancount,chancount,(jj-1)*chancount+ii);
            
            if 1,
               % plot spike-lfp coherence
               hold on
               plot(f,Cb,'Color',lcol{midx},'LineWidth',2);
               
            else
               % plot phase
               hold on
               plot(f(fpf:end),[os1p],'Color',lcol{midx});
               plot(f(fpf:end),[os1n],'--','Color',lcol{midx});
               hold off
               %title(sprintf('phase chan %d v %d...\n',channels(c1),channels(c2)));
               
               %ylabel('ms offset (t_{c1}-t_{c2})');
            end
         else
            % same channel: compute spectrum
            fprintf('Spectrum Ch %d:\n',channels(c1));
            
            [S1,f,S1e]=mtspectrumc(rprocessed{midx}(:,:,c1),params);
            subplot(chancount,chancount,(ii-1)*chancount+jj);
            if midx>1,
               hold on
            end
            semilogy(f,[S1],'Color',lcol{midx},'LineWidth',2);
            hold off
            %title(sprintf('spectrum chan %d...\n',channels(c1)));
            
         end
      end
      
      set(gca,'XTickLabel',[],'YTickLabel',[]);
      aa=axis;
      text(aa(1),aa(4),num2str(aa(4)),'VerticalAlignment','top',...
           'HorizontalAlignment','Left');
      text(aa(2),aa(3),num2str(aa(2)),'VerticalAlignment','bottom',...
           'HorizontalAlignment','right');
      text(aa(2),aa(4),sprintf('%dv%d',channels(c1),channels(c2)),...
           'VerticalAlignment','top',...
           'HorizontalAlignment','right');
      if ii==chancount && jj==chancount,
         %xlabel('frequency');
         hl=legend(filenames);
         set(hl,'Interpreter','none');
      end
   end
   drawnow
   
end
fullpage landscape
set(gcf,'Name',filenames{midx});
