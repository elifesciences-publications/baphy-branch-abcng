function unloadnidaqmx
%UNLOADNIDAQMX calls loadlibrary with the appropriate input arguments.
%
% This function will call unloadlibrary on the library defined as nidaqmx
%
% You must have cleared memory and not have any varables defined using 
%	this library to work.
%
% This file is automatically generated by the loadlibrarygui.
%
%   See also
%   LOADLIBRARY, UNLOADLIBRARY, LOADNIDAQMX

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
% unload the library.
unloadlibrary('nidaqmx');
