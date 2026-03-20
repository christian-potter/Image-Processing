function [abc, stats] = computePrincipalAxesFromCoordCells(coordCells, voxelSize)
%COMPUTEPRINCIPALAXESFROMCOORDCELLS Compute principal semiaxis lengths a,b,c
% from a cell array of 3D voxel coordinates.
%
% INPUTS
%   coordCells : N x 1 or 1 x N cell array
%       Each cell contains an M x 3 numeric matrix.
%       Columns are [x y z] coordinates of voxels belonging to one object.
%
%   voxelSize : 1 x 3 numeric vector, optional
%       Physical size of one voxel in [x y z].
%       Default = [1 1 1].
%       Use this if your voxels are anisotropic so that the axes are computed
%       in physical units rather than voxel units.
%
% OUTPUTS
%   abc : N x 3 numeric matrix
%       Each row contains [a b c], where:
%           a >= b >= c
%       These are the effective semiaxis lengths estimated from the point cloud
%       using PCA. Specifically:
%           a,b,c = sqrt(eigenvalues of covariance matrix)
%
%   stats : struct array with one entry per cell
%       Fields:
%           .centroid      - 1x3 centroid of coordinates
%           .covMat        - 3x3 covariance matrix
%           .eigVec        - 3x3 eigenvector matrix
%           .eigVal        - 3x1 eigenvalues sorted descending
%           .a             - major semiaxis length
%           .b             - middle semiaxis length
%           .c             - minor semiaxis length
%           .nPoints       - number of coordinates
%
% NOTES
%   - a, b, c here are PCA-derived spread parameters, not exact geometric
%     ellipsoid boundary radii.
%   - If you want values in microns, provide voxelSize in microns.
%   - Each entry must contain at least 3 non-identical points to compute a
%     meaningful 3D covariance.
%
% EXAMPLE
%   coordCells = {
%       [1 1 1; 2 1 1; 3 1 1; 4 1 1; 5 1 1]
%       [1 1 1; 1 2 1; 2 1 1; 2 2 1; 1 1 2; 2 2 2]
%   };
%
%   [abc, stats] = computePrincipalAxesFromCoordCells(coordCells, [0.5 0.5 1.0]);

    arguments
        coordCells cell
        voxelSize (1,3) double = [1 1 1]
    end

    nObj = numel(coordCells);

    abc = nan(nObj, 3);

    stats = repmat(struct( ...
        'centroid', [], ...
        'covMat', [], ...
        'eigVec', [], ...
        'eigVal', [], ...
        'a', NaN, ...
        'b', NaN, ...
        'c', NaN, ...
        'nPoints', 0), nObj, 1);

    for i = 1:nObj
        coords = coordCells{i};

        % Validate current entry
        if isempty(coords)
            warning('Entry %d is empty. Returning NaNs for this entry.', i);
            continue
        end

        if ~isnumeric(coords) || size(coords,2) ~= 3
            error('Entry %d must be an Mx3 numeric matrix of [x y z] coordinates.', i);
        end

        if size(coords,1) < 3
            warning('Entry %d has fewer than 3 points. Returning NaNs for this entry.', i);
            continue
        end

        % Convert to physical units if voxel sizes are anisotropic
        coordsScaled = coords .* voxelSize;

        % Remove exact duplicate coordinates if present
        coordsScaled = unique(coordsScaled, 'rows', 'stable');

        if size(coordsScaled,1) < 3
            warning('Entry %d has fewer than 3 unique points after deduplication. Returning NaNs.', i);
            continue
        end

        % Centroid
        ctr = mean(coordsScaled, 1);

        % Centered coordinates
        X = coordsScaled - ctr;

        % Covariance matrix
        C = cov(X);

        % Handle degenerate cases
        if any(~isfinite(C), 'all')
            warning('Entry %d produced a non-finite covariance matrix. Returning NaNs.', i);
            continue
        end

        % Eigen decomposition
        [V, D] = eig(C);
        eigVals = diag(D);

        % Sort descending so that a >= b >= c
        [eigValsSorted, idx] = sort(eigVals, 'descend');
        V = V(:, idx);

        % Numerical cleanup
        eigValsSorted(eigValsSorted < 0 & eigValsSorted > -1e-12) = 0;

        if any(eigValsSorted < 0)
            warning('Entry %d has substantially negative eigenvalues. Returning NaNs.', i);
            continue
        end

        % Principal semiaxis lengths
        % These are the standard deviations along the principal axes
        axesLengths = sqrt(eigValsSorted);

        abc(i, :) = axesLengths(:).';

        stats(i).centroid = ctr;
        stats(i).covMat   = C;
        stats(i).eigVec   = V;
        stats(i).eigVal   = eigValsSorted;
        stats(i).a        = axesLengths(1);
        stats(i).b        = axesLengths(2);
        stats(i).c        = axesLengths(3);
        stats(i).nPoints  = size(coordsScaled, 1);
    end
end