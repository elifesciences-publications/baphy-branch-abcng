function out=readparams(type,varargin)

% readparams(type,varargin)
%   where type:
%           'equalizer' - blocknames,btypes and pids for equalizer blocks
%           'input'     - blocknames,btypes and pids for input blocks
%           'output'     - blocknames,btypes and pids for output blocks
%           'blocknames' - get the blocknames
%           'btype' - get the btypes
%           'pid' - get the pid value
%           'band' - get the possible band values
%           'pindex' - gets the parameter index
%           'level' - gets the index for the dblevel
%           'gain'- gets the index for the gain level
%
% Usage:
%       readparams(blocktype,index)
%               where blocktype:'equalizer','input','output'
%                     index:(optional)index of the many blocks available for a blocktype
%       readparams('blocknames',blocktype)
%               where blocktype:'equalizer','input','output'%default - all
%       readparams('btype',blocktype)
%               where blocktype:'equalizer','input','output'%default - all
%       readparams('pid',blocktype)
%               where blocktype:'equalizer','input','output',blocknames
%                                 default-all
%       readparams('band')
%       readparams('band',freq) - gets the band value closest to freq
%       readparams('pindex',blocktype,paramname,paramvalue)
%               where blocktype:'equalizer','input','output'%default-equlaizer
%                     paramname:'preset','freq','mute',etc
%                              default for equalizer-freq
%                              default for input/output-mute
%                     paramvalue:(optional)frequency band value when paramname='freq'
%       readparams('level',blocktypes,dblevel)
%               where blocktype:'equalizer','input','output'%default-equlaizer
%                     dblevel  : db level %default=0
%       readparams('gain',gainlevel)
%               where gainlevel: gain level %default=10




