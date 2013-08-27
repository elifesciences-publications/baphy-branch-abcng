function HW = InitializeStimulation(HW,varargin)
% SIMPLE INITIALIZATION FOR ELECTRICAL STIMULATION IN BAPHY
% 

P = parsePairs(varargin);
checkField(P,'Starts');
checkField(P,'Durations');
checkField(P,'Voltages');

HW.AnalogStimulation = 1; 
% LOOP OVER TIMES OF STIMULATION AND SET OTHER PROPERTIES
for i=1:length(P.Starts)
  HW.params.AnalogStimulation(i).Start = P.Starts(i);
  HW.params.AnalogStimulation(i).Duration = P.Durations(i);
  HW.params.AnalogStimulation(i).Voltage = P.Voltages(i);
end
      