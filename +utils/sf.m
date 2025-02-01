function sf(opt)

arguments 
    opt.fontsize double = 15
    opt.cond string = 'any'
    opt.fontname string = 'Arial'
end


set(gca,'FontName','Arial');
set(gca,'FontSize',opt.fontsize);
set(gcf,'Color','w')
set(gca,'FontName','Arial')
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'})

if strcmp(opt.cond,'square')
    axis square
end
