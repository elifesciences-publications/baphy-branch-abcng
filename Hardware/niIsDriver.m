function R = niIsDriver(HW)

R = 0;
if ~isempty(HW) && isfield(HW.params,'driver') && strcmp(HW.params.driver,'NIDAQMX')
  R = 1;
end