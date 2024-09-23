function [normimg]=normalize_img(img)

if size(img,3)==3
    % Normalize each channel independently for RGB images
    normimg(:, :, 1) = mat2gray(img(:, :, 1));  % Red channel
    normimg(:, :, 2) = mat2gray(img(:, :, 2));  % Green channel
    normimg(:, :, 3) = mat2gray(img(:, :, 3));  % Blue channel
elseif size(img,3)==1
    normimg(:, :) = mat2gray(img(:, :, 1));
end

