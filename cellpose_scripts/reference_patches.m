
%% GET INDICES
% create logical mask for shapeIndex between -0.1 and 0.1 (inclusive)
mask = (shapeIndex >= -0.2) & (shapeIndex <= 0.2);
% get vector of all indices that satisfy the condition
sphereidx = find(mask);


% create logical mask for shapeIndex between -0.1 and 0.1 (inclusive)
mask = (shapeIndex >= .9); 
% get vector of all indices that satisfy the condition
verticalidx = find(mask);

% create logical mask for shapeIndex between -0.1 and 0.1 (inclusive)
mask = (shapeIndex <= -.6); 
% get vector of all indices that satisfy the condition
horizontalidx = find(mask);


%% 2D PATCH 
shared = horizontalidx; 
% find unique nonzero labels in overlap_labels
ulabels = unique(overlap_labels(:));
ulabels(ulabels==0) = [];

% ensure sphereidx is a column vector of indices (labels expected)
sphere_labels = unique(shared(:));

% find intersection of the two sets
shared_labels = intersect(ulabels, sphere_labels);

% assign outputs / display
shared_labels = shared_labels(:);

% initialize cell array to hold patches: each entry will be a 1x3 cell [XY, XZ, YZ]
nShared = numel(shared_labels);
patches = cell(nShared,1);

% initial nominal patch size (height x width) for each plane (will be adapted per-label)
nominal_sz = [28 28];
half_nom = floor(nominal_sz/2);

% volume size
[ny,nx,nz] = size(overlap_labels);

% additional margin beyond mask bounds (requested margin)
margin = 1;

