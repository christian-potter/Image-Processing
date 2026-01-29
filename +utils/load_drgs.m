function [zstack,tseries_md,zstack_md,tsync,s2p,ypix_zplane] = load_drgs(dsnum,plotstr)
%% DESCRIPTION
% loads DRGS datasets
% ** gives only the iscell == 1 output for relevant variables

% INPUTS 
% dsnum: number of dataset 
% plotstr: will plot image of functional images w/r/t 

% OUTPUTS
% zstack: X x Y x RGB x Z matrix 
% tseries_md: structure with time series metadata
% zstack_md: structure with z stack metadata
% tsync: individual thorsync file 
% s2p: suite2p path to load all suite2p data (needs to be loaded outside of
    % function) 
% ypix_zplane: vector that connects every ypixel row to a zplane in the
%   zstack

%% NOTES 
% THIS IS LEGACY CODE THAT LOADS WITHOUT FILE STRUCTURE AND 


%% GET PATHNAMES
if ismac 
    if dsnum == 505
        disp('not ready')
    
    elseif dsnum == 511
        s2p= '/Volumes/Potter/DRGS/#511/Final FOV/Time Series/SDH/Split/suite2p/combined/Fall.mat';
        tseriesmd_path='/Volumes/Potter/DRGS/#511/Final FOV/Time Series/SDH/SDH#510_000/Experiment.xml'; 
        zstack_mdpath = '/Volumes/Potter/DRGS/#511/Final FOV/Structural/1x resolution (26)/SDH#511_026/Experiment.xml';
        zstack_path = '/Volumes/Potter/DRGS/#511/Final FOV/Structural/#511 1x resolution final.tif';
        thorsync_h5 = '/Volumes/Potter/DRGS/#511/Final FOV/ThorSync/SDH/TS_DRG#511_000/Episode_0000.h5'; 
        
    elseif dsnum == 518
        s2p='/Volumes/Potter/DRGS/#518/Final FOV/TimeLapse/Finished new/suite2p/combined/Fall.mat'; 
        tseriesmd_path='/Volumes/Potter/DRGS/#518/Final FOV/TimeLapse/#518_000/Experiment.xml'; 
        zstack_mdpath = '/Volumes/Potter/DRGS/#518/Final FOV/Structural/#518_032/Experiment.xml'; 
        zstack_path = '/Volumes/Potter/DRGS/#518/Final FOV/TimeLapse/Finished new/oldsuite2p/#518 Suite2p/Depth Files/Zstack 512 8bit RGB.tif';
        thorsync_h5='/Volumes/Potter/DRGS/#518/Final FOV/ThorSync/TS_SDH#518/Episode_0000.h5'; 
        
    elseif dsnum == 519 
        disp('not ready')
    
    elseif dsnum == 541 
        s2p = '/Volumes/Warwick/DRGS project/#541 3-22-25/Time Lapse/Final FOV/Functional/Split/Split/suite2p-2 removed/combined/Fall.mat'; 
        %tseriesmd_path= '/Volumes/Warwick/DRGS project/#541 3-22-25/Time Lapse/Final FOV/Functional/raw/raw Doubles/#541_003/Experiment.xml';
        tseriesmd_path = '/Volumes/Ross/Christian/DRGS/#541/tseries_md.mat'; 
        zstack_path= '/Volumes/Warwick/DRGS project/#541 3-22-25/Time Lapse/Final FOV/Structural/Reference Zstack/#541 Structural Ref.tif'; 
        zstack_mdpath = '/Volumes/Warwick/DRGS project/#541 3-22-25/Time Lapse/Final FOV/Structural/Reference Zstack/Experiment.xml'; 
        thorsync_h5 = '/Volumes/Warwick/DRGS project/#541 3-22-25/Time Lapse/Final FOV/ThorSync/Original Files/#541_TS_0000/Episode_0000.h5'; 
    elseif dsnum == 542
        s2p = '/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Functional/Split/suite2p/combined/Fall.mat';
        tseriesmd_path='/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Functional/Raw Files/#542_000/Experiment.xml'; 
        zstack_mdpath='/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Structural/#542 post z stack_002 (100pct 1040)/Experiment.xml';
        %zstack_mdpath= '/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Structural/#542 post z stack/Experiment.xml';  
        zstack_path='/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Structural/#542 post z stack_002.tif'; 
        zstack_path='/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Structural/#542 post z stack_001+002 Final.tif';
        %zstack_path='/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Structural/#542 pre-zstack.tif';
        %zstack_path='/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/Structural/#542 post z stack.tif';
        thorsync_h5 = '/Volumes/Warwick/DRGS project/#542 3-25-25/Final FOV/ThorSync/Raw/#542_TS_0005.h5';
    elseif dsnum == 545
        s2p='/Volumes/Warwick/DRGS project/#545 4-4-25/Final FOV/Functional/Split/suite2p/combined/Fall.mat';
        tseriesmd_path ='/Volumes/Warwick/DRGS project/#545 4-4-25/Final FOV/Functional/Raw/#545_002/Experiment.xml';
        zstack_mdpath = '/Volumes/Warwick/DRGS project/#545 4-4-25/Final FOV/Structural/#545 post z_002/Experiment.xml';
        zstack_path = '/Volumes/Warwick/DRGS project/#545 4-4-25/Final FOV/Structural/#545 Final Structural Ref.tif'; 
        thorsync_h5='/Volumes/Warwick/DRGS project/#545 4-4-25/Final FOV/ThorSync/Raw/#545_TS_0002.h5'; 
    elseif dsnum == 547
        s2p = '/Volumes/Warwick/DRGS project/#547- 8-6-25/#547 8-6-25/final FOV/Time Lapse/Split/suite2p/combined/Fall.mat'; 
        tseriesmd_path = '/Volumes/Warwick/DRGS project/#547- 8-6-25/#547 8-6-25/final FOV/Time Lapse/Raw/#547_000/Experiment.xml';  
        zstack_path = '/Volumes/Warwick/DRGS project/#547- 8-6-25/#547 8-6-25/final FOV/Structural Images/#547 Pre Structural 1030_Smoothed Cropped and downscaled to match post (Final).tif';
        zstack_mdpath = '/Volumes/Warwick/DRGS project/#547- 8-6-25/#547 8-6-25/final FOV/Structural Images/#547 Pre Structural 1030 /Experiment.xml'; 
        %zstack_path= '/Volumes/Warwick/DRGS project/#547- 8-6-25/#547 8-6-25/final FOV/Structural Images/#547 Post Structural 1030_Smoothed (Final).tif'; 
        %zstack_mdpath = '/Volumes/Warwick/DRGS project/#547- 8-6-25/#547 8-6-25/final FOV/Structural Images/#547 Post Structural 1030/Experiment.xml';
        thorsync_h5 ='/Volumes/Warwick/DRGS project/#547- 8-6-25/#547 8-6-25/final FOV/ThorSync/Raw/TS#547_000.h5';
    elseif dsnum == 548
        s2p = '/Volumes/Warwick/DRGS project/#548 8-8-25/Final FOV/Split/suite2p/combined/Fall.mat';
        tseriesmd_path  = '/Volumes/Warwick/DRGS project/#548 8-8-25/Final FOV/Raw/#548_001/Experiment.xml';
        zstack_path ='/Volumes/Warwick/DRGS project/#548 8-8-25/Final FOV/Structural/#548 post 1033_Smoothed 1xy 2z (Final CAW 8-23-25).tif';
        zstack_mdpath =  '/Volumes/Warwick/DRGS project/#548 8-8-25/Final FOV/Structural/#548 post 1033/Experiment.xml';
        thorsync_h5 = '/Volumes/Warwick/DRGS project/#548 8-8-25/Final FOV/ThorSync/Exp#548_001/Episode_0000.h5'; 
       
    end
