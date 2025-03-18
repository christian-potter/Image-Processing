function [] = umap_img(labels,colors,xy)

%% PLOT LABELS ON TSNE PLOT 
t = 'Clusters Identified By t-SNE'; 
shift = 1; 


figure
hold on 

for i = 1:size(xy,1)     
    scatter(xy(i,1),xy(i,2),[],colors(labels(i),:));
    textscatter(mean(xy(labels==labels(i),1))+shift,mean(xy(labels==labels(i),2))+shift,string(labels(i)),'ColorData',colors(labels(i),:),'FontSize',30,'FontWeight','Bold');
end
 
xlabel('UMAP Dimension 1')
ylabel('UMAP Dimension 2')
%title({t,['Dataset #',num2str(d.tag)]})
title('DBSCAN Clustering on All Responsive CICADA Neurons')

utils.sf




end 