for ii = 1:nShared
    lbl = shared_labels(ii);
    if lbl == 0
        patches{ii} = {[],[],[]};
        continue;
    end
    % find linear indices where overlap_labels equals lbl
    loc = find(overlap_labels == lbl);
    if isempty(loc)
        patches{ii} = {[],[],[]};
        continue;
    end
    % convert to subscripts (y,x,z)
    [y,x,z] = ind2sub([ny,nx,nz], loc);
    % compute median coordinates
    my = round(median(y));
    mx = round(median(x));
    mz = round(median(z));
    % For each plane determine required extents including margin, then choose maximum HxW
    % XY plane extent (centered at my,mx) uses Z=mz
    % propose window centered at (my,mx) with half_nom and margin
    y1_xy = my - half_nom(1) - margin;
    y2_xy = my + half_nom(1) + margin - 1 + mod(nominal_sz(1),2);
    x1_xy = mx - half_nom(2) - margin;
    x2_xy = mx + half_nom(2) + margin - 1 + mod(nominal_sz(2),2);
    % XZ plane extent (rows=Z centered at mz, cols=X centered at mx)
    z1_xz = mz - half_nom(1) - margin;
    z2_xz = mz + half_nom(1) + margin - 1 + mod(nominal_sz(1),2);
    x1_xz = mx - half_nom(2) - margin;
    x2_xz = mx + half_nom(2) + margin - 1 + mod(nominal_sz(2),2);
    % YZ plane extent (rows=Z centered at mz, cols=Y centered at my)
    z1_yz = mz - half_nom(1) - margin;
    z2_yz = mz + half_nom(1) + margin - 1 + mod(nominal_sz(1),2);
    y1_yz = my - half_nom(2) - margin;
    y2_yz = my + half_nom(2) + margin - 1 + mod(nominal_sz(2),2);

    % compute heights and widths for each plane (desired sizes before clipping)
    H_xy = (y2_xy - y1_xy + 1);
    W_xy = (x2_xy - x1_xy + 1);
    H_xz = (z2_xz - z1_xz + 1);
    W_xz = (x2_xz - x1_xz + 1);
    H_yz = (z2_yz - z1_yz + 1);
    W_yz = (y2_yz - y1_yz + 1);

    % choose largest height and width among planes to make them consistent
    H = max([H_xy, H_xz, H_yz, nominal_sz(1)]);
    W = max([W_xy, W_xz, W_yz, nominal_sz(2)]);

    % ensure H and W are integers >=1
    H = max(1,round(H));
    W = max(1,round(W));

    % prepare three empty patches: XY (H x W x 3), XZ (H x W x 3), YZ (H x W x 3)
    patchXY = zeros(H,W,3,'like',overlap_labels);
    patchXZ = zeros(H,W,3,'like',overlap_labels);
    patchYZ = zeros(H,W,3,'like',overlap_labels);

    % For each plane compute window such that the requested center falls in the center of HxW
    % compute offsets to position the original intended center near center of new HxW
    cy = ceil(H/2);
    cx = ceil(W/2);

    % XY: want (my,mx) to map to (cy,cx)
    y1 = my - (cy-1);
    y2 = y1 + H - 1;
    x1 = mx - (cx-1);
    x2 = x1 + W - 1;
    ys = max(y1,1):min(y2,ny);
    xs = max(x1,1):min(x2,nx);
    ty1 = ys(1) - y1 + 1;
    tx1 = xs(1) - x1 + 1;
    ty2 = ty1 + numel(ys)-1;
    tx2 = tx1 + numel(xs)-1;
    if exist('zrgb','var') && ndims(zrgb)==4 && mz>=1 && mz<=size(zrgb,3)
        sliceXY = squeeze(zgrb(:,:,mz,:)); % ny x nx x 3
        patchXY(ty1:ty2,tx1:tx2,:) = sliceXY(ys,xs,:);
    else
        if mz>=1 && mz<=nz
            sliceXY = double(overlap_labels(:,:,mz));
            vmax = max(1,double(max(sliceXY(:))));
            sliceXY = sliceXY / vmax;
            sc = sliceXY(ys,xs);
            for c=1:3, patchXY(ty1:ty2,tx1:tx2,c) = sc; end
        end
    end

    % XZ: want (mz,mx) to map to (cy,cx) where rows are Z and cols are X
    z1 = mz - (cy-1);
    z2 = z1 + H - 1;
    x1 = mx - (cx-1);
    x2 = x1 + W - 1;
    zs = max(z1,1):min(z2,nz);
    xs = max(x1,1):min(x2,nx);
    tz1 = zs(1) - z1 + 1;
    tx1 = xs(1) - x1 + 1;
    tz2 = tz1 + numel(zs)-1;
    tx2 = tx1 + numel(xs)-1;
    if exist('zrgb','var') && ndims(zrgb)==4
        if my>=1 && my<=size(zgrb,1)
            sliceXZ = squeeze(zgrb(my,:,:, :)); % nx x nz x 3
            sliceXZ = permute(sliceXZ, [2 1 3]); % nz x nx x 3
            patchXZ(tz1:tz2,tx1:tx2,:) = sliceXZ(zs,xs,:);
        end
    else
        if my>=1 && my<=ny
            sliceXZ = squeeze(overlap_labels(my,:,:)); % nx x nz
            sliceXZ = double(sliceXZ) / max(1,double(max(sliceXZ(:))));
            sliceXZ = permute(sliceXZ, [2 1]); % nz x nx
            sc = sliceXZ(zs,xs);
            for c=1:3, patchXZ(tz1:tz2,tx1:tx2,c) = sc; end
        end
    end

    % YZ: want (mz,my) to map to (cy,cx) where rows are Z and cols are Y
    z1 = mz - (cy-1);
    z2 = z1 + H - 1;
    y1 = my - (cx-1); % note: columns correspond to Y here
    y2 = y1 + W - 1;
    zs = max(z1,1):min(z2,nz);
    ys = max(y1,1):min(y2,ny);
    tz1 = zs(1) - z1 + 1;
    ty1 = ys(1) - y1 + 1;
    tz2 = tz1 + numel(zs)-1;
    ty2 = ty1 + numel(ys)-1;
    if exist('zrgb','var') && ndims(zrgb)==4
        if mx>=1 && mx<=size(zgrb,2)
            sliceYZ = squeeze(zgrb(:,mx,:,:)); % ny x nz x 3
            sliceYZ = permute(sliceYZ, [2 1 3]); % nz x ny x 3
            patchYZ(tz1:tz2,ty1:ty2,:) = sliceYZ(zs,ys,:);
        end
    else
        if mx>=1 && mx<=nx
            sliceYZ = squeeze(overlap_labels(:,mx,:)); % ny x nz
            sliceYZ = double(sliceYZ) / max(1,double(max(sliceYZ(:))));
            sliceYZ = permute(sliceYZ, [2 1]); % nz x ny
            sc = sliceYZ(zs,ys);
            for c=1:3, patchYZ(tz1:tz2,ty1:ty2,c) = sc; end
        end
    end

    % assign as cell of three planes: {XY, XZ, YZ}
    patches{ii} = {patchXY, patchXZ, patchYZ};
