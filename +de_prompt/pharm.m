function [stim,strlist]= pharm(i,tpoints,answer,stim)  

% For input_str(1.1)

% -- TTX START---------
if strcmp(answer,'a')
    stim.ttx(1) = tpoints(i); % should only be one entry 
    strlist{i} =[stim.strlist{i},'|TTX Start|']; 
% -- CBX START ---------
elseif strcmp(answer,'s')
    stim.cbx =[stim.cbx,tpoints(i)]; 
    strlist{i}=[stim.strlist{i},'|CBX Start|']; 
% -- CBX END ---------
elseif strcmp(answer,'d')
    %relies on same counter as CBX start 
    stim.cbx =[stim.cbx,tpoints(i)]; 
    strlist{i}=[stim.strlist{i},'|CBX End|']; 
% -- WASHOUT ---------
elseif strcmp(answer,'w')
    stim.washout = [stim.washout,tpoints(i)]; 
    strlist{i} =[stim.strlist{i},'|Washout|']; 
%-- BASELINE ---------
elseif strcmp(answer,'b')
    stim.baseline = [stim.baseline,tpoints(i)]; 
    strlist{i} = [stim.strlist{i},'|Baseline|']; 
end



%%

end
