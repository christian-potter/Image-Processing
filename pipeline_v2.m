%% LOAD 
 [zs,tlapse,zstack,tsync,s2p,ypix_zplane,idvect] = utils.load_drgs(518,'noplot'); 
load(s2p); 
%% CREATE SAMPLE ID_VECT

cellstat= stat(iscell(:,1)==1); 

idvect = idvect(iscell(:,1)==1); 
%%
%id_vect(:)=3; 
idvect(:)=4; 
%% DS 511
idvect = id_vect; 
idvect(:)=4; 

%% LOAD FIGURE POSITIONS 
load('work-positions.mat')
figs.zstack = figs.rgb; 
figs.zslider=figs.slider;
figs.ref=figs.rgb; 
%% RUN MAIN MENU
zs=zstack;
p = 1; 
%idvect([2])=3; 
atype= 'mean';ftype='max'; 
img_mode='rgb'; 
nplanes=5;
xyshift = [ops.xoff(end) ops.yoff(end)];
[idvect,figs] = prompt.main_menu(idvect,figs,p,ops,cellstat,ftype,atype,img_mode,nplanes,ypix_zplane,zs,'rgb',xyshift);

%%

