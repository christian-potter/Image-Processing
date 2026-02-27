%% LOAD DATASET
dsnum= 545; 
[Fall,tseries_md,zstack,zstack_md,tsync] = utils.load_Data_Organization(548); 
%% 545 
[zstack]= get.zstack('/Volumes/Warwick/DRGS/#545/SDH/Structural/Final Z-Stack.tif');
xml = md.importxml('/Volumes/Warwick/DRGS/#545/SDH/Functional/Raw/#545_002/Experiment.xml'); 
tseries_md = md.extract_metadata(xml);
[raw_tsync]= md.read_h5('/Volumes/Warwick/DRGS/#545/SDH/Functional/ThorSync/#545_TS_0002/Episode_0000.h5');
%% 548 
%[zstack] = get.zstack('/Volumes/Warwick/DRGS/#548/SDH/Structural/Final Z-Stack.tif'); 
[ntsync]= md.read_h5('/Volumes/Warwick/DRGS/#548/SDH/Functional/ThorSync/Exp#548_001/Episode_0000.h5');
xml = md.importxml('/Volumes/Warwick/DRGS/#548/SDH/Functional/Raw/#548_001/Experiment.xml'); 
tseries_md = md.extract_metadata(xml);

%% 550 
raw_tsync = md.read_h5('/Volumes/Warwick/DRGS/#550/SDH/Functional/ThorSync/TS#550_000/Episode_0000.h5'); 


%% ADD PARAMETERS TO TSERIES_MD
tseries_md.stepSize = 30 ; tseries_md.nplanes=4; 

%% PLOT FUNCTIONAL VS ANATOMICAL  
% factor that converts tsync value to microns of depth 
ts_per_zmicron = .018164; 

%tsync.framecount = round(tsync.framecount); 
[ypix_zdist,zlocs,totalpdist]= dep.fa_zdist(tseries_md,zstack_md,raw_tsync); 
%%
plot.functional_vs_anatomical(550,zlocs,ypix_zdist,tseries_md,raw_tsync); 


%%
file=dep.tsync_zdist('Warwick','DRGS',545); 