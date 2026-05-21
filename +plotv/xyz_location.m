function [] = xyz_location(xyp,xyz, ypix_zplane,depth,Fall,zlocs)
arguments
    xyp double % rows contain xy and plane distance from surface based on ref_cell 
    xyz double % each row contains xyz values for each neuron 
    ypix_zplane cell % location of 
    depth % structure output from dep.findRedSurfaceDepth
    Fall struct 
    zlocs double % translates the zplane to depth for plotting the planes correctly 

end

%% NOTES
% change the planes so that they are also warped according to
% depth.surfaceMapSmooth
% - alternatively, make it so that the color code is based on xyz and the
% position is just based on the plane 

%% EDIT VARIABLES 
ref_yx = size(Fall.ops.refImg); 
%zlocs=-zlocs; 
xyz(:,3)= -xyz(:,3); 
xyp(:,3)=-xyp(:,3); 
%% coords for each plane 
for i = 1:length(ypix_zplane)
    curplane = ypix_zplane{i};
    coords = [1 1 (curplane(1)) ; ref_yx(2) 1 (curplane(1)); 1 ref_yx(1) (curplane(end)); ref_yx(2) ref_yx(1) (curplane(end))];
    coords = flip(coords,1);
    adj = zeros(size(depth.surfaceMapSmooth));
    adj_coords = coords; 
    adj_coords(:,3) = -[coords(1,3)+adj(1,1), coords(2,3)+adj(ref_yx(1),1),coords(3,3)+adj(1,ref_yx(2)), coords(4,3)+adj(ref_yx(1),ref_yx(2))]; 
    planecoords{i}=adj_coords; 

end
%%


figure('Name','Cells 3D scatter','Color','w');
hold on 
% Plot the smoothed surface map as a semi-transparent surface
% depth.surfaceMapSmooth contains negative distances from the surface;
% create x and y grids matching ref image dimensions
[YX, XX] = ndgrid(1:ref_yx(1), 1:ref_yx(2)); % YX = rows, XX = cols
surfX = XX;
surfY = YX;
surfZ = depth.surfaceMapSmooth; % already negative distances as specified

% Convert to same coordinate convention as plotting (xyz was negated above)
surfZ = -surfZ; % flip sign so plotted surface aligns with other negated coords
deepest = find(min(surfZ)); 
offset = deepest

hSurf = surf(surfX, surfY, surfZ, 'FaceAlpha', 0.35, 'EdgeColor', 'none', ...
    'FaceColor', [0.8 0.8 0.9]);
hold on
colormap(parula);
% % add a slight lighting effect for depth perception
% light('Position',[1 0 1]);

%%
% color by xyz: map depth (z in xyz) to colormap, keep marker size
zvals = xyz(:,3);
% normalize z to [0,1]
zmin = min(zvals); zmax = max(zvals);
if zmax>zmin
    zn = (zvals - zmin) / (zmax - zmin);
else
    zn = zeros(size(zvals));
end
cmap = parula(256);
ci = max(1, round(zn*(size(cmap,1)-1)) + 1);
colors = cmap(ci, :);

% scatter at plane positions xyp but color by corresponding xyz z-value.
% Assume rows correspond (same ordering) between xyp and xyz.
h = scatter3(xyp(:,1), xyp(:,2), xyp(:,3), 36, colors, 'filled');
% color code by xyz 

%%
% Draw semi-transparent planes for each set of corner coordinates in planecoords
for k = 1:numel(planecoords)
    coords = planecoords{k}; % 4x3 matrix: [x y z] rows are corners
    % Ensure the polygon is closed by repeating first vertex
    verts = coords;
    faces = [1 2 4 3]; % quads formed from the 4 corners
    % Create patch (semi-transparent)
    ppatch = patch('Vertices', verts, 'Faces', faces, ...
        'FaceColor', [0.5 0.5 1], ...     % light bluish color
        'FaceAlpha', 0.25, ...
        'EdgeColor', 'none', ...
        'FaceLighting', 'gouraud', ...
        'AmbientStrength', 0.6);
    hold on
end

%% 
% Add two XY planes (full image size) at z = 0 and z = max plane value
imgH = ref_yx(1); imgW = ref_yx(2);
z0 = 0;
zmax_plane = -max(ypix_zplane{end});

% Create grid corners for the full image in same coordinate convention
planeVerts = [1 1 z0;
              imgW 1 z0;
              imgW imgH z0;
              1 imgH z0];

planeVerts2 = planeVerts;
planeVerts2(:,3) = zmax_plane;

% Draw the planes as semi-transparent patches
faces = [1 2 3 4];

patch('Vertices', planeVerts2, 'Faces', faces, ...
    'FaceColor', [1 0.8 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
patch('Vertices', planeVerts, 'Faces', faces, ...
    'FaceColor', [0.8 1 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none');

%% EDIT FIGURE 
xlabel('X (px)'); ylabel('Y (px)'); zlabel('Z (plane)');
axis vis3d equal;
grid on;
title(sprintf('3D cell positions (%d cells)',size(xyz,1)));



