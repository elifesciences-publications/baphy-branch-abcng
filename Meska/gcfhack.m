function g = gcd(a)
%GCFHACK    Greatest common factor.
%   G = GCFHACK(A) is the greatest common factor of the
%   elements of the vector A.  The array is rounded and absolute valued.
%   This is a very inefficient algorithm, but it works.

%   Author: Jonathan Z. Simon

a = abs(round(a));
top = max(a);
for mm = [top:-1:1]
 test = a./mm;
 if test==round(test)
  break
 end
end

g=mm;


 
