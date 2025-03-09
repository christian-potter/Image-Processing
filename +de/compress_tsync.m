function [ntsync] = compress_tsync(tsync,nframes)

%% DESCRIPTION
%function that averages tsync vectors 

field = fields(tsync); 

select= [1 2 3 4 5 8 9 11]; 

for f = 1:length(field)
    vect = tsync.(field{f}); 
    compress_vect = nan(nframes,1); 

    for i = 1:nframes
        curframes = tsync.framecount ==i-1; % framecounts starts at 0
        compress_vect(i) = mean(vect(curframes)); 

    end
    ntsync.(field{f})= compress_vect; 
end


