function [input_str] = input_str(num,varargin)
%% VARIABLE ARGUMENTS 
if ~isempty(varargin)
    curstr=varargin{1}; 
    fnumber = varargin{2};
end


%%
liglabels= {'OXY','GRP','CCK','SP','Talt','NKB','Oxo','NMB'}; 
labels=lower('liglabels'); 

bookend = ['----------',char(10)]; 
% MAIN MENU
if num == 1
    first = ['Enter t-series type:',char(10)]; 
    a = ['A: Ligand',char(10)]; 
    s = ['S: Sensory Input',char(10)]; 
    d = ['D: Pharmacology State',char(10)]; 
    r = ['R: Repeat Previous',char(10)]; 
    input_str=[bookend,first,a,s,d,r,bookend]; 

%TYPE OF PHARMACOLOGY STATE    
elseif num ==1.1
    % if main menu == d
    a = ['A: TTX Start',char(10)];
    c = ['C: CBX Start',char(10)]; 
    d = ['D: CBX End',char(10)]; 
    %c = ['C: CICADA Start',char(10)]; 
    w = ['W: Washout',char(10)]; 
    s= ['S: BL/Spont',char(10)];
    input_str=[bookend,a,c,d,w,s,bookend];

%REPEAT Y/N INPUT  
elseif num == 1.2
    %-- display how T-Series is currently labeled 
    if isempty(curstr)
        info_str = sprintf(['TSeries #%d is marked as REPEATED',char(10)],fnumber );
    else
        info_str = sprintf(['TSeries #%d is marked as %s',char(10)], fnumber, curstr);
    end
    
    %-- List options 
    a = ['A: Add Additional Info',char(10)];
    c = ['C: Continue to Next TSeries',char(10)];
    d = ['D: Delete Info and Re-Enter',char(10)]; 
    
    input_str = [bookend,info_str,a,c,d,bookend]; 
      
    % if pharmacology_state = other
    %a = ['A: GRP']

% elseif num == 1.2
%     % if main menu == d
%     first = ['Enter option from list',char(10)];
%     disp(labels)

end




