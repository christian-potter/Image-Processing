function [id_str] = neuron_idstr(id_vect,roi)

strnum=1; 

%% 
if strnum == 1 
    % ID_STR 1
    % used in prompt.change_rois
     if id_vect(roi)==1
            str1 ='EX'; 
        elseif id_vect(roi)==2
            str1='IN';
        elseif id_vect(roi)==0
            str1 ='SPBN'; 
        elseif id_vect(roi)==3
            str1='Unclassified';
     end


    id_str=['ROI# ', num2str(roi),' is ',str1]; 
    


end 

