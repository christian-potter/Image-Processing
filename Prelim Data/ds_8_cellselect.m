tlapse_path = '/Volumes/ross/Christian/#8/t-series.xml'; 
zstack_mdpath = '/Volumes/ross/Christian/#8/z-stack.xml'; 
zstack_path = '/Volumes/ross/Christian/#8/z-stack_blur1.tif'; 
load('/Volumes/ross/Christian/#8/Fall.mat')
load('ypix_zplane.mat')

%%
tlapse_xml=md.importxml(tlapse_path);
[tlapse] = md.extract_metadata(tlapse_xml);

zstack_xml = md.importxml(zstack_mdpath); 
[zstack]=md.extract_metadata(zstack_xml);

zs= get.zstack(zstack_path);
%%

cellstat= stat(iscell(:,1)==1); 
idvect = ones(sum(iscell(:,1)==1),1)*4; 
%% LOAD FIGURE POSITIONS 
load('work-positions.mat')
figs.zstack = figs.rgb; 
figs.zslider=figs.slider;
figs.ref=figs.rgb; 

%%
p = 1; 
%idvect([4,7])=3; 
atype= 'mean';ftype='max'; 
img_mode='rgb'; 
nplanes=5;
xyshift = [ops.xoff(end) ops.yoff(end)];
[idvect,figs] = prompt.main_menu(idvect,figs,p,ops,cellstat,ftype,atype,img_mode,nplanes,ypix_zplane,zs,xyshift);

%%

