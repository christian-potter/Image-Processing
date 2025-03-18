function [p1x,p1y] = cluster_locations(d,data,labels,cmatrix,colors,opt)
    arguments
        d struct 
        data struct
        labels (1,:) double
        cmatrix (:,:) double     
        colors(:,3) double
        opt.include logical = logical(ones(1,size(d.sdff,1))>0); 
        opt.specific_label double % only plot members from one cluster 
        opt.plot_type string = 'bstick'
        opt.marker_size double = 2; 
        opt.font_size double = 15 ;
        opt.thresh double 
        opt.alphas double = ones(size(d.sdff,1),1); 
        opt.view double = [-12 16]; 
        opt.frame double = -1; 
        opt.position double = [1440 818 560 420]; 
    end

%% MAKE VARIABLES 
xy=d.xy(opt.include,:); 
%hw=d.hw(opt.include,:); 
hw=ones(size(d.sdff,1),2); 
hw=hw.*25; 
pidx=d.pidx(opt.include);
total_planes=unique(d.pidx);
%issp=d.issp(opt.include); 


if isfield(opt,'specific_label')
    sp_idx= ismember(labels,opt.specific_label); 
    xy=xy(sp_idx,:);
    hw = hw(sp_idx,:); 
    pidx= pidx(sp_idx); 
    cmatrix=cmatrix(sp_idx,sp_idx);
    labels=labels(sp_idx); 
    %issp=issp(sp_idx); 
    
    t={['Spatial Map of Neurons '],['Cluster Label #',num2str(opt.specific_label),', Dataset #',num2str(d.tag)]};
else
    t={['Spatial Map of Neurons'],['Dataset #',num2str(d.tag)]};
end
%% SORT FOR LEGEND
[labels,label_order] = sort(labels); 

xy=xy(label_order,:);
hw = hw(label_order,:); 
pidx= pidx(label_order); 
cmatrix=cmatrix(label_order,label_order);

%% MARKER SIZE
if numel(opt.marker_size)==1
    marker_size=ones(length(pidx))*opt.marker_size; 
else
    marker_size= opt.marker_size;
end


%% PLOT CELLS
locations = figure(2); 
%set(gcf, 'renderer', 'zbuffer');
clf
hold on 
zdist= -.5;
label_log=[]; count =1; 

for i = 1:size(xy,1)
    if strcmp(opt.plot_type,'text')
        textscatter3(xy(i,1),xy(i,2),(pidx(i)+1)*zdist,string(i),'ColorData',colors(labels(i),:),'MarkerSize',opt.marker_size,'FontSize',opt.font_size)  
    elseif strcmp(opt.plot_type,'bstick')
        if ~ismember(labels(i),label_log) % register new label for legend purposes
            label_log(count)=labels(i); count=count+1; 
            scatter3(xy(i,1),xy(i,2),(pidx(i)+1)*zdist,sum(hw(i,:))*marker_size(i),'MarkerFaceColor',colors(labels(i),:),'MarkerEdgeColor',colors(labels(i),:),'MarkerFaceAlpha',opt.alphas(i))%issp(i)
        else
            scatter3(xy(i,1),xy(i,2),(pidx(i)+1)*zdist,sum(hw(i,:))*marker_size(i),'MarkerFaceColor',colors(labels(i),:),'HandleVisibility','off','MarkerEdgeColor',colors(labels(i),:),'MarkerFaceAlpha',opt.alphas(i))
        end
    end

end

%% DRAW EDGES (if option is selected)

if isfield(opt,'thresh')
    for i = 1:size(cmatrix,1)
        for j = 1:size(cmatrix,2)
            if i>j 
                if cmatrix(i,j)>thresh
                    iloc=xy(i,:);
                    jloc=xy(j,:); 
                    plot3([iloc(1),jloc(1)],[iloc(2), jloc(2)],[(pidx(i)+1)*zdist,(pidx(j)+1)*zdist],'Color',colors(labels(i),:),'LineWidth',(cmatrix(i,j)-thresh)*3)
                end
            end
        end
    end
end

%% EDIT FIGURE
zticks(flip((total_planes+1)*zdist))
%zticklabels(flip(data.planelist))

if opt.frame>-1
    title(['Frame: ',num2str(opt.frame)]) 
else
    title(t)
end
utils.set_figure(25,'rect')
zlabel('Plane')
xlabel('X Location')
ylabel('Y Location ')

view(opt.view)
if isfield(opt,'specific_label')
    l =legend(split(num2str(label_log)));
    title(l,'Cluster')
end

set(gcf,'Position',opt.position)

%% DRAW PLANES
for i = 1:length(total_planes)
    px = d.xy(d.pidx==total_planes(i),1); 
    py = d.xy(d.pidx==total_planes(i),2); 
    patch([min(px) max(px) max(px) min(px)],[min(py) min(py) max(py) max(py)],[(total_planes(i)+1)*zdist (total_planes(i)+1)*zdist (total_planes(i)+1)*zdist (total_planes(i)+1)*zdist],'k','FaceAlpha',.025,'HandleVisibility','off')
end

p1x = min(d.xy(d.pidx==total_planes(1),1)); 
p1y = min(d.xy(d.pidx==total_planes(1),2)); 

