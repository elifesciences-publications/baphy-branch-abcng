function t = attenuator(varargin)
% T = ATTENUATOR(primary_address)   Constructor for attenuator
% Class attenuator:
%   1. Inherits from class GPIB
%   2. The instrument doesnt return signals for id, status, etc.
%   3. Assumes National Instrument board and GPIB card # 0.
% Usage:
% t = attenuator;   % Default values (primary address = 28)
% t = attenuator(Xatten); %Xatten is a attenuator object
% t = attenuator(primary_address); % primary_address = (0,...,30)
%
% See Also: @instrument/[set,get,fopen,fclose,delete]
%           @attenuator/attenuate
CARD_DEF = 0;
GPIB_DEF = 28;
GPIB_CTR = 'ni';

switch nargin
    case 0
        t.gpib = gpib(GPIB_CTR,CARD_DEF,GPIB_DEF);
        t.attenuation = [];
        t = class(t,'attenuator');
    case 1
        if isa(varargin,'attenuator')
            t = varargin{1};
        elseif isa(varargin,'gpib')
            t.gpib = varargin{1};
            t.attenuation = [];
            t = class(t,'attenuator');
        elseif (varargin{1}<=30)&(varargin{1}>=0)
            t.gpib = gpib(GPIB_CTR,CARD_DEF,varargin{1});
            t.attenuation = [];
            t = class(t,'attenuator');
        else
            error('Sorry incorrect first argument');
        end;
    otherwise
        error('Sorry first argument must belong to class ATTENUATOR or be a number from 0...30');
end;

            
