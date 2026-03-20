function hFig = plotShapeIndexEquationWithSchematic(sphericalThresh)
%PLOTSHAPEINDEXEQUATIONWITHSCHEMATIC Show the shapeIndex equation together
% with a simple horizontal/spherical/vertical schematic.

    arguments
        sphericalThresh (1,1) double = 1.2
    end

    hFig = figure('Color','w', 'Position', [100 100 1200 650]);
    ax = axes('Parent', hFig, 'Position', [0 0 1 1]);
    axis(ax, [0 1 0 1]);
    axis(ax, 'off');
    hold(ax, 'on');

    % Title
    text(0.5, 0.94, 'shapeIndex equation and interpretation', ...
        'HorizontalAlignment', 'center', 'FontSize', 22, 'FontWeight', 'bold');

    % Equation
    eqText = {
        'anisotropy = a / c'
        'orientationScore = |v_z| - max(|v_x|, |v_y|)'
        sprintf('magnitudeScore = max(0, (anisotropy - %.3g) / %.3g)', sphericalThresh, sphericalThresh)
        'shapeIndex = orientationScore * magnitudeScore'
        };
    text(0.08, 0.80, eqText, ...
        'FontName', 'Courier', 'FontSize', 19, 'VerticalAlignment', 'top');

    % Definitions
    text(0.08, 0.53, ...
        {'a,b,c: principal-axis spreads from PCA'; ...
         'v: major-axis eigenvector'; ...
         'z: vertical axis'; ...
         'x,y: horizontal axes'}, ...
        'FontSize', 14, 'VerticalAlignment', 'top');

    % Baseline schematic
    y0 = 0.23;
    line([0.08 0.92], [y0 y0], 'Color', 'k', 'LineWidth', 1.2);

    xs = [0.18 0.36 0.55 0.74 0.88];
    vals = [-0.9 -0.5 0 0.5 0.9];
    widths = [0.16 0.11 0.08 0.06 0.05];
    heights = [0.05 0.07 0.08 0.12 0.16];

    for i = 1:numel(xs)
        rectangle('Position', [xs(i)-widths(i)/2, 0.36-heights(i)/2, widths(i), heights(i)], ...
                  'Curvature', [1 1], ...
                  'EdgeColor', 'k', ...
                  'LineWidth', 1.8, ...
                  'FaceColor', 'none');
        text(xs(i), y0-0.04, sprintf('%.1f', vals(i)), ...
            'HorizontalAlignment', 'center', 'FontSize', 13);
    end

    text(0.20, 0.46, 'horizontal', 'HorizontalAlignment', 'center', 'FontSize', 14);
    text(0.55, 0.46, 'spherical', 'HorizontalAlignment', 'center', 'FontSize', 14);
    text(0.84, 0.46, 'vertical', 'HorizontalAlignment', 'center', 'FontSize', 14);

    text(0.5, 0.10, 'shapeIndex', ...
        'HorizontalAlignment', 'center', 'FontSize', 16, 'FontWeight', 'bold');

end