elseif ispc
    if dsnum == 505
        disp('not ready')
    
    elseif dsnum == 511
        s2p= '\\Shadowfax\Warwick\DRGS\#511\Final FOV\Time Series\SDH\Split\suite2p\combined\Fall.mat';
        tseriesmd_path='\\Shadowfax\Warwick\DRGS\#511\Final FOV\Time Series\SDH\SDH#510_000\Experiment.xml'; 
        zstack_mdpath = '\\Shadowfax\Warwick\DRGS\#511\Final FOV\Structural\1x resolution (26)\SDH#511_026\Experiment.xml';
        zstack_path = '\\Shadowfax\Warwick\DRGS\#511\Final FOV\Structural\#511 1x resolution final.tif';
        thorsync_h5 = '\\Shadowfax\Warwick\DRGS\#511\Final FOV\ThorSync\SDH\TS_DRG#511_000\Episode_0000.h5'; 
        
    elseif dsnum == 518
        s2p='\\Shadowfax\Warwick\DRGS\#518\Final FOV\TimeLapse\Finished new\suite2p\combined\Fall.mat'; 
        tseriesmd_path='\\Shadowfax\Warwick\DRGS\#518\Final FOV\TimeLapse\#518_000\Experiment.xml'; 
        zstack_mdpath = '\\Shadowfax\Warwick\DRGS\#518\Final FOV\Structural\#518_032\Experiment.xml'; 
        zstack_path = '\\Shadowfax\Warwick\DRGS\#518\Final FOV\TimeLapse\Finished new\oldsuite2p\#518 Suite2p\Depth Files\Zstack 512 8bit RGB.tif';
        thorsync_h5='\\Shadowfax\Warwick\DRGS\#518\Final FOV\ThorSync\TS_SDH#518\Episode_0000.h5'; 
        
    elseif dsnum == 519 
        disp('not ready')
    
    elseif dsnum == 541 
        s2p = '\\Shadowfax\Warwick\DRGS project\#541 3-22-25\Time Lapse\Final FOV\Functional\Split\Split\suite2p-2 removed\combined\Fall.mat'; 
        %tseriesmd_path= '\\Shadowfax\Warwick\DRGS project\#541 3-22-25\Time Lapse\Final FOV\Functional\raw\raw Doubles\#541_003\Experiment.xml';
        tseriesmd_path = '\\Shadowfax\Warwick\DRGS\#541\tseries_md.mat'; 
        zstack_path= '\\Shadowfax\Warwick\DRGS project\#541 3-22-25\Time Lapse\Final FOV\Structural\Reference Zstack\#541 Structural Ref.tif'; 
        zstack_mdpath = '\\Shadowfax\Warwick\DRGS project\#541 3-22-25\Time Lapse\Final FOV\Structural\Reference Zstack\Experiment.xml'; 
        thorsync_h5 = '\\Shadowfax\Warwick\DRGS project\#541 3-22-25\Time Lapse\Final FOV\ThorSync\Original Files\#541_TS_0000\Episode_0000.h5'; 
    elseif dsnum == 542
        s2p = '\\Shadowfax\Warwick\DRGS project\#542 3-25-25\Final FOV\Functional\Split\suite2p\combined\Fall.mat';
        tseriesmd_path='\\Shadowfax\Warwick\DRGS project\#542 3-25-25\Final FOV\Functional\Raw Files\#542_000\Experiment.xml'; 
        zstack_mdpath='\\Shadowfax\Warwick\DRGS project\#542 3-25-25\Final FOV\Structural\#542 post z stack_002 (100pct 1040)\Experiment.xml';
        %zstack_mdpath= '\\Shadowfax\Warwick\DRGS project\#542 3-25-25\Final FOV\Structural\#542 post z stack\Experiment.xml';  
        zstack_path='\\Shadowfax\Warwick\DRGS project\#542 3-25-25\Final FOV\Structural\#542 post z stack_002.tif'; 
        zstack_path='\\Shadowfax\Warwick\DRGS project\#542 3-25-25\Final FOV\Structural\#542 post z stack_001+002 Final.tif';
        %zstack_path='\\Shadowfax\Warwick\DRGS project\#542 3-25-25\Final FOV\Structural\#542 pre-zstack.tif';
        %zstack_path='\\Shadowfax\Warwick\DRGS project\#542 3-25-25\Final FOV\Structural\#542 post z stack.tif';
        thorsync_h5 = '\\Shadowfax\Warwick\DRGS project\#542 3-25-25\Final FOV\ThorSync\Raw\#542_TS_0005.h5';
    elseif dsnum == 545
        s2p='\\Shadowfax\Warwick\DRGS project\#545 4-4-25\Final FOV\Functional\Split\suite2p\combined\Fall.mat';
        tseriesmd_path ='\\Shadowfax\Warwick\DRGS project\#545 4-4-25\Final FOV\Functional\Raw\#545_002\Experiment.xml';
        zstack_mdpath = '\\Shadowfax\Warwick\DRGS project\#545 4-4-25\Final FOV\Structural\#545 post z_002\Experiment.xml';
        zstack_path = '\\Shadowfax\Warwick\DRGS project\#545 4-4-25\Final FOV\Structural\#545 Final Structural Ref.tif'; 
        thorsync_h5='\\Shadowfax\Warwick\DRGS project\#545 4-4-25\Final FOV\ThorSync\Raw\#545_TS_0002.h5'; 
    elseif dsnum == 547
        s2p = '\\Shadowfax\Warwick\DRGS project\#547- 8-6-25\#547 8-6-25\final FOV\Time Lapse\Split\suite2p\combined\Fall.mat'; 
        tseriesmd_path = '\\Shadowfax\Warwick\DRGS project\#547- 8-6-25\#547 8-6-25\final FOV\Time Lapse\Raw\#547_000\Experiment.xml';  
        zstack_path = '\\Shadowfax\Warwick\DRGS project\#547- 8-6-25\#547 8-6-25\final FOV\Structural Images\#547 Pre Structural 1030_Smoothed Cropped and downscaled to match post (Final).tif';
        zstack_mdpath = '\\Shadowfax\Warwick\DRGS project\#547- 8-6-25\#547 8-6-25\final FOV\Structural Images\#547 Pre Structural 1030 \Experiment.xml'; 
        %zstack_path= '\\Shadowfax\Warwick\DRGS project\#547- 8-6-25\#547 8-6-25\final FOV\Structural Images\#547 Post Structural 1030_Smoothed (Final).tif'; 
        %zstack_mdpath = '\\Shadowfax\Warwick\DRGS project\#547- 8-6-25\#547 8-6-25\final FOV\Structural Images\#547 Post Structural 1030\Experiment.xml';
        thorsync_h5 ='\\Shadowfax\Warwick\DRGS project\#547- 8-6-25\#547 8-6-25\final FOV\ThorSync\Raw\TS#547_000.h5';
    elseif dsnum == 548
        s2p = '\\Shadowfax\Warwick\DRGS project\#548 8-8-25\Final FOV\Split\suite2p\combined\Fall.mat';
        tseriesmd_path  = '\\Shadowfax\Warwick\DRGS project\#548 8-8-25\Final FOV\Raw\#548_001\Experiment.xml';
        zstack_path ='\\Shadowfax\Warwick\DRGS project\#548 8-8-25\Final FOV\Structural\#548 post 1033_Smoothed 1xy 2z (Final CAW 8-23-25).tif';
        zstack_mdpath =  '\\Shadowfax\Warwick\DRGS project\#548 8-8-25\Final FOV\Structural\#548 post 1033\Experiment.xml';
        thorsync_h5 = '\\Shadowfax\Warwick\DRGS project\#548 8-8-25\Final FOV\ThorSync\Exp#548_001\Episode_0000.h5'; 
       
    end


