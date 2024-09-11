function [g_thresh,r_thresh]= change_brightness(gclim,rclim)

%%
g_thresh=gclim; 
r_thresh = rclim; 

%%
disp(['Current Functional Thresholds:',num2str(gclim)])
disp(['Current Anatomical Thresholds:',num2str(rclim),char(10)])

answer = input(['F: Change FUNCTIONAL/ A: Change ANATOMICAL/ D: Change BOTH',char(10)],'s'); 
if strcmp(answer,'f')
    g_thresh=input(['Input new FUNCTIONAL thresholds',char(10),'Enter scalar to multiply automatic thresholds',char(10)]); 
elseif strcmp(answer,'a')
    r_thresh = input(['Input new ANATOMICAL thresholds',char(10),'Enter scalar to multiply automatic thresholds',char(10)]); 
elseif strcmp(answer,'d')
    g_thresh = input(['Input new thresholds for BOTH channels',char(10),'Enter scalar to return to automatic thresholds',char(10)]);
    r_thresh = g_thresh; 
else
    disp('Invalid input')
end



