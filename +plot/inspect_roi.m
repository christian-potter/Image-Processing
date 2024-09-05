function [] = inspect_roi(roi,cstat,surround,ops,stat)

%% DETERMINE SELECTED AREA TO PLOT 
dims = size(ops.meanImg); 

selection = zeros(dims); 

x1= min(cstat.xpix)-surround; 
if x1 < 1
    x1=1; 
end

x2= max(cstat.xpix)+surround; 
if x2 > dims(1)
    x2=dims(1); 
end

y1= min(cstat.xpix)-surround; 
if y1 < 1
    y1=1; 
end

y2= max(cstat.xpix)+surround; 
if y2 > dims(2)
    y2=dims(2); 
end

selection(x1:x2,y1:y2)=1; 
%%

[maskcoords]=get.mask_coordinates(stat); 

%% PLOT SELECTION 
figure(3)

clf 

subplot(2,1,1)
title('Green Image')
imshow(ops.meanImg(selection==1))
hold on 
plot.mask_boundaries([1 0 1]',maskcoords(roi),[x1,y2],roi,'idxtype','specified');

subplot(2,1,2)
title('Red Image')
imshow(ops.meanImg_chan2(selection==1))
hold on 
plot.mask_boundaries([1 0 1]',maskcoords(roi),[x1,y2],roi,'idxtype','specified'); 


utils.set_figure(15,'any')



sgtitle(['ROI#: ',num2str(roi)])

