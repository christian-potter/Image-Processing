function [id_vect] = change_rois(id_vect,curprompt)

roi= input(curprompt);


for i = 1:length(roi)
    % make string to show to ROI is currently classified 
    if id_vect(roi(i))==1
        str1 ='EX'; 
    elseif id_vect(roi(i))==2
        str1='IN';
    elseif id_vect(roi(i))==0
        str1 ='SPBN'; 
    elseif id_vect(roi(i))==3
        str1='Unclassified';
    end
    
    formatstr=['ROI# ', num2str(roi(i)),'is ',str1]; 
    sprintf(formatstr)
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
            sprintf('Error: Entry outside of allowed options')
        end

    
    end

end
