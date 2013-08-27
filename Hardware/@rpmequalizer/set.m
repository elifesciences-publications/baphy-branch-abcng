function a=set(a,varargin)

if isa(a,'rpmequalizer')
    for i=1:length(varargin)/2
        prop=varargin{i};
        val=varargin{i+1};
        if strcmpi(prop,'handle')
            if isa(val,'COM.RaneSock_RaneSocket')|isa(val,'COM.ranesock.ranesocket')
                a.handle=val;
            else
                error('Handle should be a valid COM.RaneSock_RaneSocket handle');
            end
        else
            a.tagid=set(a.tagid,prop,val);
        end
    end
end