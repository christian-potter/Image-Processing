
load('/Volumes/Warwick/DRGS/#550/SDH/Processed/cellpose/soma_labels.mat')
load('/Volumes/Warwick/DRGS/#550/SDH/Processed/cellpose/nuclear_labels.mat')

%%
h = plotv.volshow_rgb_dualAlpha(zrgb,'OverlayData',binsoma); 

%%
binsoma = soma_labels>0 ; 

%%

% Ensure binsoma is logical mask of same spatial size as zrgb first 3 dims
mask = binsoma > 0;
if ~isequal(size(mask), size(zrgb,1,2,3))
    % size(zrgb,1,2,3) is not valid syntax; compute explicitly
end
% Better size check:
if ~isequal(size(mask), size(zrgb(:,:, :,1)))
    if ~isequal(size(mask), size(zrgb,1:3)) % try another form for robustness
        % Fall back to explicit check
        if ~(size(mask,1)==size(zrgb,1) && size(mask,2)==size(zrgb,2) && size(mask,3)==size(zrgb,3))
            error('Size mismatch between binsoma and spatial dimensions of zrgb.');
        end
    end
end

% Create a 3x3x3 structuring element and dilate mask so each positive voxel expands to a 3x3x3 block
se = ones(5,5,5);
% Use convolution to dilate: any nonzero neighbor within 3x3x3 becomes >0
mask_dilated = convn(double(mask), se, 'same') > 0;

% Apply dilated mask across all channels (4th dim) of zrgb: set those voxels to zero
zsubl = zrgb;
zsubl(repmat(mask_dilated, [1,1,1,size(zrgb,4)])) = 0;

%%
zsubl = zrgb; 
% Replicate mask along 4th dimension and set corresponding zrgb values to zero
zsubl(repmat(mask, [1,1,1,size(zrgb,4)])) = 0;
%%
h = plotv.volshow_rgb_dualAlpha(zsubl,'OverlayData',binsoma); 
%%
plotOrthogonalPlanesFromConcatenatedPNG('/Users/ctp21/Library/Mobile Documents/com~apple~CloudDocs/Ross Lab/Conferences/USASP 2026/Anatomical Figures/v1.png', 'OriginMode', 'center');