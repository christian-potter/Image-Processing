function [] = functional_vs_anatomical(zlocs,ypix_zdist)

arguments
    zlocs double % depth of planes in anatomical stack
    ypix_zdist cell 

end
%% DESCRIPTION 
% function that plots 

%% FUNCTIONAL VS ANATOMICAL 
figure
hold on 

for z = 1:length(zlocs)
    plot([1 ts.ypix],[max(zlocs)-zlocs(z) max(zlocs)-zlocs(z)],'color','k')
end

for p = 1:ts.nplanes
    plot(max(zlocs)-ypix_zdist{p},'LineWidth',3)
    leg{p}= ['Plane ', num2str(p)];
end

xlabel('Y Pixel')
ylabel('Z Location')
yticks([0:.02:.14])
yticklabels(140:-20:0)
title(['#',num2str(dsnum),' Z-Stack v Functional Registration'])

utils.sf
%% MAKE PLOT OF PIEZO POSITION 
figure 
hold on 
plot([80000 80000],[ 2 2],'HandleVisibility','off')% to set color sequence the same as zs
for p = 1:ts.nplanes+ts.flybackFrames
    curframes = find(tsync.framecount==p); 
    curpiezo = tsync.piezo(curframes); 
    plot(curframes,curpiezo,'LineWidth',4)     
end

xticks([])
yticks([])
ylabel('Z Position')
xlabel('Time')

title(['#',num2str(518),' Piezo Frame Acquisition'])

if ts.nplanes == 4
    legend({'frame 1','frame 2','frame 3','frame 4','fb1','fb2'},'location','northwest')
elseif ts.nplanes == 5
    legend({'frame 1','frame 2','frame 3','frame 4','frame 5','flyback 1','flyback 2'},'location','northwest')
end


utils.sf 

end 
