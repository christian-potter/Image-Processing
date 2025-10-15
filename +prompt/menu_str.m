function [inputstr] = menu_str(menu)
%% DESCRIPTION
% function that returns string necessary for prompt 

%%
% MENU 1
% used in prompt.main_menu  
titleinput = ['-------------------',char(10),'Select Option:',char(10)]; 
%strend = ['-------------------'];
if menu == 1 
    a = ['A: Reclassify Neurons',char(10)]; 
    s = ['S: Go To Next Plane',char(10)]; 
    d = ['D: Go to Previous Plane',char(10)]; 
    r = ['R: Change Image Type ',char(10)];
    w = ['W: Lock Figure Positions',char(10)]; 
    e = ['E: Save id_vect/ Current Figure Positions',char(10)]; 
    z = ['Z: Align Z-Stack for Selected Plane',char(10)];
    v = ['V: Set Depth',char(10)]; 
    inputstr= [titleinput,a,s,d,r,w,e,z,v]; 

% MENU 2.5 
% used in prompt.change_rois 
elseif menu ==2.5 
    a = ['A: Change ALL to EX',char(10)];
    s = ['S: Change ALL to IN',char(10)];
    d = ['D: Change ALL to SPBN',char(10)]; 
    f = ['F: Change ALL to Uncertain',char(10)];  
    z = ['Z: Add ALL to delete_vect',char(10)];
    r = ['R: Classify Individually',char(10)];
    inputstr= [titleinput,a,s,d,f,z,r]; 
    
% MENU 2
% used in prompt.change_rois
elseif menu == 2
    a = ['A: Change to EX',char(10)]; 
    s = ['S: Change to IN',char(10)]; 
    d = ['D: Change to SPBN',char(10)]; 
    f = ['F: Change to Uncertain',char(10)];   
    z = ['Z: Add to delete_vect',char(10)];
    inputstr= [titleinput,a,s,d,f,z]; 

% MENU 4
% used in prompt.menu_str 
elseif menu == 4
    a = ['A: Change FUNCTIONAL to MEAN',char(10)]; 
    s = ['S: Change FUNCTIONAL to ENHANCED',char(10)]; 
    d = ['D: Change FUNCTIONAL to CORRELATION',char(10)]; 
    f = ['F: Change FUNCTIONAL to MAX',char(10)]; 
    q = ['Q: Change ANATOMICAL to MEAN',char(10)]; 
    r = ['R: Change ANATOMICAL to CORRECTED',char(10)];
    inputstr= [titleinput,a,s,d,f,q,r]; 

% used in prompt.align_zstack 
elseif menu == 5 
     e = ['E: Manually Enter Correction ',char(10)]; 
     r= ['R: Find With ROI',char(10)];
     inputstr=[titleinput,e,r]; 

% used in set_depth 
elseif menu == 6
    a = ['A: Enter Values for X Reference Bands',char(10)];
    s = ['S: Enter Values for Y Reference Bands',char(10)];
    q = ['Q: Quit and Return to Main Menu',char(10)];
    inputstr = [titleinput, a,s, q];

elseif menu == 7

end

end

