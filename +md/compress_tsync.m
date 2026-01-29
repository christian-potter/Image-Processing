function [tsync] =  compress_tsync(direct,tseries_md,opt)
arguments 
    direct string % address of directory 
    tseries_md struct % metadata for tseries 
    opt.stopped_early double= 0;  
end
%% NOTES 
% *determine which frames stopped early by consulting frames_per_tseries
% and seeing which tseries have an unexpected number of frames 


%% GO TO/ RETURN FROM DIRECTORY 
rf = cd; 
cd(direct)
direct = dir; 
cd(rf)
%% CREATE VARIABLES 
bin = tseries_md.nplanes+tseries_md.flybackFrames; 

%% INDEX THROUGH H5 FILES

ts_start=0;
count = 1;

for d = 1:length(direct)
    if contains(direct(d).name,'TS')
        [ntsync]= md.read_h5([direct(d).folder,'/',direct(d).name]);
        ntsync = md.averageByFramecount(ntsync,bin);  
        ntsync.tseries = ones(size(ntsync,1),1)*count; % label entries as coming from a t-series 
        
        if ismember(d,opt.stopped_early)
            ntsync(end-9:end,:)=[];  % estimate how many frames are lost by tseries ending early 
        end

        if ts_start ==0 % 
            tsync = ntsync; 
            ts_start=1; 
        elseif ts_start ==1
            tsync=[tsync;ntsync]; 
        end

        count = count+1; 

    end
end



%% 



