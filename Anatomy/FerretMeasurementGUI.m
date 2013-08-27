function FerretMeasurementGUI(varargin)

P = parsePairs(varargin);
checkField(P,'FIG',1);

clear global CaudalYPos

figure(P.FIG); clf; set(gcf,'Toolbar','figure','Menubar','figure')

DC = HF_axesDivide([1],[2,1],[0.1,0.1,0.85,0.85],[],0.5);

%% MAIN FIGURE WITH FERRET SKULL
axes('Pos',DC{1}); axis tight;
I = imread(which('FerretMeasurements.png'));
I = I(end:-1:1,:,:);
dP = 25/800; % StepSize/Pixel
X = [-1930:144]*dP;
Y = [-672:660]*dP;
imagesc(X,Y,I); set(gca,'YDir','normal')
title('Enter Coordinates');
 
%% PUT ENTRY BOXES
% LATERAL
Name = 'Lateral'; evalin('base',['global ',Name]);
dY = 2.5; 
YPos = [-5*dY:dY:-dY,dY:dY:5*dY];
XPos = repmat(-20,size(YPos));
for i=1:length(YPos)
  UD.HLat(i) = LF_addEdit(XPos(i),YPos(i),i,Name,0.5,-0.5);
end

% MIDLINE
Name = 'Midline'; evalin('base',['global ',Name]);
XPos = [-35,-30,-20,-10,0];
YPos = repmat(0,size(XPos));
for i=1:length(YPos)
  UD.HMid(i) = LF_addEdit(XPos(i),YPos(i),i,Name,0.5,-0.5);
end

% OFFCENTER 5MM LINE
Name = 'Sideline5mm'; evalin('base',['global ',Name]);
dX = 2.5;
XPos = [(-14*dY+1):dY:1];
YPos = repmat(5,size(XPos));
for i=1:length(YPos)
  UD.HSide(i) = LF_addEdit(XPos(i),YPos(i),i,Name,-1.5,1.5);
end

% HEADPOST
Name = 'Headpost'; evalin('base',['global ',Name]);
XPos = [-50,-45,-40];
YPos = repmat(-15,size(XPos));
Tooltips = {'RC','ML','Z'};
for i=1:length(YPos)
  UD.HHead(i) = LF_addEdit(XPos(i),YPos(i),i,Name,-1.5,1.5,Tooltips{i});
end
UD.Handles = [UD.HSide,UD.HLat,UD.HHead,UD.HMid];
set(gcf,'UserData',UD);

% LATERAL POSITION OF CAUDAL POINT
Name = 'CaudalYPos'; evalin('base',['global ',Name]);
XPos = [0];
YPos = [0];
Tooltips = {'YPos of Caudal Position'};
UD.HCaudalYPos = LF_addEdit(XPos,YPos,1,Name,0.5,-1.5,Tooltips{1});

% DATA PLOT
UD.AH(2) = axes('Pos',DC{2});
set(gca,'ButtonDownFcn',{@Rotator});
set(gcf,'WindowButtonUpFcn','global Rotating_ ; Rotating_ = 0;');
grid on; box on; title('Measured Coordinates');
set(gcf,'UserData',UD);

% ADD COMPUTE BUTTON
uicontrol('style','pushbutton','Units','normalized','Position',[0.01,0.01,0.08,0.05],...
  'String','Compute','Callback',{@LF_plotData});

% ADD SAVE BUTTON
uicontrol('style','pushbutton','Units','normalized','Position',[0.1,0.01,0.08,0.05],...
  'String','Save','Callback',{@LF_saveData});

function LF_saveData(handle,event)
global Midline Sideline5mm Headpost Lateral

[FileName,DirName] = uiputfile;
if FileName
  save([DirName,FileName],'Midline','Sideline5mm','Headpost','Lateral');
end

function LF_plotData(handle,event)
UD = get(gcf,'UserData');
axes(UD.AH(2)); cla; hold on;
global Midline Lateral Sideline5mm Headpost
PlotOpts = {'Marker','.','MarkerSize',20};
plot3(Midline(:,1),Midline(:,2),Midline(:,3),...
  'Color',[1,0.5,0],PlotOpts{:});
