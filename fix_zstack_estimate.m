function [] = fix_zstack_estimate(new_coordmap,zstack_md,tlapse_md,ypix_zplane,stat)
arguments 
    new_coordmap double % vector with cell_id and corresponding z-stack frame 
    zstack_md struct 
    tlapse_md struct 
    ypix_zplane cell 
    stat cell 
end

%% DESCRIPTION 
% initial estimate of the location in the zstack of the can be off. This
% takes the location of the first cell (ROI #1) and uses that to adjust the
% estimate 

%% NOTES
% ypix_zdist is in microscope-generated coordinates, where a lower value
% is closer to the top. will be mirror image of plotted schematic by
% load_drgs 


%% RECALCULATE YPIX_ZPLANE 
% change zlocs so that it is reoriented to coincide with the plane the
% first cell appears on 

totalpdist = tsync.piezo(allplanes(end))-tsync.piezo(allplanes(1));% distance of functional planes 

%% 




%% REFERENCE POSITION OF ZSTACK 
refcell_xy = stat{new_coordmap(1)}.med; 





