function printfigure (h,rotation)
% function printfigure (h,rotation)
%
% this function prints figures manually, it's good for cases when matlab
% fails to print correctly.
% h: the handle of the figure. examples:
%   printfigure(gcf); % current figure
%   printfigure(1); % current figure
%   printfigure([1 3]); % current figure
%   printfigure(1:4); % current figure
% rotation: is the orientation of the page. default is landscape,

if nargin<2
    rotation = 'landscape';
end
% Nima, Jan 2006

for cnt1 = 1:length(h)
    try
        set(h(cnt1), 'PaperType', 'usletter');  %specifies paper type usletter as default (8.5x11)
        if strcmpi(rotation,'portrait')
            set(h(cnt1), 'PaperPosition', [0.25 0.25 7 10.5]);  %specifies paper position in inches
        else
            set(h(cnt1), 'PaperPosition', [  .25 .25 10 7.5]);
        end
        set(h(cnt1), 'PaperOrientation',rotation); %specifies landscape or portrait orientation
        figure(h(cnt1));drawnow;
%         disp('printing to atlantic!!!');
%         print (h(cnt1),'-P\\atlantic\oud', '-opengl');  %specifies printer name on print server
        print (h(cnt1),'-Poud', '-opengl');  %specifies printer name on print server
        % changed svd 2007-02-13
        %print (h(cnt1),'-P\\bhangra.isr.umd.edu\oud', '-opengl');  %specifies printer name on print server
        disp(h(cnt1));
    catch
        disp(['failed to print figure ' num2str(cnt1)]);
    end
end
