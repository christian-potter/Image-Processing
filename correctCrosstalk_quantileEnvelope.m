function [Rcorr, alpha, b, stats] = correctCrosstalk_quantileEnvelope(G, R, varargin)
% correctCrosstalk_quantileEnvelope
% Blind (no-controls) correction for green->red bleedthrough using a robust
% lower-quantile ("envelope") fit of R vs G:
%   R ~= alpha*G + b  for pixels where true red ~ 0
% then:
%   Rcorr = max(0, R - alpha*G)
%
% INPUTS
%   G, R : 2D (or ND) arrays, same size. Typically raw (linear) intensities.
%
% NAME-VALUE OPTIONS
%   'Quantile'        : lower quantile for envelope fit (default 0.10)
%   'NumBins'         : number of bins along G for envelope estimation (default 128)
%   'MinPixelsPerBin' : minimum pixels in a bin to use its quantile point (default 200)
%   'GMinForFit'      : minimum G intensity to include in fit (default [], auto)
%   'Mask'            : logical mask of pixels to consider (default [], auto from thresholds)
%   'AutoMask'        : true/false, build mask from thresholds (default true)
%   'GThresh'         : threshold for G in auto mask (default [], auto)
%   'RThresh'         : threshold for R in auto mask (default [], auto)
%   'ClipNegative'    : true/false, clip corrected R at 0 (default true)
%   'TileSize'        : scalar, if provided >0 does tile-wise alpha map (default 0 = global)
%   'SmoothAlpha'     : scalar std for gaussian smoothing of alpha map (default 0)
%   'Verbose'         : true/false (default true)
%
% OUTPUTS
%   Rcorr : corrected red channel
%   alpha : estimated bleedthrough slope (scalar or alpha-map if tile-wise)
%   b     : estimated intercept
%   stats : struct with diagnostics

% -------------------- Parse inputs --------------------
p = inputParser;
p.addParameter('Quantile', 0.10, @(x) isnumeric(x) && isscalar(x) && x>0 && x<0.5);
p.addParameter('NumBins', 128, @(x) isnumeric(x) && isscalar(x) && x>=16);
p.addParameter('MinPixelsPerBin', 200, @(x) isnumeric(x) && isscalar(x) && x>=10);
p.addParameter('GMinForFit', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x)));
p.addParameter('Mask', [], @(x) isempty(x) || islogical(x));
p.addParameter('AutoMask', true, @(x) islogical(x) && isscalar(x));
p.addParameter('GThresh', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x)));
p.addParameter('RThresh', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x)));
p.addParameter('ClipNegative', true, @(x) islogical(x) && isscalar(x));
p.addParameter('TileSize', 0, @(x) isnumeric(x) && isscalar(x) && x>=0);
p.addParameter('SmoothAlpha', 0, @(x) isnumeric(x) && isscalar(x) && x>=0);
p.addParameter('Verbose', true, @(x) islogical(x) && isscalar(x));
p.parse(varargin{:});
opt = p.Results;

assert(isequal(size(G), size(R)), 'G and R must be the same size.');

G = double(G);
R = double(R);

% -------------------- Build mask / background reject --------------------
if isempty(opt.Mask)
    if opt.AutoMask
        % Robust thresholds using median + k*MAD (works decently without controls)
        % You can override with 'GThresh'/'RThresh' if you prefer.
        gMed = median(G(:), 'omitnan');
        rMed = median(R(:), 'omitnan');
        gMad = mad(G(:), 1); % median absolute deviation (scaled? here unscaled)
        rMad = mad(R(:), 1);

        if isempty(opt.GThresh), opt.GThresh = gMed + 3*gMad; end
        if isempty(opt.RThresh), opt.RThresh = rMed + 3*rMad; end

        % Consider pixels with some signal in either channel
        mask = (G >= opt.GThresh) | (R >= opt.RThresh);
    else
        mask = true(size(G));
    end
else
    mask = opt.Mask;
end

% Optional: ignore weird negatives / NaNs
mask = mask & isfinite(G) & isfinite(R);

% Auto choose minimum G for fit: avoid near-floor region
if isempty(opt.GMinForFit)
    gVals = G(mask);
    if isempty(gVals)
        error('Mask removed all pixels; adjust thresholds or provide Mask.');
    end
    opt.GMinForFit = prctile(gVals, 10); % start fit above 10th percentile of masked G
end

% -------------------- Choose global vs tile-wise --------------------
if opt.TileSize <= 0
    [alpha, b, fitInfo] = local_fitEnvelopeSlope(G, R, mask, opt);
    Rcorr = R - alpha.*G;  % apply subtraction
    if opt.ClipNegative, Rcorr = max(Rcorr, 0); end

    stats = fitInfo;
    stats.mode = 'global';