end

%% PLOT 2D 
zgrb = zrgb(:,:,:,[2 1 3]); 
%%zrgb = permute(zrgb, [2 1 3 4]);

% combine the arrays from each cell entry before plotting 
% Each patches{ii} may be a cell {XY,XZ,YZ} or a 3D array (from later code).
% Build a combined 2D montage image per entry by placing the three planes side-by-side.
nEntries = 17;
combined = cell(nEntries,1);
% determine target plane size from earlier variables if available, else infer
defaultH = exist('sz','var') && numel(sz)>=1 && ~isempty(sz(1)) && sz(1)>0 && sz(1) || 128;
defaultW = exist('sz','var') && numel(sz)>=2 && ~isempty(sz(2)) && sz(2)>0 && sz(2) || 128;

for k = 1:nEntries
    p = patches{k};
    if isempty(p)
        combined{k} = zeros(defaultH, defaultW*3, 3, 'like', overlap_labels);
        continue;
    end
    % if p is a cell of three planes
    if iscell(p) && numel(p)>=3
        A = p{1}; B = p{2}; C = p{3};
    else
        % if p is a 4-D volumetric patch (sy x sx x szp x 3), create max-intensity projections for each plane
        if ndims(p)==4 && size(p,4)==3
            % XY: max projection along Z -> sy x sx x 3
            A = squeeze(max(p,[],3));
            % XZ: project along Y -> szp x sx x 3 (Z rows, X cols) -> permute to rows=sz, cols=sx
            XZ = squeeze(max(p,[],1)); % 1 x sx x szp x3 -> squeeze -> sx x szp x3
            Atemp = permute(XZ, [2 1 3]); % szp x sx x3
            B = Atemp;
            % YZ: project along X -> sy x szp x3 -> permute to szp x sy x3
            YZ = squeeze(max(p,[],2)); % sy x 1 x szp x3 -> sy x szp x3
            C = permute(YZ, [2 1 3]); % szp x sy x3
        else
            % unexpected format: try to squeeze to HxWx3 and replicate if needed
            tmp = squeeze(p);
            if ndims(tmp)==2
                A = repmat(tmp,1,1,3);
                B = A; C = A;
            elseif ndims(tmp)==3 && size(tmp,3)==3
                A = tmp; B = tmp; C = tmp;
            else
                combined{k} = zeros(defaultH, defaultW*3, 3, 'like', overlap_labels);
                continue;
            end
        end
    end

    % ensure each plane is HxW x 3 by resizing or padding to common size
    hA = size(A,1); wA = size(A,2);
    hB = size(B,1); wB = size(B,2);
    hC = size(C,1); wC = size(C,2);
    H = max([hA,hB,hC,defaultH]);
    W = max([wA,wB,wC,defaultW]);

    padA = zeros(H,W,3,'like',A); padB = zeros(H,W,3,'like',A); padC = zeros(H,W,3,'like',A);
    padA(1:hA,1:wA,:) = A;
    padB(1:hB,1:wB,:) = B;
    padC(1:hC,1:wC,:) = C;

    % combine side-by-side: [A | B | C]
    combined{k} = cat(2, padA, padB, padC);
end

