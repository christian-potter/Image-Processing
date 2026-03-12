function out = findRedSurfaceDepth(V, opts)
%FINDREDSURFACEDEPTH Detect a red-channel surface from the top of a z-stack.
%
% This function:
%   1) scans from the top of the z-stack downward
%   2) finds the first significant red signal in each XY bin
%   3) estimates a smooth/fitted surface from those depths
%   4) optionally enforces a local slope constraint such that moving by
%      one x or y pixel cannot change the depth by more than a specified amount
%   5) returns a 1-voxel-thick binary X x Y x Z surface volume
%
% INPUT
%   V : X x Y x Z x RGB numeric array
%
% OPTIONS
%   Detection options
%   -----------------
%   .BinSize             - scalar or [bx by], default [10 10]
%   .RedChannel          - index of red channel in 4th dimension, default 1
%   .Statistic           - 'mean', 'median', 'max', or 'fraction'
%                          default 'mean'
%   .ThresholdMode       - 'absolute' or 'relative', default 'relative'
%   .Threshold           - threshold value
%                          if relative and empty, default = 0.20
%                          if absolute, must be specified
%   .MinVoxelFraction    - for Statistic='fraction', default 0.10
%   .PixelThreshold      - per-pixel threshold for Statistic='fraction'
%                          if empty, estimated automatically
%   .SmoothZ             - smooth each bin's z trace before thresholding
%                          default true
%   .SmoothWindow        - z smoothing window, default 3
%   .MinConsecutiveZ     - require threshold crossing for this many
%                          consecutive z planes, default 1
%   .UseGlobalNorm       - for relative thresholding:
%                          true  -> normalize by global max across all bins
%                          false -> normalize each bin independently
%                          default false
%   .ReturnNaNIfMissing  - if no depth found, return NaN, default true
%
%   Surface estimation options
%   --------------------------
%   .SurfaceMode         - one of:
%                          'none'
%                          'smooth'
%                          'interp'
%                          'poly2'
%                          'poly3'
%                          'smooth_constrained'
%                          'interp_constrained'
%                          'poly2_constrained'
%                          'poly3_constrained'
%                          default 'smooth'
%   .SurfaceSmoothSigma  - smoothing sigma in BIN units for coarse map
%                          default 1
%   .SurfaceFillMissing  - fill missing coarse bins before fitting/smoothing
%                          default true
%   .InterpMethod        - for interpolant surface:
%                          'natural', 'linear', or 'nearest'
%                          default 'natural'
%
%   Constraint options
%   ------------------
%   .MaxDeltaPerPixel    - maximum allowed depth change per XY pixel
%                          for constrained surface modes, default 3
%   .ConstraintIterations - number of projection passes for constraint
%                           default 30
%
% OUTPUT
%   out.depthMap              - raw binned depth map (nBinX x nBinY)
%   out.depthImage            - raw expanded X x Y depth image
%   out.depthVolume           - raw 1-voxel-thick X x Y x Z volume
%   out.surfaceMapRaw         - same as depthMap
%   out.surfaceMapSmooth      - coarse smoothed/fitted surface map
%   out.surfaceImageSmooth    - full-resolution expanded surface image
%   out.surfaceImageConstrained - full-resolution constrained surface image
%   out.surfaceVolumeSmooth   - final 1-voxel-thick X x Y x Z surface volume
%   out.binMetric             - nBinX x nBinY x Z metric used for detection
%   out.binEdgesX             - x bin edges
%   out.binEdgesY             - y bin edges
%   out.thresholdUsed         - threshold used
%   out.params                - resolved input options
%
% EXAMPLE
%   opts = struct;
%   opts.BinSize = [10 10];
%   opts.RedChannel = 1;
%   opts.Statistic = 'max';
%   opts.ThresholdMode = 'relative';
%   opts.Threshold = 0.25;
%   opts.MinConsecutiveZ = 2;
%   opts.SurfaceMode = 'smooth_constrained';
%   opts.SurfaceSmoothSigma = 1.2;
%   opts.MaxDeltaPerPixel = 3;
%   opts.ConstraintIterations = 30;
%   out = findRedSurfaceDepth(V, opts);
%
%   figure;
%   imagesc(out.surfaceImageConstrained);
%   axis image;
%   set(gca, 'YDir', 'normal');
%   colorbar;
%
%   volshow(out.surfaceVolumeSmooth)

