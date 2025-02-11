function [converted] = convert_img(img)
% Converts tiff 

%% 
if size(img,4)==1
    
    count = 1; 
    converted = nan(size(img,1),size(img,2),3,size(img,3)/2); 
    
    for i = 1:2:size(img,3)
        red = utils.normalize_img(img(:,:,i)); 
        green = utils.normalize_img(img(:,:,i+1)); 
        blue = zeros(size(img,1),size(img,2)); 
    
        converted(:,:,1,count)=red; converted(:,:,2,count)=green; converted(:,:,3,count)=blue; 
        count = count+1; 
    
    end

elseif size(img,4)==3 
    converted = nan(size(img,1),size(img,2),3,size(img,3)); 
    converted(:,:,1,:)= img(:,:,:,1); 
    converted(:,:,2,:)= img(:,:,:,2); 
    converted(:,:,3,:)= img(:,:,:,3); 
   
end



