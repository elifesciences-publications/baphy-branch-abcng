function HW = IOReadyManta(HW)
% Make MANTA ready for acquiring a trial

MSG = ['SETVAR',HW.MANTA.COMterm,...
  ['MG.DAQ.StimLength = ',n2s(HW.StimLength),';',...
  'MG.DAQ.TrialLength = ',n2s(3600),';'],...
  HW.MANTA.MSGterm];
IOSendMessageManta(HW,MSG,'SETVAR OK');
MSG = ['START',HW.MANTA.COMterm,HW.Filename,HW.MANTA.MSGterm];
IOSendMessageManta(HW,MSG,'START OK');
