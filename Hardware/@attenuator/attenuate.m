function err = attenuate(t,atten_val)
% ERR = ATTENUATE(T,ATTEN_VAL); Sets attenuation value of the attenuator,T to
% ATTEN_VAL
% ATTEN_VAL = (0,...,121)dB

% Implementation:
% I have a used a very simple and coarse but effective algorithm. Lets say
% the desired attenuation is ATTEN_VAL. The Attenuator has the following
% steps: Atten_X = {1,2,4,4} and Atten_Y = {10,20,40,40}. Hence the ranges
% of Atten_X and Atten_Y are (0 - 11)dB and (0 - 110)dB respectively. GPIB
% swicthes for Atten_X and Atten_Y are (1,2,3,4) and (5,6,7,8)
% respectively. ie
%   GPIB switch         Attenuation,dB
%       1                   1
%       2                   2
%       3                   4
%       4                   4
%       5                   10
%       6                   20
%       7                   40
%       8                   40
% 
% Let,  
%       Y = floor(ATTEN_VAL/10);
%       X = ATTEN_VAL - 10*Y;
%       except for 120,121 for which Y = 11,11 and X = 10,11 respectively
% For numbers i = 1,2,...,11 initialize AttenOn(i) and AttenOff(i) to the
% combination of switches required to obtain i dB attenuation from Atten_X.
% For sets in which multiple combinations of switches for the same
% atteuation (eg. 7), choose the smaller set.
% Then,
% AttenXOn = AttenOn(X); AttenXOff = AttenOff(X);
% AttenYOn = AttenOn(Y)+4;AttenYOff = AttenOff(Y)+4;
% Example:
% ATTEN_VAL = 76;
% X = mod(76,11) = 10;
% Y = floor(76/11) = 6;
% AttenOn(X) = [2 3 4]; (2+4+4 = 10)    |   AttenOff(X) = [1];
% AttenOn(Y) = [2 3];   (2+4   = 6)     |   AttenOff(Y) = [1 4];
% Hence,
% AttenXOn = [2 3 4];   AttenYOn = [6 7];
% AttenXOff= [1];       AttenYOff= [5 8];
% Commands are sent to the attenuator using fprintf. Command structure:
% '[A|B]GPIB_SWICTHES'
% 'A' turns the switches on whereas B turns them off.
% Hence for the case above,
% CommandOn = 'A12467';
% CommandOff= 'B358';
err = 0;
attenon = {[];...
        [1];...
        [2];...
        [1 2];...
        [3];...
        [1 3];...
        [2 3];...
        [1 2 3];...
        [3 4];...
        [1 3 4];...
        [2 3 4];...
        [1 2 3 4]};
attenoff = {[1 2 3 4];...
        [2 3 4];...
        [1 3 4];...
        [3 4];...
        [1 2 4];...
        [2 4];...
        [1 4];...
        [4];...
        [1 2];...
        [2];...
        [1];...
        []};
if nargin<1
    err = -1;
    disp('sorry atleast one argument is required');
    return;
end;
if ~isa(t,'attenuator')
    err = -2;
    disp('sorry first argument must be attenuator class');
    return;
end;
if nargin<2
    atten_val = 0;
end;

atten_val = floor(atten_val); % Only integers allowed
% check for range
if atten_val>121|atten_val<0
    disp('Sorry attenuation value must be 0,...,121dB');
    err = -3;
    return;
end;
t.attenuation = atten_val;
y = floor(atten_val/10);
y = y - (~(y-12)&1);
x = atten_val - 10*y;
attenxon = attenon{x+1};
attenxoff= attenoff{x+1};
attenyon = attenon{y+1}+4;
attenyoff= attenoff{y+1}+4;

commandon = ['A' sprintf('%d',[attenxon,attenyon])];
commandoff= ['B' sprintf('%d',[attenxoff,attenyoff])];

gpibstatus = get(t,'Status');
if strcmpi(gpibstatus,'closed'),
   startq = input('GPIB Object is closed. Do you wish to open it? - (Return|Y,N)','s');
   if isempty(startq)|strcmpi(startq,'y')
       fopen(t);
   else
       err = -4;
       disp('Sorry unable to continue - GPIB object closed');
       return;
   end;
end;
fprintf(t.gpib,'REMOTE');
fprintf(t.gpib,commandon);
fprintf(t.gpib,commandoff);