switch lower(type)
    case 'equalizer'
        blks=readparams('blocknames','equalizer');
        if nargin>1
            blks={blks{varargin{1}}};
        end
        for i=1:length(blks)
            out(i).blocknames=blks{i};
            out(i).btype=readparams('btype','equalizer');
            out(i).pid=readparams('pid',blks{i});            
            out(i).pcount=readparams('paramcount','equalizer');
            out(i).desc=type;
        end
    case 'input'
        blks=readparams('blocknames','input');
        if nargin>1
            blks=blks{varargin{1}};
        end
        for i=1:length(blks)
            out(i).blocknames=blks{i};
            out(i).btype=readparams('btype','input');
            tmp=readparams('pid');
            out(i).pid=readparams('pid',blks{i});            
            out(i).pcount=readparams('paramcount','input');
            out(i).desc=type;
        end
    case 'output'
        blks=readparams('blocknames','output');
        if nargin>1
            blks=blks{varargin{1}};
        end
        for i=1:length(blks)
            out(i).blocknames=blks{i};
            out(i).btype=readparams('btype','output');
            out(i).pid=readparams('pid',blks{i});                        
            out(i).pcount=readparams('paramcount','output');
            out(i).desc=type;
        end
    case 'all'
        out=[];
        out=[out readparams('equalizer')];
        out=[out readparams('input')];
        out=[out readparams('output')];
    case 'blocknames'
        if nargin<2
            out={'eq1','eq2','eq3','ip1','op1'};
        else
            switch lower(varargin{1})
                case 'equalizer'
                    out={'eq1','eq2','eq3'};
                case 'input'
                    out={'ip1'};
                case 'output'
                    out={'op1'};
            end
        end
    case 'btype'
        if nargin<2
            out=[1555,263,264];
        else
            switch lower(varargin{1})
                case 'equalizer'
                    out=1555;
                case 'input'
                    out=263;
                case 'output'
                    out=264;
            end
        end
    case 'pid'
        if nargin<2
            out=[19 20 21 1 11];
        else
            switch lower(varargin{1})
                case 'equalizer'
                    out=[19 20 21];
                    if nargin>2 & isnumeric(varagin{2})
                        out=out(varargin{2});
                    end
                case 'input'
                    out=1;
                    if nargin>2 & isnumeric(varagin{2})
                        out=out(varargin{2});
                    end
                case 'output'
                    out=11;
                    if nargin>2 & isnumeric(varagin{2})
                        out=out(varargin{2});
                    end
                otherwise
                    blks=lower(readparams('blocknames'));
                    pids=readparams('pid');
                    out=pids(strmatch(lower(varargin{1}),blks,'exact'));
            end
        end
    case 'band'
        if nargin<2
            out=[25,31.5,40,50,63,80,100,125,160,200,250,315,400,...
                500,630,800,1000,1250,1600,2000,2500,3100,4000,...
                5000,6300,8000,10000,12500,16000,20000];
        else
            bands=readparams('band');
            if strcmpi(varargin{1},'all')
                out=bands;
            else
                for i=1:length(varargin{1})
                    tmp=find(bands>=varargin{1}(i));
                    if ~isempty(tmp)
                        out(i)=bands(tmp(1));
                    else
                        out(i)=bands(end);
                    end
                end
            end
        end
    case 'param2index'
        if nargin<2
            blk='equalizer';
        else
            blk=varargin{1};
        end
        switch lower(blk)
            case 'equalizer'
                if nargin<3
                    param='freq';
                else
                    param=varargin{2};
                end
                switch lower(param)
                    case 'preset'
                        out=0;
                    case 'freq'
                        if nargin<4
                            band='all';
                        else
                            band=varargin{3};
                        end
                        band=readparams('band',band);
                        bands=readparams('band');
                        for i=1:length(band)
                            out(i)=find(bands==band(i))+1;
                        end
                    case 'lowlevel'
                        out=32;
                    case 'midlevel'
                        out=33;
                    case 'highlevel'
                        out=34;
                    case 'lowcut'
                        out=35;
                    case 'highcut'
                        out=36;
                    case 'input'
                        out=37;
                    case 'output'
                        out=38;
                    case 'bypass'
                        out=39;
                    case 'range'
                        out=40;
                    case 'eqtype'
                        out=41;
                end
            case 'input'
                if nargin<3
                    param='mute';
                else
                    param=varargin{2};
                end
                switch lower(param)
                    case 'preset'
                        out=0;
                    case 'trim'
                        out=2;
                    case 'mute'
                        out=3;
                end
            case 'output'
                if nargin<3
                    param='mute';
                else
                    param=varargin{2};
                end
                switch lower(param)
                    case 'preset'
                        out=0;
                    case 'trim'
                        out=2;
                    case 'mute'
                        out=3;
                    case 'invert'
                        out=4;
                end
        end % end of switch - blk
    case 'level2index'
        if nargin<2
            blk='equalizer';
        else
            blk=varargin{1};
        end
        switch lower(blk)
            case 'input'
                if nargin<3
                    db=0;
                else
                    db=varagin{2};
                end
                db=round(db);
                if db<-96
                    db=-96;
                elseif db>32
                    db=32;
                end
                out=96+db;
            case 'output'
                if nargin<3
                    db=0;
                else
                    db=varargin{2};
                end
                db=round(db*2);
                if db<-192
                    db=-96;
                elseif db>31.5*2
                    db=31.5;
                end
                out=192+db;
            case 'equalizer'
                if nargin<3
                    db=0;
                else
                    db=varargin{2};
                end
                db=round(db*4);
                db(find(db<-120))=-120;
                db(find(db>120))=120;
                out=120+db;
        end % end of switch - blk
    case 'gain2index'
        if nargin<2
            gain=10;
        else
            gain=varargin{1};
        end
        allowed=[-5,10,15,30,45,60];
        if gain<-5
            gain=-5;
        elseif gain>60
            gain=0;
        end
        out=find(allowed>=gain);
        out=out(1)-1;
    case 'index2param'
        if nargin<2
            blk='equalizer';
        else
            blk=varargin{1};
        end
        switch lower(blk)
            case 'equalizer'
                if nargin<3
                    indx=2;
                else
                    indx=varargin{2};
                end
                switch indx
                    case 0
                        out='preset';
                    case 32
                        out='lowlevel';
                    case 33
                        out='midlevel';
                    case 34
                        out='highlevel';
                    case 35
                        out='lowcut';
                    case 36
                        out='highcut';
                    case 37
                        out='input';
                    case 38
                        out='output';
                    case 39
                        out='bypass';
                    case 40
                        out='range';
                    case 41
                        out='eqtype';
                    otherwise
                        if (indx>1&indx<32)
                            out='freq'
                            bands=readparams('band');
                            out=[out num2str(bands(indx-1))];
                        end
                end
            case 'input'
                if nargin<3
                    indx=3;
                else
                    indx=varagin{2};
                end
                switch indx
                    case 0
                        out='preset';
                    case 2
                        out='trim';
                    case 3
                        out='mute';
                end
            case 'output'
                if nargin<3
                    param=3;
                else
                    param=varagin{2};
                end
                switch indx
                    case 0
                        out='preset';
                    case 2
                        out='trim';
                    case 3
                        out='mute';
                    case 4
                        out='invert';
                end
        end % end of switch - blk
    case 'index2level'
        if nargin<2
            blk='equalizer';
        else
            blk=varargin{1};
        end
        switch lower(blk)
            case 'input'
                if nargin<3
                    indx=96;
                else
                    indx=varagin{2};
                end
                if indx<0
                    indx=0;
                elseif indx>128
                    indx=128;
                end
                out=indx-96;
            case 'output'
                if nargin<3
                    indx=192;
                else
                    indx=varargin{2};
                end
                if indx<0
                    indx=0;
                elseif indx>255
                    indx=255;
                end
                out=(indx-192)/2;
            case 'equalizer'
                if nargin<3
                    indx=120;
                else
                    indx=varargin{2};
                end
                indx(find(indx<0))=0;
                indx(find(indx>240))=240;                
                out=(indx-120)/4;
        end % end of switch - blk
    case 'index2gain'
        if nargin<2
            indx=1;
        else
            indx=varargin{1};
        end
        allowed=[-5,10,15,30,45,60];
        if indx<0
            indx=0;
        elseif indx>length(allowed)-1
            indx=length(allowed)-1;
        end
        out=allowed(indx+1);
    case 'paramcount'
        if nargin<2
            out=[0:41];
        else
            switch lower(varargin{1})
                case {'equalizer'}
                    out=[0:41];
                case readparams('blocknames','equalizer')
                    out=[0:41];
                case {'input'}
                    out=[0:5];
                case readparams('blocknames','input')
                    out=[0:5];
                case 'output'
                    out=[0:4];
                case readparams('blocknames','output')
                    out=[0:4];
            end
        end
    case 'eqzlevel'
        out=12;        
end % end of switch - type