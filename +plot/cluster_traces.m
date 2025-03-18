function cluster_traces(tpoints,activityMatrix, clusterIDs, clustersToPlot,colors,opt)

arguments
    tpoints
    activityMatrix double
    clusterIDs double 
    clustersToPlot double 
    colors double 
    opt.offset double = 1
    opt.timepoints double = [1 size(activityMatrix,2)]
end

%% MAKE VARIABLES
activityMatrix = activityMatrix(:,opt.timepoints(1):opt.timepoints(2)); 

[sclusters,cidx] = sort(clusterIDs,'ascend'); 
sorted_activity = activityMatrix(cidx,:);

included_clusters= ismember(sclusters,clustersToPlot); 

sorted_activity= sorted_activity(included_clusters,:);

sclusters=sclusters(included_clusters); % sorted clusters for plotting 

%% PLOT TRACES 
cluster_list=[]; 
figure
hold on 

for i = 1:size(sorted_activity,1)
    
    if ~ismember(sclusters(i),cluster_list)
        plot(sorted_activity(i,:)+opt.offset*i,'color',colors(sclusters(i),:))
    else 
        plot(sorted_activity(i,:)+opt.offset*i,'color',colors(sclusters(i),:),'HandleVisibility','off')
        cluster_list = [cluster_list,sclusters(i)]; 
    end
end

uniqueClusters = intersect(unique(clusterIDs), clustersToPlot);
legendLabels = arrayfun(@(c) sprintf('Cluster %d', c), uniqueClusters, 'UniformOutput', false);
legend(legendLabels, 'Location', 'best');
%% ADD TSERIES BOUNDARIES

cur_tpoints = tpoints(tpoints>opt.timepoints(1)); 
xline(cur_tpoints-opt.timepoints(1),'HandleVisibility','off'); 
%%
utils.sf 