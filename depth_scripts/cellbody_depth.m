
%% LOAD 550 
dsnum= 550; 
[Fall,tseries_md,zstack,zstack_md,tsync,ypix_zplane] = utils.load_Data_Organization(dsnum); 
raw_tsync = md.read_h5('/Volumes/Warwick/DRGS/#550/SDH/Functional/ThorSync/TS#550_000/Episode_0000.h5'); 

[ypix_zdist,zlocs,totalpdist]= dep.fa_zdist(tseries_md,zstack_md,raw_tsync); 
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
load('/Volumes/Warwick/DRGS/#550/SDH/Processed/cellpose/soma_labels.mat')
load('/Volumes/Warwick/DRGS/#550/SDH/Processed/cellpose/nuclear_labels.mat')

%%

z = squeeze(zstack(:,:,1,1:121));
%%

volshow(z)
%%
volshow(z,OverlayData=soma_labels)

%%
binlab = soma_labels; 
idx = binlab>1;
binlab(idx)=1;

sumbin= sum(binlab,3);

figure
bar3(sumbin)

%%

[label_medians,medians,vols] = dep.get_label_medians(soma_labels(:,:,1:40)); 
%%
figure
histogram(vols,'BinWidth',50)
diam=mean(vols); 
xline(mean(vols),'color','r')
title('Distribution of Cell Volumes Detected by Cellpose')
xlabel('Cubic Microns')
ylabel('Frequency')
utils.sf
%%
used_labels = 1:size(medians,1); 
umedians = medians; 
%umedians(vols<100,:)=[]; used_labels(vols<100)=[]; 

%%

