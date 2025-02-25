function [mask_colors] = mask_colors(id_vect)

% Turns id_vect into array with RGB triplet in each column 

mask_colors= nan(3,length(id_vect)); 

for i = 1:size(mask_colors,2)
    if id_vect(i)==2
        mask_colors(:,i)=[0 0 1]; 
    elseif id_vect(i)==1
        mask_colors(:,i)=[1 0 0]; 
    elseif id_vect(i)==0
        mask_colors(:,i)=[0 1 0]; 
    elseif id_vect(i)==3
        mask_colors(:,i)=[1 0 1]; 
    elseif id_vect(i)==4
        mask_colors(:,i)=[.5 .5 .5]; 
    end
end

