function [zstack,tlapse_md,zstack_md,tsync,s2p,ypix_zplane] = load_drgs(dsnum,plotstr)
%% DESCRIPTION
% loads DRGS datasets
% ** gives only the iscell == 1 output for relevant variables

% INPUTS 
% dsnum: number of dataset 
% plotstr: will plot image of functional images w/r/t 

% OUTPUTS
% zstack: X x Y x RGB x Z matrix 
% tlapse_md: structure with time series metadata
% zstack_md: structure with z stack metadata
% tsync: individual thorsync file 
% s2p: suite2p path to load all suite2p data (needs to be loaded outside of
    % function) 
% ypix_zplane: vector that connects every ypixel row to a zplane in the
%   zstack


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
elseif dsnum == 545
    s2p='/Volumes/Warwick/DRGS project/#545 4-4-25/Final FOV/Functional/Split/suite2p/combined/Fall.mat';
    tlapse_path ='/Volumes/Warwick/DRGS project/#545 4-4-25/Final FOV/Functional/Raw/#545_002/Experiment.xml';
    zstack_mdpath = '/Volumes/Warwick/DRGS project/#545 4-4-25/Final FOV/Structural/#545 post z_002/Experiment.xml';
    zstack_path = '/Volumes/Warwick/DRGS project/#545 4-4-25/Final FOV/Structural/#545 Final Structural Ref.tif'; 
    thorsync_h5='/Volumes/Warwick/DRGS project/#545 4-4-25/Final FOV/ThorSync/Raw/#545_TS_0002.h5'; 
    
elseif dsnum == 542
    s2p = '/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Functional/Split/suite2p/combined/Fall.mat';
    tlapse_path='/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Functional/Raw Files/#542_000/Experiment.xml'; 
    zstack_mdpath='/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Structural/#542 post z stack_002 (100pct 1040)/Experiment.xml';
    %zstack_mdpath= '/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Structural/#542 post z stack/Experiment.xml';
    
    zstack_path='/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Structural/#542 post z stack_002.tif'; 
    zstack_path='/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Structural/#542 post z stack_001+002 Final.tif';
    %zstack_path='/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Structural/#542 pre-zstack.tif';
   %zstack_path='/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Structural/#542 post z stack.tif';
    thorsync_h5 = '/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/ThorSync/Raw/#542_TS_0005.h5';
elseif dsnum == 541 
    s2p = '/Volumes/Warwick/DRGS project/#541 3-22-25/Time Lapse/Final FOV/Functional/Split/Split/suite2p-2 removed/combined/Fall.mat'; 
    tlapse_path= '/Volumes/Warwick/DRGS project/#541 3-22-25/Time Lapse/Final FOV/Functional/raw/raw Doubles/#541_003/Experiment.xml';
    zstack_path= '/Volumes/Warwick/DRGS project/#541 3-22-25/Time Lapse/Final FOV/Functional/Split/Final Suite2p copy/Reference Zstack/#541 Structural Ref.tif';
    zstack_mdpath = '/Volumes/Warwick/DRGS project/#541 3-22-25/Time Lapse/Final FOV/Functional/Split/Final Suite2p copy/Reference Zstack/Experiment.xml'; 
    thorsync_h5 = '/Volumes/Warwick/DRGS project/#541 3-22-25/Time Lapse/Final FOV/ThorSync/Original Files/#541_TS_0000/Episode_0000.h5'; 
elseif dsnum == 1 % ABBY 
    % PUT YOUR DATASET HERE BUT USE WINDOWS FILE FORMAT 
    %s2p = ; % Fall file that you save as your suite2p output (need to do file->save to mat in suite2p)
    %tlapse_path =; % choose any experiment.xml file from one of the tseries. they should all be the same in the variables that m 
    %zstack_path = ; % find the tif of 
   
end

%% LOAD DATA
tlapse_xml=md.importxml(tlapse_path);
[tlapse_md] = md.extract_metadata(tlapse_xml);

zstack_xml = md.importxml(zstack_mdpath); 
[zstack_md]=md.extract_metadata(zstack_xml);

zstack= get.zstack(zstack_path);

[tsync]= md.read_h5(thorsync_h5); 

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
zlocs = nan(1,zstack_md.nplanes);
%get zloc of each plane 

for z =  1:zstack_md.nplanes
    zlocs(z)= zstack_md.startPos + 1/1000*z; 
end

%% GET CLOSEST Z PLANE FOR EACH ROW OF YPIXELS 

ypix_zplane = cell(1,tlapse_md.nplanes);

% assign each ypix to a plane 
for p = 1:tlapse_md.nplanes
    y_zmap = nan(1,tlapse_md.ypix); 
    curypix_zdist = ypix_zdist{p}; 
    
    for y = 1:tlapse_md.ypix
        offsets=abs(zlocs-curypix_zdist(y)); 
        zloc = find(offsets==min(offsets)); 
        y_zmap(y) = zloc; 
    end
    ypix_zplane{p}=y_zmap;

end
%% GET ID VECT 
load(s2p)
%id_vect = ones(sum(iscell(:,1)==1))*4; 
%cellstat = stat(iscell(:,1)==1); 

%% 511 adjustment
if dsnum == 511
    for i = 1:length(ypix_zplane)
        curplane = ypix_zplane{i};
        curplane = curplane+34; 
        ypix_zplane{i}=curplane; 
    end
end


%% PLOT RELATIONSHIP BETWEEN TLAPSE AND ZSTACK
if strcmp(plotstr,'plot')
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
    for p = 1:tlapse_md.nplanes+tlapse_md.flybackFrames
        curframes = find(tsync.framecount==p); 
        curpiezo = tsync.piezo(curframes); 
        plot(curframes,curpiezo,'LineWidth',2)     
    end
    
    xticklabels([])
    ylabel('Z Position')
    xlabel('Timepoint')
    
    title(['#',num2str(dsnum),' Piezo Frame Acquisition'])
    legend({'frame 1','frame 2','frame 3','frame 4','fb1','fb2'},'location','northwest')
    utils.sf 

end



%%

