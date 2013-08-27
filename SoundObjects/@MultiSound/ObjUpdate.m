function o = ObjUpdate (o)
% ObjUpdate updates the fields of TorcToneDiscrim object after any set
% command. Names is set to be the name of torc plus the tone. max index is
% the maxindex of Torc.

global exptparams_Copy;
TargetObjects = [];
if get(o,'IncTone'),
    TargetObjects = [TargetObjects 1];
end
if get(o,'IncToneInTorc'),
    TargetObjects = [TargetObjects 2];
end
if get(o,'IncMultipleTones'),
    TargetObjects = [TargetObjects 3];
end
if get(o,'IncRandomTone'),
    TargetObjects = [TargetObjects 4];
end
if get(o,'IncClick'),
    TargetObjects = [TargetObjects 5];
end
if get(o,'IncFMSweep'),
    TargetObjects = [TargetObjects 6];
end
o = set(o,'TargetObjects',TargetObjects);
