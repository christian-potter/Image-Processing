function out = estimatePerPixelEntryDepth(zstackRGB, dz_um, opts)
% estimatePerPixelEntryDepth_RG
% Per (x,y) pixel, estimate the first z where the sample appears, using only
% the Red and Green channels of an RGB z-stack.
%
% EXPECTED INPUT FORMATS
%   - Numeric: HxWx3xZ  (preferred)
%   - Numeric: HxWxZx3  (auto-detected and permuted internally)
%   - Cell array: {Zx1}, each cell is HxWx3
%
% OUTPUT (struct)
%   out.zEntryIdx   : HxW first z index where pixel becomes sample (NaN outside sample)
%   out.zEntryUm    : HxW entry depth in microns, with z=1 -> 0 um by convention
%   out.sampleFoot  : HxW logical footprint derived from last slice (fully exposed)
%   out.params      : resolved options

    if nargin < 2 || isempty(dz_um), dz_um = 1; end
    if nargin < 3, opts = struct(); end

    % -------- defaults --------
    d = struct();
    d.smoothSigma          = 1.0;   % gaussian smoothing (px)
    d.bgDiskRadius         = 25;    % background estimation radius (px); 0 disables
    d.minObjectAreaPx      = 200;   % remove small components (per slice)
    d.useAdaptive          = true;  % adaptive threshold vs Otsu
    d.adaptSensitivity     = 0.55;  % imbinarize adaptive sensitivity
    d.invertIfDarkOnBright = false; % fluorescence typical: bright objects -> keep false
    d.enforceMonotonic     = true;  % once present, stays present along z
    d.minConsecutive       = 2;     % require pixel present for N consecutive slices (>=1)
    d.combineRG            = "max"; % "max" or "sum" for combining R and G after preprocessing
    d.verbose              = true;
    d.debugShow            = false;

    opts = applyDefaults(opts, d);

    % -------- normalize/standardize stack representation --------
    stack = standardizeRGBStack(zstackRGB); % returns numeric HxWx3xZ double [0,1]
    [H, W, ~, Z] = size(stack);

    % -------- build per-slice masks (from R and G only) --------
    BWvol = false(H, W, Z);

    for k = 1:Z
        Irgb = stack(:,:,:,k); % HxWx3 double in [0,1]

        R = Irgb(:,:,1);
        G = Irgb(:,:,2);

        % Smooth (per channel)
        if opts.smoothSigma > 0
            R = imgaussfilt(R, opts.smoothSigma);
            G = imgaussfilt(G, opts.smoothSigma);
        end

        % Background subtraction (per channel)
        if opts.bgDiskRadius > 0
            se = strel('disk', opts.bgDiskRadius);
            Rbg = imopen(R, se);  R = mat2gray(R - Rbg);
            Gbg = imopen(G, se);  G = mat2gray(G - Gbg);
        else
            R = mat2gray(R);
            G = mat2gray(G);
        end

        % Combine R and G into a single "sample evidence" image
        switch lower(string(opts.combineRG))
            case "max"
                I = max(R, G);
            case "sum"
                I = R + G;
                I = mat2gray(I);
            otherwise
                error('opts.combineRG must be "max" or "sum".');
        end

        % Inversion (generally false for fluorescence)
        if opts.invertIfDarkOnBright
            I = imcomplement(I);
        end

        % Threshold to foreground mask
        if opts.useAdaptive
            BW = imbinarize(I, 'adaptive', ...
                'Sensitivity', opts.adaptSensitivity, ...
                'ForegroundPolarity', 'bright');
        else
            BW = imbinarize(I, graythresh(I));
        end

        % Clean per slice
        BW = bwareaopen(BW, opts.minObjectAreaPx);
        BW = imfill(BW, 'holes');

        BWvol(:,:,k) = BW;

        if opts.debugShow && (k == 1 || k == Z)
            figure('Name', sprintf('Debug slice %d', k));
            tiledlayout(2,3);
            nexttile; imshow(R, []); title('R (pre)');
            nexttile; imshow(G, []); title('G (pre)');
            nexttile; imshow(I, []); title('Combine(R,G)');
            nexttile; imshow(stack(:,:,:,k)); title('RGB');
            nexttile; imshow(BW); title('Mask');
            nexttile; imshow(label2rgb(bwlabel(BW))); title('Components');
        end
    end

    % -------- define sample footprint from last slice (fully exposed) --------
    sampleFoot = BWvol(:,:,Z);
    sampleFoot = imfill(sampleFoot, 'holes');
    sampleFoot = bwareaopen(sampleFoot, opts.minObjectAreaPx);

    % Restrict detection to within final footprint (suppresses background noise)
    BWvol = BWvol & repmat(sampleFoot, 1, 1, Z);

    % -------- enforce monotonic exposure along z (optional) --------
    if opts.enforceMonotonic
        BWvol = cummax(BWvol, 3);
    end

    % -------- require N consecutive slices (optional) --------
    N = max(1, round(opts.minConsecutive));
    if N > 1
        BWrun = movsum(BWvol, [N-1 0], 3) >= N;
        BWused = BWrun;
        offset = N - 1; % entry is k-(N-1)
    else
        BWused = BWvol;
        offset = 0;
    end

    % -------- first z where BWused becomes true, per pixel --------
    zEntryIdx = nan(H, W);
    found = false(H, W);

    for k = 1:Z
        newly = BWused(:,:,k) & ~found;
        if any(newly(:))
            zEntryIdx(newly) = k - offset;
            found(newly) = true;
        end
        if all(found(sampleFoot), 'all')
            break;
        end
    end

    zEntryIdx(~sampleFoot) = NaN;
    zEntryUm = (zEntryIdx - 1) * dz_um;

    out = struct();
    out.zEntryIdx  = zEntryIdx;
    out.zEntryUm   = zEntryUm;
    out.sampleFoot = sampleFoot;
    out.params     = opts;

    if opts.verbose
        finiteVals = zEntryIdx(isfinite(zEntryIdx));
        if ~isempty(finiteVals)
            fprintf('Per-pixel entry depth (R+G) computed.\n');
            fprintf('  Min entry z: %d (%.3f um)\n', min(finiteVals), (min(finiteVals)-1)*dz_um);
            fprintf('  Max entry z: %d (%.3f um)\n', max(finiteVals), (max(finiteVals)-1)*dz_um);
        else
            fprintf('No sample pixels detected in last slice footprint.\n');
        end
    end