plot3(Lateral(:,1),Lateral(:,2),Lateral(:,3),...
  'Color',[1,0,0],PlotOpts{:});
plot3(Sideline5mm(:,1),Sideline5mm(:,2),Sideline5mm(:,3),...
  'Color',[0,0,1],PlotOpts{:});
plot3(Headpost(1)+[0,0],Headpost(2)+[0,0],Headpost(3)+[0,-20],...
  'Color',[0,0,0],PlotOpts{:});
S5  = Sideline5mm;
NFit = 10; Fun = @(Beta,X)Beta(1)*X+Beta(2); Beta0 = [0,0];
Beta = nlinfit(S5(1:NFit,1),S5(1:NFit,3),Fun,Beta0);
plot3(S5(:,1),S5(:,2),Fun(Beta,S5(:,1)),'k')
Angle = asin(Beta(1))/(2*pi)*360;
text(0.1,0.1,num2str(Angle),'Units','normalized');

function H = LF_addEdit(XPos,YPos,i,Name,RelX,RelY,Tooltip)

if ~exist('RelX','var') RelX = 0.5; end
if ~exist('RelY','var') RelY = 0.5; end

APos = get(gca,'Position');
XLim = get(gca,'XLim');
YLim = get(gca,'YLim');
XRange = diff(XLim);
YRange = diff(YLim);
Height = 1.2/YRange;
Width = 2/XRange;
RelX = RelX/XRange;
RelY = RelY/YRange;

XPosN = (XPos-XLim(1))/XRange;
YPosN = (YPos-YLim(1))/YRange;
XPosNN = XPosN*APos(3) + APos(1);
YPosNN = YPosN*APos(4) + APos(2);

if ~exist('Tooltip','var') 
  Tooltip = [Name,' @ [ RC ',n2s(XPos,3),' |  ML ',n2s(YPos,3),' ]' ]; 
end

H = uicontrol('style','edit', 'Units','Normalized','BackgroundColor','white',...
  'Position',[XPosNN+RelX,YPosNN+RelY,Width,Height],...
 'FontSize',7,'String','0',...
 'Callback',{@LF_Callback,i,Name,XPos,YPos},...
 'Tooltip',Tooltip);
LF_Callback(H,'',i,Name,XPos,YPos)

function LF_Callback(handle,event,i,Name,XPos,YPos)
Value = str2num(get(handle,'String'));
set(handle,'BackgroundColor',[1,1,1]);
if isempty(Value) Value = NaN; 
  set(handle,'BackgroundColor',[1,1,1]);
elseif Value
  set(handle,'BackgroundColor',[1,1,0]);
else
  set(handle,'BackgroundColor',[1,1,1]);
end
switch Name
  case 'Headpost';
    assignin('base','tmp',Value);
    evalin('base',[Name,'(1,',n2s(i),') = tmp;'])
  case 'CaudalYPos' % CHANGE TOOLTIPS TO REAL MEASUREMENT VALUES
    global CaudalYPos; 
    assignin('base','tmp',Value);
    evalin('base',[Name,'(1,',n2s(i),') = tmp;'])
    UD = get(gcf,'UserData');
    if ~isempty(CaudalYPos)
      for i=1:length(UD.Handles)
        TT = get(UD.Handles(i),'Tooltip');
        cPos = find(TT==']'); if isempty(cPos) continue; end; TT = TT(1:cPos);
        cPos = find(TT=='L'); if isempty(cPos) continue; end;
        YPos = str2num(TT(cPos(end)+1:end-1));
        TT2 = [TT,' MLC : ',n2s(YPos+CaudalYPos(1),3)];
        set(UD.Handles(i),'Tooltip',TT2);
      end
    end
  otherwise
    assignin('base','tmp',XPos);
    evalin('base',[Name,'(',n2s(i),',1) = tmp;'])
    assignin('base','tmp',YPos);
    evalin('base',[Name,'(',n2s(i),',2) = tmp;'])
    assignin('base','tmp',Value);
    evalin('base',[Name,'(',n2s(i),',3) = tmp;'])
end

