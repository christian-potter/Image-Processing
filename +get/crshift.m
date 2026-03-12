function [crshift] = crshift(ops,p)
% p should start at 1 (stat starts at 0 by default)

% returns the column and row shift for each plane relative to the combined
% image

% allows you to go from the larger ops.refImg size to the individual plane
% size 

planesize= size(ops.refImg);

cshift=0; 
if mod(p,2)==0
    cshift=planesize(2);
end 
rshift=floor((p-1)/2)*planesize(1); 

crshift(2)=rshift; 
crshift(1)=cshift;
