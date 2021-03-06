% function r=dbopen(dbserver,dbuser,dbpassword,dbname,force)
%
% open connection to mysql database (requires mysql mex file)
%
% force - optional.  if force==1, reopen, even if global variable
%         DBISOPEN is already non-zero (allows connecting to a
%         different database)
%
% created SVD 6/2001
% modified - SVD - 2005-10-10 - persistent, optional db parameters
%
function r=dbopen(dbserver,dbuser,dbpassword,dbname,force)

global DBISOPEN DBUSER
global DB_USER DB_SERVER DB_PASSWORD DB_NAME
force = 1;
% force backwards compatibility
if exist('dbserver','var'),
   if isnumeric(dbserver),
      force=dbserver;
      clear dbserver
   end
end

% set defaults on first call
if isempty(DB_SERVER),
   DB_SERVER='bhangra.isr.umd.edu';
   %DB_SERVER='128.8.140.174';
   %DB_SERVER='polka.isr.umd.edu';
   %DB_SERVER='metal.isr.umd.edu';
end
if isempty(DB_USER),
   DB_USER='david';
end
if isempty(DB_PASSWORD),
   DB_PASSWORD='nine1997';
end
if isempty(DB_NAME),
   DB_NAME='cell';
end

DBUSER=getenv('USER');
if isempty(DBUSER),
   DBUSER=getenv('user');
end
% kludge to maintain easy compatibility between jlg and nsl networks
%if strcmp(DBUSER,'svd'),
%   DBUSER='david';
%end
if isempty(DBUSER),
   DBUSER=DB_USER;
end

% use remembered values if connection parameters not passed
if ~exist('dbserver','var'),
   dbserver=DB_SERVER;
end
if ~exist('dbuser','var'),
   dbuser=DB_USER;
end
if ~exist('dbpassword','var'),
   dbpassword=DB_PASSWORD;
end
if ~exist('dbname','var'),
   dbname=DB_NAME;
end
if ~exist('force','var'),
   force=0;
end

% save as defaults if parameters not passed next time
DB_SERVER=dbserver;
DB_USER=dbuser;
DB_PASSWORD=dbpassword;
DB_NAME=dbname;

if force || strcmp(computer,'GLNX86'),
   try
      mysql(['use ',dbname]);
      DBISOPEN=1;
   catch
      force=1;
      DBISOPEN=0;
   end
end

if isempty(DBISOPEN) || ~DBISOPEN || force==1,
    try,
        if ~(strcmp(computer,'PCWIN') || strcmp(computer,'PCWIN64') || ...
                strcmp(computer,'MAC') || strcmp(computer,'MAC'))
            hostname=getenv('HOSTNAME');
            if strcmp(hostname,dbserver),
                mysql('open','localhost',dbuser,dbpassword);
            else
                mysql('open',dbserver,dbuser,dbpassword);
            end
        end
        
        mysql(['use ',dbname]);  % ie, cell
        DBISOPEN=1;
    catch
        DBISOPEN=0;
    end
end

r=DBISOPEN;





