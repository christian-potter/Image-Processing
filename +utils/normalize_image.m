function [normimg]=normalize_image(img)

% Normalize each channel independently for RGB images
normimg(:, :, 1) = mat2gray(img(:, :, 1));  % Red channel
normimg(:, :, 2) = mat2gray(img(:, :, 2));  % Green channel
normimg(:, :, 3) = mat2gray(img(:, :, 3));  % Blue channel