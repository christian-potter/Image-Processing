function plotGroupedViolins(label_vect, label_values, label_names, vector_names, vec1, vec2)
%PLOTGROUPEDVIOLINSDUALAXIS Grouped violin plot with two raw-value y-axes.
%
%   plotGroupedViolinsDualAxis(label_vect, label_values, label_names, vector_names, vec1, vec2)
%
% Inputs:
%   label_vect    - Nx1 or 1xN vector of labels for each observation
%   label_values  - vector listing the label values to plot, in the exact
%                   order they should appear on the x-axis
%   label_names   - cell array or string array of display names for each
%                   label value in label_values
%   vector_names  - 1x2 cell array or string array with names for vec1, vec2
%   vec1, vec2    - numeric vectors, each the same length as label_vect
%
% Notes:
%   - vec1 is plotted against the LEFT y-axis in raw units
%   - vec2 is plotted against the RIGHT y-axis in raw units
%   - no normalization is applied
%   - this function is intended for exactly two variables

    label_vect   = label_vect(:);
    label_values = label_values(:);
    vec1         = vec1(:);
    vec2         = vec2(:);

    n = numel(label_vect);

    if numel(vec1) ~= n || numel(vec2) ~= n
        error('vec1 and vec2 must have the same number of elements as label_vect.');
    end

    if isstring(label_names)
        label_names = cellstr(label_names);
    end
    if isstring(vector_names)
        vector_names = cellstr(vector_names);
    end

    if ~iscell(label_names)
        error('label_names must be a cell array or string array.');
    end
    if ~iscell(vector_names) || numel(vector_names) ~= 2
        error('vector_names must be a cell array or string array with exactly 2 entries.');
    end

    nLabels = numel(label_values);
    if numel(label_names) ~= nLabels
        error('label_names must have the same number of entries as label_values.');
    end

    % X positions for the two violins within each group
    base_pos = 1:nLabels;
    offsets = [-0.10, 0.10];
    violin_width = 0.12;

    cmap = lines(2);

    figure;
    hold on;

    %-----------------------------%
    % Plot vec1 on left y-axis
    %-----------------------------%
    yyaxis left
    hold on

    leftAll = [];

    for iLabel = 1:nLabels
        idx = (label_vect == label_values(iLabel));
        vals = vec1(idx);
        vals = vals(isfinite(vals));

        xpos = base_pos(iLabel) + offsets(1);

        drawSingleViolin(vals, xpos, violin_width, cmap(1,:));

        if ~isempty(vals)
            jitter = (rand(size(vals)) - 0.5) * 0.04;
            scatter(xpos + jitter, vals, 18, ...
                'MarkerFaceColor', cmap(1,:), ...
                'MarkerEdgeColor', 'k', ...
                'MarkerFaceAlpha', 0.6, ...
                'MarkerEdgeAlpha', 0.35);

            medVal = median(vals, 'omitnan');
            plot([xpos - violin_width*0.35, xpos + violin_width*0.35], ...
                 [medVal medVal], 'k-', 'LineWidth', 1.8);

            leftAll = [leftAll; vals]; %#ok<AGROW>
        end
    end

    ylabel(vector_names{1});
    ax = gca;
    ax.YAxis(1).Color = [0 0 0];

    if ~isempty(leftAll)
        setNiceAxisLimits(leftAll);
    end

    %-----------------------------%
    % Plot vec2 on right y-axis
    %-----------------------------%
    yyaxis right
    hold on

    rightAll = [];

    for iLabel = 1:nLabels
        idx = (label_vect == label_values(iLabel));
        vals = vec2(idx);
        vals = vals(isfinite(vals));

        xpos = base_pos(iLabel) + offsets(2);

        drawSingleViolin(vals, xpos, violin_width, cmap(2,:));

        if ~isempty(vals)
            jitter = (rand(size(vals)) - 0.5) * 0.04;
            scatter(xpos + jitter, vals, 18, ...
                'MarkerFaceColor', cmap(2,:), ...
                'MarkerEdgeColor', 'k', ...
                'MarkerFaceAlpha', 0.6, ...
                'MarkerEdgeAlpha', 0.35);

            medVal = median(vals, 'omitnan');
            plot([xpos - violin_width*0.35, xpos + violin_width*0.35], ...
                 [medVal medVal], 'k-', 'LineWidth', 1.8);

            rightAll = [rightAll; vals]; %#ok<AGROW>
        end
    end

    ylabel(vector_names{2});
    ax.YAxis(2).Color = [0 0 0];

    if ~isempty(rightAll)
        setNiceAxisLimits(rightAll);
    end

    %-----------------------------%
    % Shared x-axis formatting
    %-----------------------------%
    xlim([0.5, nLabels + 0.5]);
    set(gca, ...
        'XTick', base_pos, ...
        'XTickLabel', label_names, ...
        'FontSize', 12);

    title('Grouped violin plots by label');
    box off;

    % Legend
    h1 = scatter(nan, nan, 40, ...
        'MarkerFaceColor', cmap(1,:), ...
        'MarkerEdgeColor', 'k', ...
        'DisplayName', vector_names{1});

    h2 = scatter(nan, nan, 40, ...
        'MarkerFaceColor', cmap(2,:), ...
        'MarkerEdgeColor', 'k', ...
        'DisplayName', vector_names{2});

    legend([h1 h2], vector_names, 'Location', 'best');

    yyaxis left
    hold off
end


function drawSingleViolin(vals, xpos, violin_width, face_color)
%DRAWSINGLEVIOLIN Draw a violin centered at xpos.

    vals = vals(:);
    vals = vals(isfinite(vals));

    if numel(vals) < 2
        return;
    end

    try
        [f, yi] = ksdensity(vals);
    catch
        return;
    end

    if isempty(f) || all(f == 0)
        return;
    end

    f = f ./ max(f) * violin_width;

    xv = [xpos + f(:)', fliplr(xpos - f(:)')];
    yv = [yi(:)',       fliplr(yi(:)')];

    patch(xv, yv, face_color, ...
        'FaceAlpha', 0.28, ...
        'EdgeColor', face_color, ...
        'LineWidth', 1.2);
end


function setNiceAxisLimits(vals)
%SETNICEAXISLIMITS Set y-limits to show the distribution well in raw units.

    vals = vals(isfinite(vals));
    if isempty(vals)
        return;
    end

    if numel(vals) >= 5
        qLow  = prctile(vals, 2);
        qHigh = prctile(vals, 98);
    else
        qLow  = min(vals);
        qHigh = max(vals);
    end

    vMin = min(vals);
    vMax = max(vals);

    if qHigh <= qLow
        qLow  = vMin;
        qHigh = vMax;
    end

    if qHigh <= qLow
        pad = max(abs(qLow) * 0.1, 1);
        ylim([qLow - pad, qHigh + pad]);
        return;
    end

    pad = 0.10 * (qHigh - qLow);
    y1 = qLow - pad;
    y2 = qHigh + pad;

    % Expand if necessary to include all points
    y1 = min(y1, vMin);
    y2 = max(y2, vMax);

    if y2 <= y1
        pad = max(abs(y1) * 0.1, 1);
        y1 = y1 - pad;
        y2 = y2 + pad;
    end

    ylim([y1 y2]);
end