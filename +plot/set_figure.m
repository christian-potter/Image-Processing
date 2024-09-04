function set_figure(fontsize,cond)
set(gca,'FontName','Arial');
set(gca,'FontSize',fontsize);
set(gcf,'Color','w')
set(gca,'FontName','Arial')
%set(gca,'Color','k'b)
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'})

if strcmp(cond,'square')
    axis square
end
