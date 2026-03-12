[Fall,tseries_md,zstack,zstack_md,tsync] = utils.load_Data_Organization(550); 
%% DETERMINE DIAMETER
d=[]; 
for i = 1:length(Fall.stat)
    d = [d,Fall.stat{i}.radius*2]; 
end 
%%
figure
histogram(d)

title({'Distribution of Cell Diameters','From 2D Masks Calculated by Suite2p'})
utils.sf
%%
cp = cellpose(Model="cyto2",ModelFolder='/Users/ctp21/Desktop/cellpose files'); 

%%
z = squeeze(zstack(:,:,1,1:121));

labels = segmentCells3D(cp,z,ImageCellDiameter=15); 
%%

for i = 1:50
    s= zstack(:,:,1,1); 
    l2(:,:,i)= segmentCells2D(cp,s);

end
%%
volshow(z)
%%
volshow(z,OverlayData=soma_labels)
%%
binlab = labels; 
idx = binlab>1;
binlab(idx)=1;

sumbin= sum(binlab,3);
%%
figure
bar3(sumbin)
%%


%%
rmlabels = labels; 

first= unique(labels(:,:,1)); 
first(first==0)=[]; 

for i = 1:length(first)
    rmlabels(rmlabels==first(i))=0; 
    i
end


volshow(z,OverlayData=rmlabels)