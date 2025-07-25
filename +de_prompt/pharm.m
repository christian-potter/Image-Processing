function [stim]= pharm(i,tpoints,answer,stim)  



% For input_str(1.1)

% -- TTX START---------
if strcmp(answer,'a')
    stim.ttx(1) = tpoints(i); % should only be one entry 
    stim.strlist{i} =[stim.strlist{i},'|TTX Start|']; 
% -- CBX START ---------
elseif strcmp(answer,'c')
    stim.cbx =[stim.cbx,tpoints(i)]; 
    stim.strlist{i}=[stim.strlist{i},'|CBX Start|']; 
% -- CBX END ---------
elseif strcmp(answer,'d')
    %relies on same counter as CBX start 
    stim.cbx =[stim.cbx,tpoints(i)]; 
    stim.strlist{i}=[stim.strlist{i},'|CBX End|']; 
%-- CICADA START------
% is this redundant? 
% -- WASHOUT ---------
elseif strcmp(answer,'w')
    stim.wash = [stim.wash,tpoints(i)]; 
    stim.strlist{i} =[stim.strlist{i},'|Washout|']; 
%-- BASELINE ---------
elseif strcmp(answer,'s')
    stim.spont = [stim.spont,tpoints(i)]; 
    stim.strlist{i} = [stim.strlist{i},'|Baseline|']; 
end



%%

end
