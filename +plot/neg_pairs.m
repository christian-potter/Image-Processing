function [] = neg_pairs (d,prct,cmatrix,labels,colors,opt)
    arguments 
        d struct
        prct  double 
        cmatrix (:,:) double 
        labels(:,1) double
        colors (:,3) double 
        opt.avgwindow =15 
    
    end

%% MAKE VARIABLES

allcorrs = triu(cmatrix,1); allcorrs(allcorrs>=0)=[];

thresh = prctile(allcorrs,prct); 
offset = .5; 
%% PLOT TRACES
figure 
hold on 
offcount = 0 ; 
yts=[]; ytls =[]; 
for i = 1:size(cmatrix,1)
    for j = 1:size(cmatrix,1)
        if i > j 
            if cmatrix(i,j)<thresh
                offcount = offcount+1; 
                ioff =offcount * offset ; joff = offcount* offset - offset * .5; 
                plot(movmean(d.sdff(i,:),opt.avgwindow)-ioff ,'Color',colors(labels(i),:))
                plot(movmean(d.sdff(j,:),opt.avgwindow)- joff,'Color',colors(labels(j),:))
                yline(-ioff)
                
                yts = [yts,[-joff -ioff]]; 
                ytls = [ytls,[labels(j), labels(i)]]; 
    
            end
        end

    end
end

%% EDIT FIGURE

xlabel('Time')
ylabel('Cluster Label')
%yticks(flip(round(yts,2)))
yticks([])
yticklabels(flip(ytls))

utils.set_figure(15,'any')






