function [inputstr] = menu_str(menu)
% MENU 1
% Main Menu 
if menu == 1 
    titleinput = ['Select Option:',char(10)]; 
    a = ['A: Reclassify Neurons',char(10)]; 
    s = ['S: Go To Next Plane',char(10)]; 
    d = ['D: Go to Previous Plane',char(10)]; 
    r = ['R: Change Image Type ',char(10)];
    q = ['Q: Examine Uncertain',char(10)]; 
    c = ['C: Combine/ Separate Images',char(10)];
    w = ['W: Lock Figure Positions',char(10)]; 
    e = ['E: Save id_vect/ Current Figure Positions',char(10)]; 
    z = ['Z: Align Z-Stack',char(10)]; 
    inputstr= [titleinput,a,s,d,q,r,c,w,e,z]; 

% MENU 2
% used in prompt.change_rois
elseif menu == 2
    titleinput = ['Select Option:',char(10)]; 
    a = ['A: Change to EX',char(10)]; 
    s = ['S: Change to IN',char(10)]; 
    d = ['D: Change to SPBN',char(10)]; 
    f = ['F: Change to Uncertain',char(10)];    
    inputstr= [titleinput,a,s,d,f]; 

% MENU 3
% used in prompt.examine_uncertain 
elseif menu == 3 
    titleinput = ['Select Option:',char(10)]; 
    a = ['A: Change to EX',char(10)]; 
    s = ['S: Change to IN',char(10)]; 
    d = ['D: Change to SPBN',char(10)]; 
    f = ['F: Keep Uncertain',char(10)]; 
    r = ['R: Return to Main Menu',char(10)]; 
    w = ['W: Lock Figure Positions',char(10)]; 
    inputstr= [titleinput,a,s,d,f,r,w]; 

% MENU 4
% used in 
elseif menu == 4
    titleinput = ['Select Option:',char(10)];
    a = ['A: Change FUNCTIONAL to MEAN',char(10)]; 
    s = ['S: Change FUNCTIONAL to ENHANCED',char(10)]; 
    d = ['D: Change FUNCTIONAL to CORRELATION',char(10)]; 
    f = ['F: Change FUNCTIONAL to MAX',char(10)]; 
    q = ['Q: Change ANATOMICAL to MEAN',char(10)]; 
    r = ['R: Change ANATOMICAL to CORRECTED',char(10)]; 
    inputstr= [titleinput,a,s,d,f,q,r]; 
end

end

