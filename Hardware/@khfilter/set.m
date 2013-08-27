function t = set(t,varargin)
% T = SET(T,Property,Value);
%See set.m,@instrument/set.m

if isa(t,'khfilter')&nargin>=2
    set(t.gpib,varargin{:});
end;