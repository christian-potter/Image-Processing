
% create a sphere
[xs,ys,zs] = sphere(100); % 101x101 grid
r = 1;
xs = xs*r; ys = ys*r; zs = zs*r;

figure
surf(xs,ys,zs,'FaceAlpha',0.5,'EdgeColor','none','FaceColor',[0.6 0.8 1])
hold on
axis equal
colormap(parula)

% define plane size (extent)
lim = 1.2;
[X,Y] = meshgrid(linspace(-lim,lim,2), linspace(-lim,lim,2));

% XY plane (Z=0)
Zxy = zeros(size(X));
surf(X,Y,Zxy,'FaceAlpha',0.4,'FaceColor',[1 0.8 0.8],'EdgeColor','none')

% YZ plane (X=0)
Xyz = zeros(size(X));
surf(Xyz,Y,X,'FaceAlpha',0.4,'FaceColor',[0.8 1 0.8],'EdgeColor','none') % reuse X for Z grid

% XZ plane (Y=0)
% create grid for X and Z (reuse X for X grid and Y for Z grid)
Xxz = X;           % X grid as before
Zxz = Y;           % use Y grid values for Z coordinates
Yxz = zeros(size(X)); % Y = 0 plane
surf(Xxz,Yxz,Zxz,'FaceAlpha',0.4,'FaceColor',[0.8 0.8 1],'EdgeColor','none')
% draw axes through origin
quiver3(0,0,0,1.1,0,0,'k','LineWidth',3,'MaxHeadSize',0.2)
quiver3(0,0,0,0,1.1,0,'k','LineWidth',3,'MaxHeadSize',0.2)
quiver3(0,0,0,0,0,1.1,'k','LineWidth',3,'MaxHeadSize',0.2)
text(1.3,0,0,'X','FontSize',24)
text(0,1.3,0,'Y','FontSize',24)
text(0,0,1.3,'Z','FontSize',24)

% formatting
xlabel('X'), ylabel('Y'), zlabel('Z')
title('Sphere with intersecting XY, YZ and XZ planes at the origin')
lightangle(-45,30)
lighting gouraud
view(45,25)
% remove axes, grid, ticks and tick labels
axis off
grid off
set(gca, 'XTick', [], 'YTick', [], 'ZTick', [], 'XTickLabel', {}, 'YTickLabel', {}, 'ZTickLabel', {})
hold off
utils.sf

%%

% define plane size (extent)
lim = 1.2;
[X,Y] = meshgrid(linspace(-lim,lim,2), linspace(-lim,lim,2));

% displacement: scalar multiple of [1 1 0]
base_disp_scalar = 1.5; % base displacement magnitude
base_disp = base_disp_scalar * [1 1 0];

% give each plane a different additional offset so they do not touch
offsets = [0.0,  0.2, -0.2]; % original small offsets
offsets = offsets * 10; % increase the offset by a factor of 10 as requested

% XY plane (originally Z=0) -> shift by base_disp + offsets(1) along X and Y, and by positive Z shift
d_xy = base_disp + offsets(1)*[1 1 0] + [0 0 1.2]; % include a Z shift so plane is separated
Xxy = X + d_xy(1);
Yxy = Y + d_xy(2);
Zxy = zeros(size(X)) + d_xy(3);

% YZ plane (originally X=0) -> shift by base_disp + offsets(2) along X and Y, and by negative Z shift
d_yz = base_disp + offsets(2)*[1 1 0] + [0 0 -1.2];
Xyz = zeros(size(X)) + d_yz(1);
Yyz = Y + d_yz(2);
Zyz = X + d_yz(3); % reuse X grid for Z coordinates

% XZ plane (originally Y=0) -> shift by base_disp + offsets(3) along X and Y, and by different Z shift
d_xz = base_disp + offsets(3)*[1 1 0] + [0 0 0]; % center Z near 0 but X/Y displaced sufficiently
Xxz = X + d_xz(1);
Yxz = zeros(size(X)) + d_xz(2);
Zxz = Y + d_xz(3);

figure
hold on
axis equal
colormap(parula)

% plot the three displaced planes with transparency and distinct colors
surf(Xxy,Yxy,Zxy,'FaceAlpha',0.6,'EdgeColor','none','FaceColor',[1 0.8 0.8])
surf(Xyz,Yyz,Zyz,'FaceAlpha',0.6,'EdgeColor','none','FaceColor',[0.8 1 0.8])
surf(Xxz,Yxz,Zxz,'FaceAlpha',0.6,'EdgeColor','none','FaceColor',[0.8 0.8 1])

% formatting
xlabel('X'), ylabel('Y'), zlabel('Z')
title('Three displaced planes with distinct origins (do not touch)')
lightangle(-45,30)
lighting gouraud
view(45,25)

% remove axes, ticks and middle axis arrows as requested
axis off
set(gca, 'XTick', [], 'YTick', [], 'ZTick', [])
hold off
utils.sf