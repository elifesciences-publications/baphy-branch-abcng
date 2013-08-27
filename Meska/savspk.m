if ~SAVED
   tfname=fname;
   % remove evp extension from spike file
   if strcmp(lower(tfname((end-3):end)),'.evp')
      tfname=tfname(1:(end-4));
   end
   if ~ONEFILE,
      tf2name=f2name;
      if strcmp(lower(tf2name((end-3):end)),'.evp')
         tf2name=tf2name(1:(end-4));
      end
   end
   if USEDB,
      % added USEDB code SVD 10/04/2005 to make life easier
      %SORTROOT='/afs/glue.umd.edu/department/isr/labs/nsl/users/svd/data';
      SORTROOT=[NET_DATA_ROOT 'users',filesep,'svd',filesep,'data'];
      set(ste1,'string',[tfname]);
      set(ste2,'string',[SORTROOT, filesep, 'sorted', filesep]);
      set(ste3,'string',fullfile(path,direc,filesep));
      if ~ONEFILE
         set(ste4,'string',[tf2name]);
         set(ste5,'string',[SORTROOT, filesep, 'sorted', filesep]);
         set(ste6,'string',fullfile(path2,direc2,filesep));
      end
   else
      set(ste1,'string',[tfname]);
      set(ste2,'string',fullfile(path,direc,'sorted',filesep));
      set(ste3,'string',fullfile(path,direc,filesep));
      if ~ONEFILE
         set(ste4,'string',[tf2name]);
         set(ste5,'string',fullfile(path2,direc2,'sorted',filesep));
         set(ste6,'string',fullfile(path2,direc2,filesep));
      end
   end
end
if SAVEAS | ~SAVED
    set(savfig,'visible','on');
    uiwait(savfig);
end
if RESUME
    if FIRSTSAVED
        source=fullfile(get(ste3,'string'),fname);
        destin=fullfile(get(ste2,'string'),get(ste1,'string'));
        sorter= get(stsort,'string');
        for ab=1:length(spk);
            spksav1{ab}=spk{ab,1};
        end
        savespikes(source,destin,st,spiketemp,spksav1,sorter,PSORTER,comments,extras,REGORDER1,xaxis);
    end
    if ~ONEFILE
        if SECONDSAVED
            source2=fullfile(get(ste6,'string'),f2name);
            destin2=fullfile(get(ste5,'string'),get(ste4,'string'));
            sorter= get(stsort,'string');
            for ab=1:length(spk);
                spksav2{ab}=spk{ab,2};
            end
            savespikes(source2,destin2,st2,spiketemp2,spksav2,sorter, PSORTER,comments,extras2,REGORDER2,xaxis);
        end
    end
    SAVED=1;
end
