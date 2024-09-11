function [ftype,atype] = img_type(ftype,atype)


answer = input(prompt.menu_str(4),'s'); 

if strcmp(answer,'a')
    ftype = 'mean'; 
elseif strcmp(answer,'s')
    ftype = 'enhanced'; 
elseif strcmp(answer,'d')
    ftype = 'correlation'; 
elseif strcmp(answer,'f')
    ftype = 'max'; 
elseif strcmp (answer,'q')
    atype = 'mean'; 
elseif strcmp(answer,'r')
    atype = 'corrected'; 
end



