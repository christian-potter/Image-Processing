function hFig = plotOrthogonalPlanesFromCell(planeSets, opt)
%PLOTORTHOGONALPLANCELL Plot orthogonal XY, XZ, YZ planes from a cell array.
%
% hFig = plotOrthogonalPlanesFromCell(planeSets)
% hFig = plotOrthogonalPlanesFromCell(..., 'Name', value, ...)
%
% INPUT
%   planeSets : cell array where each entry is a 1x3 cell:
%                   {XY, XZ, YZ}
%               Each plane can be grayscale [H x W] or RGB [H x W x 3].
%
%               Example:
%                 planeSets = {
%                     {XY1, XZ1, YZ1}
%                     {XY2, XZ2, YZ2}
%                 };
%
% OPTIONAL NAME-VALUE PAIRS
%   'OriginMode'      : 'corner' or 'center'
%                       default = 'corner'
%   'ShowEdges'       : true/false
%                       default = true
%   'AxisLabels'      : true/false
%                       default = true
%   'Titles'          : string/cellstr for each set
%                       default = "Set 1", "Set 2", ...
%   'FlipVertical'    : true/false, flip each input plane with flipud
%                       default = true
%   'NormalizeImages' : true/false, scale grayscale images to [0,1]
%                       default = true
%
% OUTPUT
%   hFig : figure handle
%
% NOTES
% - Each row of the figure corresponds to one entry of planeSets.
% - Column 1: orthogonal 3D rendering.
% - The XY plane is placed at z = 0
% - The XZ plane is placed at y = 0
% - The YZ plane is placed at x = 0

arguments
    planeSets cell
    opt.OriginMode (1,:) char {mustBeMember(opt.OriginMode, {'corner','center'})} = 'corner'
    opt.ShowEdges (1,1) logical = true
    opt.AxisLabels (1,1) logical = true
    opt.Titles = []
    opt.FlipVertical (1,1) logical = true
    opt.NormalizeImages (1,1) logical = true
end

validatePlaneSets(planeSets);

nSets = numel(planeSets);

if isempty(opt.Titles)
    titles = "Set " + string(1:nSets);
else
    titles = string(opt.Titles);
    if numel(titles) ~= nSets
        error('Number of titles must match numel(planeSets).');
    end
end

hFig = figure('Color', 'w');
tl = tiledlayout(hFig, nSets, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

for s = 1:nSets
    ax = nexttile(tl);
    hold(ax, 'on');

    XY = planeSets{s}{1};
    XZ = planeSets{s}{2};
    YZ = planeSets{s}{3};

    XY = prepPlane(XY, opt.FlipVertical, opt.NormalizeImages);
    XZ = prepPlane(XZ, opt.FlipVertical, opt.NormalizeImages);
    YZ = prepPlane(YZ, opt.FlipVertical, opt.NormalizeImages);

    [xyH, xyW, ~] = size(XY);
    [xzH, xzW, ~] = size(XZ);
    [yzH, yzW, ~] = size(YZ);

    % Consistency checks:
    % XY is [Y x X]
    % XZ is [Z x X]
    % YZ is [Z x Y]
    if xyW ~= xzW
        error('Set %d: XY width (%d) must equal XZ width (%d).', s, xyW, xzW);
    end
    if xyH ~= yzW
        error('Set %d: XY height (%d) must equal YZ width (%d).', s, xyH, yzW);
    end
    if xzH ~= yzH
        error('Set %d: XZ height (%d) must equal YZ height (%d).', s, xzH, yzH);
    end

    nX = xyW;
    nY = xyH;
    nZ = xzH;

    switch lower(opt.OriginMode)
        case 'corner'
            x = [0, nX-1];
            y = [0, nY-1];
            z = [0, nZ-1];
        case 'center'
            x = [-(nX-1)/2, (nX-1)/2];
            y = [-(nY-1)/2, (nY-1)/2];
            z = [-(nZ-1)/2, (nZ-1)/2];
    end

    edgeColor = ternary(opt.ShowEdges, 'k', 'none');

    % XY plane at z = 0
    surf(ax, ...
        [x(1) x(2); x(1) x(2)], ...
        [y(1) y(1); y(2) y(2)], ...
        [0 0; 0 0], ...
        'CData', XY, ...
        'FaceColor', 'texturemap', ...
        'EdgeColor', edgeColor);

    % XZ plane at y = 0
    surf(ax, ...
        [x(1) x(2); x(1) x(2)], ...
        [0 0; 0 0], ...
        [z(1) z(1); z(2) z(2)], ...
        'CData', XZ, ...
        'FaceColor', 'texturemap', ...
        'EdgeColor', edgeColor);

    % YZ plane at x = 0
    surf(ax, ...
        [0 0; 0 0], ...
        [y(1) y(2); y(1) y(2)], ...
        [z(1) z(1); z(2) z(2)], ...
        'CData', YZ, ...
        'FaceColor', 'texturemap', ...
        'EdgeColor', edgeColor);

    % Origin marker
    plot3(ax, 0, 0, 0, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 5);
    text(ax, 0, 0, 0, '  origin', ...
        'FontWeight', 'bold', ...
        'FontSize', 10, ...
        'VerticalAlignment', 'bottom', ...
        'Interpreter', 'none');

    axis(ax, 'equal');
    grid(ax, 'on');
    box(ax, 'on');
    view(ax, [-35 25]);

    if opt.AxisLabels
        xlabel(ax, 'X');
        ylabel(ax, 'Y');
        zlabel(ax, 'Z');
    end

    title(ax, titles(s), 'Interpreter', 'none');
    hold(ax, 'off');
end

end

function validatePlaneSets(planeSets)
if ~iscell(planeSets) || isempty(planeSets)
    error('planeSets must be a nonempty cell array.');
end

for i = 1:numel(planeSets)
    entry = planeSets{i};
    if ~iscell(entry) || numel(entry) ~= 3
        error('Each entry of planeSets must be a 1x3 cell: {XY, XZ, YZ}. Problem at entry %d.', i);
    end
    for j = 1:3
        A = entry{j};
        if ~(isnumeric(A) || islogical(A))
            error('Plane %d in entry %d must be numeric or logical.', j, i);
        end
        if ~(ismatrix(A) || (ndims(A) == 3 && size(A,3) == 3))
            error('Plane %d in entry %d must be grayscale [H x W] or RGB [H x W x 3].', j, i);
        end
    end
end
end

function I = prepPlane(I, doFlip, doNormalize)
if ismatrix(I)
    I = double(I);
    if doNormalize
        mn = min(I(:));
        mx = max(I(:));
        if mx > mn
            I = (I - mn) ./ (mx - mn);
        else
            I = zeros(size(I));
        end
    end
    I = repmat(I, 1, 1, 3);
else
    I = im2double(I);
end

if doFlip
    I = flipud(I);
end
end

function out = ternary(cond, a, b)
if cond
    out = a;
else
    out = b;
end
end