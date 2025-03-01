function [id_vect] = change_rois(id_vect,curprompt)
%% ASK WHICH ROIS 

roi = input(curprompt); 


%% CHANGE ID_VECT ACCORDING TO RESPONSE 
input_str = prompt.menu_str(2.5); 
change = input(input_str,"s"); 

%-- make EX  
if strcmp(change,'a')
    id_vect(roi)=1;
%-- make IN  
elseif strcmp(change,'s')
    id_vect(roi)=2; 
%-- make SPBN  
elseif strcmp(change,'d')
    id_vect(roi)=0;
%-- make uncertain 
elseif strcmp(change,'f')
    id_vect(roi)=3;    
%-- add to delete_vect 
elseif strcmp(change,'z')
    id_vect(roi)=4; 

%-- categorize individually 
elseif strcmp(change,'r')

    for i = 1:length(roi)
        [formatstr]= prompt.neuron_idstr(id_vect,roi(i)); 
        disp(formatstr)
        input_str = prompt.menu_str(2); 
        change=input(input_str,"s");  
        if strcmp(change,'a')
            id_vect(roi(i))=1;  
        elseif strcmp(change,'s')
            id_vect(roi(i))=2; 
        elseif strcmp(change,'d')
            id_vect(roi(i))=0;     
        elseif strcmp(change,'f')
            id_vect(roi(i))=3;   
        elseif strcmp(change,'z')
            id_vect(roi(i))=4; 
           
        end
    end
end

    
    
    
    
    
    
    

