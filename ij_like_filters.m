function out = ij_like_filters(img, varargin)
% IJ_LIKE_FILTERS Apply ImageJ-like Gaussian blur and top-hat filters.
%   out = ij_like_filters(img, 'Param1', val1, ...)
%
% Inputs:
%   img     - numeric array of size [nx, ny, 3, nz] or [nx, ny, 1, nz] or
%             [nx, ny, nz] (will be interpreted appropriately). Supports any
%             numeric class; processing done in double and converted back.
%
% Supported name-value parameters:
%   'Filter'      - cell array of strings specifying filters to apply in
%                   sequence. Allowed values: 'gaussian', 'tophat'.
%                   Default: {'gaussian'}.
%   'Sigma'       - scalar or 1x2 vector specifying gaussian sigma in
%                   pixels (X,Y). If scalar, applied to both dims.
%                   Default: 2.
%   'Radius'      - scalar radius for morphological top-hat (structuring
%                   element radius in pixels). Default: 10.
%   'SEShape'     - shape of structuring element for tophat: 'disk' or
%                   'square'. Default: 'disk'.
%   'Normalize'   - logical; if true, result is rescaled to original class
%                   data range. Default: true.
%
% Output:
%   out - filtered image array of same size and class as input.
%
% Notes:
%   - Gaussian implemented via imgaussfilt (requires Image Processing
%     Toolbox). For 3D (multiple z-planes) filtering is applied per z.
%   - Top-hat (white top-hat) is implemented using imtophat with 2D SE on
%     each z-plane.
%
% Example:
%   out = ij_like_filters(img, 'Filter', {'gaussian','tophat'}, ...
%                         'Sigma',1.5,'Radius',8);

% Input validation and defaults
p = inputParser;
validImg = @(x) isnumeric(x) && ndims(x) >=2 && ndims(x) <=4;
addRequired(p,'img', validImg);
addParameter(p,'Filter', {'gaussian'}, @(x) iscellstr(x) || isstring(x) || ischar(x));
addParameter(p,'Sigma', 2, @(x) isnumeric(x) && isreal(x) && all(x>=0));
addParameter(p,'Radius', 10, @(x) isnumeric(x) && isscalar(x) && x>=0);
addParameter(p,'SEShape','disk', @(x) ischar(x) || isstring(x));
addParameter(p,'Normalize', true, @(x) islogical(x) || (isnumeric(x) && isscalar(x)));
parse(p,img,varargin{:});

filters = cellstr(p.Results.Filter);
sigma = p.Results.Sigma;
radius = p.Results.Radius;
seshape = lower(char(p.Results.SEShape));
normalize = logical(p.Results.Normalize);

% Normalize sigma to two elements [sx sy]
if isscalar(sigma)
    sigma = [sigma sigma];
elseif numel(sigma) == 2
    sigma = sigma(:).';
else
    error('Sigma must be scalar or 1x2 vector.');
end

% Prepare image: interpret various dims as [nx ny channels z]
sz = size(img);
switch ndims(img)
    case 2
        nx = sz(1); ny = sz(2); nch = 1; nz = 1;
        img4 = reshape(img, [nx, ny, 1, 1]);
    case 3
        % Could be nx x ny x nch OR nx x ny x nz (ambiguous). We assume
        % third dim = channels if size==3, else it's z.
        if sz(3) == 3
            nx = sz(1); ny = sz(2); nch = 3; nz = 1;
            img4 = reshape(img, [nx, ny, 3, 1]);
        else
            nx = sz(1); ny = sz(2); nch = 1; nz = sz(3);
            img4 = reshape(img, [nx, ny, 1, nz]);
        end
    case 4
        nx = sz(1); ny = sz(2); nch = sz(3); nz = sz(4);
        img4 = img;
    otherwise
        error('Unsupported image dimensionality.');
end

origClass = class(img);
imgDouble = double(img4);

% Apply filters in sequence
res = imgDouble;
for f = 1:numel(filters)
    fname = lower(strtrim(filters{f}));
    switch fname
        case 'gaussian'
            % Apply 2D gaussian per channel and z-plane
            % Use imgaussfilt if available; otherwise use imfilter with fspecial
            useImgauss = exist('imgaussfilt','file')==2;
            for zz = 1:nz
                for ch = 1:nch
                    plane = squeeze(res(:,:,ch,zz));
                    if useImgauss
                        plane = imgaussfilt(plane, sigma, 'FilterSize', max(1,2*ceil(3*max(sigma))+1));
                    else
                        % separable filter via imfilter
                        hx = fspecial('gaussian', [1, max(1,2*ceil(3*sigma(1))+1)], sigma(1));
                        hy = fspecial('gaussian', [max(1,2*ceil(3*sigma(2))+1), 1], sigma(2));
                        plane = imfilter(imfilter(plane, hx, 'replicate'), hy, 'replicate');
                    end
                    res(:,:,ch,zz) = plane;
                end
            end

        case 'tophat'
            % White top-hat: imtophat(A, se)
            switch seshape
                case 'disk'
                    se = strel('disk', round(radius), 0);
                case 'square'
                    se = strel('square', max(1,2*round(radius)+1));
                otherwise
                    error('Unsupported SEShape. Use ''disk'' or ''square''.');
            end
            for zz = 1:nz
                for ch = 1:nch
                    plane = squeeze(res(:,:,ch,zz));
                    plane = imtophat(plane, se);
                    res(:,:,ch,zz) = plane;
                end
            end

        otherwise
            error('Unknown filter "%s". Supported: ''gaussian'', ''tophat''.', fname);
    end
end

% Convert back to original class, with optional normalization
if normalize
    % Rescale to original dynamic range
    switch origClass
        case {'uint8','uint16','uint32'}
            mx = double(intmax(origClass));
            mn = 0;
        case {'int8','int16','int32'}
            mx = double(intmax(origClass));
            mn = double(intmin(origClass));
        case 'logical'
            mx = 1; mn = 0;
        otherwise % double, single, etc.
            % For floating, keep range preserved (no clipping)
            out = cast(res, origClass);
            out = reshape(out, size(img));
            return;
    end
    % Scale res per entire image to [mn mx] using min/max of res
    rmin = min(res(:));
    rmax = max(res(:));
    if rmax > rmin
        resScaled = (res - rmin) / (rmax - rmin); % 0..1
    else
        resScaled = zeros(size(res));
    end
    resScaled = resScaled * (mx - mn) + mn;
    out = cast(resScaled, origClass);
else
    % Clip to numeric limits of original class, then cast
    if isinteger(eval(['(''' origClass ''')']))
        % integer types
        mx = double(intmax(origClass));
        mn = double(intmin(origClass));
        res = min(max(res, mn), mx);
    end
    out = cast(res, origClass);
end

% Restore original dimensions
out = reshape(out, size(img));
end