arguments
    V {mustBeNumeric, mustBeNonempty}

    opts.BinSize = [10 10]
    opts.RedChannel (1,1) double {mustBePositive, mustBeInteger} = 1
    opts.Statistic (1,:) char {mustBeMember(opts.Statistic, {'mean','median','max','fraction'})} = 'mean'
    opts.ThresholdMode (1,:) char {mustBeMember(opts.ThresholdMode, {'absolute','relative'})} = 'relative'
    opts.Threshold = []
    opts.MinVoxelFraction (1,1) double {mustBeGreaterThanOrEqual(opts.MinVoxelFraction,0), mustBeLessThanOrEqual(opts.MinVoxelFraction,1)} = 0.10
    opts.PixelThreshold = []
    opts.SmoothZ (1,1) logical = true
    opts.SmoothWindow (1,1) double {mustBePositive, mustBeInteger} = 3
    opts.MinConsecutiveZ (1,1) double {mustBePositive, mustBeInteger} = 1
    opts.UseGlobalNorm (1,1) logical = false
    opts.ReturnNaNIfMissing (1,1) logical = true

    opts.SurfaceMode (1,:) char {mustBeMember(opts.SurfaceMode, ...
        {'none','smooth','interp','poly2','poly3', ...
         'smooth_constrained','interp_constrained','poly2_constrained','poly3_constrained'})} = 'smooth'
    opts.SurfaceSmoothSigma (1,1) double {mustBeNonnegative} = 1
    opts.SurfaceFillMissing (1,1) logical = true
    opts.InterpMethod (1,:) char {mustBeMember(opts.InterpMethod, {'natural','linear','nearest'})} = 'natural'

    opts.MaxDeltaPerPixel (1,1) double {mustBeNonnegative} = 3
    opts.ConstraintIterations (1,1) double {mustBePositive, mustBeInteger} = 30
end

if ndims(V) ~= 4
    error('V must be an X x Y x Z x RGB array.');
end

[nX, nY, nZ, nC] = size(V);

if opts.RedChannel > nC
    error('opts.RedChannel exceeds the number of channels in V.');
end

% Resolve bin size
binSize = opts.BinSize;
if isscalar(binSize)
    bx = binSize;
    by = binSize;
else
    if numel(binSize) ~= 2
        error('opts.BinSize must be a scalar or a 2-element vector [bx by].');
    end
    bx = binSize(1);
    by = binSize(2);
end

% Extract red channel
R = double(V(:,:,:,opts.RedChannel));

% Bin edges
xStarts = 1:bx:nX;
yStarts = 1:by:nY;
nBinX = numel(xStarts);
nBinY = numel(yStarts);

xEdges = zeros(nBinX, 2);
for ix = 1:nBinX
    x1 = xStarts(ix);
    x2 = min(x1 + bx - 1, nX);
    xEdges(ix,:) = [x1 x2];
end

yEdges = zeros(nBinY, 2);
for iy = 1:nBinY
    y1 = yStarts(iy);
    y2 = min(y1 + by - 1, nY);
    yEdges(iy,:) = [y1 y2];
end

xCenters = mean(xEdges, 2);
yCenters = mean(yEdges, 2);

% Compute bin metric across z
binMetric = nan(nBinX, nBinY, nZ);

pixelThreshold = opts.PixelThreshold;
if strcmp(opts.Statistic, 'fraction') && isempty(pixelThreshold)
    vals = R(:);
    vals = vals(isfinite(vals));
    if isempty(vals)
        error('Red channel contains no finite values.');
    end
    medVal = median(vals);
    madVal = median(abs(vals - medVal));
    robustSigma = 1.4826 * madVal;
    pixelThreshold = medVal + 3 * robustSigma;
end

for ix = 1:nBinX
    xr = xEdges(ix,1):xEdges(ix,2);

    for iy = 1:nBinY
        yr = yEdges(iy,1):yEdges(iy,2);
        block = R(xr, yr, :);  % bx x by x z

        switch opts.Statistic
            case 'mean'
                trace = squeeze(mean(block, [1 2], 'omitnan'));

            case 'median'
                tmp = reshape(block, [], nZ);
                trace = median(tmp, 1, 'omitnan')';

            case 'max'
                tmp = reshape(block, [], nZ);
                trace = max(tmp, [], 1, 'omitnan')';

            case 'fraction'
                above = block > pixelThreshold;
                trace = squeeze(mean(above, [1 2], 'omitnan'));

            otherwise
                error('Unsupported statistic.');
        end

        trace = trace(:);

        if opts.SmoothZ && opts.SmoothWindow > 1
            trace = movmean(trace, opts.SmoothWindow, 'omitnan');
        end

        binMetric(ix, iy, :) = trace;
    end
end

% Threshold
thresholdUsed = opts.Threshold;
switch opts.ThresholdMode
    case 'absolute'
        if isempty(thresholdUsed)
            error('For ThresholdMode=''absolute'', opts.Threshold must be specified.');
        end

    case 'relative'
        if isempty(thresholdUsed)
            thresholdUsed = 0.20;
        end
end

% Detect raw depth in each bin
depthMap = nan(nBinX, nBinY);

