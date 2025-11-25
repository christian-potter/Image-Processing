function [avgImg, denomIdxPerFile, fileList, totalFramesUsed] = averageTiffFolder(folderPath, excludeIdx, opt)
arguments
    folderPath (1,1) string
    excludeIdx = []
    opt.precision (1,1) string {mustBeMember(opt.precision,["double","single"])} = "double"
    opt.verbose (1,1) logical = false
    opt.recursive (1,1) logical = false
    opt.exclude_mode (1,1) string {mustBeMember(opt.exclude_mode,["denominator","skip"])} = "denominator"
end
%%
% averageTiffFolder  Average multi-frame TIFFs in a folder with end-stage exclusion.
%
%   [avgImg, denomIdxPerFile, fileList, totalFramesUsed] = ...
%       averageTiffFolder(folderPath, excludeIdx)
%   [...] = averageTiffFolder(folderPath, excludeIdx, opt)
%
% Inputs
%   folderPath  – string/char: folder containing .tif/.tiff files
%   excludeIdx  – vector of 1-based frame indices to exclude PER FILE
%                 (applied to the denominator only by default)
%   opt         – struct with fields:
%       .precision     "double"(default) | "single"
%       .verbose       logical (default=false)
%       .recursive     logical (default=false) search subfolders
%       .exclude_mode  "denominator"(default) | "skip"
%                      "denominator": sum ALL frames; subtract excluded count from divisor
%                      "skip":        do not sum excluded frames (previous behavior)
%
% Outputs
%   avgImg            – average image (double/single)
%   denomIdxPerFile   – per-file indices that COUNT toward the denominator
%   fileList          – full paths of files included
%   totalFramesUsed   – total frames used in the denominator
%
% NOTE: With exclude_mode="denominator", excluded frames still contribute to the SUM
%       (numerator) but are removed from the COUNT (denominator).

%% DESCRIPTION 
% function that takes 


%% RUN CODE 
if ~isfolder(folderPath)
    error('Folder not found: %s', folderPath);
end

% Collect .tif/.tiff files
if opt.recursive
    pattern1 = fullfile(folderPath, '**', '*.tif');
    pattern2 = fullfile(folderPath, '**', '*.tiff');
else
    pattern1 = fullfile(folderPath, '*.tif');
    pattern2 = fullfile(folderPath, '*.tiff');
end
d = [dir(pattern1); dir(pattern2)];
if isempty(d)
    error('No .tif/.tiff files found in: %s', folderPath);
end
[~, ord] = sort(lower({d.name}));
d = d(ord);
fileList = strings(numel(d),1);
for i = 1:numel(d)
    fileList(i) = string(fullfile(d(i).folder, d(i).name));
end

% Sanitize exclusion vector
if ~isempty(excludeIdx)
    if ~(isnumeric(excludeIdx) || islogical(excludeIdx))
        error('excludeIdx must be numeric/logical indices.');
    end
    excludeIdx = unique(double(excludeIdx(:).'));
    if any(~isfinite(excludeIdx)) || any(excludeIdx ~= round(excludeIdx))
        error('excludeIdx must contain finite integer indices.');
    end
end

acc = [];           % accumulator (double)
imSize = [];
isRGB  = [];
totalFrames = 0;    % total frames actually summed (for "skip" mode; also informative)
denomFrames = 0;    % frames that count toward the denominator
denomIdxPerFile = cell(numel(fileList),1);

for f = 1:numel(fileList)
    fp = fileList(f);
    info = imfinfo(fp);
    nF = numel(info);
    if nF < 1
        warning('File has no frames (skipped): %s', fp);
        denomIdxPerFile{f} = [];
        continue;
    end

    % Per-file denominator indices (what will COUNT in the divisor)
    excl = excludeIdx(excludeIdx >= 1 & excludeIdx <= nF);
    denomIdx = setdiff(1:nF, excl);
    denomIdxPerFile{f} = denomIdx;

    % Read first frame to set accumulator and consistency
    F0 = imread(fp, 1, 'Info', info);
    thisIsRGB = (ndims(F0) == 3 && size(F0,3) == 3);
    thisSize  = size(F0);
    if isempty(acc)
        imSize = thisSize;
        isRGB  = thisIsRGB;
        acc    = zeros(imSize, 'double');
    else
        if ~isequal(thisSize, imSize) || (thisIsRGB ~= isRGB)
            error(['Image size/channels mismatch.\n' ...
                   '  Expected: %s (RGB=%d)\n  Got:      %s (RGB=%d)\n  File: %s'], ...
                   mat2str(imSize), isRGB, mat2str(thisSize), thisIsRGB, fp);
        end
    end

    % Accumulate frames
    switch opt.exclude_mode
        case "denominator"
            % Sum ALL frames; only the denominator will exclude 'excl'
            for k = 1:nF
                F = imread(fp, k, 'Info', info);
                if ~isequal(size(F), imSize)
                    error('Frame size mismatch in %s (frame %d).', fp, k);
                end
                acc = acc + double(F);
            end
            totalFrames = totalFrames + nF;          % informative
            denomFrames = denomFrames + numel(denomIdx);

        case "skip"
            % Old behavior: only sum frames that are NOT excluded
            for k = denomIdx
                F = imread(fp, k, 'Info', info);
                if ~isequal(size(F), imSize)
                    error('Frame size mismatch in %s (frame %d).', fp, k);
                end
                acc = acc + double(F);
            end
            totalFrames = totalFrames + numel(denomIdx); % equals denom in skip mode
            denomFrames = denomFrames + numel(denomIdx);
    end

    if opt.verbose
        fprintf('[%d/%d] %s: denom uses %d/%d frames (mode=%s)\n', ...
            f, numel(fileList), d(f).name, numel(denomIdx), nF, opt.exclude_mode);
    end
end

if denomFrames == 0
    error('No frames counted in the denominator. Check excludeIdx or inputs.');
end

avg = acc / denomFrames;
switch opt.precision
    case "single", avgImg = single(avg);
    otherwise,     avgImg = avg;
end

totalFramesUsed = denomFrames;

if opt.verbose
    fprintf('Finished. Denominator frames: %d. (Total summed frames: %d)\n', denomFrames, totalFrames);
end
end
