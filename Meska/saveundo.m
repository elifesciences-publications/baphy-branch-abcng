% make sure Wt and Ws are the first variables in the list

if ONEFILE
    undodata = struct('Wt',{Wt},'Ws',{Ws},'St',{St},'Ss',{Ss},'spk',{spk},'hood',hood);
else
    undodata = struct('Wt',{Wt},'Ws',{Ws},'St',{St},'Ss',{Ss},'spk',{spk},'hood',hood,'Wt2',{Wt2},'Ws2',{Ws2},'St2',{St2},'Ss2',{Ss2},'hood2',hood2);
end
