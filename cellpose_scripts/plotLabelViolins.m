function plotLabelViolins(id_vect, d_vect, med_vect)
%PLOTLABELVIOLINS Make violin plots for d_vect and med_vect within each label.
%
%   plotLabelViolins(id_vect, d_vect, med_vect)
%
% Inputs:
%   id_vect  - Nx1 or 1xN vector of class labels (0, 1, 2)
%   d_vect   - Nx1 or 1xN numeric vector
%   med_vect - Nx1 or 1xN numeric vector
%
% Labels:
%   0 -> Projection
%   1 -> Excitatory
%   2 -> Inhibitory
%
% Notes:
%   This function uses ksdensity to draw violin shapes, then overlays the
%   raw data points for d_vect and med_vect.

    % Ensure column vectors
    id_vect  = id_vect(:);
    d_vect   = d_vect(:);
    med_vect = med_vect(:);

    % Basic checks
    if ~isequal(numel(id_vect), numel(d_vect), numel(med_vect))
        error('id_vect, d_vect, and med_vect must have the same number of elements.');
    end

    % Keep only finite rows
    valid = isfinite(id_vect) & isfinite(d_vect) & isfinite(med_vect);
    id_vect  = id_vect(valid);
    d_vect   = d_vect(valid);
    med_vect = med_vect(valid);

    % Define groups and names
    group_ids   = [0 1 2];
    group_names = {'Projection', 'Excitatory', 'Inhibitory'};

    % Figure
    figure;
    hold on;

    % X positions:
    % each label gets two side-by-side violins:
    % left = d_vect, right = med_vect
    base_pos = [1 2 3];
    offset = 0.18;
    violin_width = 0.28;

    % Colors
    color_d   = [0.2 0.4 0.8];
    color_med = [0.85 0.3 0.3];

    for i = 1:numel(group_ids)
        gid = group_ids(i);
        idx = id_vect == gid;

        dvals   = d_vect(idx);
        medvals = med_vect(idx);

        xpos_d   = base_pos(i) - offset;
        xpos_med = base_pos(i) + offset;

        % Draw violins
        drawSingleViolin(dvals, xpos_d, violin_width, color_d);
        drawSingleViolin(medvals, xpos_med, violin_width, color_med);

        % Overlay raw points with horizontal jitter
        jitter_d   = (rand(size(dvals)) - 0.5) * 0.08;
        jitter_med = (rand(size(medvals)) - 0.5) * 0.08;

        scatter(xpos_d + jitter_d, dvals, 18, ...
            'MarkerFaceColor', color_d, ...
            'MarkerEdgeColor', 'k', ...
            'MarkerFaceAlpha', 0.6, ...
            'MarkerEdgeAlpha', 0.4);

        scatter(xpos_med + jitter_med, medvals, 18, ...
            'MarkerFaceColor', color_med, ...
            'MarkerEdgeColor', 'k', ...
            'MarkerFaceAlpha', 0.6, ...
            'MarkerEdgeAlpha', 0.4);

        % Median lines
        if ~isempty(dvals)
            plot([xpos_d-0.08 xpos_d+0.08], median(dvals)*[1 1], ...
                'k-', 'LineWidth', 2);
        end
        if ~isempty(medvals)
            plot([xpos_med-0.08 xpos_med+0.08], median(medvals)*[1 1], ...
                'k-', 'LineWidth', 2);
        end
    end

    % Axis formatting
    xlim([0.5 3.5]);
    set(gca, 'XTick', base_pos, 'XTickLabel', group_names, 'FontSize', 12);
    xtickangle(0);
    ylabel('Value');
    title('Violin plots by label');
    box off;

    % Legend
    h1 = scatter(nan, nan, 40, 'MarkerFaceColor', color_d, ...
        'MarkerEdgeColor', 'k', 'DisplayName', 'd\_vect');
    h2 = scatter(nan, nan, 40, 'MarkerFaceColor', color_med, ...
        'MarkerEdgeColor', 'k', 'DisplayName', 'med\_vect');
    legend([h1 h2], 'Location', 'best');

    hold off;
end


function drawSingleViolin(vals, xpos, violin_width, face_color)
%DRAWSINGLEVIOLIN Draw one violin centered at xpos.

    vals = vals(isfinite(vals));
    if numel(vals) < 2
        % Too few points for density estimate; just skip violin body
        return;
    end

    try
        [f, yi] = ksdensity(vals);
    catch
        return;
    end

    if all(f == 0) || isempty(f)
        return;
    end

    % Normalize violin width
    f = f ./ max(f) * violin_width;

    xv = [xpos + f, fliplr(xpos - f)];
    yv = [yi, fliplr(yi)];

    patch(xv, yv, face_color, ...
        'FaceAlpha', 0.3, ...
        'EdgeColor', face_color, ...
        'LineWidth', 1.2);
end