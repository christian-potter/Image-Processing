function [idx,c,sumd,k] = kmeans_ssopt(mat,maxclust)
%% DESCRIPTION 
% finds mean silhouette score up until specified max K and then 

%% FIND MEAN SS FOR EACH K 

for i = 1:maxclust
    clust= kmeans(mat,i); 
    s = silhouette(mat,clust); 
    meansil(i)=mean(s); 
end


%% FIND MAX SS
k = find(meansil==max(meansil)); 

%% CLUSTER 
[idx,c,sumd]=kmeans(mat,k); 

end
