function [id_vect] = change_rois(id_vect,curprompt)

roi= input(curprompt);


for i = 1:length(roi)
    % make string to show to ROI is currently classified 

    [formatstr]= prompt.neuron_idstr(id_vect,roi(i)); 

    disp(formatstr)
    input_str = prompt.menu_str(2); 
    completion =0; 
    while completion ~= 1
        change=input(input_str,"s"); 
     
        if strcmp(change,'a')
            id_vect(roi(i))=1; 
            completion=1; 
        elseif strcmp(change,'s')
            id_vect(roi(i))=2; 
            completion = 1; 
        elseif strcmp(change,'d')
            id_vect(roi(i))=0;
            completion = 1; 
        elseif strcmp(change,'f')
            id_vect(roi(i))=3; 
            completion = 1;          
        else
            disp('Error: Entry outside of allowed options')
        end

    
    end

end
