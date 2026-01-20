%% GOAL 
% 1) validate  the alignment between functional and anatomical
% 2) estimate surface in this coordinate system 

%% LOAD 
load("/Users/christianpotter/Desktop/Analysis/Image-Processing/home_positions.mat")
load("/Users/christianpotter/Desktop/Analysis/Image-Processing/old_ws/511/ds511_0215.mat")
load("/Users/christianpotter/Desktop/Analysis/Image-Processing/old_ws/511/ds511_load_drgs.mat")

%%
ref_cell = [11,12];
[ypix_zplane2] = dep.modify_alignment(zlocs,ypix_zdist,stat,ref_cell,tseries_md,zstack_md);


%% LOOK AT ALIGMENT BETWEEN FUNCTIONAL AND ANATOMICAL 

%zstack=zs;
p = 1;% Choose Plane 
atype= 'mean';ftype='max'; %choose default anatomical and functional image types 
nplanes=5;
zstack_drift = [-16 4]; % estimates the x/y coordinates of the z-stack by taking last value of x and y offset 
colororder = 'rgb'; % change between 'grb' and 'rgb' if your z-stack channels are switched 
[id_vect,figs,ref_bands] = prompt.main_menu(id_vect,figs,p,ops,stat,ftype,atype,nplanes,ypix_zplane2,zstack,colororder,zstack_drift);
%%