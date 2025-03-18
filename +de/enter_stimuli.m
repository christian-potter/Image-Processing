function [stim] = enter_stimuli(tseries_frames,dsnum,ops)
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

  
%% DEFINE STIMULUS STRUCTURE
stim.dsnum = dsnum; 
stim.fps = 8; % update eventually to work 

%% ADD LIGANDS 
epochs =['spont','wash','ttx','cbx','spont',lligs]; 

for e = 1:length(epochs)
    stim.(epochs{e})=[];
end

%** in the future, have cicada be its own separate structure called by
%stim.cic.grp 

%% DETERMINE T-SERIES NUMBERS 
for i = 1:length(ops.filelist)
    fnumber(i)=str2double(ops.filelist(i,end-10:end-8)); 
end

fnumber=unique(fnumber); 
stim.strlist = cell(length(fnumber),1); 
stim.tpoints= tpoints;  
%% INPUT INFO FOR EACH TSERIES
i = 1; 
bookend ='----------'; 
while i < length(fnumber)
    disp([bookend,char(10),'T-Series:', num2str(fnumber(i))])
    answer = input(de_prompt.input_str(1),"s"); 
    %-- Ligand ----------------------------
    if strcmp(answer,'a')
        disp(bookend);disp(lligs)
        answer = input(['Enter Option from List',char(10),bookend,char(10)],"s");
        if ismember(answer,lligs) 
            stim.(answer)=tpoints(i);  
            stim.strlist{i}=answer; 
        else 
            disp('Incorrect Selection') % change so that it loops back to ask you to enter another option 
        end
    %-- Pharmacology State ------------------
    elseif strcmp(answer,'d')
        answer = input(de_prompt.input_str(1.1),"s"); 
        [stim]= de_prompt.pharm(i,tpoints,answer,stim);  

    %-- Repeat of Previous TSeries-----------
    elseif strcmp(answer,'r')
        stim.strlist{i}=''; 
    %-- CANCEL---------- 
    elseif strcmp(answer,'x')
        i = length(fnumber)+1; 
    end
    %------------------------------
    %---Confirm/ Add/ Delete Info------------- 
    curstr = stim.strlist{i};
    [input_str]=de_prompt.input_str(1.2,curstr,fnumber(i)); 
    answer = input(input_str,"s"); 

    if strcmp(answer,'a')% add new info 
        % -rerun while loop unchanged 
    elseif strcmp(answer,'c') %continue 
        i = i+1; 
    elseif strcmp(answer,'d') %delete info and re-enter
        stim.strlist{i}=''; 
        stim = de.removeNumberFromStruct(tpoints(i),stim); 
    end
    
end

disp('All T-Series Annotated')

%% ADD VARIABLES TO STIM


%% TO ADD 
% - indication that recorded activity is something near spontaneous based
% on previous windows 

