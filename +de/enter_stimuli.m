function [stim] = enter_stimuli(tseries_frames,dsnum)
%% DESCRIPTION
% creates stim function with fields for each ligand or start of a
% pharmacology state
%
% fields: 
% strlist = account of each epoch for plotting purposes
% tpoints = cumsum of tseries frames for time accounting 
% (lligs) = field for when each ligand was applied 
% (epochs) = includes spont, wash, ttx 


%% NOTES 
% eventually make this so that you have to enter key to advance to next
% t-series so that you can enter multiple for each point 
%   ** should display a string confirming what you have entered before
%   advancing 
%

%% MAKE VARIBLES 
liglabels= {'OXY','GRP','CCK','SP','Talt','NKB','Oxo','NMB'}; 
lligs = lower(liglabels); 

tpoints = cumsum(tseries_frames);
tpoints =[0,tpoints];tpoints(end)=[]; % adjust to start with 0

tlist = nan(length(tseries_frames),1); % coordinates 
strlist=cell(length(tseries_frames),1);  
%% DEFINE STIMULUS STRUCTURE
stim.dsnum = dsnum; 
stim.fps = 8; 

%% ADD LIGANDS 
epochs =['spont','wash','ttx',lligs]; 

for e = 1:length(epochs)
    stim.(epochs{e})=[];
end

%** in the future, have cicada be its own separate structure called by
%stim.cic.grp 

%%
i = 1; 
while i < length(tseries_frames)
    disp(['T-Series:', num2str(i)])
    answer = input(de_prompt.input_str(1),"s"); 
    %-- Ligand ----------------------------
    if strcmp(answer,'a')
        disp(lligs)
        answer = input('Enter Option from List',"s"); 
        if ismember(answer,lligs) 
            stim.(answer)=tpoints(i);  
            strlist{i}=answer; 
        else 
            disp('Incorrect Selection') % change so that it loops back to ask you to enter another option 
        end
    %-- Pharmacology State ------------------
    elseif strcmp(answer,'d')
        answer = input(de_prompt.input_str(1.1),"s"); 
        [stim,strlist]= de_prompt.pharm(i,tpoints,answer,stim);  

    %-- Repeat of Previous TSeries-----------
    elseif strcmp(answer,'r')
        strlist{i}=''; 
    end
    %--------End Options----------------------

    %---Confirm/ Add/ Delete Info------------- 
    curstr = strlist{i};
    [input_str]=de_prompt.input_str(1.2,curstr,dsnum); 
    answer = input(input_str,"s"); 

    if strcmp(answer,'a')% add new info 

    elseif strcmp(answer,'c') %continue 
        i = i+i; 
    elseif strcmp(answer,'d') %delete info and re-enter
        strlist{i}=''; 
        stim = de.removeNumberFromStruct(tpoints(i),stim); 
    end
    
end

disp('All T-Series Annotated')

%% ADD VARIABLES TO STIM
stim.strlist=strlist; 

%% TO ADD 
% - indication that recorded activity is something near spontaneous based
% on previous windows 

