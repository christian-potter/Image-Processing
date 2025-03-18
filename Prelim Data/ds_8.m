%% LOAD FILES 
tlapse_path = '/Volumes/ross/Christian/#8/t-series.xml'; 
zstack_mdpath = '/Volumes/ross/Christian/#8/z-stack.xml'; 
zstack_path = '/Volumes/ross/Christian/#8/z-stack_blur1.tif'; 
load('/Volumes/ross/Christian/#8/Fall.mat')

tlapse_xml=md.importxml(tlapse_path);
[tlapse] = md.extract_metadata(tlapse_xml);

zstack_xml = md.importxml(zstack_mdpath); 
[zstack]=md.extract_metadata(zstack_xml);

zs= get.zstack(zstack_path);

%% GET FRAMES PER TSERIES
[tseries_frames]= de.tseries_frames(ops);
nframes= sum(tseries_frames);
tpoints = cumsum(tseries_frames);
tpoints =[0,tpoints];tpoints(end)=[]; % adjust to start with 0

%%

%%
d.sdff=sdff; 
d.tag =8;
[grp_cm]= r.cmatrix(d,[stim.ttx,stim.cbx(3)]); 
[gcbx_cm]= r.cmatrix(d,[stim.cbx(3),stim.cbx(4)]); 
%%

[idx,c,sumd,k]=clust.kmeans_opt(grp_cm,10);
%[idx,c,sumd,k]=clust.kmeans_opt(gcbx_cm,10);
% can look at distances between centroids to compare how similar clusters
% are 

%%
e=eye(size(ttxmat,1));
ttxmat(e==1)=NaN;
%%
t= 'Clustering of correlation matrix for GRP ONLY'; 
kcolors = utils.distinguishable_colors(k);
plot.img_cmatrix(grp_cm,d,t,'labels',idx,'colors',kcolors,'crameri',true);
%%

plot.cluster_traces(tpoints,sdff, idx,[2,3],kcolors,'timepoints',[stim.ttx size(sdff,2)])
xline(stim.cbx(3),'LineWidth',3)


title({'Dataset 8','Clusters 2 + 3'})