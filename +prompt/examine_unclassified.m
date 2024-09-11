function [id_vect] = examine_unclassified(roi_planeidx,id_vect,ops,stat,g_thresh,r_thresh)

arguments
    roi_planeidx(1,:) double 
    id_vect (:,1) double
    ops struct
    stat cell
    g_thresh double 
    r_thresh double 
end

unc = find(id_vect==3); 
nplanes = max(roi_planeidx); 

i = 1; 

surround = 20;
completion = 0; 
r_thresh= 1; 
g_thresh= 1; 


% determine index of neuron for inspect_roi 
while completion ~= 1
    %- 
    if i > length(unc)  % -- put option to go back to other planes here 
        completion = 1; 
        disp(["All Unclassified ROIs in this plane have been sorted",char(10)])
    else   
        %-
        cstat= stat{unc(i)}; 
        [maskcoords]=get.mask_coordinates(stat); 
        [gclim,rclim]=plot.roi_mask(unc(i),stat,surround,ops,maskcoords,r_thresh,g_thresh); 
        
        id_str=prompt.neuron_idstr(id_vect,unc(i)); 
        disp(id_str)
        
        % menu_str #3
        inputstr=prompt.menu_str(3);
        change= input(inputstr,"s"); 
        
        if strcmp(change,'a')
            id_vect(unc(i))=1; 
            i = i+1; 
             
        elseif strcmp(change,'s')
            id_vect(unc(i))=2; 
            i = i+1; 
         
        elseif strcmp(change,'d')
            id_vect(unc(i))=0;
            i = i+1; 
        
        elseif strcmp(change,'f')
            id_vect(unc(i))=3; 
            i = i+1; 
        
        elseif strcmp(change,'q')
            [g_thresh,r_thresh]= prompt.change_brightness(gclim,rclim);

        elseif strcmp(change,'r')
            completion = 1; 
        end
    
    end


end





