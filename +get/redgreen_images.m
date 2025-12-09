function [redwin,greenwin]= redgreen_images(anatomical,functional,ops,crshift) 


%% DESCRIPTION 
% takes ops file and returns redwin/ greenwin based on what image type is
% requested and the crshift for that given plane 



%% CREATE VARIABLES 
planesize= [size(ops.refImg,1) size(ops.refImg,2)]; 



%% FUNCTIONAL IMAGE 

if strcmp(anatomical,'mean')
    redwin= ops.meanImg_chan2(crshift(2)+1:crshift(2)+planesize(1),crshift(1)+1:crshift(1)+planesize(2)); 
elseif strcmp(anatomical,'corrected')
    redwin= ops.meanImg_chan2_corrected(crshift(2)+1:crshift(2)+planesize(1),crshift(1)+1:crshift(1)+planesize(2)); 
else
    disp(['Input not recognized, defaulting to mean',char(10)])
    redwin= ops.meanImg_chan2(crshift(2)+1:crshift(2)+planesize(1),crshift(1)+1:crshift(1)+planesize(2)); 
end
%% ANATOMICAL IMAGE 

if strcmp(functional,'mean')
    greenwin= ops.meanImg(crshift(2)+1:crshift(2)+planesize(1),crshift(1)+1:crshift(1)+planesize(2)) ; 
elseif strcmp(functional,'enhanced') 
    greenwin= ops.meanImgE(crshift(2)+1:crshift(2)+planesize(1),crshift(1)+1:crshift(1)+planesize(2)) ; 
elseif strcmp(functional,'correlation') 
    greenwin= ops.Vcorr(crshift(2)+1:crshift(2)+planesize(1),crshift(1)+1:crshift(1)+planesize(2)) ; 
elseif strcmp(functional,'max') 
    greenwin= ops.max_proj(crshift(2)+1:crshift(2)+planesize(1),crshift(1)+1:crshift(1)+planesize(2)) ; 
else
    disp(['Input not recognized, defaulting to mean',char(10)])
    greenwin= ops.meanImg(crshift(2)+1:crshift(2)+planesize(1),crshift(1)+1:crshift(1)+planesize(2)) ;
end
