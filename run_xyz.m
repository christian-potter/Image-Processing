%%
%% LOAD Dataset 
dsnum= 541; 
[Fall,tseries_md,zstack,zstack_md,tsync,ypix_zplane] = utils.load_Data_Organization(dsnum); 
raw_tsync = md.read_h5('/Volumes/Ross/Warwick/4TB Drive Transfer/#541 3-22-25/Time Lapse/Final FOV/#541_TS_0000/Episode_0000.h5'); 
%%
ref_cell = [219 43];

[ypix_zdist,zlocs,totalpdist]= dep.fa_zdist(tseries_md,zstack_md,raw_tsync); 
%[ypix_zplane] = dep.fa_alignment(ypix_zdist,zlocs,tseries_md); 
[ypix_zplane,zlocs] = dep.modify_alignment(zlocs,ypix_zdist,cellstat,ref_cell,tseries_md,zstack_md); 

%%

load("/Users/ctp21/Desktop/Analysis/Image-Processing/work-positions.mat")
%zstack=zs;
p = 1;% Choose Plane 
atype= 'mean';ftype='max'; %choose default anatomical and functional image types 
nplanes=4;
zstack_drift = [Fall.ops.xoff(end) Fall.ops.yoff(end)]; % estimates the x/y coordinates of the z-stack by taking last value of x and y offset 
colororder = 'rgb'; % change between 'grb' and 'rgb' if your z-stack channels are switched 
%%
cellstat = Fall.stat(Fall.iscell(:,1)==1); 
%cellstat=Fall.stat; 
id_vect= id_vect_full; 
id_vect(id_vect==4)=[]; 

%%
[id_vect,figs,ref_bands] = prompt.main_menu(id_vect,figs,p,Fall.ops,cellstat,ftype,atype,nplanes,ypix_zplane,zstack,colororder,zstack_drift);
%%

zrgb = permute(zstack, [1 2 4 3]);
opts = struct;
opts.BinSize = [10 10];
opts.RedChannel = 2;
opts.Statistic = 'max';
opts.ThresholdMode = 'relative';
opts.Threshold = 0.01;
opts.MinConsecutiveZ = 2;
opts.interpMethod= 'nearest'; 
opts.SurfaceMode = 'poly3_constrained';
opts.SurfaceSmoothSigma = 1.2;
opts.SurfaceFillMissing = true;
depth = dep.findRedSurfaceDepth(zrgb,'Statistic',opts.Statistic,'MinConsecutiveZ',opts.MinConsecutiveZ,'SurfaceMode',opts.SurfaceMode,'InterpMethod',opts.interpMethod,'BinSize',[1 1],'Threshold',opts.Threshold);
volshow(depth.surfaceVolumeSmooth)
%%

%% XY PLOT OF DEPTH 

imagesc(depth.surfaceMapSmooth)
colorbar
title('First red crossing depth per XY pixel');
xlabel('X Position');ylabel('Y Position'); 

utils.sf
%% INSERT SURFACE INTO BLUE CHANNEL 
zrgb = permute(zstack, [1 2 4 3]);
zrgb(:,:,:,3)= depth.surfaceVolumeSmooth; 

h = plotv.volshow_rgb_dualAlpha(zrgb); 
%%


%% MAKE XYZ
cellstat = stat(iscell(:,1)==1);
cellstat = cellstat(id_vect_full~=4); 
%%
cellstat = Fall.stat(Fall.iscell(:,1)==1);
cellstat = cellstat(id_vect_full~=4); 


depth.surfaceMapSmooth= ones(size(depth.surfaceMapSmooth));
% in the future, this should be from registered cellpose/ s2p masks 
% also should take account xy shift from anatomical to functional 

xyz= nan(length(cellstat),3); 

for i = 1:length(cellstat)
    yx = cellstat{i}.med; 
    if yx(1)> size(Fall.ops.refImg,1)
        yx(1)=yx(1)-size(Fall.ops.refImg,1); 
    end

    if yx(2) > size(Fall.ops.refImg,2)
        yx(2) = yx(2)-size(Fall.ops.refImg,2); 
    end

    zoff = depth.surfaceMapSmooth(yx(1),yx(2)); 
    plane = cellstat{i}.iplane+1; 

    yz = ypix_zplane{plane}; 
    z = yz(yx(1)); % zlocation for plane/ ypixel 
    xyz(i,:)=[yx(2) yx(1) z+round(zoff)]; 


end
%%

figure('Name','Cells 3D scatter','Color','w');
scatter3(xyz(:,1),xyz(:,2),xyz(:,3),36,'filled');
xlabel('X (px)'); ylabel('Y (px)'); zlabel('Z (plane)');
axis vis3d equal;
grid on;
view(45,25);
title(sprintf('3D cell positions (%d cells)',size(xyz,1)));