function t = hpmux(varargin)
% T = HPMUX(primary_address)   Constructor for hpmux
% Class hpmux:
%   1. Inherits from class GPIB
%   2. Assumes National Instrument board and GPIB card # 0.
% Usage:
% t = hpmux;   % Default values (primary address = 13)
% t = hpmux(HPmux); %HPMux is a hpmux object
% t = hpmux(primary_address); % primary_address = (0,...,30)
%
% See Also: @instrument/[set,get,fopen,fclose,delete]
%           @hpmux/attenuate
CARD_DEF = 0;
GPIB_DEF = 13;
GPIB_CTR = 'ni';

switch nargin
    case 0
        t.gpib = gpib(GPIB_CTR,CARD_DEF,GPIB_DEF);
        t = class(t,'hpmux');
    case 1
        if isa(varargin,'hpmux')
            t = varargin{1};
        elseif isa(varargin,'gpib')
            t.gpib = varargin{1};
            t = class(t,'hpmux');
        elseif (varargin{1}<=30)&(varargin{1}>=0)
            t.gpib = gpib(GPIB_CTR,CARD_DEF,varargin{1});
            t = class(t,'hpmux');
        else
            error('Sorry incorrect first argument');
        end;
    otherwise
        error('Sorry first argument must belong to class HPMUX or be a number from 0...30');
end;

            
