%%
%% LOAD Dataset 
dsnum= 542; 
[Fall,tseries_md,zstack,zstack_md,tsync,ypix_zplane,raw_tsync] = utils.load_Data_Organization(dsnum); 

%%
ref_cell = [56 31];

[ypix_zdist,zlocs,totalpdist]= dep.fa_zdist(tseries_md,zstack_md,raw_tsync); 
%[ypix_zplane] = dep.fa_alignment(ypix_zdist,zlocs,tseries_md); 
[ypix_zplane,zlocs] = dep.modify_alignment(zlocs,ypix_zdist,Fall.cellstat,ref_cell,tseries_md,zstack_md); 

%%
%load("C:\Users\rosslab.PITT\Desktop\MATLAB Code\Image-Processing\home_positions.mat")
%load("/Users/ctp21/Desktop/Analysis/Image-Processing/work-positions.mat")
%zstack=zs;
p = 1;% Choose Plane 
atype= 'mean';ftype='max'; %choose default anatomical and functional image types 
nplanes=4;
zstack_drift = [Fall.ops.xoff(end) Fall.ops.yoff(end)]; % estimates the x/y coordinates of the z-stack by taking last value of x and y offset 
colororder = 'rgb'; % change between 'grb' and 'rgb' if your z-stack channels are switched 
%%
load(['\\Shadowfax\Warwick\DRGS\#',num2str(dsnum),'\SDH\Processed\id_vect_full.mat'])

%%
[id_vect,figs,ref_bands] = prompt.main_menu(id_vect_full,figs,p,Fall.ops,Fall.cellstat,ftype,atype,nplanes,ypix_zplane,zstack,colororder,zstack_drift);
%%
zrgb = zstack; 
zrgb = permute(zstack, [1 2 4 3]);
zrgb(:,:,:,1)=zstack(:,:,2,:); 
zrgb(:,:,:,2)=zstack(:,:,1,:); 
opts = struct;
opts.BinSize = [1 1];
opts.RedChannel = 1;
opts.Statistic = 'mean';
opts.ThresholdMode = 'relative';
opts.Threshold = 0.25;
opts.MinConsecutiveZ = 2;
opts.interpMethod= 'nearest'; 
opts.SurfaceMode = 'poly2_constrained';
opts.SurfaceSmoothSigma = 1.2;
opts.SurfaceFillMissing = true;
depth = dep.findRedSurfaceDepth(zrgb,'Statistic',opts.Statistic,'MinConsecutiveZ',opts.MinConsecutiveZ,'SurfaceMode',opts.SurfaceMode,'InterpMethod',opts.interpMethod,'BinSize',[1 1],'Threshold',opts.Threshold);
%volshow(depth.surfaceVolumeSmooth)
zrgb(:,:,:,3)= depth.surfaceVolumeSmooth; 
h = plotv.volshow_rgb_dualAlpha(zrgb); 

%%

%% XY PLOT OF DEPTH 
figure
axis('equal')
imagesc(depth.surfaceMapSmooth)
colorbar
title('First red crossing depth per XY pixel');
xlabel('X Position');ylabel('Y Position'); 

utils.sf('cond','any')
%% INSERT SURFACE INTO BLUE CHANNEL 
%zrgb = permute(zstack, [1 2 4 3]);
%zrgb = zstack;


%%
%id_vect= id_vect_full(id_vect_full~=4); 
[xyz,xyp,id_vect] = dep.neuron_xyz(id_vect_full,Fall,ypix_zplane,depth,zlocs);
%%

plotv.xyz_location(xyp,xyz, ypix_zplane,depth,Fall,zlocs)
%%
 save(['\\Shadowfax\Warwick\DRGS\#',num2str(dsnum),'\SDH\Processed\zrgb.mat'],'zrgb')

%%
  save(['\\Shadowfax\Warwick\DRGS\#',num2str(dsnum),'\SDH\Processed\xyz.mat'],'xyz')
%%
utils.save_depth(dsnum,xyz,zlocs,ypix_zplane,depth,zrgb,ref_cell)