end


%% LOAD DATA
try
    if contains(tseriesmd_path,'.mat')
        t = load(tseriesmd_path); 
        tseries_md = t.tseries_md;
    else
        tseries_xml=md.importxml(tseriesmd_path);
        [tseries_md] = md.extract_metadata(tseries_xml);
    end
catch
    tseries_md=[]; 
end

zstack_xml = md.importxml(zstack_mdpath); 
[zstack_md]=md.extract_metadata(zstack_xml);

zstack= get.zstack(zstack_path);
[tsync]= md.read_h5(thorsync_h5); 
%%
ypix_zplane=[]; 
%% GET PIEZO MOVEMENT FROM TSYNC
% %% UNCOMPRESSED TSYNC, SO GET THOUSANDS OF FRAMES FOR DISTANCE 
% a = 1:tseries_md.nplanes; b = tsync.framecount; 
% allplanes = find(ismember(b,a));% get indices for the first nplanes 
% 
% totalpdist = tsync.piezo(allplanes(end))-tsync.piezo(allplanes(1));% distance of functional planes 
% totalzdist =  tseries_md.stepSize*tseries_md.nplanes/1000; %total distance of z-stack (stepsize * nplanes)
% %%
% plane_zranges = nan(tseries_md.nplanes,2); 
% piezoprop = 0; 
% %- get distance moved by the piezo for first frames 
% % ** this assumes piezo moves at linear rate** 
% for p = 1:tseries_md.nplanes
%     curframes = tsync.framecount==p; 
%     curpiezo = tsync.piezo(curframes); 
%     curpdist = curpiezo(end)-curpiezo(1); % distance at beginning and end of frame 
%     piezoprop(p+1) = curpdist/totalpdist; % proprotion of the total distance covered 
% end
% 
% %------ DISTANCE COVERED BY THE PIEZO PER FRAME 
% covered_range = 0;% cumulative distance over frames 
% for p = 1:tseries_md.nplanes
%     planezdist= tseries_md.startPos + totalzdist*piezoprop(p); % starting point + proportion of covered distance per frame (first frame is less)
%     plane_zranges(p,1)= covered_range; 
%     plane_zranges(p,2)= piezoprop(p+1)*totalzdist+covered_range; 
%     covered_range = plane_zranges(p,2);
% end
% 
% plane_zranges = plane_zranges+tseries_md.startPos; % this is vulnerable to user error if the tseries_md and zstack_md do not aline
% %% GIVES TSERIES POSITION IN TERMS OF TSEREIS Y PIXELS ONLY
% 
% ypix_zdist = cell(1,tseries_md.nplanes);  
% for p = 1:tseries_md.nplanes
%     curzdists = nan(1,tseries_md.ypix); 
%     zrange = plane_zranges(p,:); 
%     zvals = linspace(zrange(1),zrange(2),tseries_md.ypix);% generate line between endpoints for each ypixel  
%     ypix_zdist{p}= zvals; % gives z-distance in 
% 
% end
% 
% %% GET POSITION OF EACH ZSTACK FRAME 
% zlocs = nan(1,zstack_md.nplanes);
% %get zloc of each plane 
% 
% for z =  1:zstack_md.nplanes
%     zlocs(z)= zstack_md.startPos + 1/1000*z; 
% end
% 
% %% GET CLOSEST ZSTACK PLANE FOR EACH ROW OF TSERIES YPIXELS 
% ypix_zplane = cell(1,tseries_md.nplanes);
% 
% % assign each ypix to a plane 
% for p = 1:tseries_md.nplanes
%     y_zmap = nan(1,tseries_md.ypix); 
%     curypix_zdist = ypix_zdist{p}; 
% 
%     for y = 1:tseries_md.ypix
%         offsets=abs(zlocs-curypix_zdist(y)); % difference between plane 
%         zloc = find(offsets==min(offsets)); 
%         y_zmap(y) = zloc; 
%     end
%     ypix_zplane{p}=y_zmap;
% 
% end
% %% GET ID VECT 
% load(s2p)
% %id_vect = ones(sum(iscell(:,1)==1))*4; 
% %cellstat = stat(iscell(:,1)==1); 
% 
% 
% %% PLOT RELATIONSHIP BETWEEN TLAPSE AND ZSTACK
% %if strcmp(plotstr,'plot')
%     figure
%     hold on 
% 
%     for z = 1:length(zlocs)
%         plot([1 tseries_md.ypix],[max(zlocs)-zlocs(z) max(zlocs)-zlocs(z)],'color','k')
%     end
% 
%     for p = 1:tseries_md.nplanes
%         plot(max(zlocs)-ypix_zdist{p},'LineWidth',3)
%         leg{p}= ['Plane ', num2str(p)];
%     end
% 
%     xlabel('Y Pixel')
%     ylabel('Z Location')
%     yticks([0:.02:.14])
%     yticklabels(140:-20:0)
%     title(['#',num2str(dsnum),' Z-Stack v Functional Registration'])
% 
%     utils.sf
% %% MAKE PLOT OF PIEZO POSITION 
%     figure 
%     hold on 
%     for p = 1:tseries_md.nplanes+tseries_md.flybackFrames
%         curframes = find(tsync.framecount==p); 
%         curpiezo = tsync.piezo(curframes); 
%         plot(curframes,curpiezo,'LineWidth',2)     
%     end
% 
%     xticklabels([])
%     ylabel('Z Position')
%     xlabel('Timepoint')
% 
%     title(['#',num2str(dsnum),' Piezo Frame Acquisition'])
% 
%     if tseries_md.nplanes == 4
%         legend({'frame 1','frame 2','frame 3','frame 4','fb1','fb2'},'location','northwest')
%     elseif tseries_md.nplanes == 5
%         legend({'frame 1','frame 2','frame 3','frame 4','frame 5','fb1','fb2'},'location','northwest')
%     end
% 
% 
%     utils.sf 
% 
% %end



%%

