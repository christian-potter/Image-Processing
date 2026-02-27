function x =tsync_zdist(user,project,dsnum)
%% DESCRIPTION
% function that generates zdist from first raw tsync file
% * cannot use compressed tsync since planes are averaged together

%% PARAMETERS 
nplanes = 4; % in future use tseries_md


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
ts_per_zmicron = .018164; % how many units of thorsync movement = 1um of actual piezo movement 
%-- determine 
a = 1:nplanes; b = tsync.framecount; 
allplanes = find(ismember(b,a));% get indices for the first nplanes 
raw_fdist = tsync.piezo(allplanes(end))-tsync.piezo(allplanes(1)); 
total_fdist = raw_fdist/ ts_per_zmicron ; 


% determine the linear estimate of distance for the piezo movement in each
% plane 
for p = 1:nplanes
    curframes = tsync.framecount==p; 
    curpiezo = tsync.piezo(curframes); 
    curpdist = curpiezo(end)-curpiezo(1); % distance at beginning and end of frame 
    piezoprop(p+1) = curpdist/total_fdist; % proprotion of the total distance covered 
end


%


total_adist = zstack_md.stepSize*zstack_md.nplanes /1000; 



end 


