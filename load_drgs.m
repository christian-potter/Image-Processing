function [zs,tlapse,zstack,tsync,s2p,ypix_zplane] = load_drgs(dsnum)


%% GET PATHNAMES

if dsnum == 505
    disp('not ready')

elseif dsnum == 511
    s2p= '/Volumes/Potter/DRGS/#511/Final FOV/Time Series/SDH/Split/suite2p/combined/Fall.mat';
    tlapse_path='/Volumes/Potter/DRGS/#511/Final FOV/Time Series/SDH/SDH#510_000/Experiment.xml'; 
    zstack_mdpath = '/Volumes/Potter/DRGS/#511/Final FOV/Structural/1x resolution (26)/SDH#511_026/Experiment.xml';
    zstack_path = '/Volumes/Potter/DRGS/#511/Final FOV/Structural/#511 1x resolution final.tif';
    thorsync_h5 = '/Volumes/Potter/DRGS/#511/Final FOV/ThorSync/SDH/TS_DRG#511_000/Episode_0000.h5'; 
    
elseif dsnum == 518
    s2p='/Volumes/Potter/DRGS/#518/Final FOV/TimeLapse/Finished new/suite2p/combined/Fall.mat'; 
    tlapse_path='/Volumes/Potter/DRGS/#518/Final FOV/TimeLapse/#518_000/Experiment.xml'; 
    zstack_mdpath = '/Volumes/Potter/DRGS/#518/Final FOV/Structural/#518_032/Experiment.xml'; 
    zstack_path = '/Volumes/Potter/DRGS/#518/Final FOV/TimeLapse/Finished new/oldsuite2p/#518 Suite2p/Depth Files/Zstack 512 8bit RGB.tif';
    thorsync_h5='/Volumes/Potter/DRGS/#518/Final FOV/ThorSync/TS_SDH#518/Episode_0000.h5'; 
    
elseif dsnum == 519 
    disp('not ready')

end


%% LOAD DATA

tlapse_xml=md.importxml(tlapse_path);
[tlapse] = md.extract_metadata(tlapse_xml);

zstack_xml = md.importxml(zstack_mdpath); 
[zstack]=md.extract_metadata(zstack_xml);

zs= get.zstack(zstack_path);

[tsync]= md.read_h5(thorsync_h5); 

%% PLOT ZSTACK TO CONFIRM

a = 1:tlapse.nplanes; b = tsync.framecount; 
allplanes = find(ismember(b,a));% get indices for the first nplanes 

totalpdist = tsync.piezo(allplanes(end))-tsync.piezo(allplanes(1)); 
totalzdist =  tlapse.stepSize*tlapse.nplanes/1000;

plane_zranges = nan(tlapse.nplanes,2); 
piezoprop = 0; 
for p = 1:tlapse.nplanes
    curframes = tsync.framecount==p; 
    curpiezo = tsync.piezo(curframes); 
    curpdist = curpiezo(end)-curpiezo(1); 
    piezoprop(p+1) = curpdist/totalpdist; 

end

covered_range = 0; 
for p = 1:5 
    planezdist= tlapse.startPos + totalzdist*piezoprop(p);  
    plane_zranges(p,1)= covered_range; 
    plane_zranges(p,2)= piezoprop(p+1)*totalzdist+covered_range; 
    covered_range = plane_zranges(p,2);
end

plane_zranges = plane_zranges+tlapse.setupPosition; 
%%

ypix_zdist = cell(1,tlapse.nplanes);  

for p = 1:5
    curzdists = nan(1,tlapse.ypix); 
    zrange = plane_zranges(p,:); 
    zvals = linspace(zrange(1),zrange(2),tlapse.ypix); 
    ypix_zdist{p}= zvals; 

end

%% GET POSITION OF EACH Z FRAME 
zlocs = nan(1,zstack.nplanes);
%get zloc of each plane 

for z =  1:zstack.nplanes
    zlocs(z)= zstack.startPos + 1/1000*z; 
end


%% GET CLOSEST Z PLANE FOR EACH ROW OF YPIXELS 

ypix_zplane = cell(1,tlapse.nplanes);

% assign each ypix to a plane 

for p = 1:tlapse.nplanes
    y_zmap = nan(1,tlapse.ypix); 
    curypix_zdist = ypix_zdist{p}; 
    
    for y = 1:tlapse.ypix
        offsets=abs(zlocs-curypix_zdist(y)); 
        zloc = find(offsets==min(offsets)); 
        y_zmap(y) = zloc; 
    end
    ypix_zplane{p}=y_zmap;

end

%% 511 adjustment
if dsnum == 511
    for i = 1:length(ypix_zplane)
        curplane = ypix_zplane{i};
        curplane = curplane+34; 
        ypix_zplane{i}=curplane; 
    end
end


%% PLOT RELATIONSHIP BETWEEN TLAPSE AND ZSTACK

figure
hold on 

for z = 1:length(zlocs)
    plot([1 tlapse.ypix],[max(zlocs)-zlocs(z) max(zlocs)-zlocs(z)],'color','k')
end

for p = 1:tlapse.nplanes
    plot(max(zlocs)-ypix_zdist{p},'LineWidth',3)
    leg{p}= ['Plane ', num2str(p)];
end

xlabel('Y Pixel')
ylabel('Z Location')

title('Matching Y Pixel from Each Plane to Z-Stack Slice')

utils.sf


%%

