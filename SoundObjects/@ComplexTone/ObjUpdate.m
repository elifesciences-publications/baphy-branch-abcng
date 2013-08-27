function o = ObjUpdate (o);
% Update the changes of a Complex_Tone object
% User first changes the properties using set, and then calls ObjUpdate.
% The default is empty, you need to write your own.
%
% Mai December 2008

AnchorFrequency= get(o,'AnchorFrequency');
ComponentsNumber= get(o,'ComponentsNumber');
PoolSize= get(o,'PoolSize');

HComponentRatios= 1:ComponentsNumber;
HComponentRatios= HComponentRatios(2:end)./HComponentRatios(1:end-1);
HComponentRatios= HComponentRatios(:); % harmonic ratios

RatiosPermutation= perms(flipud(HComponentRatios))';
RatiosPermutation= mai_shuffle(RatiosPermutation);
SequenceLength= ComponentsNumber*size(RatiosPermutation,2);
ComponentRatios= [];
FrequencyOrder= [];

Names= cell(1,1);
jter=1;


for iter= 1:size(RatiosPermutation,2)
    C= 'I';          % inharmonic complex
    if iter== 1
        C= 'H';      % harmonic complex
    end
    ratios= RatiosPermutation(:,iter);
    for kter= 1:ComponentsNumber
        if jter<=PoolSize & jter<=SequenceLength
            if check_order(kter,AnchorFrequency,ratios)
                Names{jter}= [num2str(AnchorFrequency) C num2str(kter)];
                for lter= 1:ComponentsNumber-1
                    Names{jter}= [Names{jter} '+' num2str(ratios(lter))];
                end
                ComponentRatios= [ComponentRatios ratios];
                FrequencyOrder= [FrequencyOrder; kter];
                jter= jter+1;
            end
        end
    end
end
SequenceLength= length(FrequencyOrder);
Names=Names(1:SequenceLength);
o= set(o,'FrequencyOrder',FrequencyOrder);
o= set(o,'ComponentRatios',ComponentRatios);
o= set(o,'Names',Names);
o= set(o,'MaxIndex',SequenceLength);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Internal Functions  %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Q= mai_shuffle(R)
% randomly order the possible inharmonic ratios
m= 2:size(R,2);
m= [1; shuffle(m(:))];
Q(:,1:size(R,2))= R(:,m);


function b= check_order(n,fa,ratios)
% Guarantees that fundamental frequency of complex tone lies within the
% range defined in the variable range_f0

b= 1;
range_f0= [150;4800/(length(ratios)+1)];

if n~= 1
    r= cumprod(ratios(1:n-1));
    r= r(end);
else
    r= 1;
end
if fa/r< range_f0(1) | fa/r> range_f0(2)
    b= 0;
end
