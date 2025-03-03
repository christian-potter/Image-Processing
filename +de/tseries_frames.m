function [frames_tseries]= tseries_frames(ops)
%% DESCRIPTION
%function that takes the number of frames per t-series from the stack-split
%files 

%%
count =1; 
curframesum=ops.frames_per_file(1); %start at 2
frames_tseries=[]; 
for i = 2:size(ops.filelist,1) 
    curfolder = str2double(ops.filelist(i,[end-9, end-8])); 
    prevfolder = str2double(ops.filelist(i-1,[end-9, end-8])); 

    if curfolder == prevfolder
        curframesum=curframesum+ops.frames_per_file(i); 
        frames_tseries(count)=curframesum; % account for only 1 split per file, which will be overwritten 
    elseif curfolder>prevfolder || i== size(ops.filelist,1)    
        frames_tseries(count)=curframesum; 
        count = count+1;
        curframesum=ops.frames_per_file(i);
    end

end
