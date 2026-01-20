function [ypix_zplane] = modify_alignment(zlocs,ypix_zdist,stat,ref_cell,tseries_md,zstack_md)
arguments 
    zlocs double  % unaligned output of fa_zstack_maps
    ypix_zdist cell  % "" "" for tseries
    stat cell 
    ref_cell double % vector with cell_id and corresponding zplane that it appears on 
    tseries_md struct
    zstack_md struct 
end


%% DESCRIPTION
% additional step in the pipeline that adjusts the mapping between
% functional and anatomical distance based on the observed locations of
% neurons in the zstack 

%% NOTES
%* need to make this work on multiple cells across multiple planes 


%% GET REFERENCE CELL COORDINATES 
s = stat{ref_cell(1)}; % open stat for ref_cell 

rc_y = s.med;
rc_y=rc_y(1);% r x c = yx  
rc_plane = s.iplane+1; 

rc_z = ypix_zdist{rc_plane};
rc_z=rc_z(rc_y); %index y coordinate  


%% TAKE REFERENCE POINT IN ANATOMICAL STACK AND SHIFT EVERYTHING TO CORRESPOND 
anat_ref = zlocs(ref_cell(2)); % this point should be changed to correspond with rc_z 
dif = anat_ref - rc_z ; 

zlocs = zlocs - dif; 

ypix_zplane = dep.fa_alignment(ypix_zdist,zlocs,tseries_md,zstack_md); 




