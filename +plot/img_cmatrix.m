function [] = img_cmatrix(cmatrix,d,t,opt)
    arguments
        cmatrix (:,:) double
        d struct
        t string
        opt.sz (1,1) double = 15
        opt.include (1,:) logical = logical(ones(1,size(cmatrix,1))>0) % automatically make logical vector including everything 
        opt.labelidx (1,:) double = 1:size(cmatrix,1)
        opt.labels (1,:) double = ones(1,size(cmatrix,1))
        opt.colors (:,3) double
        opt.crameri logical = true 
        opt.subplot double = []
        opt.asym logical = false 
    end
% Function that plots the correlation matrix 

% INPUTS: 
% cmatrix = should be of size that you want plotted 
% opt.sz = font size 
% opt.include = ONLY USED FOR SPBN

%% LOAD VARIABLES 
% sort values in cmatrix 
if ~isequal(ones(1,size(cmatrix,1)),opt.labels)  
    [opt.labels,opt.labelidx]=sort(opt.labels);
end

cmatrix=cmatrix(opt.labelidx,opt.labelidx);


%% MAKE FIGURE 
if isempty(opt.subplot)
    figure
else
    figure(opt.subplot(4))
    subplot(opt.subplot(1), opt.subplot(2) ,opt.subplot(3))
end

if ~opt.asym
    selfentries = zeros(1,size(cmatrix,1)); 
    cmatrix(1:size(cmatrix,1)+1:end)=selfentries; 
end

imagesc(cmatrix)
hold on 
if opt.crameri
    crameri('vik','pivot',0)
else
    crameri('roma','pivot',.5)
end

colorbar

%% EDIT FIGURE 
title({t,['Dataset #',num2str(d.tag)]})

xticks([])
yticks([])

utils.sf('fontsize',opt.sz)

%% PLOT CLUSTER INFORMATION 
if ~isequal(ones(1,size(cmatrix,1)),opt.labels) % if labels field is not default
    labelmat = nan(size(cmatrix,1),size(cmatrix,1),2); 
    plotlabels= zeros(size(cmatrix,1),size(cmatrix,1));
    
    for i = 1:size(labelmat,1)
        labelmat(i,:,1)=opt.labels(i); 
    end
    for j = 1:size(labelmat,2)
        labelmat(:,j,2)=opt.labels(j); 
    end
    
    for i = 1:size(labelmat,1)
        for j = 1:size(labelmat,2)
            if labelmat(i,j,1)==labelmat(i,j,2) && sum(isnan(labelmat(i,j,:)))==0
                plotlabels(i,j)=labelmat(i,j,1); 
            end
        end
    end

    for c = unique(opt.labels)
        curplot = plotlabels== c; 
        if sum(curplot(:))>1
            visboundaries(curplot,'Color',opt.colors(c,:))        
            curxy = sum(curplot>0); 
            curxy = find(curxy); 
           if c < length(unique(opt.labels))/2
                text(max(curxy)+2,mean(curxy),string(c),'Color',opt.colors(c,:),'FontSize',20,'FontWeight','bold'); 
           else
                text(min(curxy)-30,mean(curxy),string(c),'Color',opt.colors(c,:),'FontSize',20,'FontWeight','bold');           
           end
        end

    end
end


end 
