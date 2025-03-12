function [ligcmats,ligcvects,ligmeans,ligidx,ligsorted] = track_coupling(dsdata,dsd,dsstim,opt)
    arguments
        dsdata struct 
        dsd struct
        dsstim struct 
        opt.corrtype = 'normal'
        opt.ttxwindow double = 60; 
    end

% INPUT:
%   dsdata = can be data or dsdata
%   dsd = can be d or dsd 
%   dsstim = can be stim or dsstim 

% OUTPUT:
% ligcmats = cell array with the correlation matrices from each period of time
%            1st row is of during ligand and the 2nd is ttxtime after  

% ligidx = one row tracks the ligand that it is
%          one row tracks the chronology that it was presented 

%%
ligcmats = cell(2,length(dsstim(1).ligands)-1,length(dsd)); 
ligmeans = cell(2,length(dsstim(1).ligands)-1,length(dsd)); 
ligcvects = cell(2,length(dsstim(1).ligands)-1,length(dsd)); 


ligidx= nan(length(dsd),length(dsstim(1).ligands)-1); 
for ds = 1:length(dsd)
    d = dsd(ds); stim = dsstim(ds);data=dsdata(ds);  
    [ttxtimes,ligtimes,sortedligs,ligorder,ligblocks] = get.ttx_vs_ligand(stim,opt.ttxwindow); 
    
    for i = 1:length(ligblocks)
        if ligorder(i)~=0
            if strcmp(opt.corrtype,'normal')                              
                ligmeans{1,i,ds}=mean(mean(d.sdff(:,ligblocks{1,i}))); 
                ligmeans{2,i,ds}=mean(mean(d.sdff(:,ligblocks{2,i}))); 
                
                ligcorrs= r.cmatrix(d,ligblocks{1,i});
                ligcmats{1,i,ds}=ligcorrs; 
                ligcorrs=triu(ligcorrs,1); ligcorrs(ligcorrs==0)=[]; 
                
                ttxcorrs= r.cmatrix(d,ligblocks{2,i}); 
                ligcmats{2,i,ds}=ttxcorrs; 
                ttxcorrs = triu(ttxcorrs,1);ttxcorrs(ttxcorrs==0)=[]; 

                ligcvects{1,i,ds}=ligcorrs(:); 
                ligcvects{2,i,ds}=ttxcorrs(:); 
               
                ligidx(ds,:) = ligorder;
                ligsorted{i,ds}= sortedligs{i}; 
            end
        end       
    end
end

end

%%



%% 

 