%% LOAD 
% edit function 
[zstack,tlapse_md,zstack_md,tsync,s2p,ypix_zplane] = utils.load_drgs(541,'plot'); 
load(s2p); 

%% DEFAULT ID_VECT
id_vect = ones(sum(iscell(:,1)==1),1)*3; 
cellstat = stat(iscell(:,1)==1);
%% MAKE YPIX/ZPLANE
tseries_md.nplanes = 4; 
ypix_zplane = functional_anatomical_zmap(dsnum,tseries_md,zstack_md,raw_tsync,'plot',true); 
%%
load('/Volumes/ross/Christian/DRGS/#548/Fall.mat')
%% LOAD FIGURE POSITIONS 
load('home_positions.mat')
figs.zstack = figs.rgb; 
figs.zslider=figs.slider;
figs.ref=figs.rgb; 
%% SETTINGS 
%zstack=zs;
p = 1;% Choose Plane 
atype= 'mean';ftype='max'; %choose default anatomical and functional image types 
nplanes=5;
zstack_drift = [ops.xoff(end) ops.yoff(end)]; % estimates the x/y coordinates of the z-stack by taking last value of x and y offset 
colororder = 'grb'; % change between 'grb' and 'rgb' if your z-stack channels are switched 

%% RUN MAIN MENU
zs=zstack;
[id_vect,figs,ref_bands] = prompt.main_menu(id_vect,figs,p,ops,cellstat,ftype,atype,nplanes,ypix_zplane,zs,colororder,zstack_drift);

%%  PLANE 1 
ex = [ 8 16 11 5 29  34 48 51 21 33 56 27 68 44 25 46]; 

in = [7 10 47 16 31 30 35 53 58 54 56 71 36 45 46 41 45 39 23 32]; 

spbn = [3 28 17 12 59 62 74 ];

del = [26 60 55 15]; 


%% NOTES 
n(1).i = 47; n(1).t = 'Probably is 2 cells combined'; 

%% ADJUST YPIX_ZPLANE


%% CONVERT REFERENCE BANDS INTO NEW COORDINATES 


%% SAVE FILES

