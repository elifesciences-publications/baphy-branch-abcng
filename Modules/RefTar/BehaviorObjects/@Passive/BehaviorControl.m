function [LickEvents, exptparams] = BehaviorControl (o, HW, StimEvents, globalparams, exptparams, TrialIndex);
CurrentTime = IOGetTimeStamp(HW);
while CurrentTime < exptparams.LogDuration % BE removed +0.05 here (which screws up acquisition termination)
    CurrentTime = IOGetTimeStamp(HW);
    if ~get(o,'CalibrationPupil'); LickEvents = CalibrationPupil; end
end
if ~get(o,'CalibrationPupil')
  LickEvents = [];
end
