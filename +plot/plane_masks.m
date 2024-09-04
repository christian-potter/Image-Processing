function plane_masks(p,ops,stat,prct_thresh,id_vect,opt)
arguments
    p double 
    ops struct
    stat cell 
    prct_thresh double 
    id_vect (:,1) double
    opt.mode string = 'Separate'
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

redwin= ops.meanImg_chan2(rshift+1:rshift+planesize(1),cshift+1:cshift+planesize(2)); 
greenwin= ops.meanImg(rshift+1:rshift+planesize(1),cshift+1:cshift+planesize(2)) ; 

%redwin= redwin.*rg_gain(1); 
%greenwin=greenwin.*rg_gain(2); 

rgwindow(:,:,1)=redwin;rgwindow(:,:,2)=greenwin;rgwindow(:,:,3)=zeros(planesize(1),planesize(2)); 
%percentile normalize 
%thresh= prctile(rgwindow(:),prct_thresh); 
thresh=prct_thresh; 


%rgwindow(rgwindow>thresh)= thresh; 

rgwindow=rgwindow./max(rgwindow); 


%% PLOT IMAGE 
if strcmp(opt.mode,'Separate')
    figure(1)
    clf

    subplot(2,1,1)
    imshow(redwin) 
    clim([0 max(max(redwin(:)))/thresh(1)])
    hold on
    title('Red Channel')

    subplot(2,1,2)
    imshow(greenwin)
    clim([0 max(max(greenwin(:)))/thresh(2)])
    title('Green Channel')
    hold on 


end

sgtitle({'Masks',['Plane: ',num2str(p)]},'FontSize',20)

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
        mask_colors(:,i)=[1 1 0]; 
    end
end


%% CALULATE THE SHIFT IN IDX  
idxshifts=0;

for i = 1:nplanes 
    idxshifts=[idxshifts,find(diff(roi_planeidx)==1)]; 
    
end
%%
subplot(2,1,1)
plot.mask_boundaries(mask_colors,maskcoords(roi_planeidx==p),[cshift,rshift],idxshifts(p)); 
plot.set_figure(15,'any')

subplot(2,1,2)
plot.mask_boundaries(mask_colors,maskcoords(roi_planeidx==p),[cshift,rshift],idxshifts(p)); 
plot.set_figure(15,'any')

