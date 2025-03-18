load('/Volumes/AbbyCui/#53_2.14.2025/split/suite2p/combined/Fall.mat')

%% GET DFF
f= F(iscell(:,1)==1,:); 
dF_F = get.dF_F_rolling(f, 400);
sdff = sgolayfilt(dF_F,3,15,[],2); 
%%
[tseries_frames]= de.tseries_frames(ops); nframes= sum(tseries_frames);
%[tsync] = de.compress_tsync(tsync,nframes); 
%% MAKE STIMULUS STRUCTURE 
%needs to be a structure that can incorportate the appropriate variables from
%thorsync later 

stim = de.enter_stimuli(tseries_frames,8,ops);

%% LOAD FILES 
tlapse_path = '/Volumes/AbbyCui/#53_2.14.2025/#53_001/Experiment.xml'; 
zstack_mdpath = '/Volumes/ross/Christian/#8/z-stack.xml'; 
zstack_path = '/Volumes/ross/Christian/#8/z-stack_blur1.tif'; 
load('/Volumes/ross/Christian/#8/Fall.mat')

tlapse_xml=md.importxml(tlapse_path);
[tlapse] = md.extract_metadata(tlapse_xml);

zstack_xml = md.importxml(zstack_mdpath); 
[zstack]=md.extract_metadata(zstack_xml);

zs= get.zstack(zstack_path);

%% GET SELECTED ACTIVITY 

%18/19/20 = ttx || 21/22/23 = CBX 

tpoints = cumsum(tseries_frames);
tpoints =[0,tpoints];tpoints(end)=[]; % adjust to start with 0

sodff = sdff(:,tpoints(18):end); 

%% ORGANIZE BY SKEW
%stat=stat(iscell(:,1)==1); 
for i = 1:length(stat)
    skews(i) = stat{i}.skew; 
end

[~,skewidx]=sort(skews); 
%%
sodff=sodff(skewidx,:); 
sodff = get.offsetRows(sodff,1);

%% PLOT ALL TRACES 

figure
plot(sodff(1:200,:)'); 
xticks(tpoints(18:end)-tpoints(18))
%xticklabels(stim.strlist)
xline(tpoints(21)-tpoints(18))
xlabel('Stimulus Times')
ylabel('dF/F')
title('Smoothed dF/F')
yticks([])
utils.sf

%% GET CMATRIX
d.sdff = sdff; d.tag =53;  
[ttx_cm]= r.cmatrix(d,[tpoints(18),tpoints(21)]); 
[cbx_cm]= r.cmatrix(d,[tpoints(21),size(sdff,2)]); 

%% K MEANS OPT
[idx,c,sumd,k]=clust.kmeans_opt(ttx_cm,10);
%[idx,c,sumd,k]=clust.kmeans_opt(gcbx_cm,10);
% can look at distances between centroids to compare how similar clusters
% are 

%% PLOT KMEANS 
t= 'Clustering of correlation matrix for GRP ONLY'; 
kcolors = utils.distinguishable_colors(k);
plot.img_cmatrix(cbx_cm,d,t,'labels',idx,'colors',kcolors,'crameri',true);

%% PLOT INDIVIDUAL CLUSTER TRACES 
% 
plot.cluster_traces(sdff, idx, [5,3,2,1],kcolors,'timepoints',[tpoints(18) size(F,2)])

