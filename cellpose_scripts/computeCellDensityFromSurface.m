function out = computeCellDensityFromSurface(soma_labels, surfaceDepthUm, varargin)
%COMPUTECELLDENSITYFROMSURFACE Compute cell density and average cell size vs depth.
%
% out = computeCellDensityFromSurface(soma_labels, surfaceDepthUm)
% out = computeCellDensityFromSurface(..., 'xyPixelSizeUm', 1, 'zStepUm', 1, ...
%                                        'depthMode', 'meanVoxelDepth', ...
%                                        'makePlot', true)
%
% INPUTS
%   soma_labels     : Y x X x Z matrix. Background = 0. Each soma has a
%                     unique positive integer label repeated across its voxels.
%
%   surfaceDepthUm  : Y x X matrix giving the depth (in microns) of the tissue
%                     surface relative to the stack coordinate system at each XY.
%
%                     If surfaceDepthUm(y,x) = 12, then the surface at that XY
%                     lies 12 microns below z = 0 in stack coordinates.
%
%                     The depth from the surface of a voxel at plane z is:
%                         voxelDepthFromSurfaceUm = zCoordUm - surfaceDepthUm(y,x)
%
%                     where zCoordUm = (z-1) * zStepUm
%
% NAME-VALUE OPTIONS
%   'xyPixelSizeUm' : Size of one XY pixel in microns. Default = 1.
%   'zStepUm'       : Distance between z planes in microns. Default = 1.
%   'depthMode'     : How to assign one depth to each soma:
%                       'meanVoxelDepth'   -> mean relative depth of all soma voxels
%                       'centroidDepth'    -> depth from surface at 3D centroid
%                     Default = 'meanVoxelDepth'
%   'makePlot'      : true/false. Default = true
%
% OUTPUT
%   out is a structure with fields:
%       .depthBinsUm              % integer depth bins (um)
%       .cellCounts               % number of cells assigned to each depth bin
%       .availableAreaPix         % number of XY pixels that exist at that depth
%       .availableVolumeUm3       % available tissue volume in each 1-um bin
%       .densityCellsPerUm3       % cells / um^3 for each depth bin
%       .densityCellsPerMM3       % cells / mm^3 for each depth bin
%
%       .avgCellSizeVoxels        % mean soma size (voxels) in each depth bin
%       .avgCellSizeUm3           % mean soma size (um^3) in each depth bin
%       .sumCellSizeVoxels        % sum of soma sizes (voxels) in each depth bin
%       .sumCellSizeUm3           % sum of soma sizes (um^3) in each depth bin
%
%       .cellLabel                % label id for each cell
%       .cellDepthUm              % assigned depth for each cell
%       .cellDepthBinUm           % integer depth bin for each cell
%       .cellSizeVoxels           % size of each cell in voxels
%       .cellSizeUm3              % size of each cell in um^3
%
% NOTES
%   1) This computes density using ONE depth value per soma, not every voxel.
%   2) Cell size is computed from the number of labeled voxels in each soma.
%   3) The denominator for density is the available tissue volume at each
%      relative depth, estimated from the curved surface map.
%
% EXAMPLE
%   out = computeCellDensityFromSurface(soma_labels, surfaceDepthUm, ...
%           'xyPixelSizeUm', 0.8, 'zStepUm', 1, ...
%           'depthMode', 'meanVoxelDepth', 'makePlot', true);

