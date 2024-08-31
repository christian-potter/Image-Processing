function plane_masks(p,ops,stat,thresh,in_vect,ex_vect,proj_vect)

%% RECOGNIZE NUMBER OF PLANES 

for i = 1:length(stat)
    curstat= stat{i}; 
    roi_planeidx(i)=curstat.iplane+1; % add 1 to the plane 
end

nplanes = length(unique(roi_planeidx)); 


%%  DETERMINE WHICH PART OF THE TOTAL IMAGE TO PLOT 


planesize= size(ops.refImg);

cshift=0; 
if mod(p,2)==0
    cshift=planesize(2);
end 

rshift=floor((p-1)/2)*planesize(1); 
redwin= ops.meanImg_chan2(rshift+1:rshift+planesize(1),cshift+1:cshift+planesize(2)); 


%% PLOT IMAGE 
figure(1)
clf
imshow(redwin)
clim([0 max(max(ops.meanImg))/thresh])
hold on

%% GET MASKS / DETERMINE COLOR
[maskcoords]=get.mask_coordinates(stat); 

mask_colors= nan(3,length(in_vect)); 

for i = 1:size(mask_colors,2)
    if in_vect(i)
        mask_colors(:,i)=[0 0 1]; 
    elseif ex_vect(i)
        mask_colors(:,i)=[1 0 0]; 
    elseif proj_vect(i)
        mask_colors(:,i)=[0 1 0]; 
    end
end


%% CALULATE THE SHIFT IN IDX  
idxshifts=0;

for i = 1:nplanes 
    idxshifts=[idxshifts,find(diff(roi_planeidx)==1)]; 
    
end
%%
plot.mask_boundaries(mask_colors,maskcoords(roi_planeidx==p),[cshift,rshift],idxshifts(p)); 
title({'Masks',['Plane: ',num2str(p)]})