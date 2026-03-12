function [label_medians,medians,vol] = get_label_medians(soma_labels)
labs = soma_labels;
labs = labs(:);
labs = labs(labs>0);
uniq = unique(labs);

% Preallocate cell array
nuniq = numel(uniq);
cellLocations = cell(nuniq,1);

% For each unique label, find all voxel coordinates where it appears
for i = 1:nuniq
    val = uniq(i);
    % find returns linear indices; use 3D subscripts from original soma_labels size
    [x,y,zv] = ind2sub(size(soma_labels), find(soma_labels==val));
    % nreps is number of occurrences
    nreps = numel(x);
    % build 3 x nreps matrix: rows correspond to each spatial dimension
    if nreps>0
        cellLocations{i} = [x.'; y.'; zv.'];
    else
        cellLocations{i} = zeros(3,0);
    end
    vol(i)=nreps; 
end
%%

%%
% For each cell (row in cellLocations) compute the median of each of the 3 rows (x,y,z)
nCells = numel(cellLocations);
medians = zeros(nCells,3);

for i = 1:nCells
    coords = cellLocations{i}; % 3 x N (or 3 x 0)
    if isempty(coords)
        medians(i,:) = [NaN NaN NaN];
    else
        % median across columns for each spatial dimension
        med = median(coords,2);
        medians(i,:) = med(:).';
    end
end

medians = round(medians); 
%%
label_medians = zeros(size(soma_labels)); 
for i = 1:size(medians,1)
    label_medians(medians(i,1),medians(i,2),medians(i,3))=i ; 

end