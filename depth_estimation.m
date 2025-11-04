%% DEPTH ESTIMATION 
%%
stack_size = 50; 
dorsal_stack = squeeze(mean(zs(:,:,[1 2],1:stack_size),[3 4])); 
%%
figure
bar3(dorsal_stack)
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');

%%
figure
utils.sf

subplot(2,1,2)
hold on 
y = mean(dorsal_stack,2); 
% Fit a second order polynomial to y
p_y = polyfit((1:length(y))', y, 2); % Fit a second order polynomial
y_fit = polyval(p_y, (1:length(y))'); % Evaluate the polynomial at the original x values
plot(y)
plot(y_fit)
xlabel('Y Coordinate')
ylabel('Pixel Intensity')
title('Second Order Polynomial Fit to Gradient in Y Dimension')
legend({'Data','Fit'})

subplot(2,1,1)
hold on 
x = mean(dorsal_stack,1); 
p_x = polyfit((1:length(x))', x, 1); % Fit a second order polynomial to x
x_fit = polyval(p_x, (1:length(x))'); % Evaluate the polynomial at the original x values
plot(x)
plot(x_fit)
xlabel('X Coordinate')
title('First Order Polynomial Fit to Gradient in X Dimension')
ylabel('Pixel Intensity')
legend({'Data','Fit'})
sgtitle('Red And Green Averaged Together')
%% 

rel_surface = [find(x_fit==max(x_fit)) find(y_fit==max(y_fit))]; 
abs_surface = 1; % first plane where spinal cord is visible ( selected by user)


%% CONVERT REFERENCE BANDS INTO NEW COORDINATES 

rb.x(:,1) = ref_bands.x; 
rb.x(:,2)= ref_xs; 
rb.y(:,1)= ref_bands.y; 
rb.y(:,2)= ref_ys; 

%%

[X,Y] = meshgrid(1:length(x),1:length(y)); 

Z = zeros(size(X)); 

for i = 1:size(Z,1)
    for j = 1:size(Z,2)
        Z(i,j)= x_fit(j)+ y_fit(i); 
    end
end


%%
% Plotting the surface
figure;

s = surf(X, Y, Z); % Create a surface plot
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('Estimate of Spinal Cord Curvature');
view(3); % Set the view to 3D
s.EdgeColor='none'; 

utils.sf
% PLOT CONTOURS 
hold on 
plot3(X(:,1),Y(:,1),Z(:,1),'color','k','LineWidth',3)
plot3(X(:,end),Y(:,end),Z(:,end),'color','k','LineWidth',3)
plot3(X(1,:),Y(1,:),Z(1,:),'color','k','LineWidth',3)
plot3(X(end,:),Y(end,:),Z(end,:),'color','k','LineWidth',3)
%vertical lines 
plot3([X(1,1) X(1,1)],[Y(1,1) Y(1,1)],[Z(1,1) 0],'k','LineStyle','--','LineWidth',2)
plot3([X(1,end) X(1,end)],[Y(1,end) Y(1,end)],[Z(1,end) 0],'k','LineStyle','--','LineWidth',2)
plot3([X(end,1) X(end,1)],[Y(end,1) Y(end,1)],[Z(end,1) 0],'k','LineStyle','--','LineWidth',2)
plot3([X(end,end) X(end,end)],[Y(end,end) Y(end,end)],[Z(end,end) 0],'k','LineStyle','--','LineWidth',2)
% 
plot3(X(:,1),Y(:,1),Z(:,1)*0,'color','k','LineWidth',3)
plot3(X(:,end),Y(:,end),Z(:,end)*0,'color','k','LineWidth',3)
plot3(X(1,:),Y(1,:),Z(1,:)*0,'color','k','LineWidth',3)
plot3(X(end,:),Y(end,:),Z(end,:)*0,'color','k','LineWidth',3)

%- 
colorbar

%%

%axis tight % Adjusts axis limits to the data range.
%axis vis3d % Freezes the aspect ratio to prevent distortion.
axis equal
% 2. Get the current axis handle.
ax = gca;

% 3. Loop through a sequence of azimuth angles to create a rotation animation.
azimuths = 0:1:360; % Define a range of azimuth angles (0 to 360 in 5-degree steps).
for az = azimuths
    % Change the camera view.
    % The elevation (vertical angle) is kept constant at 30 degrees.
    view(ax, az, 20);
    
    % Force MATLAB to update the plot window.
    drawnow;
    
    % Optional: Add a short pause for a smoother animation.
    % pause(0.01);
end
%%
% Display the current view angle on the figure
view_angle = view(ax); % Get the current view angle
text('String', sprintf('Azimuth: %.1f, Elevation: %.1f', view_angle(1), view_angle(2)), ...
    'Position', [0.5, 0.5, max(Z(:))], 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', 'k', 'FontWeight', 'bold');
%%

