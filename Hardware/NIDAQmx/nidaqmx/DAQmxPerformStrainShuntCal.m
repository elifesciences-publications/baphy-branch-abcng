function varargout = DAQmxPerformStrainShuntCal(varargin)
%DAQMXPERFORMSTRAINSHUNTCAL calls nidaqmx library with the appropriate arguments.
%
% The C declaration for this function is the following:
%	 int32 _stdcall DAQmxPerformStrainShuntCal ( TaskHandle taskHandle , const char channel [], float64 shuntResistorValue , int32 shuntResistorLocation , bool32 skipUnsupportedChannels ); 
%
% The MATLAB Declaration looks like the following:
%	[int32, cstring] DAQmxPerformStrainShuntCal(uint32, cstring, double, int32, uint32)
%
% This function will call loadlibrary on the library if needed.
% This file is automatically generated by the loadlibrarygui.
%
%   See also
%   LOADLIBRARY, UNLOADLIBRARY, LOADNIDAQMX, UNLOADNIDAQMX

%
%
% $Author: $
% $Revision: $
% $Date: 27-May-2011 02:04:42 $
%
% Local Functions Defined:
%
%
% $Notes:
%
%
%
%
% $EndNotes
%
% $Description:
%
%
%
%
% $EndDescription


if nargin==0;
	help(mfilename);
	return;
end;


% If Library is loaded already unload it.

if ~libisloaded('nidaqmx')
	loadnidaqmx;
end;


if nargin~=5;
	error(mfilename:WrongNumberIn,'Incorrect number of input arguments.');
end;

if nargout~=1;
	error(mfilename:WrongNumberOut,'Incorrect number of output arguments.');
end;

% Call external function in loaded DLL.
[varargout{1}]=calllib('nidaqmx','DAQmxPerformStrainShuntCal',varargin{:});

