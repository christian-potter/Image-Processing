function dF_F = dF_F_rolling(F_matrix, window_size, method)
    % Compute dF/F for calcium imaging data with a rolling baseline
    % Inputs:
    %   F_matrix: Neurons x Time fluorescence matrix
    %   window_size: Number of time points for rolling baseline calculation
    %   method: 'median' (default) or 'mean' for baseline F0
    % Output:
    %   dF_F: Neurons x Time matrix of dF/F values

    if nargin < 2
        window_size = 400; % Default rolling window size (adjust as needed)
    end
    if nargin < 3
        method = 'median'; % Default method for baseline calculation
    end

    % Get matrix size
    [num_neurons, num_timepoints] = size(F_matrix);

    % Preallocate dF/F matrix
    dF_F = zeros(size(F_matrix));

    % Loop over each neuron
    for n = 1:num_neurons
        n
        % Initialize rolling F0
        F0_rolling = zeros(1, num_timepoints);

        % Compute rolling baseline F0
        for t = 1:num_timepoints
            % Define window range
            start_idx = max(1, t - floor(window_size / 2));
            end_idx = min(num_timepoints, t + floor(window_size / 2));

            % Extract windowed fluorescence values
            F_window = F_matrix(n, start_idx:end_idx);
            sorted_F = sort(F_window, 'ascend');
            num_samples = round(0.1 * length(sorted_F)); % 10% of window

            % Compute rolling baseline
            if strcmp(method, 'median')
                F0_rolling(t) = median(sorted_F(1:num_samples));
            else
                F0_rolling(t) = mean(sorted_F(1:num_samples));
            end
        end

        % Compute dF/F
        dF_F(n, :) = (F_matrix(n, :) - F0_rolling) ./ F0_rolling;
    end
end