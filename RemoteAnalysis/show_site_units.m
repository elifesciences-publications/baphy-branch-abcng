% function show_site_units(siteid,options);
% 
% extract and display mean waveforms for each sorted file at the specified
% site.  options don't do anything for the time being.
% 
% svd 2007-01-16
%
function show_site_units(siteid,options);

dbopen;
sitedata=dbgetsite(siteid);


unitmean={};
unitstd={};
sortedexists=zeros(length(sitedata),1);
unitmax=zeros(16,1);
unitmin=zeros(16,1);
maxunits=0;
for ii=1:length(sitedata),
    spkfile=sitedata(ii).matlabfile;
    if isempty(spkfile) || ~exist(spkfile,'file'),
        fprintf('no spk.mat file for %s\n',sitedata(ii).parmfile);
    else
        sortedexists(ii)=1;
        %ss=load(spkfile,'sortextras');
        ss=load(spkfile);
        for jj=1:length(ss.sortextras),
            if isfield(ss.sortextras{1},'unitmean'),
                unitmean{ii,jj}=ss.sortextras{jj}.unitmean;
                unitstd{ii,jj}=ss.sortextras{jj}.unitstd;
            else
                unitmean{ii,jj}=ss.sortinfo{jj}{1}(1).Template;
                unitstd{ii,jj}=zeros(size(unitmean{ii,jj}));
            end
            unitmax(jj)=max(unitmax(jj),max(unitmean{ii,jj}(:)+unitstd{ii,jj}(:)));
            unitmin(jj)=min(unitmin(jj),min(unitmean{ii,jj}(:)+unitstd{ii,jj}(:)));
            maxunits=max(maxunits,size(unitmean{ii,jj},2));
        end
    end
end

sortedidx=find(sortedexists);
colcount=sum(sortedexists);
rowcount=size(unitmean,2);

figure
for ii=1:colcount,
    for jj=1:rowcount,
        subplot(rowcount,colcount,ii+(jj-1).*colcount);
        for uu=1:size(unitmean{sortedidx(ii),jj},2),
            if sum(unitstd{sortedidx(ii),jj}(:,uu))>0,
                errorshade((1:length(unitmean{sortedidx(ii),jj}(:,uu)))',...
                    unitmean{sortedidx(ii),jj}(:,uu),...
                    unitstd{sortedidx(ii),jj}(:,uu));
                hold on
            end
        end
        hl=plot(unitmean{sortedidx(ii),jj});
        hold off
        aa=axis;
        axis([aa(1:2) unitmin(jj) unitmax(jj)]);
        if jj==1,
            ht=title(sprintf('%s',sitedata(sortedidx(ii)).parmfile));
        else
            ht=title(sprintf('electrode %d',jj));
        end
        set(ht,'Interpreter','none');
        set(gca,'XTickLabel',[]);
        set(gca,'YTickLabel',[]);
    end
end
lstring={};
for uu=1:maxunits,
    lstring{uu}=num2str(uu);
end
legend(hl,lstring);
set(gcf,'PaperOrientation','landscape','PaperPosition',[0.5 0.5 10 7.5])
