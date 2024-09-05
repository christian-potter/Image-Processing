function [] = mask_boundaries(mask_colors,maskcoords,planeshift,idxshift,opt)

arguments
    mask_colors double
    maskcoords cell  
    planeshift double
    idxshift double 
    opt.idxtype string = 'shifted'
end

%% PLOT MASKS LOOP
for i = 1:length(maskcoords)
    xcoords=maskcoords{i}(:,1); ycoords=maskcoords{i}(:,2); 
    plot(double(xcoords)-planeshift(1),double(ycoords)-planeshift(2),'Color',mask_colors(:,i),'LineWidth',2)
    if strcmp(opt.idxtype,'shifted')
        text(max(xcoords)+1-planeshift(1),max(ycoords)+1-planeshift(2),num2str(i+idxshift),'Color',mask_colors(:,i)) % make text of ROI index
    elseif strcmp(opt.idxtype,'specified')
        text(max(xcoords)+1-planeshift(1),max(ycoords)+1-planeshift(2),num2str(specified(i)),'Color',mask_colors(:,i)) % make text of ROI index
    end

end
