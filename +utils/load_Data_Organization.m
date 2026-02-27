function [Fall,tseries_md,zstack,zstack_md,tsync] = load_Data_Organization(dsnum)
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
    zstack = [base,'Processed\zstack.mat'];
elseif ismac
    base = ['/Volumes/Warwick/DRGS/#', dsnum, '/SDH/'];
    f_variables= [base, 'Processed/Fall_variables.mat'];
    tseries_md = [base, 'Processed/tseries_md.mat'];
    zstack_md = [base, 'Processed/zstack_md.mat'];
    tsync = [base, 'Processed/tsync.mat'];
    zstack = [base,'Processed/zstack.mat'];
end

% Load the data filesfall
load(f_variables); % 
load(tseries_md);

if exist('tlapse_md')
    tseries_md = tlapse_md; 
end
load(zstack_md);
load(tsync);
if exist('tsync541')
    tsync = tsync541; 
end

load(zstack); 

%%


end