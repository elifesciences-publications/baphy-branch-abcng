function init(t)
% INIT(t) Starts and initializes default attenuator gpib interface
% INIT sets the Open property of the serial interface to open and sets the
% default properties 
if nargin<1
    error('atleast one input required');
end;

if isa(t,'attenuator')
    if strcmpi(get(t,'Status'),'closed')
        fopen(t);
    end;
else
    error('Input must be Attenuator object');
end;