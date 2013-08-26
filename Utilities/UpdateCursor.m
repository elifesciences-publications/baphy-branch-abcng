function txt = UpdateCursor (empt, event_obj);
% function for cursor
lfreq = get(gca,'yticklabel');
lfreq = ifstr2num(lfreq(1,:));
pos = get(event_obj, 'position');
data = get(get(event_obj,'target'),'cdata');
txt = {['Time: ', num2str(pos(1)) ' ms'] ...
    ['Frequency: ' num2str(round(lfreq*2.^pos(2))) ' Hz'], ...
    ['Value: ' num2str(data(ceil(20*pos(2)), ceil(pos(1))))]};
