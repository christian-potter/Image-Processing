function [] = traces (timepoints,t,d,data,opt)
    arguments 
        timepoints (1,:) double 
        t string 
        d struct
        data struct      
        opt.nidx (1,:) double =[] % new index 
        opt.include (1,:) logical = ones(1,size(d.sdff,1))>0
        opt.nneurons double = size(d.sdff,1)  % will default to making it as many as are in the matrix
        opt.nshift double = 0 
        opt.dimension double = 2 
        opt.avgwindow double = 15   
        opt.labeltype string = 'time'
        opt.linewidth double = 2
        opt.stretch double = 1
    end

%% CREATE VARIABLES

incl_cells= d.sdff(opt.include,:).*2.5; % multiplier to accentuate peaks  
opt.nneurons=sum(opt.include);

if ~isempty(opt.nidx)
    idx=opt.nidx; 
    incl_cells=incl_cells(idx,:);% different order if you want to plot in 
end

inc_issp= d.issp(opt.include); % included SPBNs 
offset = .5; % dictates trace spacing  

if numel(timepoints)==2
    plottime=timepoints(1):timepoints(2);
else
    plottime=timepoints; 
end
%% FIND TIMES
% methods are different depending if times are consecutive or not 
plotted_times= 1:length(plottime); 

% starts/ ends refer to periods surrounding stimuli in data.Stimulus

if unique(diff(plottime))== 1 % if consecutive plot times 
    startidx = data.Stimulus.start-timepoints(1); %find value in data.Stimulus that most closely matches timepoints 
    startidx(startidx<0)=NaN; 
    startidx=find(startidx==min(startidx)); 
    endidx = data.Stimulus.end-plottime(end); 
    %endidx(endidx<0)=NaN; 
    endidx=find(abs(endidx)==min(abs(endidx))); 
    
    starts = data.Stimulus.start(startidx:endidx)-timepoints(1); 
    ends = data.Stimulus.end(startidx:endidx)-timepoints(1); 
else  % if not consecutive 
    breaks = find(diff(timepoints)~=1); 
    for i = 1:length(breaks)
        diff_times =  timepoints(breaks(i)) - data.Stimulus.start; 
        diff_times(diff_times<0)=NaN; 
        startidx(i)= find(diff_times==min(diff_times))+1; 
        starts(i)=plotted_times(breaks(i));  
       
    end
    ends = starts; 
    endidx=startidx;

end

%% PLOT TRACES 
figure(1)
clf
utils.sf('fontsize',20)
hold on 

%stretch=1; 

if opt.dimension == 2 
    %--------- 2D
    for i = 1:opt.nneurons 
        if inc_issp(i)
            plot(movmean(incl_cells(i+opt.nshift,plottime),opt.avgwindow)*opt.stretch-i*offset,'color','r','LineWidth',opt.linewidth)
        elseif ~inc_issp(i)
            plot(movmean(incl_cells(i+opt.nshift,plottime),opt.avgwindow)*opt.stretch-i*offset)
        end
    end
    xline(ends,'LineStyle','--','LineWidth',3,'Alpha',.2)
    xline(starts,'k','LineWidth',3,'Alpha',.2)
    ylabel('dF/F')

end

%% EDIT FIGURE 
if strcmp(opt.labeltype,'time')
    if unique(diff(plottime))== 1 
        xticks(mean([starts,ends],2))
        xticklabels(data.Stimulus.stimulus(startidx:end))     
    else 
        xticks(starts)
        xticklabels(data.Stimulus.stimulus(startidx)) 
    end
elseif strcmp(opt.labeltype,'stimuli')
    xticks(1:300*data.fps:length(plottime));
    xlabels=1:length(plottime)/300*data.fps; xlabels=(xlabels-1)*5; 
    xticklabels(xlabels)
end


planes= unique(d.pidx);
yticklabels(num2str(planes)); 


title({t,['Dataset #',num2str(d.tag)]})
yticks([])
xlabel('Time (Minutes)')

%% NOTES 
% need to add flexibilty such that if you plot neuron indices that are
% outside of a plane, it won't plot the xlines and plane numbers 
