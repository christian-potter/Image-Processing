%% NOTES 
%need to go through and understand this code line by line to figure out if
%I am in pixel or um coordinates and if that explains the error observed at
%the end of the zstack 



%% GET PIEZO MOVEMENT FROM TSYNC

a = 1:tlapse_md.nplanes; b = tsync.framecount; 
allplanes = find(ismember(b,a));% get indices for the first nplanes 

totalpdist = tsync.piezo(allplanes(end))-tsync.piezo(allplanes(1)); 
totalzdist =  tlapse_md.stepSize*tlapse_md.nplanes/1000;

plane_zranges = nan(tlapse_md.nplanes,2); 
piezoprop = 0; 
%- get distance moved by the piezo for first frames 
for p = 1:tlapse_md.nplanes
    curframes = tsync.framecount==p; 
    curpiezo = tsync.piezo(curframes); 
    curpdist = curpiezo(end)-curpiezo(1); % distance at beginning and end of frame 
    piezoprop(p+1) = curpdist/totalpdist; % proprotion of the total distance covered 
end

covered_range = 0; 
for p = 1:tlapse_md.nplanes
    planezdist= tlapse_md.startPos + totalzdist*piezoprop(p);  
    plane_zranges(p,1)= covered_range; 
    plane_zranges(p,2)= piezoprop(p+1)*totalzdist+covered_range; 
    covered_range = plane_zranges(p,2);
end

plane_zranges = plane_zranges+tlapse_md.setupPosition; 
%%

ypix_zdist = cell(1,tlapse_md.nplanes);  

for p = 1:tlapse_md.nplanes
    curzdists = nan(1,tlapse_md.ypix); 
    zrange = plane_zranges(p,:); 
    zvals = linspace(zrange(1),zrange(2),tlapse_md.ypix); 
    ypix_zdist{p}= zvals; % gives z-distance in 

end

%% GET POSITION OF EACH Z FRAME 
zlocs = nan(1,zstack.nplanes);
%get zloc of each plane 

for z =  1:zstack.nplanes
    zlocs(z)= zstack.startPos + 1/1000*z; 
end

%% PLOT FUNCTIONAL VS ZSTACK
figure
hold on 

for z = 1:length(zlocs)
    plot([1 tlapse_md.ypix],[max(zlocs)-zlocs(z) max(zlocs)-zlocs(z)],'color','k')
end

for p = 1:tlapse_md.nplanes
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
plot([80000 80000],[ 2 2],'HandleVisibility','off')% to set color sequence the same as zstack
for p = 1:tlapse_md.nplanes+tlapse_md.flybackFrames
    curframes = find(tsync.framecount==p); 
    curpiezo = tsync.piezo(curframes); 
    plot(curframes,curpiezo,'LineWidth',4)     
end

xticks([])
yticks([])
ylabel('Z Position')
xlabel('Time')

title(['#',num2str(518),' Piezo Frame Acquisition'])

if tlapse_md.nplanes == 4
    legend({'frame 1','frame 2','frame 3','frame 4','fb1','fb2'},'location','northwest')
elseif tlapse_md.nplanes == 5
    legend({'frame 1','frame 2','frame 3','frame 4','frame 5','flyback 1','flyback 2'},'location','northwest')
end


utils.sf 
