function [ypix_zdist,zlocs] = fa_zstack_maps(tseries_md,zstack_md,tsync)
arguments 
    tseries_md struct % metadata from tseries 
    zstack_md struct 
    tsync table % * using compressed tsync 
   
end

%% DESCRIPTION 
% makes estimates for the locations of the functional and anatomical z
% positions are located based on microscope estimates 

%OUTPUTS
% ypix_zdist: 1 x nplanes cell array where each entry in a cell is the
% distance from the surface in microscope coordinates 

% zlocs : initial estimate of zstack depth based on microscope metadata

%%
totalzdist =  tseries_md.stepSize*tseries_md.nplanes/1000; %total distance of z-stack (stepsize * nplanes)

%% 
plane_zranges = nan(tseries_md.nplanes,2); 
piezoprop = 0; 
%- get distance moved by the piezo for first frames 
% ** this assumes piezo moves at linear rate** 
for p = 1:tseries_md.nplanes
    curframes = tsync.framecount==p; 
    curpiezo = tsync.piezo(curframes); 
    curpdist = curpiezo(end)-curpiezo(1); % distance at beginning and end of frame 
    piezoprop(p+1) = curpdist/totalpdist; % proprotion of the total distance covered 
end
%------ DISTANCE COVERED BY THE PIEZO PER FRAME 
covered_range = 0;% cumulative distance over frames 
for p = 1:tseries_md.nplanes
    planezdist= tseries_md.startPos + totalzdist*piezoprop(p); % starting point + proportion of covered distance per frame (first frame is less)
    plane_zranges(p,1)= covered_range; 
    plane_zranges(p,2)= piezoprop(p+1)*totalzdist+covered_range; 
    covered_range = plane_zranges(p,2);
end


%% GIVES TSERIES POSITION IN TERMS OF TSERIES Y PIXELS ONLY
ypix_zdist = cell(1,tseries_md.nplanes);  
for p = 1:tseries_md.nplanes
    curzdists = nan(1,tseries_md.ypix); 
    zrange = plane_zranges(p,:); 
    zvals = linspace(zrange(1),zrange(2),tseries_md.ypix);% generate line between endpoints for each ypixel  
    ypix_zdist{p}= zvals; % gives z-distance where lower values are surface of DH 
end

%% --    
% --- ZSTACK ESTIMATE 
%% 

%% GET POSITION OF EACH ZSTACK FRAME 
zlocs = nan(1,zstack_md.nplanes);
%get zloc of each plane 

for z =  1:zstack_md.nplanes
    zlocs(z)= zstack_md.startPos + 1/1000*z*zstack_md.step_size; % step size needs to be coverted to mm with 1/1000 
end




end