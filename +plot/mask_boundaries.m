function [] = mask_boundaries(mask_colors,maskcoords,planeshift,idxstart,opt)

arguments
    mask_colors double
    maskcoords cell  
    planeshift double %correct s2p coordinates to individual image(functional or z-stack)
    idxstart double 
    opt.idxtype string = 'shifted'
    opt.masktype string = 'outline'
    opt.crop_x1y1 double =[0, 0]; % gives top-left point of cropped image relative to individual image 
    opt.image
    
end

%% DESCRIPTION 

%% DETERMINE PLOT TYPE 

if strcmp(opt.masktype,'outline')
    marker = '.';
    ls = '-'; 
elseif strcmp(opt.masktype,'mask')
    marker='.';
    ls ='none'; 
end

%% DETERMINE TOTAL SHIFT 

totalshift = planeshift - opt.crop_x1y1; 

%% PLOT MASKS LOOP
for i = 1:length(maskcoords)
    xcoords=maskcoords{i}(:,1); ycoords=maskcoords{i}(:,2); 
    adj_xc = xcoords+totalshift(1); adj_yc= ycoords+totalshift(2); 
    
    if strcmp(opt.idxtype,'shifted')
        plot(adj_xc,adj_yc,'Color',mask_colors(:,i+idxstart),'LineWidth',2,'Marker',marker,'LineStyle',ls)
        text(max(adj_xc)+1,max(adj_yc)+1,num2str(i+idxstart),'Color',mask_colors(:,i+idxstart),'FontSize',12,'FontWeight','bold') % make text of ROI index
        
    elseif strcmp(opt.idxtype,'specified')
        plot(adj_xc,adj_yc,'Color',mask_colors(:,i),'LineWidth',2,'Marker',marker,'LineStyle',ls)
        text(max(adj_xc)+1,max(adj_yc)+1,max(ycoords)+1-totalshift(2),num2str(idxstart),'Color',mask_colors(:,i),'FontSize',12,'FontWeight','bold') % make text of ROI index
    end

end