else
    % Tile-wise alpha(x,y)
    tile = opt.TileSize;
    sz = size(G);
    if numel(sz) ~= 2
        error('Tile-wise mode currently supports 2D images. Provide a single plane.');
    end

    alphaMap = nan(sz);
    bMap     = nan(sz);

    for y0 = 1:tile:sz(1)
        y1 = min(sz(1), y0+tile-1);
        for x0 = 1:tile:sz(2)
            x1 = min(sz(2), x0+tile-1);

            Gt = G(y0:y1, x0:x1);
            Rt = R(y0:y1, x0:x1);
            mt = mask(y0:y1, x0:x1);

            % If too few pixels, skip
            if nnz(mt) < max(500, opt.MinPixelsPerBin)
                continue;
            end

            try
                [aT, bT] = local_fitEnvelopeSlope(Gt, Rt, mt, opt);
                alphaMap(y0:y1, x0:x1) = aT;
                bMap(y0:y1, x0:x1)     = bT;
            catch
                % leave as NaN
            end
        end
    end

    % Fill missing alpha regions with global estimate (fallback)
    [aGlobal, bGlobal] = local_fitEnvelopeSlope(G, R, mask, opt);
    alphaMap(isnan(alphaMap)) = aGlobal;
    bMap(isnan(bMap)) = bGlobal;

    % Optional smoothing of alpha map (requires Image Processing Toolbox)
    if opt.SmoothAlpha > 0
        try
            alphaMap = imgaussfilt(alphaMap, opt.SmoothAlpha, 'FilterSize', max(3, 2*ceil(2*opt.SmoothAlpha)+1));
        catch
            if opt.Verbose
                warning('imgaussfilt not available; skipping alpha smoothing.');
            end
        end
    end

    Rcorr = R - alphaMap.*G;
    if opt.ClipNegative, Rcorr = max(Rcorr, 0); end

    alpha = alphaMap;
    b = bMap;

    stats = struct();
    stats.mode = 'tile';
    stats.alpha_global = aGlobal;
    stats.b_global = bGlobal;
    stats.alphaMap_min = min(alphaMap(:));
    stats.alphaMap_max = max(alphaMap(:));
end

if opt.Verbose
    if isscalar(alpha)
        fprintf('[crosstalk] Estimated alpha=%.4g, b=%.4g, GMinForFit=%.4g, Nmask=%d\n', ...
            alpha, b, opt.GMinForFit, nnz(mask));
    else
        fprintf('[crosstalk] Estimated tile-wise alpha map. Global fallback alpha=%.4g\n', stats.alpha_global);
    end
end

end

% ==================== Helper: envelope (quantile) slope fit ====================
function [alpha, b, info] = local_fitEnvelopeSlope(G, R, mask, opt)

g = G(mask);
r = R(mask);

% Keep only pixels above a minimum G to stabilize slope estimate
keep = (g >= opt.GMinForFit);
g = g(keep);
r = r(keep);

if numel(g) < 1000
    error('Not enough pixels for fit after masking/GMinForFit. Have %d', numel(g));
end

% Bin along G and compute low-quantile of R in each bin (envelope points)
gMin = min(g);
gMax = max(g);
if gMax <= gMin
    error('G has no dynamic range in masked pixels.');
end

edges = linspace(gMin, gMax, opt.NumBins+1);

gCenters = nan(opt.NumBins,1);
rQ       = nan(opt.NumBins,1);
nBin     = zeros(opt.NumBins,1);

for i = 1:opt.NumBins
    in = (g >= edges(i)) & (g < edges(i+1));
    n = nnz(in);
    nBin(i) = n;
    if n < opt.MinPixelsPerBin
        continue;
    end
    gi = g(in);
    ri = r(in);

    gCenters(i) = median(gi);
    rQ(i)       = quantile(ri, opt.Quantile);
end

use = isfinite(gCenters) & isfinite(rQ);
if nnz(use) < max(8, round(0.1*opt.NumBins))
    error('Too few bins met MinPixelsPerBin; reduce MinPixelsPerBin or NumBins, or adjust mask.');
end

x = gCenters(use);
y = rQ(use);

% Robust line fit y = alpha*x + b
% Prefer robustfit if available; otherwise fall back to polyfit.
if exist('robustfit','file') == 2
    % robustfit returns [b; alpha] when x is column
    coef = robustfit(x, y); % default bisquare
    b     = coef(1);
    alpha = coef(2);
else
    coef = polyfit(x, y, 1);
    alpha = coef(1);
    b     = coef(2);
end

% Enforce plausible alpha >= 0 (green leaking into red)
alpha = max(alpha, 0);

info = struct();
info.alpha = alpha;
info.b = b;
info.numBinsUsed = nnz(use);
info.nMasked = nnz(mask);
info.nUsedPixels = numel(g);
info.quantile = opt.Quantile;
info.numBins = opt.NumBins;
info.minPixelsPerBin = opt.MinPixelsPerBin;
info.GMinForFit = opt.GMinForFit;

end