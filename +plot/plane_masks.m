function [gclim,rclim]= plane_masks(p,ops,stat,g_thresh,r_thresh,id_vect,roi_planeidx,functional,anatomical,opt)
arguments
    p double 
    ops struct
    stat cell 
    g_thresh 
    r_thresh     
    id_vect (:,1) double
    roi_planeidx double 
    functional string 
    anatomical string 
    opt.mode string = 'separate'    
end

%% RECOGNIZE NUMBER OF PLANES 

for i = 1:length(stat)
    curstat= stat{i}; 
    roi_planeidx(i)=curstat.iplane+1; % add 1 to the plane 
end

nplanes = length(unique(roi_planeidx)); 


%%  DETERMINE WHICH PART OF THE TOTAL IMAGE TO PLOT 
% get info for row and column shifts for each imaging plane relative to the
% larger combined image 

planesize= size(ops.refImg);

cshift=0; 
if mod(p,2)==0
    cshift=planesize(2);
end 
rshift=floor((p-1)/2)*planesize(1); 

if strcmp(anatomical,'mean')
    redwin= ops.meanImg_chan2(rshift+1:rshift+planesize(1),cshift+1:cshift+planesize(2)); 
elseif strcmp(anatomical,'corrected')
    redwin= ops.meanImg_chan2_corrected(rshift+1:rshift+planesize(1),cshift+1:cshift+planesize(2)); 
else
    disp(['Input not recognized, defaulting to mean',char(10)])
    redwin= ops.meanImg_chan2(rshift+1:rshift+planesize(1),cshift+1:cshift+planesize(2)); 
end

if strcmp(functional,'mean')
    greenwin= ops.meanImg(rshift+1:rshift+planesize(1),cshift+1:cshift+planesize(2)) ; 
elseif strcmp(functional,'enhanced') 
    greenwin= ops.meanImgE(rshift+1:rshift+planesize(1),cshift+1:cshift+planesize(2)) ; 
elseif strcmp(functional,'correlation') 
    greenwin= ops.Vcorr(rshift+1:rshift+planesize(1),cshift+1:cshift+planesize(2)) ; 
elseif strcmp(functional,'max') 
    greenwin= ops.max_proj(rshift+1:rshift+planesize(1),cshift+1:cshift+planesize(2)) ; 
else
    disp(['Input not recognized, defaulting to mean',char(10)])
    greenwin= ops.meanImg(rshift+1:rshift+planesize(1),cshift+1:cshift+planesize(2)) ;
end

% Red-green merge 
rgwin(:,:,1)=redwin;rgwin(:,:,2)=greenwin;rgwin(:,:,3)=zeros(planesize(1),planesize(2)); 

rgwin=rescale(rgwin);
%rgwin=uint16(rgwin); 

%% PLOT IMAGE 
if strcmp(opt.mode,'separate')
    figure(1)
    clf
    subplot(2,1,1)
    imshow(greenwin) 
    
    if isscalar(g_thresh)
        clim('auto')
        gclim = clim;
        clim(gclim/g_thresh)
        gclim = clim;
    else 
        clim(g_thresh)
        gclim=g_thresh; 
    end
    hold on
    title('Functional Channel')

    subplot(2,1,2)
    imshow(redwin)
    if isscalar(r_thresh)
        clim('auto')
        rclim = clim;
        clim(rclim/r_thresh)
        rclim = clim;
    else 
        clim(r_thresh)
        rclim=r_thresh; 
    end
    title('Anatomical Channel')
    hold on 

elseif strcmp(opt.mode,'combined')
    figure(1)
    clf
    imshow(rgwin)
    hold on 
    if isscalar(r_thresh) && isscalar(g_thresh)
        clim('auto')
        rclim = clim;
        clim(rclim/r_thresh)
        rclim = clim;
        gclim = rclim;  
    else
        clim(r_thresh)
        rclim=r_thresh; 
        gclim = rclim; 
    end
    
% can add combined green/red image here 
end

%% GET MASKS / DETERMINE COLOR
[maskcoords]=get.mask_coordinates(stat); 

mask_colors= nan(3,length(id_vect)); 

for i = 1:size(mask_colors,2)
    if id_vect(i)==2
        mask_colors(:,i)=[0 0 1]; 
    elseif id_vect(i)==1
        mask_colors(:,i)=[1 0 0]; 
    elseif id_vect(i)==0
        mask_colors(:,i)=[0 1 0]; 
    elseif id_vect(i)==3
        mask_colors(:,i)=[1 0 1]; 
    end
end


%% CALULATE THE SHIFT IN IDX  
idxshifts=0;
idxshifts=[idxshifts,find(diff(roi_planeidx)==1)]; 
    

%%
if strcmp(opt.mode,'separate')

    subplot(2,1,1)
    plot.mask_boundaries(mask_colors,maskcoords(roi_planeidx==p),[cshift,rshift],idxshifts(p)); 
    plot.set_figure(15,'any')
    
    subplot(2,1,2)
    plot.mask_boundaries(mask_colors,maskcoords(roi_planeidx==p),[cshift,rshift],idxshifts(p)); 
    plot.set_figure(15,'any')
    
    sgtitle({['Plane: ',num2str(p)]},'FontSize',20)

elseif strcmp(opt.mode,'combined')

    plot.mask_boundaries(mask_colors,maskcoords(roi_planeidx==p),[cshift,rshift],idxshifts(p)); 
    plot.set_figure(15,'any')
    title({['Plane: ',num2str(p)]},'FontSize',20)

end

