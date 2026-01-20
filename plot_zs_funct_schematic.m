%%
dsnum=511; 
%ypix_zdist=ypix_zplane;
% GET POSITION OF EACH Z FRAME 
zlocs = nan(1,zstack_md.nplanes);
%get zloc of each plane 

for z =  1:zstack_md.nplanes
    zlocs(z)= zstack_md.startPos + 1/1000*z; 
end

%% GET CLOSEST Z PLANE FOR EACH ROW OF YPIXELS 

ypix_zplane = cell(1,tseries_md.nplanes);

% assign each ypix to a plane 
for p = 1:tseries_md.nplanes
    y_zmap = nan(1,tseries_md.ypix); 
    curypix_zdist = ypix_zdist{p}; 
    
    for y = 1:tseries_md.ypix
        offsets=abs(zlocs-curypix_zdist(y)); 
        zloc = find(offsets==min(offsets)); 
        y_zmap(y) = zloc; 
    end
    ypix_zplane{p}=y_zmap;

end

%% PLOT RELATIONSHIP BETWEEN TLAPSE AND ZSTACK
figure
hold on 

for z = 1:length(zlocs)
    plot([1 tseries_md.ypix],[max(zlocs)-zlocs(z) max(zlocs)-zlocs(z)],'color','k')
end

for p = 1:tseries_md.nplanes
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
for p = 1:tseries_md.nplanes+tseries_md.flybackFrames
    curframes = find(tsync.framecount==p); 
    curpiezo = tsync.piezo(curframes); 
    plot(curframes,curpiezo,'LineWidth',2)     
end

xticklabels([])
ylabel('Z Position')
xlabel('Timepoint')

title(['#',num2str(dsnum),' Piezo Frame Acquisition'])

if tseries_md.nplanes == 4
    legend({'frame 1','frame 2','frame 3','frame 4','fb1','fb2'},'location','northwest')
elseif tseries_md.nplanes == 5
    legend({'frame 1','frame 2','frame 3','frame 4','frame 5','fb1','fb2'},'location','northwest')
end


utils.sf 

