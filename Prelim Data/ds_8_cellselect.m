tlapse_path = '/Volumes/ross/Christian/#8/t-series.xml'; 
zstack_mdpath = '/Volumes/ross/Christian/#8/z-stack.xml'; 
%%
%zstack_path = '/Volumes/ross/Christian/#8/z-stack_blur1.tif'; 
%load('/Users/christianpotter/Library/Mobile Documents/com~apple~CloudDocs/Ross Lab/#8/z-stack_blur1.tif')

%%
tlapse_xml=md.importxml(tlapse_path);
[tlapse] = md.extract_metadata(tlapse_xml);

zstack_xml = md.importxml(zstack_mdpath); 
[zstack]=md.extract_metadata(zstack_xml);
%%

%load('ypix_zplane.mat')
load('/Users/christianpotter/Library/Mobile Documents/com~apple~CloudDocs/Ross Lab/#8/Fall.mat')
zstack_path= '/Users/christianpotter/Library/Mobile Documents/com~apple~CloudDocs/Ross Lab/#8/z-stack_blur1.tif'; 
zs= get.zstack(zstack_path);
load('ypix_zplane.mat')
cellstat= stat(iscell(:,1)==1); 
idvect = ones(sum(iscell(:,1)==1),1)*4; 
%% LOAD FIGURE POSITIONS 
load('work-positions.mat')
figs.zstack = figs.rgb; 
figs.zslider=figs.slider;
figs.ref=figs.rgb; 

%%
p = 1; 
idvect([2])=3; 
atype= 'mean';ftype='max'; 
img_mode='rgb'; colororder ='grb'; 
nplanes=5;
xyshift = [ops.xoff(end) ops.yoff(end)];
%xyshift=[0 0];
idvect([68 70 73 74 75])=[2 0 1 3 4];
[idvect,figs] = prompt.main_menu(idvect,figs,p,ops,cellstat,ftype,atype,img_mode,nplanes,ypix_zplane,zs,colororder,xyshift);

%%

figure
plot(sdff([1 2],:)')