for ix = 1:nBinX
    for iy = 1:nBinY
        trace = squeeze(binMetric(ix, iy, :));

        if strcmp(opts.ThresholdMode, 'relative')
            if opts.UseGlobalNorm
                denom = max(binMetric(:), [], 'omitnan');
            else
                denom = max(trace, [], 'omitnan');
            end

            if isempty(denom) || isnan(denom) || denom <= 0
                crossing = false(size(trace));
            else
                crossing = (trace ./ denom) >= thresholdUsed;
            end
        else
            crossing = trace >= thresholdUsed;
        end

        zFirst = findFirstConsecutiveTrue(crossing, opts.MinConsecutiveZ);

        if isempty(zFirst)
            if opts.ReturnNaNIfMissing
                depthMap(ix, iy) = NaN;
            else
                depthMap(ix, iy) = nZ + 1;
            end
        else
            depthMap(ix, iy) = zFirst;
        end
    end
end

% Raw expanded outputs
depthImage = expandBinnedMap(depthMap, xEdges, yEdges, nX, nY);
depthVolume = mapToVolume(depthImage, nZ);

% Surface estimation
surfaceMapRaw = depthMap;
surfaceMapSmooth = estimateSurface(depthMap, xCenters, yCenters, opts, nZ);
surfaceImageSmooth = expandBinnedMap(surfaceMapSmooth, xEdges, yEdges, nX, nY);

% Apply per-pixel slope constraint if requested
if contains(opts.SurfaceMode, 'constrained')
    surfaceImageConstrained = enforceMaxDeltaSurface( ...
        surfaceImageSmooth, ...
        opts.MaxDeltaPerPixel, ...
        nZ, ...
        opts.ConstraintIterations);
else
    surfaceImageConstrained = surfaceImageSmooth;
end

% Final 1-voxel-thick sheet
surfaceVolumeSmooth = mapToVolume(surfaceImageConstrained, nZ);

% Pack outputs
out = struct();
out.depthMap = depthMap;
out.depthImage = depthImage;
out.depthVolume = depthVolume;

out.surfaceMapRaw = surfaceMapRaw;
out.surfaceMapSmooth = surfaceMapSmooth;
out.surfaceImageSmooth = surfaceImageSmooth;
out.surfaceImageConstrained = surfaceImageConstrained;
out.surfaceVolumeSmooth = surfaceVolumeSmooth;

out.binMetric = binMetric;
out.binEdgesX = xEdges;
out.binEdgesY = yEdges;
out.thresholdUsed = thresholdUsed;
out.params = opts;

if strcmp(opts.Statistic, 'fraction')
    out.pixelThresholdUsed = pixelThreshold;
end

end

function zFirst = findFirstConsecutiveTrue(tf, nConsecutive)
%FINDFIRSTCONSECUTIVETRUE Find first index with nConsecutive true values.

tf = logical(tf(:));
zFirst = [];

if nConsecutive <= 1
    idx = find(tf, 1, 'first');
    if ~isempty(idx)
        zFirst = idx;
    end
    return;
end

runLen = conv(double(tf), ones(nConsecutive,1), 'valid');
idx = find(runLen == nConsecutive, 1, 'first');
if ~isempty(idx)
    zFirst = idx;
end

end

function img = expandBinnedMap(map, xEdges, yEdges, nX, nY)
%EXPANDBINNEDMAP Expand binned map back into full X x Y image.

img = nan(nX, nY);

for ix = 1:size(xEdges,1)
    xr = xEdges(ix,1):xEdges(ix,2);
    for iy = 1:size(yEdges,1)
        yr = yEdges(iy,1):yEdges(iy,2);
        img(xr, yr) = map(ix, iy);
    end
end

end

function vol = mapToVolume(depthImage, nZ)
%MAPTOVOLUME Convert X x Y depth image to 1-voxel-thick X x Y x Z volume.

[nX, nY] = size(depthImage);
vol = zeros(nX, nY, nZ, 'uint8');

zIdx = round(depthImage);
valid = isfinite(zIdx) & zIdx >= 1 & zIdx <= nZ;

[ix, iy] = find(valid);
for k = 1:numel(ix)
    vol(ix(k), iy(k), zIdx(ix(k), iy(k))) = 1;
end

end

function surfaceMap = estimateSurface(depthMap, xCenters, yCenters, opts, nZ)
%ESTIMATESURFACE Estimate coarse binned surface from depthMap.

surfaceMap = depthMap;

if all(~isfinite(depthMap(:)))
    return;
end

workMap = depthMap;

if opts.SurfaceFillMissing
    workMap = fillMissing2D(workMap);
end

baseMode = erase(opts.SurfaceMode, '_constrained');

