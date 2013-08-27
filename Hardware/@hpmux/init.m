function init(t)
% INIT(t) Starts and initializes default attenuator gpib interface
% INIT sets the Open property of the serial interface to open and sets the
% default properties 
if nargin<1
    error('atleast one input required');
end;

if strcmpi(get(t.gpib,'Status'),'closed')
    fopen(t);
end;