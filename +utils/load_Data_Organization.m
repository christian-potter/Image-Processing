function [Fall,tseries_md,zstack,zstack_md,tsync] = load_Data_Organization(dsnum)

if ispc 
    base = ['\\Shadowfax\Warwick\DRGS project\#',dsnum,'\SDH\'];
    f_variables =[base,'Processed\Fall_variables.mat'];
    tseries_md = [base,'Processed\tseries_md.mat']; 
    zstack_md = [base,'Processed\zstack_md.mat'];
    tsync = [base,'Processed\tsync.mat']; 
    zstack = [base,'Processed\zstack.mat'];
elseif ismac
    base = ['/Volumes/Shadowfax/Warwick/DRGS project/#', dsnum, '/SDH/'];
    f_variables= [base, 'Split/suite2p/Fall_variables.mat'];
    tseries_md = [base, 'Processed/tseries_md.mat'];
    zstack_md = [base, 'Processed/zstack_md.mat'];
    tsync = [base, 'Processed/tsync.mat'];
    zstack = [base,'Processed/zstack.mat'];
end

% Load the data files
load(f_variables); % 
load(tseries_md);
load(zstack_md);
load(tsync);
load(zstack)
%%


