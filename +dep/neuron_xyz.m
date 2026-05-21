function [xyz,xyp,id_vect] = neuron_xyz(id_vect_full,Fall,ypix_zplane,depth,zlocs)
arguments
    id_vect_full double % vector of length sum(Fall.iscell(:,1)==1)
    Fall struct % structure with all of the outputs from Fall.mat
    ypix_zplane cell % has the depth for each y pixel in each plane 
    depth struct % output from dep.findRedSurfaceDepth
    zlocs double % converts plane location to depth 
end

%% REDUCE ID_VECT_FULL
cellstat = Fall.cellstat(id_vect_full~=4); 
id_vect= id_vect_full(id_vect_full~=4); 

%% CALCULATE DEPTH 
xyz= nan(length(cellstat),3); 
xyp= nan(length(cellstat),3); 

for i = 1:length(cellstat)
    yx = cellstat{i}.med; 

    % adjust coordinates from concatenated image to   
    if yx(1)> size(Fall.ops.refImg,1)
        yx(1)=yx(1)-size(Fall.ops.refImg,1); 
    end

    if yx(2) > size(Fall.ops.refImg,2)
        yx(2) = yx(2)-size(Fall.ops.refImg,2); 
    end
    %------------------------------------------
    zoff = depth.surfaceMapSmooth(yx(1),yx(2)); 
    plane = cellstat{i}.iplane+1;  

    yz = ypix_zplane{plane}; 
    z = zlocs(yz(yx(1))); % zlocation for plane/ ypixel 
    xyz(i,:)=[yx(2) yx(1) z-round(zoff)];
    xyp(i,:)=[yx(2) yx(1) yz(yx(1))];

end


%%