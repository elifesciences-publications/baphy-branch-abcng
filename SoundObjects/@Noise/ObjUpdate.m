function o = ObjUpdate (o)
% This function is used to recalculate the properties of the object that
% depends on other properties. In these cases, user firs changes the
% properties using set, and then calls ObjUpdate. The default is empty, you
% need to write your own.

% SVD 2010-12-08

NoiseType=get(o,'NoiseType');
LowFreq=get(o,'LowFreq');
HighFreq=get(o,'HighFreq');
Count=get(o,'Count');
SamplingRate=get(o,'SamplingRate');

Names=cell(1,Count);
for ii=1:Count,
   Names{ii}=sprintf('%02d-%s',ii,NoiseType);
end

% pre-generated noise stored in @SoundObject/Sounds/
genericobject=SoundObject;
object_spec = what(class(genericobject));
soundpath = [object_spec.path filesep 'Sounds'];

% generate bandpass filter to force waveform to fall between
% LowFreq and HighFreq

if LowFreq>0,
  FILTER_ORDER=round(SamplingRate./LowFreq.*3);
  N=SamplingRate./2;
  if HighFreq==0,
    f_bp = firls(FILTER_ORDER,...
      [0 (0.95.*LowFreq)/N LowFreq/N 1],[0 0 1 1])';
  else
  %       f_bp = firls(FILTER_ORDER,...
  %                    [0 (0.95.*LowFreq)/N LowFreq/N  HighFreq/N (HighFreq./0.95)./N 1],...
  %                    [0 0 1 1 0 0])';
    
    [f_bp{1,1},f_bp{1,2}]=butter(2,LowFreq*2/N,'high');
    [f_bp{2,1},f_bp{2,2}]=butter(2,HighFreq/N,'low');
    
  end
elseif HighFreq>0,
   FILTER_ORDER=round(SamplingRate./HighFreq.*6);
   N=SamplingRate./2;
   
   f_bp = firls(FILTER_ORDER,...
                [0 HighFreq/N (HighFreq./0.95)./N 1],...
                [1 1 0 0])';
else
   f_bp=[];
end

o = set(o,'Filter',f_bp);   
o = set(o,'SoundPath',soundpath);
o = set(o,'Names',Names);
