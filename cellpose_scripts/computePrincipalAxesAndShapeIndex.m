function [abc, shapeIndex, stats] = computePrincipalAxesAndShapeIndex(coordCells, voxelSize, sphericalThresh)
%COMPUTEPRINCIPALAXESANDSHAPEINDEX Compute PCA-based semiaxis lengths and a
% signed scalar shape index for each 3D object.
%
% INPUTS
%   coordCells : N x 1 or 1 x N cell array
%       Each cell contains an M x 3 numeric matrix.
%       Columns are [x y z] coordinates of voxels belonging to one object.
%
%   voxelSize : 1 x 3 numeric vector, optional
%       Physical voxel size in [x y z]. Default = [1 1 1].
%
%   sphericalThresh : scalar, optional
%       Anisotropy threshold below which objects are treated as nearly
%       spherical. Default = 1.2.
%
% OUTPUTS
%   abc : N x 3 numeric matrix
%       Each row is [a b c], where a >= b >= c are the PCA-derived principal
%       spreads of the point cloud.
%
%   shapeIndex : N x 1 numeric vector
%       Signed scalar summarizing shape/orientation:
%
%         positive  -> more vertical (major axis aligned with z)
%         negative  -> more horizontal (major axis aligned with x/y)
%         near zero -> more spherical or oblique
%
%       Definition:
%         Let anisotropy = a/c
%         Let majorAxis = first eigenvector of covariance matrix
%         Let vz = abs(majorAxis(3))
%         Let vh = max(abs(majorAxis(1)), abs(majorAxis(2)))
%
%         orientationScore = vz - vh
%         magnitudeScore   = max(0, (anisotropy - sphericalThresh) / sphericalThresh)
%
%         shapeIndex = orientationScore * magnitudeScore
%
%       Therefore:
%         - spherical objects have shapeIndex near 0
%         - elongated vertical objects have positive values
%         - elongated horizontal objects have negative values
%
%   stats : struct array with one entry per object
%       Fields:
%           .centroid
%           .covMat
%           .eigVec
%           .eigVal
%           .a
%           .b
%           .c
%           .anisotropy
%           .majorAxisVector
%           .orientationScore
%           .magnitudeScore
%           .shapeIndex
%           .nPoints
%
% NOTES
%   - z is treated as the vertical axis.
%   - x and y are treated as horizontal axes.
%   - If you want x or y separately interpreted, that can be added.
%   - Coordinates are rescaled by voxelSize before analysis, so use real
%     voxel dimensions if your stack is anisotropic.
%
% EXAMPLE
%   [abc, shapeIndex, stats] = computePrincipalAxesAndShapeIndex( ...
%       coordCells, [0.5 0.5 1.0]);
%
%   % Interpretation:
%   %   shapeIndex > 0.2   -> fairly vertical
%   %   shapeIndex < -0.2  -> fairly horizontal
%   %   abs(shapeIndex)<0.1 -> approximately spherical / weakly oriented

    arguments
        coordCells cell
        voxelSize (1,3) double = [1 1 1]
        sphericalThresh (1,1) double = 1.2
    end

    nObj = numel(coordCells);

    abc = nan(nObj, 3);
    shapeIndex = nan(nObj, 1);

    stats = repmat(struct( ...
        'centroid', [], ...
        'covMat', [], ...
        'eigVec', [], ...
        'eigVal', [], ...
        'a', NaN, ...
        'b', NaN, ...
        'c', NaN, ...
        'anisotropy', NaN, ...
        'majorAxisVector', [], ...
        'orientationScore', NaN, ...
        'magnitudeScore', NaN, ...
        'shapeIndex', NaN, ...
        'nPoints', 0), nObj, 1);

    for i = 1:nObj
        coords = coordCells{i};

        if isempty(coords)
            warning('Entry %d is empty. Returning NaNs.', i);
            continue
        end

        if ~isnumeric(coords) || size(coords,2) ~= 3
            error('Entry %d must be an Mx3 numeric matrix of [x y z] coordinates.', i);
        end

        if size(coords,1) < 3
            warning('Entry %d has fewer than 3 points. Returning NaNs.', i);
            continue
        end

        % Convert into physical units
        coordsScaled = coords .* voxelSize;

        % Remove duplicate points
        coordsScaled = unique(coordsScaled, 'rows', 'stable');

        if size(coordsScaled,1) < 3
            warning('Entry %d has fewer than 3 unique points after deduplication.', i);
            continue
        end

        % Compute centroid and covariance
        ctr = mean(coordsScaled, 1);
        X = coordsScaled - ctr;
        C = cov(X);

        if any(~isfinite(C), 'all')
            warning('Entry %d produced a non-finite covariance matrix.', i);
            continue
        end

        % Eigen decomposition
        [V, D] = eig(C);
        eigVals = diag(D);

        [eigValsSorted, idx] = sort(eigVals, 'descend');
        V = V(:, idx);

        % Numerical cleanup
        eigValsSorted(eigValsSorted < 0 & eigValsSorted > -1e-12) = 0;

        if any(eigValsSorted < 0)
            warning('Entry %d has negative eigenvalues beyond tolerance.', i);
            continue
        end

        % PCA-derived semiaxis spreads
        axesLengths = sqrt(eigValsSorted);
        a = axesLengths(1);
        b = axesLengths(2);
        c = axesLengths(3);

        abc(i, :) = [a b c];

        % Anisotropy
        if c == 0
            anisotropy = Inf;
        else
            anisotropy = a / c;
        end

        % Major axis direction
        majorAxis = V(:,1);
        majorAxisAbs = abs(majorAxis);

        % Vertical contribution is z
        vz = majorAxisAbs(3);

        % Horizontal contribution is strongest of x or y
        vh = max(majorAxisAbs(1:2));

        % Positive means more vertical, negative more horizontal
        orientationScore = vz - vh;

        % Suppress score for nearly spherical objects
        magnitudeScore = max(0, (anisotropy - sphericalThresh) / sphericalThresh);

        % Final signed scalar index
        thisShapeIndex = orientationScore * magnitudeScore;

        shapeIndex(i) = thisShapeIndex;

        stats(i).centroid = ctr;
        stats(i).covMat = C;
        stats(i).eigVec = V;
        stats(i).eigVal = eigValsSorted;
        stats(i).a = a;
        stats(i).b = b;
        stats(i).c = c;
        stats(i).anisotropy = anisotropy;
        stats(i).majorAxisVector = majorAxis;
        stats(i).orientationScore = orientationScore;
        stats(i).magnitudeScore = magnitudeScore;
        stats(i).shapeIndex = thisShapeIndex;
        stats(i).nPoints = size(coordsScaled, 1);
    end
end