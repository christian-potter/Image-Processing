function [gclim, rclim] = roi_mask(roi,stat,surround,ops,maskcoords,g_thresh,r_thresh)
arguments
    roi double 
    stat cell
    surround double 
    ops struct
    maskcoords cell 
    g_thresh double %'1' will trigger auto clim 
    r_thresh double 
end


%% DETERMINE SELECTED AREA TO PLOT 
dims = size(ops.meanImg); 
cstat=stat{roi};

x1= min(cstat.xpix)-surround; 
if x1 < 1
    x1=1; 
end

x2= max(cstat.xpix)+surround; 
if x2 > dims(1)
    x2=dims(1); 
end

y1= min(cstat.ypix)-surround; 
if y1 < 1
    y1=1; 
end

y2= max(cstat.ypix)+surround; 
if y2 > dims(2)
    y2=dims(2); 
end

greenwin= imcrop(ops.meanImg,[x1 y1 x2-x1 y2-y1]); 
redwin= imcrop(ops.meanImg_chan2,[x1 y1 x2-x1 y2-y1]); 


%% PLOT SELECTION 
figure(3)
clf 
subplot(2,1,1)
imshow(greenwin)

if isscalar(g_thresh)
    clim('auto'); 
    gclim= clim; 
    clim(gclim*g_thresh)
    gclim= clim; 
else
    clim(g_thresh)
    gclim = g_thresh; 
end

hold on 
plot.mask_boundaries([1 0 1]',maskcoords(roi),[x1,y1],roi,'idxtype','specified');
title("Green Channel")
utils.sf('fontsize',15)

subplot(2,1,2)
imshow(redwin)
if isscalar(r_thresh)
    clim('auto'); 
    rclim= clim; 
    clim(rclim*r_thresh)
    rclim= clim; 
else
    clim(r_thresh)
    rclim= r_thresh; 
end

hold on 
plot.mask_boundaries([1 0 1]',maskcoords(roi),[x1,y1],roi,'idxtype','specified'); 
title("Red Channel")

utils.sf('fontsize',15)

sgtitle(['ROI#: ',num2str(roi)],'FontSize',15)

