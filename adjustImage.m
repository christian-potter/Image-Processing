function adjustImage(image)
    % Check if the input is a grayscale or RGB image
    if size(image, 3) == 1
        isRGB = false;  % Grayscale image
    elseif size(image, 3) == 3
        isRGB = true;   % RGB image
    else
        error('Input must be a grayscale or RGB image.');
    end

    % Normalize the image intensity values to the range [0, 1]
    if isRGB
        % Normalize each channel independently for RGB images
        image(:, :, 1) = mat2gray(image(:, :, 1));  % Red channel
        image(:, :, 2) = mat2gray(image(:, :, 2));  % Green channel
        image(:, :, 3) = mat2gray(image(:, :, 3));  % Blue channel
    else
        % Normalize grayscale image
        image = mat2gray(image);
    end

    % Create a figure for the image display and sliders
    hFig = figure('Name', 'Adjust Image with Sliders', 'NumberTitle', 'off', ...
        'Position', [100, 100, 600, 400]);

    % Create axes for displaying the image
    hAx = axes('Parent', hFig, 'Position', [0.1, 0.3, 0.8, 0.6]);
    hImg = imshow(image, 'Parent', hAx);

    % Set default values for sliders
    low_in = 0;
    high_in = 1;
    gamma = 1;

    % Create sliders and their labels
    uicontrol('Style', 'text', 'String', 'Low In:', 'Position', [50, 60, 100, 20]);
    hLowIn = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', low_in, ...
        'Position', [150, 60, 300, 20], 'Callback', @updateImage);

    uicontrol('Style', 'text', 'String', 'High In:', 'Position', [50, 30, 100, 20]);
    hHighIn = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', high_in, ...
        'Position', [150, 30, 300, 20], 'Callback', @updateImage);

    uicontrol('Style', 'text', 'String', 'Gamma:', 'Position', [50, 0, 100, 20]);
    hGamma = uicontrol('Style', 'slider', 'Min', 0.1, 'Max', 2, 'Value', gamma, ...
        'Position', [150, 0, 300, 20], 'Callback', @updateImage);

    % Callback function to update the image based on slider values
    function updateImage(~, ~)
        % Get current slider values
        low_in = get(hLowIn, 'Value');
        high_in = get(hHighIn, 'Value');
        gamma = get(hGamma, 'Value');

        % Ensure that low_in is not greater than high_in
        if low_in >= high_in
            low_in = high_in - 0.01;
        end

        % Adjust the image based on slider values
        if isRGB
            % Apply imadjust to each channel of the RGB image
            adj_img = cat(3, ...
                imadjust(image(:, :, 1), [low_in, high_in], [], gamma), ...
                imadjust(image(:, :, 2), [low_in, high_in], [], gamma), ...
                imadjust(image(:, :, 3), [low_in, high_in], [], gamma));
        else
            % Apply imadjust to grayscale image
            adj_img = imadjust(image, [low_in, high_in], [], gamma);
        end

        % Update the displayed image
        set(hImg, 'CData', adj_img);
    end
end
