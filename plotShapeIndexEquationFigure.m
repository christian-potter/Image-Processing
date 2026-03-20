function hFig = plotShapeIndexEquationFigure(sphericalThresh)
%PLOTSHAPEINDEXEQUATIONFIGURE Make a figure showing the shapeIndex equation.
%
% USAGE
%   plotShapeIndexEquationFigure
%   plotShapeIndexEquationFigure(1.2)
%
% INPUT
%   sphericalThresh : scalar, optional
%       Same threshold used in computePrincipalAxesAndShapeIndex.
%       Default = 1.2.
%
% OUTPUT
%   hFig : figure handle
%
% This makes a simple annotation-style figure that displays the equation:
%
%   anisotropy      = a / c
%   orientationScore = |v_z| - max(|v_x|, |v_y|)
%   magnitudeScore   = max(0, (anisotropy - sphericalThresh)/sphericalThresh)
%   shapeIndex       = orientationScore * magnitudeScore
%
% along with the sign convention:
%   shapeIndex > 0   -> vertical
%   shapeIndex < 0   -> horizontal
%   shapeIndex ~ 0   -> spherical / weakly oriented

    arguments
        sphericalThresh (1,1) double = 1.2
    end

    hFig = figure('Color','w', 'Position', [100 100 1100 520]);
    ax = axes('Parent', hFig, 'Position', [0 0 1 1]);
    axis(ax, [0 1 0 1]);
    axis(ax, 'off');
    hold(ax, 'on');

    % Title
    text(0.5, 0.92, 'shapeIndex equation', ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 22, ...
        'FontWeight', 'bold');

    % Equation block
    eqText = {
        'anisotropy = a / c'
        ''
        'orientationScore = |v_z| - max(|v_x|, |v_y|)'
        ''
        sprintf('magnitudeScore = max(0, (anisotropy - %.3g) / %.3g)', sphericalThresh, sphericalThresh)
        ''
        'shapeIndex = orientationScore * magnitudeScore'
        };

    text(0.08, 0.68, eqText, ...
        'FontName', 'Courier', ...
        'FontSize', 20, ...
        'VerticalAlignment', 'top');

    % Definitions block
    defText = {
        'Definitions:'
        'a, b, c = principal-axis spreads from PCA, with a >= b >= c'
        'v = major-axis eigenvector from PCA'
        'v_x, v_y, v_z = components of v along x, y, and z'
        'z is treated as the vertical axis'
        'x and y are treated as horizontal axes'
        };

    text(0.08, 0.34, defText, ...
        'FontSize', 15, ...
        'VerticalAlignment', 'top');

    % Interpretation block
    line([0.62 0.62], [0.16 0.82], 'Color', [0.75 0.75 0.75], 'LineWidth', 1.5);

    text(0.79, 0.76, 'Interpretation', ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 18, ...
        'FontWeight', 'bold');

    text(0.79, 0.62, 'shapeIndex > 0', ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 18, ...
        'Color', [0.1 0.35 0.75], ...
        'FontWeight', 'bold');
    text(0.79, 0.56, 'vertical', ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 16);

    text(0.79, 0.43, 'shapeIndex < 0', ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 18, ...
        'Color', [0.75 0.2 0.2], ...
        'FontWeight', 'bold');
    text(0.79, 0.37, 'horizontal', ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 16);

    text(0.79, 0.24, 'shapeIndex ≈ 0', ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 18, ...
        'FontWeight', 'bold');
    text(0.79, 0.17, 'spherical or weakly oriented', ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 16);

end