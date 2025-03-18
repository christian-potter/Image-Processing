function [] = selected_traces(plottimes,labels,selected_label,d,data,opt)
    arguments
        plottimes(1,:) double
        labels (1,:) double
        selected_label(1,:) double 
        d struct
        data struct
        opt.include (1,:) logical = logical(ones(1,size(d.sdff,1))>0)
        opt.t string = ['Traces From Cluster #',num2str(selected_label),' During TTX ONLY'];
        opt.dimension double = 2 
        opt.avgwindow double = 15
        opt.labeltype string='stimuli' % can also be "time"
        opt.linewidth double = 1; 
        opt.stretch double =1; 
    end


%% GET PROPER INDEXING
selected_neurons = find(opt.include==true); 
idxs= selected_neurons(labels==selected_label); 

plot_traces=logical(ones(1,length(opt.include))==0);
plot_traces(idxs)=true; 

%% PLOT TRACES

plot.traces(plottimes,opt.t,d,data,'include',plot_traces,'dimension',opt.dimension,'avgwindow',opt.avgwindow,'labeltype',opt.labeltype,'linewidth',opt.linewidth,'stretch',opt.stretch)

%% 

