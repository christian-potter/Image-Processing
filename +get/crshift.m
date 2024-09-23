function [crshift] = crshift(ops,p)

% returns the column and row shift for each plane relative to the combined
% image

planesize= size(ops.refImg);

cshift=0; 
if mod(p,2)==0
    cshift=planesize(2);
end 
rshift=floor((p-1)/2)*planesize(1); 

crshift(2)=rshift; 
crshift(1)=cshift;