switch baseMode
    case 'none'
        surfaceMap = workMap;

    case 'smooth'
        if opts.SurfaceSmoothSigma > 0
            h = gaussianKernel2D(opts.SurfaceSmoothSigma);

            validMask = isfinite(workMap);
            tmp = workMap;
            tmp(~validMask) = 0;

            num = conv2(tmp, h, 'same');
            den = conv2(double(validMask), h, 'same');

            surfaceMap = num ./ den;
            surfaceMap(den == 0) = NaN;
        else
            surfaceMap = workMap;
        end

    case {'poly2','poly3'}
        [Xc, Yc] = ndgrid(xCenters, yCenters);
        valid = isfinite(workMap);

        x = Xc(valid);
        y = Yc(valid);
        z = workMap(valid);

        if numel(z) < 6
            surfaceMap = workMap;
            return;
        end

        polyOrder = sscanf(baseMode, 'poly%d');
        A = polyDesignMatrix(x, y, polyOrder);
        coeff = A \ z;

        Agrid = polyDesignMatrix(Xc(:), Yc(:), polyOrder);
        zfit = Agrid * coeff;
        surfaceMap = reshape(zfit, size(workMap));

    case 'interp'
        [Xc, Yc] = ndgrid(xCenters, yCenters);
        valid = isfinite(workMap);

        x = Xc(valid);
        y = Yc(valid);
        z = workMap(valid);

        if numel(z) < 3
            surfaceMap = workMap;
            return;
        end

        F = scatteredInterpolant(x, y, z, opts.InterpMethod, 'nearest');
        surfaceMap = F(Xc, Yc);

        if opts.SurfaceSmoothSigma > 0
            h = gaussianKernel2D(opts.SurfaceSmoothSigma);
            surfaceMap = conv2(surfaceMap, h, 'same');
        end

    otherwise
        error('Unsupported surface mode.');
end

surfaceMap = max(surfaceMap, 1);
surfaceMap = min(surfaceMap, nZ);

end

function A = polyDesignMatrix(x, y, order)
%POLYDESIGNMATRIX Design matrix for 2D polynomial fit.

x = x(:);
y = y(:);

switch order
    case 2
        A = [ ...
            ones(size(x)), ...
            x, y, ...
            x.^2, x.*y, y.^2];

    case 3
        A = [ ...
            ones(size(x)), ...
            x, y, ...
            x.^2, x.*y, y.^2, ...
            x.^3, (x.^2).*y, x.*(y.^2), y.^3];

    otherwise
        error('Only polynomial orders 2 and 3 are supported.');
end

end

function out = fillMissing2D(in)
%FILLMISSING2D Fill NaNs in 2D map using scattered interpolation.

out = in;

if all(isfinite(out(:)))
    return;
end

[nr, nc] = size(out);
[X, Y] = ndgrid(1:nr, 1:nc);

valid = isfinite(out);
if nnz(valid) < 3
    return;
end

F = scatteredInterpolant(X(valid), Y(valid), out(valid), 'natural', 'nearest');
out(~valid) = F(X(~valid), Y(~valid));

end

function h = gaussianKernel2D(sigma)
%GAUSSIANKERNEL2D Create normalized 2D Gaussian kernel.

if sigma <= 0
    h = 1;
    return;
end

halfWidth = max(1, ceil(3*sigma));
[x, y] = ndgrid(-halfWidth:halfWidth, -halfWidth:halfWidth);
h = exp(-(x.^2 + y.^2) / (2*sigma^2));
h = h / sum(h(:));

end

function S = enforceMaxDeltaSurface(S, maxDelta, nZ, nIter)
%ENFORCEMAXDELTASURFACE Enforce local slope constraint on full-res surface.
%
% After this function, adjacent pixels in X or Y are constrained so that
% their depth difference is not allowed to exceed maxDelta.
%
% This is done by iterative forward/backward projection passes.

if nargin < 4 || isempty(nIter)
    nIter = 30;
end

S = double(S);

if any(~isfinite(S(:)))
    S = fillMissing2D(S);
end

[nX, nY] = size(S);

for it = 1:nIter

    % Forward pass along X
    for i = 2:nX
        S(i,:) = min(S(i,:), S(i-1,:) + maxDelta);
        S(i,:) = max(S(i,:), S(i-1,:) - maxDelta);
    end

    % Backward pass along X
    for i = nX-1:-1:1
        S(i,:) = min(S(i,:), S(i+1,:) + maxDelta);
        S(i,:) = max(S(i,:), S(i+1,:) - maxDelta);
    end

    % Forward pass along Y
    for j = 2:nY
        S(:,j) = min(S(:,j), S(:,j-1) + maxDelta);
        S(:,j) = max(S(:,j), S(:,j-1) - maxDelta);
    end

    % Backward pass along Y
    for j = nY-1:-1:1
        S(:,j) = min(S(:,j), S(:,j+1) + maxDelta);
        S(:,j) = max(S(:,j), S(:,j+1) - maxDelta);
    end

    % Keep within valid z range
    S = max(S, 1);
    S = min(S, nZ);
end

end