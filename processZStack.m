function stackOut = processZStack(stackRGB, opts)
% processZStack_ImageJLike  Apply ImageJ-like processing ops to an RGB z-stack.
%
% INPUT
%   stackRGB : Y x X x 3 x Z (from readZStack_ChanAChanB)
%
% OPTIONS (opts struct; all optional)
%   opts.ApplyToChannels  : which channels to process, e.g. [1 2] (default [1 2 3])
%   opts.PreserveClass    : true keeps input class (default true)
%
%   Gaussian blur (ImageJ: Process > Filters > Gaussian Blur...)
%   opts.Gaussian.Enable  : logical (default false)
%   opts.Gaussian.Sigma   : scalar sigma in pixels (default 1.0)
%   opts.Gaussian.Mode    : "perPlane" | "3D" (default "perPlane")
%
%   Top-hat (ImageJ-ish analogue: rolling ball background / morphology)
%   opts.TopHat.Enable    : logical (default false)
%   opts.TopHat.Type      : "white" | "black" (default "white")
%   opts.TopHat.Radius    : radius in pixels (default 15)
%   opts.TopHat.Shape     : "disk" (2D) | "sphere" (3D) (default inferred from Mode)
%   opts.TopHat.Mode      : "perPlane" | "3D" (default "perPlane")
%
% OUTPUT
%   stackOut : Y x X x 3 x Z processed

arguments
    stackRGB {mustBeNumeric, mustBeNonempty}
    opts.ApplyToChannels (1,:) double {mustBeInteger, mustBeInRange(opts.ApplyToChannels,1,3)} = [1 2 3]
    opts.PreserveClass (1,1) logical = true

    opts.Gaussian.Enable (1,1) logical = false
    opts.Gaussian.Sigma (1,1) double {mustBePositive} = 1.0
    opts.Gaussian.Mode (1,1) string {mustBeMember(opts.Gaussian.Mode,["perPlane","3D"])} = "perPlane"

    opts.TopHat.Enable (1,1) logical = false
    opts.TopHat.Type (1,1) string {mustBeMember(opts.TopHat.Type,["white","black"])} = "white"
    opts.TopHat.Radius (1,1) double {mustBePositive} = 15
    opts.TopHat.Mode (1,1) string {mustBeMember(opts.TopHat.Mode,["perPlane","3D"])} = "perPlane"
    opts.TopHat.Shape (1,1) string {mustBeMember(opts.TopHat.Shape,["disk","sphere","auto"])} = "auto"
end

if ndims(stackRGB) ~= 4 || size(stackRGB,3) ~= 3
    error("Expected stackRGB as Y x X x 3 x Z.");
end

inClass = class(stackRGB);

% Work in floating point for predictable filtering, then cast back if desired
work = single(stackRGB);

% Decide structuring element shape if auto
shape = opts.TopHat.Shape;
if shape == "auto"
    if opts.TopHat.Mode == "3D"
        shape = "sphere";
    else
        shape = "disk";
    end
end

% --- Apply Gaussian blur ---
if opts.Gaussian.Enable
    sigma = opts.Gaussian.Sigma;

    if opts.Gaussian.Mode == "perPlane"
        for c = opts.ApplyToChannels
            for z = 1:size(work,4)
                work(:,:,c,z) = imgaussfilt(work(:,:,c,z), sigma);
            end
        end
    else % "3D"
        for c = opts.ApplyToChannels
            vol = squeeze(work(:,:,c,:));        % Y x X x Z
            vol = imgaussfilt3(vol, sigma);
            work(:,:,c,:) = reshape(vol, size(work,1), size(work,2), 1, size(work,4));
        end
    end
end

% --- Apply Top-hat ---
% ImageJ "Top Hat" commonly maps to white top-hat (original - opening) or
% black top-hat (closing - original), using a structuring element.
if opts.TopHat.Enable
    R = opts.TopHat.Radius;

    if opts.TopHat.Mode == "perPlane"
        se2 = strel("disk", round(R), 0);
        for c = opts.ApplyToChannels
            for z = 1:size(work,4)
                I = work(:,:,c,z);
                switch opts.TopHat.Type
                    case "white"
                        I2 = imtophat(I, se2);          % I - imopen(I)
                    case "black"
                        I2 = imbothat(I, se2);          % imclose(I) - I
                end
                work(:,:,c,z) = I2;
            end
        end

    else % "3D"
        % 3D morphology: use spherical SE via logical neighborhood
        if shape ~= "sphere"
            % still allow "disk" but it doesn't make sense in 3D; coerce
            shape = "sphere";
        end
        nhood = makeSphereNhood(round(R));
        se3 = strel(nhood);

        for c = opts.ApplyToChannels
            vol = squeeze(work(:,:,c,:)); % Y x X x Z
            switch opts.TopHat.Type
                case "white"
                    % white top-hat: vol - opening(vol)
                    opened = imopen(vol, se3);
                    vol2 = vol - opened;
                case "black"
                    % black top-hat: closing(vol) - vol
                    closed = imclose(vol, se3);
                    vol2 = closed - vol;
            end
            work(:,:,c,:) = reshape(vol2, size(work,1), size(work,2), 1, size(work,4));
        end
    end
end

% Cast back
if opts.PreserveClass
    if isinteger(stackRGB)
        % Clip to valid range before casting
        info = intmin(inClass); lo = double(info);
        info = intmax(inClass); hi = double(info);
        work = min(max(work, lo), hi);
    end
    stackOut = cast(work, inClass);
else
    stackOut = work; % single
end

end

% ------------------------- helpers -------------------------

function nhood = makeSphereNhood(R)
% makeSphereNhood  Create a 3D spherical neighborhood (logical) of radius R.
% Size is (2R+1)^3.
d = 2*R + 1;
[x,y,z] = ndgrid(-R:R, -R:R, -R:R);
nhood = (x.^2 + y.^2 + z.^2) <= R^2;
% Ensure it's logical
nhood = logical(nhood);
end