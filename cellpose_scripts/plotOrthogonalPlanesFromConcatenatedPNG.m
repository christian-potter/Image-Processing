function hFig = plotOrthogonalPlanesFromConcatenatedPNG(pngFile, opt)
%PLOTORTHOGONALPLANESFROMCONCATENATEDPNG
% Load a PNG containing 3 equally sized images concatenated horizontally
% in the order:
%   [ XY | XZ | YZ ]
%
% Then display them as orthogonal planes that intersect at a common origin.
%
% Example:
%   plotOrthogonalPlanesFromConcatenatedPNG('slices.png');
%
% Optional name-value pairs:
%   'PlaneOrder'   : 3-element cell array naming the three panels
%                    default = {'XY','XZ','YZ'}
%   'OriginMode'   : 'corner' or 'center'
%                    'corner' => all planes intersect at one corner
%                    'center' => all planes intersect at their centers
%                    default = 'corner'
%   'ShowEdges'    : true/false, draw black plane borders
%                    default = true
%   'AxisLabels'   : true/false
%                    default = true
%
% Notes:
% - This uses MATLAB surface objects with texture mapping.
% - The XY plane is shown at z = 0
% - The XZ plane is shown at y = 0
% - The YZ plane is shown at x = 0
% - For display purposes, image row direction is flipped so the images
%   appear upright in a conventional axes view.

arguments
    pngFile (1,:) char
    opt.PlaneOrder cell = {'XY','XZ','YZ'}
    opt.OriginMode (1,:) char {mustBeMember(opt.OriginMode,{'corner','center'})} = 'corner'
    opt.ShowEdges (1,1) logical = true
    opt.AxisLabels (1,1) logical = true
end

% -------------------------
% Load image
% -------------------------
img = imread(pngFile);

if ndims(img) ~= 3 || ~ismember(size(img,3), [3 4])
    error('Input PNG must be an RGB or RGBA image.');
end

H = size(img,1);
W = size(img,2);

if mod(W,3) ~= 0
    error('Image width must be divisible by 3, since the PNG should contain 3 equal panels.');
end

panelW = W / 3;

% Split into three equal horizontal panels
I1 = img(:, 1:panelW, :);
I2 = img(:, panelW+1:2*panelW, :);
I3 = img(:, 2*panelW+1:3*panelW, :);

% Map panels to names
planeNames = upper(string(opt.PlaneOrder));
validNames = ["XY","XZ","YZ"];

if numel(planeNames) ~= 3 || ~all(ismember(planeNames, validNames))
    error('PlaneOrder must be a 3-element cell array using only: ''XY'', ''XZ'', ''YZ''.');
end

planeMap = containers.Map({'XY','XZ','YZ'}, {[],[],[]});
planeMap(char(planeNames(1))) = I1;
planeMap(char(planeNames(2))) = I2;
planeMap(char(planeNames(3))) = I3;

Ixy = planeMap('XY');
Ixz = planeMap('XZ');
Iyz = planeMap('YZ');

% Flip vertically so displayed orientation is more natural in axes
Ixy = flipud(Ixy);
Ixz = flipud(Ixz);
Iyz = flipud(Iyz);

% Dimensions for each extracted panel
[nXY_y, nXY_x, ~] = size(Ixy);
[nXZ_z, nXZ_x, ~] = size(Ixz);
[nYZ_z, nYZ_y, ~] = size(Iyz);

% -------------------------
% Coordinate definitions
% -------------------------
switch lower(opt.OriginMode)
    case 'corner'
        % All three planes meet at (0,0,0)
        x_xy = [0, nXY_x-1];
        y_xy = [0, nXY_y-1];

        x_xz = [0, nXZ_x-1];
        z_xz = [0, nXZ_z-1];

        y_yz = [0, nYZ_y-1];
        z_yz = [0, nYZ_z-1];

    case 'center'
        % All three planes cross through their centers
        x_xy = [-(nXY_x-1)/2, (nXY_x-1)/2];
        y_xy = [-(nXY_y-1)/2, (nXY_y-1)/2];

        x_xz = [-(nXZ_x-1)/2, (nXZ_x-1)/2];
        z_xz = [-(nXZ_z-1)/2, (nXZ_z-1)/2];

        y_yz = [-(nYZ_y-1)/2, (nYZ_y-1)/2];
        z_yz = [-(nYZ_z-1)/2, (nYZ_z-1)/2];
end

% -------------------------
% Build figure
% -------------------------
hFig = figure('Color','w');
ax = axes('Parent', hFig);
hold(ax, 'on');

if opt.ShowEdges
    edgeColor = 'k';
else
    edgeColor = 'none';
end

% XY plane at z = 0
surf(ax, ...
    [x_xy(1) x_xy(2); x_xy(1) x_xy(2)], ...
    [y_xy(1) y_xy(1); y_xy(2) y_xy(2)], ...
    [0 0; 0 0], ...
    'CData', Ixy, ...
    'FaceColor', 'texturemap', ...
    'EdgeColor', edgeColor);

% XZ plane at y = 0
surf(ax, ...
    [x_xz(1) x_xz(2); x_xz(1) x_xz(2)], ...
    [0 0; 0 0], ...
    [z_xz(1) z_xz(1); z_xz(2) z_xz(2)], ...
    'CData', Ixz, ...
    'FaceColor', 'texturemap', ...
    'EdgeColor', edgeColor);

% YZ plane at x = 0
surf(ax, ...
    [0 0; 0 0], ...
    [y_yz(1) y_yz(2); y_yz(1) y_yz(2)], ...
    [z_yz(1) z_yz(1); z_yz(2) z_yz(2)], ...
    'CData', Iyz, ...
    'FaceColor', 'texturemap', ...
    'EdgeColor', edgeColor);

% -------------------------
% Mark origin
% -------------------------
plot3(ax, 0, 0, 0, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6);
text(ax, 0, 0, 0, '  origin', 'FontWeight', 'bold', 'FontSize', 11, ...
    'VerticalAlignment', 'bottom', 'Interpreter', 'none');

% -------------------------
% Axes styling
% -------------------------
axis(ax, 'equal');
grid(ax, 'on');
box(ax, 'on');
view(ax, 3);

% A common view that makes the orthogonal arrangement clear
view(ax, [-35 25]);

if opt.AxisLabels
    xlabel(ax, 'X');
    ylabel(ax, 'Y');
    zlabel(ax, 'Z');
end

title(ax, 'Orthogonal XY, XZ, and YZ planes intersecting at the origin');

rotate3d(ax, 'on');
hold(ax, 'off');

end