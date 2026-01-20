function [ypix_zplane] = fa_alignment(ypix_zdist,zlocs,tseries_md,zstack_md)
arguments
    ypix_zdist cell % 
    zlocs double % vector where each entry is the estimated distance of 
    tseries_md struct 
    zstack_md struct 
end

%% DESCRIPTION 
% takes output from fa_zstack_maps and aligns them into cell array that
% specifies the actual zplane in the anatomical that corresponds with the
% functional image 

%% NOTES 

% 

%% GET CLOSEST ZSTACK PLANE FOR EACH ROW OF TSERIES YPIXELS 
ypix_zplane = cell(1,tseries_md.nplanes);

% assign each ypix to a plane 
for p = 1:tseries_md.nplanes
    y_zmap = nan(1,tseries_md.ypix); 
    curypix_zdist = ypix_zdist{p}; 
    
    for y = 1:tseries_md.ypix % for each yrow, find the closest anatomical zplane 
        offsets=abs(zlocs-curypix_zdist(y)); 
        zloc = find(offsets==min(offsets)); 
        y_zmap(y) = zloc; 
    end
    ypix_zplane{p}=y_zmap;

end