% display first up to 40 combined images in a grid
nShow = min(40, numel(combined));
nRows = 6;nCols = 5;
figure;
for k = 1:nShow
    img = combined{k};
    if isempty(img)
        img = zeros(defaultH, defaultW*3, 3, 'like', overlap_labels);
    end
    % ensure img is HxWx3
    if ndims(img)==2
        img = repmat(img,1,1,3);
    elseif ndims(img)==4
        img = squeeze(img);
    end
    imgd = double(img);
    mn = min(imgd(:)); mx = max(imgd(:));
    if mx > mn
        imgn = (imgd - mn) / (mx - mn);
    else
        imgn = zeros(size(imgd));
    end
    subplot(nRows,nCols,k);
    imshow(imgn);
    axis image off;
    title(sprintf('Entry %d', k));
end
for k = nShow+1 : nRows*nCols
    subplot(nRows,nCols,k); axis off;
end
%%
% Plot first 10 entries as 3D scenes with three orthogonal planes centered at origin
nPlot = min(10, numel(patches));
figure;
for ii = 1:nPlot
    p = patches{ii};
    if isempty(p)
        % create empty planes
        A = zeros(defaultH,defaultW,3);
        B = A; C = A;
    elseif iscell(p) && numel(p)>=3
        A = p{1}; B = p{2}; C = p{3};
    else
        % reuse volumetric projection logic from above to obtain A,B,C
        if ndims(p)==4 && size(p,4)==3
            A = squeeze(max(p,[],3));
            XZ = squeeze(max(p,[],1));
            B = permute(XZ,[2 1 3]);
            YZ = squeeze(max(p,[],2));
            C = permute(YZ,[2 1 3]);
        else
            tmp = squeeze(p);
            if ndims(tmp)==2
                A = repmat(tmp,1,1,3);
                B = A; C = A;
            elseif ndims(tmp)==3 && size(tmp,3)==3
                A = tmp; B = tmp; C = tmp;
            else
                A = zeros(defaultH,defaultW,3);
                B = A; C = A;
            end
        end
    end

    % convert to grayscale intensity for plotting (use luminance)
    toIntensity = @(X) im2double(X(:,:,1))*0.2989 + im2double(X(:,:,2))*0.5870 + im2double(X(:,:,3))*0.1140;

    IA = toIntensity(A); IB = toIntensity(B); IC = toIntensity(C);

    % sizes
    [hA,wA] = size(IA);
    [hB,wB] = size(IB); % B is Z x X
    [hC,wC] = size(IC); % C is Z x Y

    % define coordinates so that planes are centered at origin:
    % XY plane at z=0, spans x in [-wA/2,wA/2], y in [-hA/2,hA/2]
    xA = (-(wA-1)/2:(wA-1)/2);
    yA = (-(hA-1)/2:(hA-1)/2);
    [XA,YA] = meshgrid(xA,yA);
    ZA = zeros(size(XA));

    % XZ plane: rows correspond to Z (hB) and cols to X (wB). Place at y=0, plane normal along +y
    xB = (-(wB-1)/2:(wB-1)/2);
    zB = (-(hB-1)/2:(hB-1)/2);
    [XB,ZB] = meshgrid(xB,zB);
    YB = zeros(size(XB));

    % YZ plane: rows correspond to Z (hC) and cols to Y (wC). Place at x=0, plane normal along +x
    yC = (-(wC-1)/2:(wC-1)/2);
    zC = (-(hC-1)/2:(hC-1)/2);
    [YC, ZC] = meshgrid(yC,zC);
    XC = zeros(size(YC));

    % prepare RGB textures for surface; replicate single-channel into 3 if needed
    makeRGB = @(I) repmat(im2double(I), [1 1 3]);
    texA = makeRGB(IA);
    texB = makeRGB(IB);
    texC = makeRGB(IC);

    subplot(2,5,ii);
    hold on;
    % XY
    s1 = surf(XA, YA, ZA, 'CData', texA, 'FaceColor','texturemap', 'EdgeColor','none');
    % XZ (vertical facing +y)
    s2 = surf(XB, YB + 0, ZB, 'CData', texB, 'FaceColor','texturemap', 'EdgeColor','none');
    % Adjust XZ orientation: currently XB vs ZB; want X horizontal, Z vertical, placed at y=0
    % The surf call above uses XB as X, YB as Y shift, ZB as Z which is correct.

    % YZ (vertical facing +x)
    % For YZ, swap axes: X = XC (zeros), Y = YC, Z = ZC
    s3 = surf(XC + 0, YC, ZC, 'CData', texC, 'FaceColor','texturemap', 'EdgeColor','none');

    % set view and lighting
    axis equal vis3d;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title(sprintf('Entry %d', ii));
    % Place camera so planes are clearly visible
    view(3);
    camproj perspective;
    lighting phong;
    material dull;
    daspect([1 1 1]);
    % add faint axes lines
    plot3([-max([wA,wB,wC])/2, max([wA,wB,wC])/2],[0 0],[0 0],'k-','LineWidth',0.5);
    plot3([0 0],[-max([hA,hB,hC])/2, max([hA,hB,hC])/2],[0 0],'k-','LineWidth',0.5);
    plot3([0 0],[0 0],[-max([hA,hB,hC])/2, max([hA,hB,hC])/2],'k-','LineWidth',0.5);
    hold off;
