function mesg = hpswitch(t,varargin)
% MESG = HPSWITCH(HPMUX_OBJ,COMMAND,COMMAND_ARGS); Sends commands to
% HPMUX_OBJ - Returns state of channels as MESG or error info.
% Refer to manual for details of commands
%
% List of Commands with respective arguments:
% 1. (Reset) - Resets the switch to all open (all slots)
% 2. (Open,row,col,slot) - opens the connection between specified row
%            and column for said slot#
% 3. (Close,row,col,slot) - same as above but closes the connection instead
% 4. (View,row,col,slot) - view state(open/closed) for channel specified
% Only one command maybe given at a time. if row,col,slot arent specified
% then default values are assumed which are 0,0,1 respectively.

addpath(matlabroot)

if nargin<2
   mesg = -1;
   disp('Atleast two input is required');
   return;
end;
if ~isa(t,'hpmux')
    mesg = -2;
    disp('First input must be HPMUX');
    return;
end;

gpibstatus = get(t,'Status');
if strcmpi(gpibstatus,'closed'),
   startq = input('GPIB Object is closed. Do you wish to open it? - (Return|Y,N)','s');
   if isempty(startq)|strcmpi(startq,'y')
       fopen(t);
   else
       mesg = -4;
       disp('Sorry unable to continue - GPIB object closed');
       return;
   end;
end;
gpibcommand = translate(varargin);
fprintf(t,gpibcommand);
mesg = fscanf(t);


function gpibcmd = translate(command)
% gpibcmd = translate(command); command is a cell array of plain
% english commands.
% TRANSLATE translates from plain english to gpib commands


switch lower(command{1})
case 'reset'
%     if length(command)>1
%         slot = command{2};
%     else
%         slot = 1;
%     end;
    gpibcmd = config('hpmux');
case {'open','close','view'}
    chan = ['001']; %(row,col,slot)
    if length(command)>1
        for i = 2:length(command)
            chan(i-1) = num2str(command{i});
        end;
    end;
    gpibcmd = config('hpmux',command{1},chan);
end;