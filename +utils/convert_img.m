function [converted] = convert_img(img)
% Converts tiff 

count = 1; 
converted = nan(size(img,1),size(img,2),3,size(img,3)/2); 

for i = 1:2:size(img,3)
    red = utils.normalize_img(img(:,:,i)); 
    green = utils.normalize_img(img(:,:,i+1)); 
    blue = zeros(size(img,1),size(img,2)); 

    converted(:,:,1,count)=red; converted(:,:,2,count)=green; converted(:,:,3,count)=blue; 
    count = count+1; 

end




