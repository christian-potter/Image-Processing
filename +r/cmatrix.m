function [cm,im]= cmatrix(d,timepoints,opt)
    arguments
        d struct
        timepoints double = stim.ttx(1):stim.cicada(2)
        opt.include (1,:) logical = logical(ones(1,size(d.sdff,1))>0)
        opt.abs_diff logical = false
        opt.abs_movmean double = 1 
        opt.scramble logical = false
    end        

% INPUT
%   timepoints = vector with beginning and end times
%   include_vect = logical vector for the neurons to include

% OUTPUT
%   cm = correlation matrix 
%   im = identity matrix 

%% MAKE VARIABLES

activity = d.sdff; 
% select timepoints if vector is length 2 
if numel(timepoints)==2
    timepoints=timepoints(1):timepoints(2);
end

% if include_vect is different than default  
if sum(opt.include)== size(d.sdff,1) 
    cdff = activity(:,timepoints);  
else
    cdff = activity(opt.include,timepoints);   
end

% absolute value of derivative
if opt.abs_diff 
    %cdff = movmean(cdff,opt.abs_movmean,2); 
    cdff = sgolayfilt(cdff,3,15,[],2); 

    cdff= diff(cdff,[],2); 
    %cdff = movmean(cdff,opt.abs_movmean,2); 
    cdff = abs(cdff); 
end

% make correlation matrix 
cm= nan(size(cdff,1),size(cdff,1));
%im= nan(size(cdff,1),size(cdff,1));
%% CALCULATE CMATRIX
if ~opt.scramble
    for i = 1:size(cdff,1)
        for j = 1:size(cdff,1)
            if j>i
                [c] = corrcoef(cdff(j,:),cdff(i,:)); 
                cm(i,j)= c(2); cm(j,i)= c(2); 
               
                %im(i,j)= d.issp(i)+d.issp(j)+1; im(j,i)= d.issp(i)+d.issp(j)+1; 
            
            end
        end
    end
elseif opt.scramble 
    for i = 1:size(cdff,1)
        for j = 1:size(cdff,1)
            if j>i
                cdffj=cdff(j,:); cdffi=cdff(i,:); 
                cdffj =circshift(cdffj,randi([2000 length(cdffj)])); %cdffi=circshift(cdffi,-(randi([1000 length(cdffi)]))); 
                [c] = corrcoef(cdffi,cdffj); 
                cm(i,j)= c(2); cm(j,i)= c(2); 
                %im(i,j)= d.issp(i)+d.issp(j)+1; im(j,i)= d.issp(i)+d.issp(j)+1; 
            end
        end
    end
end

%% EDIT DIAGONAL VALUES
diag = eye(size(cm,1)); 
cm(diag==1)=1; 

end


