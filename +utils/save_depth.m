function [] = save_depth(dsnum,xyz,zlocs,ypix_zplane,depth,zrgb,ref_cell)

arguments
    dsnum double 
    xyz double % each row contains the x,y,z coordinates of each cell 
    zlocs double % depth from surface each plane is (not accounting for XY location) 
    ypix_zplane cell % microscope metadata projection of where each plane would be depth-wise 
    depth struct % output of dep.findRedSurfaceDepth
    zrgb double % modified dimension matrix for rgb (x x y x z x rgb ) 
    ref_cell double % cell(s) used to align z-stack to metadata 
end


%% SET BASE PATH 

if ispc
    base =  ['\\Shadowfax\Warwick\DRGS\#',num2str(dsnum),'\SDH\Processed\Depth\']; 
else
    base =  ['/Volumes/Warwick/DRGS/#',num2str(dsnum),'/SDH/Processed/Depth/']; 
end


%% SAVE 

save([base,'xyz.mat'],'xyz')
save([base,'depth.mat'],'depth')
save([base,'ypix_zplane.mat'],'ypix_zplane')
save([base,'zlocs.mat'],'zlocs')
save([base,'zrgb.mat'],'zrgb')
save([base,'ref_cell.mat'],'ref_cell')