end

%% 3D PATCH 
% create 3D patches around each shared label, cropped 5 voxels beyond mask bounds
shared = sphereidx; 
ulabels = unique(overlap_labels(:));
ulabels(ulabels==0) = [];

sphere_labels = unique(shared(:));
shared_labels = intersect(ulabels, sphere_labels);
shared_labels = shared_labels(:);

nShared = numel(shared_labels);
zpatches = cell(nShared,1);

% 3D patch half-size beyond mask boundary (5 voxels padding)
pad = 1;

% voxel volume size
[ny,nx,nz] = size(overlap_labels);

for ii = 1:nShared
    lbl = shared_labels(ii);
    if lbl == 0
        zpatches{ii} = [];
        continue;
    end
    % find voxels belonging to this label
    loc = find(overlap_labels == lbl);
    if isempty(loc)
        zpatches{ii} = [];
        continue;
    end
    % convert to subscripts
    [y,x,z] = ind2sub([ny,nx,nz], loc);
    % compute bounding box and add padding
    y1 = max(min(y) - pad, 1);
    y2 = min(max(y) + pad, ny);
    x1 = max(min(x) - pad, 1);
    x2 = min(max(x) + pad, nx);
    z1 = max(min(z) - pad, 1);
    z2 = min(max(z) + pad, nz);
    % sizes
    sy = y2 - y1 + 1;
    sx = x2 - x1 + 1;
    szp = z2 - z1 + 1;
    % prepare patch: sy x sx x szp x 3 (RGB) if zrgb exists, else single-channel replicated
    if exist('zrgb','var') && ndims(zrgb)==4
        % ensure zrgb has same spatial dims and enough z planes
        % zrgb assumed H x W x Z x 3
        z1c = z1; z2c = z2;
        % clamp z indices to available range
        z1c = max(z1c,1); z2c = min(z2c,size(zrgb,3));
        slice = zgrb(y1:y2, x1:x2, z1c:z2c, :); % sy x sx x szp' x 3
        % if requested z-range exceeded zrgb bounds, pad with zeros
        if (z2 - z1 + 1) ~= size(slice,3)
            fullSlice = zeros(sy,sx,szp,3,'like',slice);
            zoff = z1c - z1 + 1;
            fullSlice(:,:,(zoff):(zoff+size(slice,3)-1),:) = slice;
            slice = fullSlice;
        end
        zpatches{ii} = slice;
    else
        % fallback: extract label volume values and replicate to 3 channels
        vol = double(overlap_labels(y1:y2, x1:x2, z1:z2));
        % normalize per-patch to [0,1]
        vmax = max(1, max(vol(:)));
        voln = vol / vmax;
        zpatches{ii} = repmat(voln, [1 1 1 3]);
    end
end
%%

plotv.volshow_rgb_dualAlpha(zpatches{1})
%%

