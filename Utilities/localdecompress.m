function localdecompress(sourcefile,destdir)

startdir = pwd;

% CHECK SPECIAL SOLUTIONS ON CERTAIN PLATFORMS/COMPUTERS
switch computer
  case 'PCWIN64';
    tempfile = 'localdecompress.tmp';
    % TEST FOR CYGWIN (WORKS ONLY IF PARENT DIRECTORY IS WRITABLE)
    [Check,Output] = system('which tar');
    if destdir(end)~=filesep destdir(end+1) = filesep; end
    if 0 %~isempty(Output) && Output(1)=='/' % CYGWIN TAR AVAILABLE
      [w,s] = unix(['copy ',sourcefile,' ',destdir,tempfile]);
      if ~isempty(destdir) cd(destdir); end
      [w,s] = unix(['tar -xzf ',tempfile]);
    else  % SLOWER SOLUTION BUT EVENTUALLY AVAILABLE EVERYWHERE
      global MYSQL_BIN_PATH
      [Path,Filename,Ext] = fileparts(sourcefile); if ~isempty(Path) cd(Path); end
      cmd=[MYSQL_BIN_PATH,'gzip -dck ',sourcefile,' > ',destdir,tempfile];
      [w,s]=system(cmd);
      cmd=[MYSQL_BIN_PATH,'tar -xf ',tempfile];
      [w,s]=system(cmd);
    end
    [w,s] = unix(['del ',tempfile]);

  otherwise % WORKS FOR LINUX AND MAC
    system(['tar -xzf ',destfile,' ',sourcefile]);
end
cd(startdir);