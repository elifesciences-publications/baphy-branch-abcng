% function r=IODriver(HW)
% 
% returns the string value of HW.params.driver (replaces less flexible
% niIsDriver).  Current supported values are 'DAQTOOLBOX' (default) and 'NIDAQMX'
%
%  created SVD 2012-06-12
%
function r=IODriver(HW)

if ~isempty(HW) && isfield(HW.params,'driver') && strcmpi(HW.params.driver,'NIDAQMX'),
  r=HW.params.driver;
else
  r='DAQTOOLBOX';
end
