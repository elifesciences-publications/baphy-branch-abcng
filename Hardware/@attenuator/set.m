function t = set(t,varargin)
%See @instrument/set

if isa(t,'attenuator')
    t.gpib = set(t.gpib,varargin{:});
end;
