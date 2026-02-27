function x =tsync_zdist(user,project,dsnum)
%% DESCRIPTION
% function that generates zdist from first raw tsync file
% * cannot use compressed tsync since planes are averaged together

%% LOAD RAW TSYNC 
dsnum = num2str(dsnum); 
tsfolder = ['/Volumes/',user,'/',project,'/#',dsnum,'/SDH/Functional/ThorSync/']; 

direct = dir(tsfolder);

% one of the first two folders should contain the h5 file 
if contains(direct(1).folder,'#')
    tsfile = [direct(1).folder,'/',direct(1).name]; 
else
    tsfile = [direct(2).folder,'/',direct(2).name]; 
end

tsync = md.read_h5([tsfile,'/','Episode_0000.h5']); 

%% 

ts_per_zmicron = .018164;





end 

