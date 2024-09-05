function [id_vect] = examine_uncertain(roi_planeidx,id_vect,ops,stat)

arguments
    roi_planeidx(1,:) double 
    id_vect (:,1) double
    ops struct
    stat cell
end

unc = find(id_vect==3); 

i = 1; 

surround = 20;
completion = 0; 

% determine index of neuron for inspect_roi 
while completion ~= 1
    %-
    cstat= stat{unc(i)}; 
    
    plot.inspect_roi(unc(i),cstat,surround,ops,stat)
    
    id_str=prompt.neuron_idstr(id_vect,unc(i)); 
    disp(id_str)
    
    inputstr=prompt.menu_str(3);
    change= input(inputstr,"s"); 

    if strcmp(change,'a')
        id_vect(roi(i))=1; 
        i = i+1; 
         
    elseif strcmp(change,'s')
        id_vect(roi(i))=2; 
        i = i+1; 
     
    elseif strcmp(change,'d')
        id_vect(roi(i))=0;
        i = i+1; 

    elseif strcmp(change,'f')
        id_vect(roi(i))=3; 
        i=i+1; 

    elseif strcmp(change,'q')
        completion = 1; 
    end

end





