%% LOAD 

p0= imread('/Volumes/Warwick/DRGS project/#547- 8-6-25/chan2ref_plane0.tif');
p1= imread('/Volumes/Warwick/DRGS project/#547- 8-6-25/chan2ref_plane1.tif');
p2= imread('/Volumes/Warwick/DRGS project/#547- 8-6-25/chan2ref_plane2.tif');
p3= imread('/Volumes/Warwick/DRGS project/#547- 8-6-25/chan2ref_plane3.tif');
%%
chan2ref = [p0,p1;p2,p3];
chan2ref=imadjust(chan2ref);
figure
imshow(chan2ref)
ops.meanImg_chan2 = chan2ref; 
%% LOAD 

[zstack,tlapse_md,zstack_md,tsync,s2p,ypix_zplane] = utils.load_drgs(547,'plot'); 
load(s2p); 
cellstat = stat(iscell(:,1)==1);
% DEFAULT ID_VECT
id_vect = ones(sum(iscell(:,1)==1),1)*3; 
%%
%lad('/Volumes/ross/Christian/DRGS/#547/Fall.mat')
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
%%

%% RUN MAIN MENU
[id_vect,figs] = prompt.main_menu(id_vect,figs,p,ops,cellstat,ftype,atype,nplanes,ypix_zplane,zstack,'grb',zstack_drift);


%% PLANE 1



p0 =imread('/Volumes/Warwick/DRGS project/#547- 8-6-25/chan2ref_plane1.tif'); 
p0=imadjust(p0)
figure;imshow(p0)