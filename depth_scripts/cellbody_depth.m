
%% LOAD 550 
dsnum= 550; 
[Fall,tseries_md,zstack,zstack_md,tsync,ypix_zplane] = utils.load_Data_Organization(dsnum); 
raw_tsync = md.read_h5('/Volumes/Warwick/DRGS/#550/SDH/Functional/ThorSync/TS#550_000/Episode_0000.h5'); 

[ypix_zdist,zlocs,totalpdist]= dep.fa_zdist(tseries_md,zstack_md,raw_tsync); 
%% LOAD 550 
dsnum= 550; 
[Fall,tseries_md,zstack,zstack_md,tsync] = utils.load_Data_Organization(dsnum); 
raw_tsync = md.read_h5('/Volumes/Warwick/DRGS/#550/SDH/Functional/ThorSync/TS#550_000/Episode_0000.h5'); 

[ypix_zdist,zlocs,totalpdist]= dep.fa_zdist(tseries_md,zstack_md,raw_tsync); 
%% ALIGN FUNCTIONAL AND ANATOMICAL 
stat = Fall.stat; 
stat = stat(Fall.iscell(:,1)==1); 
ref_cell = [82 37 ]; % cell id, zplane  

%[ypix_zdist,zlocs,totalpdist] = dep.fa_zdist(tseries_md,zstack_md,raw_tsync); 
[ypix_zplane,zlocs] = dep.modify_alignment(zlocs,ypix_zdist,stat,ref_cell,tseries_md,zstack_md); 


%%
load('/Volumes/Warwick/DRGS/#550/SDH/Processed/cellpose/soma_labels.mat')
load('/Volumes/Warwick/DRGS/#550/SDH/Processed/cellpose/nuclear_labels.mat')

% Default usage
depth = dep.findRedSurfaceDepth(zrgb);
imagesc(depth.depthMap);
axis image;
colorbar;
title('First red crossing depth per 10x10 bin');
%%

opts = struct;
opts.BinSize = [10 10];
opts.RedChannel = 1;
opts.Statistic = 'max';
opts.ThresholdMode = 'relative';
opts.Threshold = 0.25;
opts.MinConsecutiveZ = 2;
opts.interpMethod= 'nearest'; 
opts.SurfaceMode = 'poly3_constrained';
opts.SurfaceSmoothSigma = 1.2;
opts.SurfaceFillMissing = true;
depth = dep.findRedSurfaceDepth(zrgb,'Statistic',opts.Statistic,'MinConsecutiveZ',opts.MinConsecutiveZ,'SurfaceMode',opts.SurfaceMode,'InterpMethod',opts.interpMethod,'BinSize',[1 1]);
volshow(depth.surfaceVolumeSmooth)
%% XY PLOT OF DEPTH 

imagesc(depth.surfaceMapSmooth)
colorbar
title('First red crossing depth per XY pixel');
xlabel('X Position');ylabel('Y Position'); 

utils.sf

%%
used_labels = 1:size(medians,1); 
umedians = medians; 
%umedians(vols<100,:)=[]; used_labels(vols<100)=[]; 

%%
% 
somastat = computeCellDensityFromSurface(soma_labels,depth.surfaceMapSmooth); 

%%

density = somastat.densityCellsPerMM3; 

mdl = fitlm(1:length(density),density)

figure
plot(movmean(density,10),[length(density):-1:1],'LineWidth',2)
yticks([0:20:110])
yticklabels([110:-20:10])
xlabel('Cell Density per mm^3')
ylabel('Depth From Surface (um)')
utils.sf