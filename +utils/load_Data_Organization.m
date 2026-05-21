function [Fall,tseries_md,zstack,zstack_md,tsync,ypix_zplane,raw_tsync] = load_Data_Organization(dsnum)
arguments
    dsnum 

end


dsnum = num2str(dsnum); 

%% IF FVARIABLES EXISTS 


if ispc 
    base = ['\\Shadowfax\Warwick\DRGS\#',dsnum,'\SDH\'];
    f_variables =[base,'Processed\Fall_variables.mat'];
    tseries_md = [base,'Processed\tseries_md.mat']; 
    zstack_md = [base,'Processed\zstack_md.mat'];
    tsync = [base,'Processed\tsync.mat']; 
    raw_tsync = [base,'Processed\raw_tsync.mat']; 
    zstack = [base,'Processed\zstack.mat'];
    ypix_zplane = [base,'Processed/ypix_zplane.mat']; 
elseif ismac
    base = ['/Volumes/Warwick/DRGS/#', dsnum, '/SDH/'];
    f_variables= [base, 'Processed/Fall_variables.mat'];
    tseries_md = [base, 'Processed/tseries_md.mat'];
    zstack_md = [base, 'Processed/zstack_md.mat'];
    tsync = [base, 'Processed/tsync.mat'];
    raw_tsync = [base, 'Processed/raw_tsync.mat'];
    zstack = [base,'Processed/zstack.mat'];
    ypix_zplane = [base,'Processed/Depth/ypix_zplane.mat']; 
end

%% load f_variables
try 
    load(f_variables); % 
catch 
    fall_path = [base, 'Processed/Fall.mat'];
    disp('Fall_variables not created')
end

if ~isfield(Fall,'cellstat')
    Fall.cellstat = Fall.stat(Fall.iscell(:,1)==1); 
end


%%
load(tseries_md);
load(zstack_md);
load(tsync);
load(raw_tsync)
load(ypix_zplane)
load(zstack); 

%%


end