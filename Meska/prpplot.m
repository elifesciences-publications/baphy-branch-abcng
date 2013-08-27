function prpplot(fname,ripvel,varargin)
% MPLOT(fname)
% MPLOT(fname, recs)
% MPLOT(fname, fname2, ...)
% MPLOT([fname; fname2; ...])
% MPLOT([fname; fname2; ...], recs)
%%
% prpplot uses getspikes and mpstplot to display spiketrain psts
% (and their linear fits).
% fname is a string containing the experiment and filename,
%  for example '225/30a07.a1-.fea' or
%              '/software/daqsc/data/225/30a07.a1-.fea'
% recs is an optional range of which records to plot (default = all)
% (currently unimplemented)

recs=1:10;
if ~exist('ripvel');ripvel = 4;end


for i=1:length(recs),
	rv(i) = ripvel; 
end;

[spdata,ddur,stonset,stdur,saf,hf,ncomp,mf,paramdata, nUnit] =getspikes(fname,1);
binnum = 250;
%[DC,AC1,norm,ACP,pst] = mpst(spdata,rv,binnum,pststart,pstend,mf);
[DC,AC1,norm,ACP,pst] = mpst(spdata,rv,binnum);

rips=rv;
spikes=size(spdata,1);

if stonset <= 0;stonset = 3; end
if stdur >= spikes/mf-stonset;stdur = spikes/mf-stonset;end

ylabels = [1:length(recs)]';
ylabelstring = 'stimulus';
if ~isempty(paramdata) & (length(fname)>7)
 [ylabels,ylabelstring,paramstring] = relevantfeainfo(fname,paramdata,1/mf);
 %ylabels = ylabels(recs);
 ylabelstring = ['\fontname{Times}',ylabelstring];
 paramstring = ['\fontname{Times}\fontsize{9}',paramstring];
end
figure

clf
hold on

yAx = axes('position',[0.0700    0.1100    0.01    0.8125]);
set(yAx,'XColor','w','YColor','w','ZColor','w','xTick',[],'yTick',[])
yLbl = ylabel('','Color','k');
set(yLbl,'String',ylabelstring)

paramAx = axes('Position',[0.1300    0.0400    0.7750    0.01]) ;
set(paramAx,'XColor','w','YColor','w','ZColor','w','xTick',[],'yTick',[])
xLbl = xlabel('','Color','k');
xPos = get(xLbl,'Position');xPos(1) = 1;set(xLbl,'Position',xPos)
set(xLbl,'HorizontalAlignment', 'right')
set(xLbl,'String',paramstring)

plotLims = [min(min(min(pst)),min(DC-AC1)),max(max(max(pst)),max(DC+AC1))];

for abc = 1:length(recs)

        subplot(length(recs),1,abc)
        set(gca,'Ytick',[]);
        hold on
%line(stonset*[1 1]*mf,plotLims,'Color',[.95 .95 .75])
        %line((stonset+stdur)*[1 1]*mf,plotLims,'Color',[.95 .95 .75])
        %line(pststart*[1 1]*mf,plotLims,'Color',[.95 .75 .95])

%       plot(1:spikes, DC(abc)+...
%         AC1(abc)*sin(2*pi*abs(rips(abc))*(1:spikes)/mf*0.001 ...
%         + ACP(abc)), 'b')
        pstplotnum = round(ddur*abs(rips(abc))/1000);
        pstplot = pst(binnum,abc);
pstplotnum=1;
        for mm = 1:pstplotnum
         pstplot = [pstplot;pst(:,abc)];
        end
        pstplot = [pstplot;pst(1,abc)];
        plot(([0:pstplotnum*binnum+1]-0.5)/binnum*1000/abs(rips(abc)),...
         pstplot,'r')

        ylabel(['\fontsize{9}',num2str(ylabels(abc),3)],...
      'Rotation',0,'HorizontalAlignment', 'right')
%       set(gca,'XLim',[0 ddur]);
        set(gca,'YLim',plotLims);
    set(gca,'box','off')
        set(gca,'tickdir','out')

        if abc == 1
                title(['\fontname{Times}\fontsize{10}\bf',fname])
                set(gca,'XtickLabel','');
        elseif abc ~= length(recs)
                set(gca,'XtickLabel','');
        else
                xlab = str2num(get(gca,'xticklabel'));
                set(gca,'xticklabel',num2str(xlab/mf))
                set(gca,'fontsize',9)
                %xlabel('\fontname{Times}Time (ms)')
        end

end



