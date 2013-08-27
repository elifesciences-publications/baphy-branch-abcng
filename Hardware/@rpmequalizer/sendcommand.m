function out=sendcommand(t,command,varargin)

% sendcommand(t,'start')
% sendcommand(t,'stop')
% sendcommand(t,'check')
% sendcommand(t,'copy',srcblk,destblk)
% sendcommand(t,'copy',blkdesc,srcindex,destindex)
% sendcommand(t,'get',blk,'freq',freqpoint)
% sendcommand(t,'get',blk,'range')
% sendcommand(t,'get',blk,'EQtype')
% sendcommand(t,'get',blk,'IPLevel')
% sendcommand(t,'get',blk,'OPLevel')
% sendcommand(t,'set',blk,'freq',freqpoint,value)
% sendcommand(t,'set',blk,'range',value)
% sendcommand(t,'set',blk,'EQtype',value)
% sendcommand(t,'set',blk,'IPLevel',value)
% sendcommand(t,'set',blk,'OPLevel',value)
%
% input values for set and output values for get are in encoded form.

if isa(t,'rpmequalizer')
    if nargin<2
        command='check';
    end
    if ~isa(t.handle,'COM.RaneSock_RaneSocket')&~isa(t.handle,'COM.ranesock.ranesocket')
        t=fopen(t);
        if ~strcmpi(command,'start')
            sendcommand(t,'start')
        end
    end
    switch lower(command)
        case 'start'
            %check if the ipaddress is valid
            if (sendcommand(t,'check'))
                t.handle.StartMonitoring(get(t,'IPAddress'),...
                    get(t,'MemoryNumber'));
            else
                error(['The instrument at the given IP Address', ...
                    'is not a valid RPM Equalizer']);
            end
        case 'stop'
            % it doesnt harm to stop irrespective of whether it was started
            % or not; hence no check
            t.handle.StopMonitoring;
        case 'check'
            out=t.handle.IsDeviceValid(get(t,'IPAddress'));
        case 'copy'
            % need to check whether monitoring is started or not
            sendcommand(t,'start');
            if nargin<3
                blks=readparams('equalizer');
                srcBlk=blks(1);
                destBlk=srcBlk;
            else
                if isstruct(varargin{1})
                    srcBlk=varargin{1};
                    if nargin<4
                        destBlk=srcBlk;
                    end
                else
                    blks=readparams(varargin{1});
                    if nargin<4
                        srcBlk=blks(1);
                    else
                        srcBlk=blks(varargin{2});
                    end
                    if nargin<5
                        destBlk=srcBlk;
                    else
                        destBlk=blks(varargin{3});
                    end
                end
            end
            if strcmpi(srcBlk.desc,destBlk.desc)
                t.handle.CopyBlock(srcBlk.pid,destBlk.pid,get(t,'IPAddress'));
            else
                error('The source and destination blocks should be similar');
            end
        case 'get'
            % check whether monitoring is started or not
            sendcommand(t,'start');
            if nargin<3
                blk=readparams('equalizer');
                blk=blk(1);
            else
                blk=varargin{1};
            end
            if nargin<4
                cmd='freq';
            else
                cmd=varargin{2};
            end
            if strcmpi(cmd,'freq')
                if nargin<5
                    pindex=readparams('param2index',blk.desc,cmd);
                else
                    pindex=readparams('param2index',blk.desc,cmd,varargin{3});
                end                
            else
                pindex=readparams('param2index',blk.desc,cmd);
            end
            for i=1:length(pindex)
                [out(i).numBytes,out(i).value,out(i).ret]=t.handle.GetSingleParameter(...
                    blk.btype,blk.pid,pindex(i));                
            end            
        case 'set'
            % check whether monitoring is started or not
            sendcommand(t,'start');
            if nargin<3
                blks=readparams('equalizer');
                blk=blk(1);
            else
                blk=varargin{1};
            end
            if nargin<4
                cmd='freq';
            else
                cmd=varargin{2};
            end
            if strcmpi(cmd,'freq')
                if nargin<5
                    pindex=readparams('param2index',blk.desc,cmd);
                else
                    pindex=readparams('param2index',blk.desc,cmd,varargin{3});
                end  
                if nargin<6
                    value=readparams('level2index'); % set to zero db
                else
                    value=varargin{4};                    
                end
                if ~(length(value)==length(pindex))
                    value=value*ones(length(pindex),1);
                end   
                value=char(value);
            else
                pindex=readparams('param2index',blk.desc,cmd);
                if nargin<5
                    value=char(0);
                else
                    if strcmp(varargin{2},'trim')
                        value=char(varargin{4});
                    else
                        value=char(varargin{3});
                    end
                end
            end
            val0=char(0);
            usedBytes=1;
            for i=1:length(pindex)
                t.handle.SendParameter(blk.btype,blk.pid,pindex(i),...
                    val0,val0,val0,value(i),usedBytes);
            end
        case 'restore'
            if nargin<3
                blknames='all';               
            else
                blknames=varargin{1};
            end                       
            blks=readparams(blknames);
            if nargin>3
                blks=blks(varargin{2});
            end
            for i=1:length(blks)
                t.handle.RestoreDefaultParameters(blks(i).btype,blks(i).pid);
            end                    
    end% end of switch
end % end of isa