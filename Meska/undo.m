%load undodata

Wt = undodata.Wt;
Ws = undodata.Ws;

if ~ONEFILE
    Wt2 = undodata.Wt2;
    Ws2 = undodata.Ws2;
end

meska

undovars = fieldnames(undodata);
for abc = 3:length(undovars),
  eval([undovars{abc} ' = undodata.' undovars{abc} ';'])
end

if exist('s1'), set(s1,'value',hood+1), end
if ~ONEFILE, if exist('s12'), set(s12,'value',hood2+1), end, end
spikeselect

classrefresh
