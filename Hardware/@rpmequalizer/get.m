function out=get(a,prop)

if isa(a,'rpmequalizer')
    if nargin<2
        get(a.tagid);
    else
        if strcmpi(prop,'handle')
            out=a.handle;
        elseif strcmpi(prop,'eqzmax')
            tmp=readparams('blocknames','equalizer');
            out=length(tmp)*readparams('eqzLevel');
        else
            out=get(a.tagid,prop);
        end
    end        
end