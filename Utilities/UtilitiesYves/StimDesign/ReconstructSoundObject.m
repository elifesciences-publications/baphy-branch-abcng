function p = ReconstructSoundObject(exptparams)

o = exptparams(1).TrialObject(1).TargetHandle(1);
p = TextureMorphing();
eval(['p = ' exptparams(1).TrialObject(1).TargetHandle.descriptor '();']);
FN = fieldnames(o);
for FNum = 1:length(FN)
    if any(strcmp(fieldnames(p),FN{FNum})) || any(strcmp(fieldnames(get(p,'SoundObject')),FN{FNum})) % for retrocompatibility
        %look after the FN{FNum} in the SoundObject or in parent (cf. <get> properties of the SoundObject for understanding)
        p = set(p,FN{FNum},o.(FN{FNum}));
    end
end
% p = ObjUpdate(p);
