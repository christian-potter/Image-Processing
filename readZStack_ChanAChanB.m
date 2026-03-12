function stackRGB = readZStack_ChanAChanB(folderPath, opts)
% readZStack_ChanAChanB  Read a z-stack of 2-channel TIFF planes into an RGB stack.
%
% INPUTS
%   folderPath (char/string): Folder containing per-plane .tif files.
%     - Files with "ChanA" in the name are treated as GREEN channel.
%     - Files with "ChanB" in the name are treated as RED channel.
%
% OPTIONAL (name-value via opts struct)
%   opts.SortMode     (string) : "natural" (default) | "lex"
%   opts.RedIn        (double) : Which RGB channel index to write red into (default 1)
%   opts.GreenIn      (double) : Which RGB channel index to write green into (default 2)
%   opts.BlueValue    (double) : Constant value for blue channel if no data (default 0)
%   opts.CastTo       (string) : "" (keep native) | "single" | "double" | "uint16" etc.
%   opts.Normalize01  (logical): If true, scale each channel to [0,1] (default false)
%
% OUTPUT
%   stackRGB : Y x X x 3 x Z array (RGB in 3rd dim, z-plane in 4th dim)

arguments
    folderPath (1,1) string
    opts.SortMode (1,1) string {mustBeMember(opts.SortMode,["natural","lex"])} = "natural"
    opts.RedIn (1,1) double {mustBeInteger, mustBeInRange(opts.RedIn,1,3)} = 1
    opts.GreenIn (1,1) double {mustBeInteger, mustBeInRange(opts.GreenIn,1,3)} = 2
    opts.BlueValue (1,1) double = 0
    opts.CastTo (1,1) string = ""
    opts.Normalize01 (1,1) logical = false
end

if ~isfolder(folderPath)
    error("Folder does not exist: %s", folderPath);
end

% Collect TIFF files
tifList = dir(fullfile(folderPath, "*.tif"));
tifList = [tifList; dir(fullfile(folderPath, "*.tiff"))];
if isempty(tifList)
    error("No .tif/.tiff files found in: %s", folderPath);
end
names = string({tifList.name});

% Identify channels
isA = contains(names, "ChanA", "IgnoreCase", true); % GREEN
isB = contains(names, "ChanB", "IgnoreCase", true); % RED

if ~any(isA) || ~any(isB)
    error("Could not find both ChanA and ChanB files in folder. Found ChanA=%d, ChanB=%d.", any(isA), any(isB));
end

filesA = names(isA);
filesB = names(isB);

% Sort (attempt to keep z-order consistent)
filesA = sortFileNames(filesA, opts.SortMode);
filesB = sortFileNames(filesB, opts.SortMode);

% If counts differ, try to pair by shared stem after removing ChanA/ChanB
if numel(filesA) ~= numel(filesB)
    [filesA, filesB] = pairByStem(filesA, filesB);
end

Z = numel(filesA);
if Z == 0
    error("No paired ChanA/ChanB planes could be matched.");
end

% Read first plane to size/cast
imA1 = imread(fullfile(folderPath, filesA(1)));
imB1 = imread(fullfile(folderPath, filesB(1)));

if ~isequal(size(imA1), size(imB1))
    error("First paired planes have different sizes: ChanA=%s, ChanB=%s", filesA(1), filesB(1));
end

[Y, X] = size(imA1);

% Determine output class
outClass = class(imA1);
if opts.CastTo ~= ""
    outClass = char(opts.CastTo);
end

stackRGB = zeros(Y, X, 3, Z, outClass);

% Fill blue constant (optional)
if opts.BlueValue ~= 0
    stackRGB(:,:,setdiff(1:3,[opts.RedIn opts.GreenIn]),:) = cast(opts.BlueValue, outClass);
end

% Read each z-plane
for z = 1:Z
    imG = imread(fullfile(folderPath, filesA(z))); % ChanA -> Green
    imR = imread(fullfile(folderPath, filesB(z))); % ChanB -> Red

    if ~isequal(size(imG), [Y X]) || ~isequal(size(imR), [Y X])
        error("Plane size mismatch at z=%d. ChanA=%s ChanB=%s", z, filesA(z), filesB(z));
    end

    if opts.CastTo ~= ""
        imG = cast(imG, outClass);
        imR = cast(imR, outClass);
    end

    stackRGB(:,:,opts.GreenIn,z) = imG;
    stackRGB(:,:,opts.RedIn,z)   = imR;
end

% Optional normalization to [0,1] per channel across whole stack
if opts.Normalize01
    stackRGB = normalizeStack01(stackRGB);
end

end

% ------------------------- helpers -------------------------

function filesOut = sortFileNames(filesIn, mode)
filesOut = filesIn;
switch mode
    case "lex"
        filesOut = sort(filesIn);
    case "natural"
        % Simple natural sort: split into numeric/non-numeric tokens
        [~, idx] = sortNat(filesIn);
        filesOut = filesIn(idx);
end
end

function [Aout, Bout] = pairByStem(A, B)
% Pair planes by a "stem" that ignores ChanA/ChanB (case-insensitive).
stemA = regexprep(lower(A), "chana", "");
stemB = regexprep(lower(B), "chanb", "");

% Also remove common separators around the token (optional)
stemA = regexprep(stemA, "(_|-| )", "");
stemB = regexprep(stemB, "(_|-| )", "");

[common, ia, ib] = intersect(stemA, stemB, "stable");
Aout = A(ia);
Bout = B(ib);

if isempty(common)
    % fallback: truncate to min length (keeps order but may mispair)
    n = min(numel(A), numel(B));
    warning("Could not match ChanA/ChanB by stem. Truncating to %d planes by sorted order.", n);
    Aout = A(1:n);
    Bout = B(1:n);
end
end

function stack = normalizeStack01(stack)
% Normalize each RGB channel globally across all z-planes.
stack = single(stack);
for c = 1:3
    ch = stack(:,:,c,:);
    mn = min(ch(:));
    mx = max(ch(:));
    if mx > mn
        stack(:,:,c,:) = (ch - mn) ./ (mx - mn);
    else
        stack(:,:,c,:) = 0;
    end
end
end

function [sorted, idx] = sortNat(strs)
% Minimal natural sort for strings like "img_2.tif" vs "img_10.tif".
s = cellstr(strs);
tokens = regexp(s, '\d+|\D+', 'match');
maxLen = max(cellfun(@numel, tokens));

key = cell(numel(s), maxLen);
for i = 1:numel(s)
    t = tokens{i};
    for j = 1:numel(t)
        tj = t{j};
        if all(isstrprop(tj,'digit'))
            key{i,j} = str2double(tj);
        else
            key{i,j} = lower(tj);
        end
    end
end

% Build table for sorting: convert to string where needed
K = cell(size(key));
for j = 1:size(key,2)
    col = key(:,j);
    if all(cellfun(@(x) isempty(x) || isnumeric(x), col))
        K(:,j) = col;
    else
        K(:,j) = cellfun(@(x) string(x), col, 'UniformOutput', false);
    end
end

% Replace empties
for i = 1:size(K,1)
    for j = 1:size(K,2)
        if isempty(K{i,j})
            K{i,j} = "";
        end
    end
end

% Sort rows iteratively (robust to mixed types)
idx = (1:numel(s))';
for j = size(K,2):-1:1
    col = K(:,j);
    if all(cellfun(@isnumeric, col))
        v = cell2mat(col);
        [~, ord] = sort(v);
    else
        v = string([col{:}])';
        [~, ord] = sort(v);
    end
    idx = idx(ord);
    K = K(ord,:);
end

sorted = strs(idx);
end