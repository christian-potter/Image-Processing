%% LOAD 
dsnum = 542; 
[Fall,tseries_md,zstack_raw,zstack_md,tsync] = utils.load_Data_Organization(dsnum); 

%% EXAMINE ZSTACK
%zrgb = zstack_raw; 
zrgb = permute(zstack_raw,[1 2 4 3]); 
ref_slice = squeeze(zrgb(:,:,50,:)); 

figure
imshow(ref_slice)
%%
zstack = zrgb; 
save(['\\Shadowfax\Warwick\DRGS\#',num2str(dsnum),'\SDH\Processed\zstack.mat'],'zstack')
%%
zr = zrgb(:,:,:,1); 
zg = zrgb(:,:,:,2); 

%% DETERMINE DIAMETER
cellstat = Fall.stat(Fall.iscell(:,1)==1); 
d= nan(1,length(cellstat));

for i = 1:length(Fall.stat)
    d(i)= Fall.stat{i}.radius*2; 
end 

p = 10; 
thresh = prctile(d,p); 
%-- plot 
figure
histogram(d,'HandleVisibility','off')
xline(median(d),'Color','b','LineWidth',2)
xline(mean(d),'Color','g','LineWidth',2)
xline(thresh,'color','r','LineWidth',2)

legend({'Median','Mean','10th Percentile'})
xlabel('Diameter (um)')
ylabel('Frequency')
title({'Distribution of Cell Diameters','From 2D Masks Calculated by Suite2p'})
utils.sf
%%
downloadCellposeModels(Models=["cyto","cyto2","nuclei"],ModelFolder='C:\Users\rosslab.PITT\Desktop\cellpose models')
%%
ce = cellpose(Model="cyto2",ModelFolder='C:\Users\rosslab.PITT\Desktop\cellpose models',UseEnsemble=true); 
ne = cellpose(Model="nuclei",ModelFolder='C:\Users\rosslab.PITT\Desktop\cellpose models',UseEnsemble=true); 
%% MAKE CELLPOSE OBJECT
c = cellpose(Model="cyto2",ModelFolder='C:\Users\rosslab.PITT\Desktop\cellpose models',UseEnsemble=false); 
n = cellpose(Model="nuclei",ModelFolder='C:\Users\rosslab.PITT\Desktop\cellpose models',UseEnsemble=false); 

%% SEGMENT
tic
soma_labels = segmentCells3D(c,zg,ImageCellDiameter=15); 
toc
tic
nuclear_labels = segmentCells3D(n,zr,ImageCellDiameter=15); 
toc
%%
h = plotv.volshow_rgb_dualAlpha(V, opts); 

%%
label_rgb(:,:,:,1)=nuclear_labels; 
label_rgb(:,:,:,2)=soma_labels;
label_rgb(:,:,:,3) = zeros(size(soma_labels)); 


%%
%h = volshow_rgb_dualAlpha(zrgb,OverlayData=); 
st = ['\\Shadowfax\Warwick\DRGS\#',num2str(dsnum),'\SDH\Processed\cellpose\soma_labels2.mat' ];
nt = ['\\Shadowfax\Warwick\DRGS\#',num2str(dsnum),'\SDH\Processed\cellpose\nuclear_labels2.mat'] ;
save(st,'soma_labels')
save(nt,'nuclear_labels')