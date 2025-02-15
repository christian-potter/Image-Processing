function [nimage,x1,y1] = roi_surround(image,roi,stat,surround,xyshift,p)
xshift = xyshift(1); yshift = xyshift(2); 

image_plane = image(:,:,1,1);
dims = size(image_plane); 

cstat=stat{roi};
%% GET CRSHIFT FOR PLANE


%% DETERMINE BOUNDARIES 
x1= min(cstat.xpix)-surround+xshift;
if x1 < 1
    x1=1; 
end

x2= max(cstat.xpix)+surround+xshift; 
if x2 > dims(1)
    x2=dims(1); 
end

y1= min(cstat.ypix)-surround+yshift; 
if y1 < 1
    y1=1; 
end

y2= max(cstat.ypix)+surround+yshift; 
if y2 > dims(2)
    y2=dims(2); 
end

%% CROP IMAGE
for i = 1:size(image,3)
    for j = 1:size(image,4)
        nimage(:,:,i,j) = imcrop(image(:,:,i,j),[x1 y1 x2-x1 y2-y1]); 
    end
end