end

% ---------------- helpers ----------------

function opts = applyDefaults(opts, d)
    fn = fieldnames(d);
    for i = 1:numel(fn)
        if ~isfield(opts, fn{i}) || isempty(opts.(fn{i}))
            opts.(fn{i}) = d.(fn{i});
        end
    end
end

function stack = standardizeRGBStack(zstackRGB)
    % Returns numeric double stack HxWx3xZ in [0,1]
    if iscell(zstackRGB)
        Z = numel(zstackRGB);
        first = zstackRGB{1};
        assert(ndims(first) == 3 && size(first,3) == 3, ...
            'Cell stack must contain HxWx3 RGB images.');
        [H,W,~] = size(first);
        stack = zeros(H,W,3,Z, 'double');
        for k = 1:Z
            Ik = zstackRGB{k};
            assert(ndims(Ik) == 3 && size(Ik,3) == 3, 'All slices must be HxWx3.');
            stack(:,:,:,k) = im2double(Ik);
        end
        return;
    end

    if ~isnumeric(zstackRGB)
        error('zstackRGB must be a numeric array or a cell array of RGB images.');
    end

    nd = ndims(zstackRGB);
    if nd ~= 4
        error('Numeric RGB zstack must be 4D: HxWx3xZ (preferred) or HxWxZx3.');
    end

    sz = size(zstackRGB);

    % Preferred: HxWx3xZ
    if sz(3) == 3
        stack = im2double(zstackRGB);
        return;
    end

    % Alternate: HxWxZx3
    if sz(4) == 3
        stack = permute(zstackRGB, [1 2 4 3]); % -> HxWx3xZ
        stack = im2double(stack);
        return;
    end

    error('Could not identify channel dimension. Provide HxWx3xZ or HxWxZx3.');
end