% ---------------- Parse inputs ----------------
p = inputParser;
p.addParameter('xyPixelSizeUm', 1, @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('zStepUm', 1, @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('depthMode', 'meanVoxelDepth', @(x) ischar(x) || isstring(x));
p.addParameter('makePlot', true, @(x) islogical(x) && isscalar(x));
p.parse(varargin{:});

xyPixelSizeUm = p.Results.xyPixelSizeUm;
zStepUm       = p.Results.zStepUm;
depthMode     = char(p.Results.depthMode);
makePlot      = p.Results.makePlot;

% ---------------- Validate sizes ----------------
if ndims(soma_labels) ~= 3
    error('soma_labels must be a 3D matrix of size Y x X x Z.');
end

[Y, X, Z] = size(soma_labels);

if ~isequal(size(surfaceDepthUm), [Y, X])
    error('surfaceDepthUm must have size Y x X matching the first two dimensions of soma_labels.');
end

soma_labels = double(soma_labels);
surfaceDepthUm = double(surfaceDepthUm);

% ---------------- Label list ----------------
labelIDs = unique(soma_labels(:));
labelIDs(labelIDs <= 0) = [];
nCells = numel(labelIDs);

if nCells == 0
    warning('No positive labels found in soma_labels.');
    out = struct();
    return;
end

% ---------------- Geometry ----------------
zCoordUm = reshape((0:Z-1) * zStepUm, 1, 1, Z);
zCoordUm = repmat(zCoordUm, Y, X, 1);

surfaceDepth3D = repmat(surfaceDepthUm, 1, 1, Z);
relDepthUm = zCoordUm - surfaceDepth3D;

voxelVolumeUm3 = (xyPixelSizeUm^2) * zStepUm;

% ---------------- Per-cell measurements ----------------
cellDepthUm = nan(nCells, 1);
cellSizeVoxels = nan(nCells, 1);

switch lower(depthMode)
    case 'meanvoxeldepth'
        for i = 1:nCells
            id = labelIDs(i);
            mask = (soma_labels == id);
            cellDepthUm(i) = mean(relDepthUm(mask), 'omitnan');
            cellSizeVoxels(i) = nnz(mask);
        end

    case 'centroiddepth'
        for i = 1:nCells
            id = labelIDs(i);
            mask = (soma_labels == id);
            cellSizeVoxels(i) = nnz(mask);

            [yy, xx, zz] = ind2sub([Y, X, Z], find(mask));

            yc = mean(yy);
            xc = mean(xx);
            zc = mean(zz);

            y0 = min(max(round(yc), 1), Y);
            x0 = min(max(round(xc), 1), X);
            z0 = min(max(round(zc), 1), Z);

            voxelZUm = (z0 - 1) * zStepUm;
            cellDepthUm(i) = voxelZUm - surfaceDepthUm(y0, x0);
        end

    otherwise
        error('Unknown depthMode: %s', depthMode);
end

cellSizeUm3 = cellSizeVoxels * voxelVolumeUm3;

% ---------------- Bin cells into integer micron bins ----------------
cellDepthBinUm = round(cellDepthUm);

validCells = isfinite(cellDepthBinUm) & (cellDepthBinUm >= 0);

labelIDs        = labelIDs(validCells);
cellDepthUm     = cellDepthUm(validCells);
cellDepthBinUm  = cellDepthBinUm(validCells);
cellSizeVoxels  = cellSizeVoxels(validCells);
cellSizeUm3     = cellSizeUm3(validCells);

if isempty(cellDepthBinUm)
    warning('No cells remained after depth filtering.');
    out = struct();
    return;
end

maxCellDepthBin = max(cellDepthBinUm);
depthBinsUm = (0:maxCellDepthBin).';

% ---------------- Available tissue volume per depth bin ----------------
maxZUm = (Z - 1) * zStepUm;
availableAreaPix = zeros(size(depthBinsUm));

for k = 1:numel(depthBinsUm)
    d = depthBinsUm(k);

    absZUm = surfaceDepthUm + d;
    inside = (absZUm >= 0) & (absZUm <= maxZUm);

    zIdx = round(absZUm / zStepUm) + 1;
    inside = inside & (zIdx >= 1) & (zIdx <= Z);

    availableAreaPix(k) = nnz(inside);
end

availableVolumeUm3 = availableAreaPix * voxelVolumeUm3;

% ---------------- Per-depth counts and density ----------------
cellCounts = accumarray(cellDepthBinUm + 1, 1, [maxCellDepthBin + 1, 1], @sum, 0);

densityCellsPerUm3 = cellCounts ./ availableVolumeUm3;
densityCellsPerUm3(availableVolumeUm3 == 0) = NaN;

densityCellsPerMM3 = densityCellsPerUm3 * 1e9;

% ---------------- Per-depth cell size summaries ----------------
sumCellSizeVoxels = accumarray(cellDepthBinUm + 1, cellSizeVoxels, ...
    [maxCellDepthBin + 1, 1], @sum, 0);

sumCellSizeUm3 = accumarray(cellDepthBinUm + 1, cellSizeUm3, ...
    [maxCellDepthBin + 1, 1], @sum, 0);

avgCellSizeVoxels = sumCellSizeVoxels ./ cellCounts;
avgCellSizeUm3    = sumCellSizeUm3 ./ cellCounts;

avgCellSizeVoxels(cellCounts == 0) = NaN;
avgCellSizeUm3(cellCounts == 0)    = NaN;

% ---------------- Output ----------------
out = struct();
out.depthBinsUm          = depthBinsUm;
out.cellCounts           = cellCounts;
out.availableAreaPix     = availableAreaPix;
out.availableVolumeUm3   = availableVolumeUm3;
out.densityCellsPerUm3   = densityCellsPerUm3;
out.densityCellsPerMM3   = densityCellsPerMM3;

out.avgCellSizeVoxels    = avgCellSizeVoxels;
out.avgCellSizeUm3       = avgCellSizeUm3;
out.sumCellSizeVoxels    = sumCellSizeVoxels;
out.sumCellSizeUm3       = sumCellSizeUm3;

out.cellLabel            = labelIDs;
out.cellDepthUm          = cellDepthUm;
out.cellDepthBinUm       = cellDepthBinUm;
out.cellSizeVoxels       = cellSizeVoxels;
out.cellSizeUm3          = cellSizeUm3;

% ---------------- Plot ----------------
if makePlot
    figure('Color', 'w', 'Name', 'Cell density and size vs surface depth');

    subplot(4,1,1);
    bar(depthBinsUm, cellCounts);
    xlabel('Depth from surface (\mum)');
    ylabel('Cell count');
    title('Cells assigned to each depth bin');
    box off;

    subplot(4,1,2);
    plot(depthBinsUm, densityCellsPerMM3, 'LineWidth', 1.5);
    xlabel('Depth from surface (\mum)');
    ylabel('Density (cells/mm^3)');
    title('Cell density vs depth');
    box off;

    subplot(4,1,3);
    plot(depthBinsUm, avgCellSizeVoxels, 'LineWidth', 1.5);
    xlabel('Depth from surface (\mum)');
    ylabel('Mean size (voxels)');
    title('Average cell size vs depth');
    box off;

    subplot(4,1,4);
    plot(depthBinsUm, avgCellSizeUm3, 'LineWidth', 1.5);
    xlabel('Depth from surface (\mum)');
    ylabel('Mean size (\mum^3)');
    title('Average cell size vs depth');
    box off;
end
end