function [nimage,x1,y1,cutoff] = roi_surround(image,roi,stat,surround,ops,opt)
arguments 
    image double % individual rgb image. Either one plane or zstack
    roi double % idx of ROI to crop around 
    stat cell 
    surround double % scalar for how much to grab in each direction around median   
    ops % for crshift coordinates 
    opt.zstack_drift double = [0,0]; % if plotting the zstack, this aligns offset to functional 
    opt.plane double % current plane 
  
end

%-- outputs
% nimage: cropped image 
% x1: leftmost coordinate
% y1: topmost coordinate
% cutoff: (x,y) to report if there was any image that was cropped
    % * use these to recenter ROI on cutoff image
    % (-) = cutoff left or above ROI 
    % (+) = cutoff right or below ROI 
    % ** will need at some point if you want to center ROI on the cropped
    % image when there is cutoff 
%% DESCRIPTION 
% function that takes either single plane image or z-stack and crops it 

%% MAKE VARIABLES 
zs_xshift = opt.zstack_drift(1); zs_yshift = opt.zstack_drift(2); % z-stack adjustment, if it exists 
image_plane = image(:,:,1,1);
dims = size(image_plane);dims =flip(dims); % max dimensions to correct for if surround is off 
cstat=stat{roi};
cutoff =[0,0]; % assume surround does not require a cutoff 

if isfield(opt,'plane')
    [plane_crshift]=get.crshift(ops,opt.plane);
else
    plane_crshift=[0,0]; 
end

%% DETERMINE BOUNDARIES 
x1= min(cstat.xpix-plane_crshift(1))-surround+zs_xshift;
if x1 < 1
    cutoff(1)= x1-1; 
    x1=1; 
end

x2= max(cstat.xpix-plane_crshift(1))+surround+zs_xshift; 
if x2 > dims(1)
    cutoff(1)= x2-dims(1); 
    x2=dims(1); 
end

y1= min(cstat.ypix-plane_crshift(2))-surround+zs_yshift; 
if y1 < 1
    cutoff(2) = y1-1; 
    y1=1; 
end

y2= max(cstat.ypix-plane_crshift(2))+surround+zs_yshift; 
if y2 > dims(2)
   cutoff(2) = y2-dims(2); 
    y2=dims(2);   
end
%% CROP IMAGE
for i = 1:size(image,3)
    for j = 1:size(image,4)
        nimage(:,:,i,j) = imcrop(image(:,:,i,j),[x1 y1 x2-x1 y2-y1]); 
    end
end


%% DECIDE IF CROPPED OR NOT 

if surround > 0 
    nimage = squeeze(nimage); 
elseif surround == 0
    nimage= image; 
    x1 = 0; y1= 0; 
end

%%


