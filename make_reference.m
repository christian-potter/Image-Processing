function [avgPlane, avgGreen, avgRed, meta] = make_reference(tifPath, nPlanes)
% avgPlanesFromInterleavedTiff  Average per plane from interleaved G/R multi-page TIFF
%
% Order per cycle: G(p1), R(p1), G(p2), R(p2), ..., G(pN), R(pN), then repeats.
%
% Inputs
%   tifPath  - path to the .tif/.tiff file
%   nPlanes  - number of imaging planes (N)
%
% Outputs
%   avgPlane - H x W x N array: mean of (Green+Red)/2 for each plane
%   avgGreen - H x W x N array: mean of Green channel for each plane
%   avgRed   - H x W x N array: mean of Red channel for each plane
%   meta     - struct with helpful metadata (height, width, nFrames, nCycles, class)
%
% Example:
%   [avgP, avgG, avgR, meta] = avgPlanesFromInterleavedTiff('stack.tif', 6);
%   figure; montage(avgP, 'Size', [ceil(sqrt(meta.nPlanes)) NaN]); title('Avg per plane (combined)');

    info = imfinfo(tifPath);
    nFrames = numel(info);
    if nFrames < 2*nPlanes
        error('Not enough frames for one full G/R cycle across %d planes (found %d frames).', nPlanes, nFrames);
    end

    H = info(1).Height;
    W = info(1).Width;
    cls = info(1).BitDepth;                 % for reference only
    meta = struct('height',H,'width',W,'nFrames',nFrames,'nPlanes',nPlanes, ...
                  'bitDepth',cls,'filename',tifPath);

    framesPerCycle = 2*nPlanes;             % G/R for each plane
    nCycles = floor(nFrames / framesPerCycle);
    meta.nCycles = nCycles;
    if nFrames ~= nCycles*framesPerCycle
        warning('Ignoring %d trailing frame(s) that do not complete a full G/R cycle.', ...
                nFrames - nCycles*framesPerCycle);
        nFrames = nCycles*framesPerCycle;   % ignore partial tail
    end

    % Accumulators (double to avoid overflow when summing)
    sumG = zeros(H, W, nPlanes, 'double');
    sumR = zeros(H, W, nPlanes, 'double');

    % Use imread with the pre-fetched info for speed
    for k = 1:nFrames
        I = imread(tifPath, k, 'Info', info);
        if ~isa(I,'double'), I = double(I); end

        posInCycle = mod(k-1, framesPerCycle);   % 0..(2N-1)
        planeIdx   = floor(posInCycle/2) + 1;    % 1..N
        isGreen    = mod(posInCycle, 2) == 0;    % even positions are Green

        if isGreen
            sumG(:,:,planeIdx) = sumG(:,:,planeIdx) + I;
        else
            sumR(:,:,planeIdx) = sumR(:,:,planeIdx) + I;
        end
    end

    % Number of frames per plane per channel
    framesPerPlanePerChannel = nCycles;
    if framesPerPlanePerChannel == 0
        error('No complete cycles detected. Check nPlanes or file ordering.');
    end

    avgGreen = sumG / framesPerPlanePerChannel;
    avgRed   = sumR / framesPerPlanePerChannel;

    % Combined average per plane (simple mean of channels)
    avgPlane = (avgGreen + avgRed) / 2;

    % Carry original class info
    meta.class = class(imread(tifPath, 1, 'Info', info));
end
