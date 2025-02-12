function [nfigs] = adjustImagev3(p, stat, crshift, figs, ops, id_vect, ypix_zplane, xyshift, opt)
arguments
    p double
    stat cell
    crshift double
    figs struct
    ops struct
    id_vect double
    ypix_zplane cell
    xyshift double
    opt.type string = 'rgb'
    opt.functional string = 'mean'
    opt.anatomical string = 'mean'
    opt.idx (1,1) double
    opt.zstack double = 0;
    opt.surround double = 10
    opt.default_plane (1,1) double = 1
    opt.xyshift logical = false
end

%% GET VARIABLES
[roi_planeidx, idxshifts, nplanes] = get.roipidx_shift(stat);
[mask_coords] = get.mask_coordinates(stat);
[mask_colors] = get.mask_colors(id_vect);

%% GET RED/GREEN WIN
[redwin, greenwin] = get.redgreen_images(opt.anatomical, opt.functional, ops, crshift);

%% DEFINE IMAGE
if strcmp(opt.type, 'rgb')
    image(:, :, 1) = redwin;
    image(:, :, 2) = greenwin;
    image(:, :, 3) = zeros(size(redwin, 1), size(redwin, 2));
    image = utils.normalize_img(image);
    stack = false;
elseif strcmp(opt.type, 'zstack')
    stack = true;
    image = opt.zstack;
    [image, x1, y1] = get.roi_surround(image, opt.idx, stat, opt.surround, xyshift);
    for i = 1:size(image, 4)
        for j = 1:size(image, 3)
            image(:, :, j, i) = utils.normalize_img(image(:, :, j, i));
        end
    end
end

%% CREATE FIGURES
hFigImg = figure('Name', 'RGB Image', 'NumberTitle', 'off', 'Position', figs.rgb.Position, 'Color', 'White');
hAx = axes('Parent', hFigImg, 'Position', [0.01, 0.01, 0.99, 0.99]);
hImg = imshow(image(:, :, :, 1), 'Parent', hAx); hold on;
plot.mask_boundaries(mask_colors(:, 1), mask_coords(opt.idx), [x1 y1], opt.idx, "idxtype", 'specified');

%% CREATE SLIDER FIGURE
hFigSlider = figure('Name', 'Adjustments & Histogram', 'NumberTitle', 'off', 'Position', figs.slider.Position, 'Color', 'White');

% XY shift sliders (if enabled)


%% UPDATE IMAGE FUNCTION
function updateImage(~, ~)
    xyshift_x = get(hXShift, 'Value');
    xyshift_y = get(hYShift, 'Value');
    [updated_image, x1, y1] = get.roi_surround(image, opt.idx, stat, opt.surround, [xyshift_x, xyshift_y]);
    set(hImg, 'CData', updated_image(:, :, :, 1));
end

nfigs.rgb = hFigImg;
nfigs.slider = hFigSlider;
end
