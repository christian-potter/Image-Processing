function [roi_planeidx,idxshifts,nplanes] = roipidx_shift(cellstat)


%%
for i = 1:length(cellstat)
    curstat= cellstat{i}; 
    roi_planeidx(i)=curstat.iplane+1; % add 1 to the plane 
end

nplanes = length(unique(roi_planeidx));

%%


idxshifts=0;
idxshifts=[idxshifts,find(diff(roi_planeidx)==1)]; 