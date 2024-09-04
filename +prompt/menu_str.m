function [inputstr] = menu_str(menu)


% MENU 1
if menu == 1 

    titleinput= ['Select Option:',char(10)]; 
    a = ['A: Reclassify Neurons',char(10)]; 
    s = ['S: Go To Next Plane',char(10)]; 
    d = ['D: Go to Previous Plane',char(10)]; 
    f = ['F: Change Image Brightness',char(10)];
    r = ['R: Stop ',char(10)];
    inputstr= [titleinput,a,s,d,f,r]; 

% MENU 2
% used in prompt.change_rois
elseif menu == 2
    titleinput= ['Select Option:',char(10)]; 
    a = ['A: Change to EX',char(10)]; 
    s = ['S: Change to IN',char(10)]; 
    d = ['D: Change to SPBN',char(10)]; 
    f = ['F: Change to Uncertain',char(10)]; 
    
    inputstr= [titleinput,a,s,d,f]; 

end





%% OLD 
% titleinput= ['Select Option:',char(10)]; 
% a = ['A: Reclassify Excitatory',char(10)]; 
% s = ['S: Reclassify Inhibitory',char(10)]; 
% d = ['D: Reclassify Projection',char(10)]; 
% f = ['F: Reclassify Uncertain',char(10)]; 
% q = ['Q: Go To Next Plane',char(10)]; 
% w = ['W: Go to Previous Plane',char(10)]; 
% 
% f = ['Z: Change Image Brightness',char(10)]; 
% 
% inputstr= [titleinput,a,s,d,f,q,w]; 