function localcompress(destfile,sourcefile)

tempfile = 'localcompress.tmp';

% CHECK SPECIAL SOLUTIONS ON CERTAIN PLATFORMS/COMPUTERS
switch computer
  case {'PCWIN','PCWIN64'},
    % TEST FOR CYGWIN (WORKS ONLY IF PARENT DIRECTORY IS WRITABLE)
    [Check,Output] = system('which tar');
    if ~isempty(Output) && Output(1)=='/' % CYGWIN TAR AVAILABLE
      [Path,Filename,Ext] = fileparts(sourcefile); if ~isempty(Path) cd(Path); end
%       [w,s] = unix(['tar -czf ',tempfile,' ',Filename,Ext]);
%   movefile([tempfile '.tar'],tempfile);
      tar([tempfile(1:end-4) '.tgz'],[Filename,Ext]);      
      movefile([tempfile(1:end-4) '.tgz'],tempfile);
      [w,s] = unix(['copy ',tempfile,' ',destfile]);
      [w,s] = unix(['del ',tempfile]);
    else  % SLOW SOLUTION BUT EVENTUALLY AVAILABLE EVERYWHERE
      global MYSQL_BIN_PATH
      [Path,Filename,Ext] = fileparts(sourcefile); if ~isempty(Path) cd(Path); end
      cmd=[MYSQL_BIN_PATH,'tar -c ',[Filename,Ext],' > ',tempdir,tempfile]; 
      [w,s]=system(cmd);
      cd(tempdir);
      cmd=[MYSQL_BIN_PATH,'gzip -c ',tempfile,' > ' destfile];
      [w,s]=system(cmd);
    end
  otherwise % WORKS FOR LINUX AND MAC
    system(['tar -czf ',destfile,' ',sourcefile]);
end