function cluster_subplots(yvariable,labels,dsstim,dsd,dsids,opt)
arguments 
    yvariable double
    labels double 
    dsstim struct
    dsd struct 
    dsids double 
    opt.fontsize double = 15
end

ligand_select  = [1 2 3 4 5 6 7 10];
liglabels= {'OXY','GRP','CCK','SP','Talt','NKB','Oxo','NMB'}; 

nlabels =length(unique(labels)); 
%% DETERMINE SUBPLOT ROWS 

sp = ceil(nlabels/4); 

%% MAKE DSVECT
% dsvect = []; 
% for i = 1:length(dsd) 
%     dsvect = [dsvect;ones(size(dsd(i).sdff,1),1)*i];
% end

%% SUBPLOT FOR EACH CLUSTER LABEL AND VIOLIN FOR EACH CATEGORY 
figure
  
for i = 1:nlabels
    subplot(sp,4,i)
    hold on 
    curnorm = yvariable(labels ==i,:); 
       
    violinplot(curnorm); 
    yline(0); yline(1)

    xticklabels(liglabels);
    title({['Cluster ',num2str(i)],['N = ',num2str(sum(labels==i))]},'FontSize',8)
    utils.sf('fontsize',opt.fontsize)
    scatter(1:length(ligand_select),mean(curnorm,1),'k','filled')
    for j =1:length(ligand_select)
        p=prctile(curnorm(:,j),[25 75]); 
        plot([j j],p,'k')
    end

end

sgtitle('Mean Activity For Each Cluster','FontSize',opt.fontsize,'FontWeight','bold')

%% BAR GRAPH OF DATASET DISTRIBUTION

barmat=[]; 
for i = 1:nlabels
    curlabel = find(labels==i); 
    for j = 1:length(dsstim)
        curds = find(dsids==j); 
        inter= intersect(curlabel,curds); 
        barmatp(i,j)=length(inter)*100/sum(dsids==j); 
        barmat(i,j)=length(inter); 
        leg{j}=['# ',num2str(dsstim(j).tag)];
    end
end

%  ----- un-normalized bar graph 
% figure 
% bar(barmat,'stacked')
% %leg =utils.genleg(length(ligand_select),'Dataset '); 
% legend(leg)
% xlabel('Cluster')
% ylabel('Neurons Contributed for Each Dataset')
% title('Contribution of Neurons By Dataset to Each Cluster')
% utils.sf('fontsize',opt.fontsize)


figure 
bar(barmatp,'stacked')
%leg =utils.genleg(length(ligand_select),'Dataset '); 
legend(leg)
xlabel('Cluster')
ylabel("Percentage of Dataset's Neurons Contributed For Each Dataset")
title('Contribution of Neurons By Dataset to Each Cluster')
utils.sf('fontsize',opt.fontsize)

%% PIE CHART SUBPLOTS 
figure('color','w')
%t =utils.genleg(nlabels,'Cluster '); 
for i = 1:nlabels
    subplot(sp,4,i)
    pie(barmatp(i,:))
    title({['Cluster ',num2str(i)],['N = ',num2str(sum(labels==i))]})
end
sgtitle('Percentage Contribution of Neurons By Dataset to Each Cluster','FontSize',opt.fontsize,'FontWeight','bold')

%% SPIDER PLOT 
colors = utils.distinguishable_colors(nlabels);

mean_resps = nan(nlabels,length(ligand_select)); 
for i = 1:nlabels 
    for j = 1:length(ligand_select)
        mean_resps(i,j)=mean(yvariable(labels==i,j)); 
    end
end

limits = ones(2,length(ligand_select)); limits(1,:)=0; 

figure
plot.spider_plot(mean_resps,'AxesLabels',liglabels,'AxesLimits', limits,'Color',colors)
title('Mean Responses for Each Cluster')
for i = 1:nlabels 
    leg{i}=['Cluster #',num2str(i)]; 
end
legend(leg)

%% t-SNE PLOT
ts = tsne(yvariable); 

figure 
hold on 

dslist = []; 

for i = 1:size(ts,1)
    if ~ismember(dsids(i),dslist)
        text(ts(i,1),ts(i,2),num2str(dsids(i)),'color',colors(labels(i),:));
    end
    
end
axis([min(ts(:,1)-10), max(ts(:,1)+10), min(ts(:,2)-10) max(ts(:,2)+10)])
utils.sf('fontsize',15)

title('tSNE Plot of k-Means CICADA Clusters')