function[ypix_zplane] = functional_anatomical_zmap(dsnum,ts,zs,tsync,opt)

arguments 
    dsnum double 
    ts struct % metadata from one of the tseries
    zs struct % metadata from chosen z-stack 
    tsync table % uncompressed thorsync file from one imaging session 
    opt.plot logical = false 
end

%% DESCRIPTION
% takes functional and anatomical metadata and creates map between the
% ypixel of the functional imaging for each plane to the expected location
% in the z-stack 
%% NOTES
% * need to make a function where user can specify the location of the
% first and last cells on a plane remap the z-distance 

%% GET PIEZO MOVEMENT FROM TSYNC

a = 1:ts.nplanes; b = tsync.framecount; 
allplanes = find(ismember(b,a));% get indices for the first nplanes 

%total distance covered by the piezo 
totalpdist = tsync.piezo(allplanes(end))-tsync.piezo(allplanes(1)); 
%
totalzdist =  ts.stepSize*ts.pixelsize*ts.nplanes/1000;% ** INSERTED uM CONVERSION TO PIXELS HERE

plane_zranges = nan(ts.nplanes,2); 
piezoprop = 0; 

%- get distance moved by the piezo for first planes (remaining should be identical) 
%- this is a linear approximation for each plane contained in piezoprop 
for p = 1:ts.nplanes
    curframes = tsync.framecount==p; 
    c = tsync.piezo(curframes); 
    curpdist = c(end)-c(1); % distance at beginning and end of frame 
    piezoprop(p+1) = curpdist/totalpdist; % proprotion of the total distance covered 
end

%-maps functional plane to relative z position 
%- 
covered_range = 0; 
for p = 1:ts.nplanes
    planezdist= ts.startPos + totalzdist*piezoprop(p);  
    plane_zranges(p,1)= covered_range; 
    plane_zranges(p,2)= piezoprop(p+1)*totalzdist+covered_range; 
    covered_range = plane_zranges(p,2);
end

plane_zranges = plane_zranges+ts.setupPosition; 


%% 

ypix_zdist = cell(1,ts.nplanes);  

for p = 1:ts.nplanes
    curzdists = nan(1,ts.ypix); 
    zrange = plane_zranges(p,:); 
    zvals = linspace(zrange(1),zrange(2),ts.ypix); 
    ypix_zdist{p}= zvals; % gives z-distance in arbitrary z-units 

end


%% GET POSITION OF EACH Z FRAME 
zlocs = nan(1,zs.nplanes);
%get zloc of each plane 

for z =  1:zs.nplanes
    zlocs(z)= zs.startPos + 1/1000*z; 
end

%% GET CLOSEST ZSTACK PLANE FOR EACH ROW OF TSERIES YPIXELS 
%ypix_zplane = cell(1,ts.nplanes);
ypix_zplane = cell(1,4);
ts.nplanes=4; % FIX THIS, UNCLEAR WHY UNABLE TO RESOLVE TSERIES_MD.NPLANES 

% assign each ypix to a plane 
for p = 1:ts.nplanes
    y_zmap = nan(1,ts.ypix); 
    curypix_zdist = ypix_zdist{p}; 

    for y = 1:ts.ypix
        offsets=abs(zlocs-curypix_zdist(y)); % difference between plane 
        zloc = find(offsets==min(offsets)); 
        y_zmap(y) = zloc; 
    end
    ypix_zplane{p}=y_zmap;

end

%% PLOT FUNCTIONAL VS ZSTACK
if opt.plot 
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
