function [maskcoords]=mask_coordinates(stat,opt)
arguments
    stat cell % input from suite2p 
    opt.type string = 'outline'
end

%% RUN CODE 
for i = 1:length(stat)
    curstat=stat{i};
 
    xpix=double(curstat.xpix(curstat.soma_crop==1)); %get x/y pixels
    ypix=double(curstat.ypix(curstat.soma_crop==1));
   
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
    ycoords(end)=ycoords(1); % complete the outline 
    xcoords(end)=xcoords(1);

    if strcmp(opt.type,'outline')
        maskcoords{i}=[xcoords,ycoords]; 
    elseif strcmp(opt.type,'mask')
        maskcoords{i}=[xpix',ypix']; 
    end




end

end
