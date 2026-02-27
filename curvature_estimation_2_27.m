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
load("/Users/ctp21/Desktop/Analysis/Image-Processing/work-positions.mat")

%% SETTINGS 
%zstack=zs;
p = 1;% Choose Plane 
atype= 'mean';ftype='max'; %choose default anatomical and functional image types 
nplanes=5;
zstack_drift = [Fall.ops.xoff(end) Fall.ops.yoff(end)]; % estimates the x/y coordinates of the z-stack by taking last value of x and y offset 
colororder = 'grb'; % change between 'grb' and 'rgb' if your z-stack channels are switched 
%%
id_vect = ones(sum(Fall.iscell(:,1)==1),1)*3; 
cellstat = stat; %stat(Fall.iscell(:,1)==1);
%% RUN MAIN MENU
zs=zstack;
[id_vect,figs,ref_bands] = prompt.main_menu(id_vect,figs,p,Fall.ops,cellstat,ftype,atype,nplanes,ypix_zplane,zs,colororder,zstack_drift);