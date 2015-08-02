set(0,'defaultAxesFontName', 'Arial')
set(0,'defaultTextFontName', 'Arial')

set(0,'defaultAxesFontSize', FontSize)
set(0,'defaultTextFontSize', FontSize)
set(0,'defaultTextFontSize', FontSize)
set(0,'defaultTextFontSize', FontSize)
set(0,'defaultlinelinewidth',1.5)
set(0,'defaultaxeslinewidth',1.2)
set(0,'defaultpatchlinewidth',1.2)

set(findall(gca, 'Type','text'), 'FontSize', FontSize)


% set(gcf, 'PaperUnits', 'inches');
% set(gcf, 'PaperSize', [6.25 7.5]);
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperPosition', [0 0 6.25 7.5]);
% 
% 
% set(gcf, 'renderer', 'painters');
% 
% % print(gcf, '-dpdf', 'my-figure.pdf');
% % print(gcf, '-dpng', 'my-figure.png');
% print(gcf, '-depsc2', 'my-figure.eps');
