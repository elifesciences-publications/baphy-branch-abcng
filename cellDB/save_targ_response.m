baphy_set_path;
dbopen;

sql=['SELECT gDataRaw.*,gPenetration.numchans',...
     ' FROM gDataRaw,gCellMaster,gPenetration',...
     ' WHERE gDataRaw.masterid=gCellMaster.id',...
     ' AND gCellMaster.penid=gPenetration.id',...
     ' AND not(gDataRaw.bad)',...
     ' AND (gDataRaw.cellid like "sir%" OR gDataRaw.cellid like "tel%")',...
     ' AND (runclass="LDS" or runclass="NON" or runclass="PTD" or runclass="DMS" or runclass="RTD" or runclass="CCH")',...
     ' AND gDataRaw.training=0'];
dmsdata=mysql(sql);


for ii=1:length(dmsdata),
   sql=['SELECT * FROM gData WHERE rawid=',num2str(dmsdata(ii).id),...
        ' AND name="Tar_Resp"'];
   targdata=mysql(sql);
   if isempty(targdata) || (sum(targdata.value)==0 &&...
             (isempty(targdata.svalue) || sum(eval(targdata.svalue))==0))
      Tar_Resp=zeros(1,dmsdata(ii).numchans);
      Ref_Resp=zeros(1,dmsdata(ii).numchans);
      
      PreStimSilence=0.2;
      PostStimSilence=0.3;
      rasterfs=100;
      options.rasterfs=rasterfs;
      options.tag_masks={'SPECIAL-COLLAPSE-BOTH'};
      options.includeprestim=[0 0];
      mfile=[dmsdata(ii).resppath dmsdata(ii).parmfile];
      
      for cc=1:dmsdata(ii).numchans,
         
         options.channel=cc;
         
         try,
            [r,tags,trialset,exptevents]=loadevpraster(mfile,options);
            
            Ref_Resp(cc)=nanmean(nanmean(r(:,:,1),2),1).*rasterfs;
            Tar_Resp(cc)=nanmean(nanmean(r(:,:,2),2),1).*rasterfs;
            
            if 0
               prerange=((PreStimSilence-0.1).*rasterfs+1):...
                        (PreStimSilence.*rasterfs);
               earlyrange=round((PreStimSilence.*rasterfs+1):...
                                ((PreStimSilence+0.07).*rasterfs));
               laterange=round(((PreStimSilence+0.07).*rasterfs+1):...
                               ((PreStimSilence+0.4).*rasterfs));
               pretarg=nanmean(targresp(prerange,:));
               earlytarg=nanmean(targresp(earlyrange,:));
               latetarg=nanmean(targresp(laterange,:));
               sust=latetarg>pretarg;
               trans=earlytarg>pretarg & ~sust;
               weird=~sust & ~trans;
               if isempty(pretarg) || isnan(pretarg) || pretarg==0 || ...
                      isnan(latetarg) || isempty(latetarg),
                  Targ_Resp_Sust(cc)=0;
               else
                  Targ_Resp_Sust(cc)=latetarg./pretarg;
               end
               if isempty(pretarg) || isnan(pretarg) || pretarg==0 || ...
                      isnan(earlytarg) || isempty(earlytarg),
                  Targ_Resp_Trans(cc)=0;
               else
                  Targ_Resp_Trans(cc)=earlytarg./pretarg;
               end
            end
         catch
            % save Targ_Resp_XXX with blanks
            warning('error loading evp');
         end
      end
      Ref_Resp(isnan(Ref_Resp))=0;
      Tar_Resp(isnan(Tar_Resp))=0;
      
      perf=[];
      perf.Tar_Resp=round(Tar_Resp.*1000)./1000;
      perf.Ref_Resp=round(Ref_Resp.*1000)./1000
      
      dbWriteData(dmsdata(ii).id,perf,1,1);
   end
end
