function AlarmClock(varargin)

P = parsePairs(varargin);

checkField(P,'Interval',15)
figure(111); set(gcf,'position',[1000,1000,100,50],'name','Álarm Clock','toolbar','none','menubar','none');
UH = uicontrol('style','togglebutton','string','Silence','units','normalized','position',[0.1,0.1,0.8,0.8]);
    
while 1 
  cTime = clock;
  if ~mod(cTime(5),P.Interval)
    while get(UH,'Value') == 0
      beep; pause(1);
    end
    set(UH,'Value',0);
    pause(60)
  end
  pause(1);
end
