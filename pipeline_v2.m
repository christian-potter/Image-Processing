%% LOAD 
[zstack,tlapse,zstack_md,tsync,s2p,ypix_zplane] = utils.load_drgs(511,'noplot'); 
load(s2p); 
id_vect = ones(sum(iscell(:,1)==1),1)*4; 
cellstat = stat(iscell(:,1)==1);

%% LOAD FIGURE POSITIONS 
load('work-positions.mat')
figs.zstack = figs.rgb; 
figs.zslider=figs.slider;
figs.ref=figs.rgb; 
%% RUN MAIN MENU
id_vect = ones(sum(iscell(:,1)==1),1)*4; 
%cellstat = stat(iscell(:,1)==1);
%zstack = zs; 
p = 1; 
atype= 'mean';ftype='max'; 
img_mode='functional'; 
nplanes=5;
xyshift = [ops.xoff(end) ops.yoff(end)];
[id_vect,figs] = prompt.main_menu(id_vect,figs,p,ops,cellstat,ftype,atype,img_mode,nplanes,ypix_zplane,zstack,'rgb',xyshift);

%%

