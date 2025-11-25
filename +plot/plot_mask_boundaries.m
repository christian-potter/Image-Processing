function []=plot_mask_boundaries(backgroundImage,img_brightness,stat,index,color,varargin)
% Function that plots only the boundaries of the neuron takes the mask coordinates and x/y shift if they are needed
% and plots them over a background image 

%stat should be the subselection of cells you want to plot 

% ** IF PLOTTING ON FUNCTIONAL DATA AND NOT W-SERIES REG TIF, XSHIFT AND
% YSHIFT SHOULD BE 0 ** 


% Christian Potter - updated: 2/2/2024

%%

display_type='imshow'; % default to using imshow

xshift=varargin{1};
yshift=varargin{2};

if length(varargin)>2
    display_type=varargin{3}; % if there is an argument for dipslay type, update variable
end

if strcmp(display_type,'imagesc') % use imshow by default, but can specify imagesc
    imagesc(backgroundImage)
    caxis([0 max(max(backgroundImage))/img_brightness])
elseif strcmp(display_type,'imshow')
    imshow(backgroundImage)
    caxis([0 max(max(backgroundImage))/img_brightness])
end

hold on 

for i = 1:length(stat)
    curstat=stat{i};
    xpix=double(curstat.xpix(curstat.soma_crop==1)); %get x/y pixels
    ypix=double(curstat.ypix(curstat.soma_crop==1));
    
    xpix=xpix+xshift+1; %shift them over by x/yshfit and add 1 to convert from python values
    ypix=ypix+yshift+1;

    xcoords=nan(2*range(ypix)+1,1); % make variable so that code can go by each row of y and put the x coordinates in at the tails (forming circle)
    ycoords=nan(2*range(ypix)+1,1);
    
    ycl=unique(ypix);% unique y coordinates (y coords list)
   
    [ycl,~]=sort(ycl);
    if length(ycl)<range(xpix) % this code plots imperfect masks for cells that for whatever reason have masks that have gaps in ypix 
        for j=1:length(ycl)
        
            curx=xpix(ypix==ycl(j)); % find the x pixels for each of the y coordinates of the mask 
            xcoords(j)=min(curx); % put the minimum x coordinate closest to the start
            xcoords((end-1)-(j-1))=max(curx); % put the max x closest to the end (the max y coordinate will have min and max x coordinates touching each other)
            ycoords(j)=ycl(j);
            ycoords((end-1)-(j-1))=ycl(j);    
        end
    else
        for j=1:range(ypix) % this code plots good masks boundaries for cells that have all y values 
        
            curx=xpix(ypix==ycl(j));
            xcoords(j)=min(curx);
            xcoords((end-1)-(j-1))=max(curx);
            ycoords(j)=ycl(j);
            ycoords((end-1)-(j-1))=ycl(j);    
        end
    end
    ycoords(end)=ycoords(1);
    xcoords(end)=xcoords(1);

    plot(double(xcoords),double(ycoords),color,'LineWidth',2)
    text(mean(xpix)+5,mean(ypix)+5,num2str(index(i)),'Color',color) % make text of ROI index 
 
end
