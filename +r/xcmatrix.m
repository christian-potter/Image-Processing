function [xcmatrix] = xcmatrix(d,timepoints,neurons,maxlag)
% INPUT
%   timepoints = vector with beginning and end times
%   neurons = logical vector for the neurons to include

% OUTPUT
%   xcmatrix = cross correlation matrix 

%% MAKE VARIABLES
activity = d.sdff; 
if isstr(neurons)
    if strcmp(neurons,'all')
        activity = activity(:,timepoints(1):timepoints(2));
    end
else
    activity = activity(neurons,timepoints(1):timepoints(2)); 
    
end

xcmatrix= nan(size(activity,1),size(activity,1),2); 

%% CALCULATE CMATRIX
for i = 1:size(activity,1)
    for j = 1:size(activity,1)
        if j>i
            [xc,lags]= crosscorr(activity(j,:),activity(i,:),maxlag);
      
            maxval= find(abs(xc)==max(abs(xc))); 
            xcmatrix(i,j,1)= xc(maxval); 
            xcmatrix(j,i,1)= xc(maxval);

            loc = find(abs(xc)==max(abs(xc)));
            xcmatrix(i,j,2) = lags(loc); 
            xcmatrix(j,i,2) = lags(loc);


        end
    end
end


end



