function t = khfilter(varargin)
% T = KHFILTER(primary_address); Constructor for Krihn-Hite Filter
% khfilter constructs the object for Krohn-Hite filters
% Class KHFILTER:
%   1. Inherits from class GPIB
%   2. The instrument returns signals for id, status, etc.
%   3. Assumes National Instrument board and GPIB card # 0.
% Usage:
% t = khfilter;   % Default values (primary address = 23)
% t = khfilter(Xkh); %Xkh is a khfilter object
% t = khfilter(primary_address); % primary_address = (0,...,30)
%
% Description : Header for Krohn Hite filter related functions.
%                Krohn Hite main frame is Model 3905A
%                High-Pass PlugIn : Model 31-1 : 1Hz to 99kHz
%                                     Band     Frequency         Resolution
%                                     1        1Hz - 99Hz        1Hz
%                                     2        100Hz - 990Hz     10Hz
%                                     3        1kHz - 9.9kkHz    100Hz
%                                     4        10kHz - 99kHz     1000Hz
%                Low-Pass PlugIn : Model 30-1 : 1Hz to 99kHz
%                                     Band     Frequency         Resolution
%                                     1        1Hz - 99Hz        1Hz
%                                     2        100Hz - 990Hz     10Hz
%                                     3        1kHz - 9.9kkHz    100Hz
%                                     4        10kHz - 99kHz     1000Hz
%                
%                Both High-Pass and Low-Pass PlugIns round down frequencies :
%                                     1.3Hz -> 1.0Hz (1Hz resolution)
%                                     1.9hz -> 1.0Hz (1Hz resolution)
%                                     109Hz -> 100Hz (10Hz resolution)
%                                     ...
% Channels 1,2 are Low-pass whereas 3,4 are High-pass
% InputGain varies as 0,10,20,30,40 dB
% OutputGain varied as 0,10,20 dB
% The four channels can take values for Frequency,InputGain,OutputGain.
% Hence ChannelSpecs = [F1  F2  F3  F4;
%                       IG1 IG2 IG3 IG4;
%                       OG1 OG2 OG3 OG4];

CARD_DEF = 0;
GPIB_DEF = 23;
GPIB_CTR = 'ni';

%t.ChannelSpecs = [ones(1,4);zeros(2,4)];
t.Private.InputGains = [0,10,20,30,40];
t.Private.OutputGains= [0,10,20];
t.Private.FreqSpecs = [1 99 1]; % Freq-lo,Freq-Hi,Resolution for Band-1 (Other bands
                                % simply multiples of Band-1 specs by 10
switch nargin
    case 0
        t.gpib = gpib(GPIB_CTR,CARD_DEF,GPIB_DEF);
        t = class(t,'khfilter');
    case 1
        if isa(varargin,'khfilter')
            t = varargin{1};
        elseif isa(varargin,'gpib')
            t.gpib = varargin{1};
            t = class(t,'khfilter');
        elseif (varargin{1}<=30)&(varargin{1}>=0)
            t.gpib = gpib(GPIB_CTR,CARD_DEF,varargin{1});
            t = class(t,'khfilter');
        else
            error('Sorry incorrect first argument');
        end;
    otherwise
        error('Sorry first argument must belong to class khfilter or be a number from 0...30');
end;
%t = updateSpecs(t);