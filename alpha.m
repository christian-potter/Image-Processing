function [] = alpha(img,cellid,stat,varargin)
arguments
    img double % sample image you want corrected (zstack or functional image)
    cellid double % chosen cellids that almost certainly do not contain a red fluorophore
    stat % s2p output
    varargin double % n of zplane if it is a zstack  

end


truegreenpix=[]; 

for i = 1:length(cellid)
    




end