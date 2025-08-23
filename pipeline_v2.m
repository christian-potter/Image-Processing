%% LOAD 
% edit function 
[zstack,tlapse_md,zstack_md,tsync,s2p,ypix_zplane] = utils.load_drgs(548,'plot'); 
load(s2p); 
cellstat = stat(iscell(:,1)==1);
%% DEFAULT ID_VECT
id_vect = ones(sum(iscell(:,1)==1),1)*3; 

%% LOAD FIGURE POSITIONS 
load('work-positions.mat')
figs.zstack = figs.rgb; 
figs.zslider=figs.slider;
figs.ref=figs.rgb; 
%% SETTINGS 
%zstack=zs;
p = 1;% Choose Plane 
atype= 'mean';ftype='max'; %choose default anatomical and functional image types 
nplanes=4;
zstack_drift = [ops.xoff(end) ops.yoff(end)]; % estimates the x/y coordinates of the z-stack by taking last value of x and y offset 
colororder = 'grb'; % change between 'grb' and 'rgb' if your z-stack channels are switched 

%% RUN MAIN MENU
[id_vect,figs] = prompt.main_menu(id_vect,figs,p,ops,cellstat,ftype,atype,nplanes,ypix_zplane,zstack,'grb',zstack_drift);


%%

