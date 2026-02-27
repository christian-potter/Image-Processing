%% LOAD DATASET
dsnum= 545; 
[Fall,tseries_md,zstack,zstack_md,tsync] = utils.load_Data_Organization(dsnum); 


%% PLOT FUNCTIONAL VS ANATOMICAL  
% factor that converts tsync value to microns of depth 
ts_per_zmicron = .018164; 

tsync.framecount = round(tsync.framecount); 
[ypix_zdist,zlocs]= dep.fa_zdist(tseries_md,zstack_md,tsync); 

plot.functional_vs_anatomical(zlocs,ypix_zdist); 


%%
file=dep.tsync_zdist('Warwick','DRGS',545); 