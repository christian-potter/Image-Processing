function hFig = plotShapeIndexEllipsoids3D(shapeVals, varargin)
%PLOTSHAPEINDEXELLIPSOIDS3D Draw 3D ellipsoids illustrating shapeIndex.
%
% This function makes a schematic 3D figure where:
%   negative shapeIndex -> horizontally stretched ellipsoids
%   near zero           -> spherical ellipsoids
%   positive shapeIndex -> vertically stretched ellipsoids
%
% The mapping is illustrative and designed to visually match the earlier
% 2D outlines. It is not an exact inversion of the PCA-based shapeIndex.
%
% USAGE
%   plotShapeIndexEllipsoids3D
%   plotShapeIndexEllipsoids3D([-0.9 -0.5 0 0.5 0.9])
%   plotShapeIndexEllipsoids3D(..., 'BaseRadius', 0.35, 'Spacing', 2.2)
%
% INPUT
%   shapeVals : numeric vector, optional
%       Values to illustrate. Default = [-0.9 -0.5 0 0.5 0.9]
%
% NAME-VALUE PAIRS
%   'BaseRadius'      : base ellipsoid radius for near-spherical object
%                       default = 0.35
%   'StretchGain'     : controls how strongly shapeIndex affects shape
%                       default = 0.85
%   'Spacing'         : spacing between ellipsoid centers along x
%                       default = 2.2
%   'Resolution'      : ellipsoid mesh resolution
%                       default = 40
%   'FaceAlpha'       : surface transparency
%                       default = 0.85
%   'DrawLabels'      : true/false
%                       default = true
%
% OUTPUT
%   hFig : figure handle
%
% INTERPRETATION
%   For each shapeIndex s:
%       s < 0  -> x/y axes larger, z axis smaller  (horizontal)
%       s ~ 0  -> all axes similar                 (spherical)
%       s > 0  -> z axis larger, x/y axes smaller  (vertical)
%
% The mapping used here is:
%   horizScale = 1 + k*max(-s,0)
%   vertScale  = 1 + k*max( s,0)
%
%   rx = baseRadius * horizScale
%   ry = baseRadius * (0.92*horizScale + 0.08*vertScale)
%   rz = baseRadius * vertScale
%
% This keeps near-zero values spherical while making negative values look
% horizontally elongated and positive values vertically elongated.
%
% EXAMPLE
%   plotShapeIndexEllipsoids3D([-0.9 -0.5 0 0.5 0.9], ...
%       'BaseRadius', 0.4, 'StretchGain', 0.9, 'Spacing', 2.5);

    if nargin < 1 || isempty(shapeVals)
        shapeVals = [-0.9 -0.5 0 0.5 0.9];
    end

    p = inputParser;
    addParameter(p, 'BaseRadius', 0.35, @(x) isnumeric(x) && isscalar(x) && x > 0);
    addParameter(p, 'StretchGain', 0.85, @(x) isnumeric(x) && isscalar(x) && x >= 0);
    addParameter(p, 'Spacing', 2.2, @(x) isnumeric(x) && isscalar(x) && x > 0);
    addParameter(p, 'Resolution', 40, @(x) isnumeric(x) && isscalar(x) && x >= 10);
    addParameter(p, 'FaceAlpha', 0.85, @(x) isnumeric(x) && isscalar(x) && x > 0 && x <= 1);
    addParameter(p, 'DrawLabels', true, @(x) islogical(x) || isnumeric(x));
    parse(p, varargin{:});

    baseRadius  = p.Results.BaseRadius;
    stretchGain = p.Results.StretchGain;
    spacing     = p.Results.Spacing;
    nRes        = p.Results.Resolution;
    faceAlpha   = p.Results.FaceAlpha;
    drawLabels  = logical(p.Results.DrawLabels);

    shapeVals = shapeVals(:).';
    nShapes = numel(shapeVals);

    % Centers of ellipsoids
    centersX = ((1:nShapes) - mean(1:nShapes)) * spacing;
    centersY = zeros(1, nShapes);
    centersZ = zeros(1, nShapes);

    % Unit sphere mesh
    [Xs, Ys, Zs] = sphere(nRes);

    hFig = figure('Color', 'w');
    ax = axes('Parent', hFig);
    hold(ax, 'on');

    % Plot each ellipsoid
    for i = 1:nShapes
        s = shapeVals(i);

        % Clamp to [-1, 1] only for display mapping
        sDisp = max(-1, min(1, s));

        % Negative = horizontal, positive = vertical
        horizScale = 1 + stretchGain * max(-sDisp, 0);
        vertScale  = 1 + stretchGain * max( sDisp, 0);

        % Radii chosen to visually match the previous 2D schematic:
        % negative values: wider in x/y, shorter in z
        % positive values: narrower in x/y, taller in z
        rx = baseRadius * horizScale;
        ry = baseRadius * (0.92 * horizScale + 0.08 * vertScale);
        rz = baseRadius * vertScale;

        Xe = rx * Xs + centersX(i);
        Ye = ry * Ys + centersY(i);
        Ze = rz * Zs + centersZ(i);

        surf(ax, Xe, Ye, Ze, ...
            'FaceColor', [0.82 0.86 0.93], ...
            'EdgeColor', [0.15 0.15 0.15], ...
            'FaceAlpha', faceAlpha, ...
            'LineWidth', 0.7);

        % if drawLabels
        %     text(ax, centersX(i), 0, -(baseRadius*2.1), sprintf('%.1f', s), ...
        %         'HorizontalAlignment', 'center', ...
        %         'VerticalAlignment', 'top', ...
        %         'FontSize', 11);
        % end
    end

    % Draw a baseline under the ellipsoids
    % xLine = linspace(min(centersX)-spacing*0.7, max(centersX)+spacing*0.7, 200);
    % yLine = zeros(size(xLine));
    % zLine = -baseRadius*1.7 * ones(size(xLine));
    % plot3(ax, xLine, yLine, zLine, 'k-', 'LineWidth', 1.0);

    % Region labels
    % if drawLabels
    %     text(ax, mean(centersX(1:max(1,floor(nShapes/3)))), 0, baseRadius*2.4, ...
    %         'Negative values \rightarrow horizontal', ...
    %         'HorizontalAlignment', 'center', 'FontSize', 12);
    % 
    %     text(ax, 0, 0, baseRadius*2.4, ...
    %         'Near zero \rightarrow spherical', ...
    %         'HorizontalAlignment', 'center', 'FontSize', 12);
    % 
    %     text(ax, mean(centersX(max(1,ceil(2*nShapes/3)):end)), 0, baseRadius*2.4, ...
    %         'Positive values \rightarrow vertical', ...
    %         'HorizontalAlignment', 'center', 'FontSize', 12);
    % 
    %     text(ax, 0, 0, -baseRadius*2.9, 'shapeIndex', ...
    %         'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');
    % end

    % Formatting
    axis(ax, 'equal');
    axis(ax, 'off');
    view(ax, [-28 20]);
    camlight(ax, 'headlight');
    lighting(ax, 'gouraud');

    xlim(ax, [min(centersX)-spacing*0.7, max(centersX)+spacing*0.7]);
    ylim(ax, [-baseRadius*2.0, baseRadius*2.0]);
    zlim(ax, [-baseRadius*3.2, baseRadius*3.0]);
    % 
    % title(ax, '3D schematic mapping of shapeIndex to ellipsoid shape', ...
    %     'FontWeight', 'normal');

end