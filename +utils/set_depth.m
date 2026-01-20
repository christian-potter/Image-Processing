function [] = set_depth(figs,slider,ypix_zplane,opt)
arguments
    figs struct 
    slider struct % contains current slider values for reference z-stack 
    ypix_zplane cell 
    opt.zstack double % needs to be specified w/ name-value argument pair. legacy code shortcut 
    opt.type string = 'zstack' % used this for convenience with copying old code 
    opt.colororder string
end


%% DESCRIPTION 
% clone of adjustImageV2 with unneccessary components removed for setting
% depth 
% ** used to validate automatic depth processing** 

%% CREATE VARIABLES
%hFigImg= NaN; hFigSlider = NaN;
xyshift_x = 0; xyshift_y = 0; % legacy code to ignore 
opt.default_plane = 1 ; 

%% DEFINE IMAGE (opt.type == zstack)
stack = true; 
image = opt.zstack; 
%nzstack_drift = [0 0]; 
for i = 1:size(image,4)
   image(:,:,:,i) = utils.normalize_img(image(:,:,:,i));        
end
if strcmp(opt.colororder,'grb') % do nothing if rgb
    image(:,:,[1 2],:)=image(:,:,[2 1],:);
end
opt.zstack = image; % normalize zstack now before cropping 
redChannel = image(:, :, 1,opt.default_plane);greenChannel = image(:,:,2,opt.default_plane);    
cur_ypixz = [ypix_zplane{1},ypix_zplane{2}];% should only need first and second plane  

%% CREATE FIGURE FOR IMAGE 
DepthImg = figure('Name', 'Depth Finder', 'NumberTitle', 'off', 'Position',figs.zstack.Position, 'Color', 'White');
hAx = axes('Parent', DepthImg, 'Position', [0.01, 0.01, 0.99, 0.99]);
hImg = imshow(image(:,:,:,opt.default_plane), 'Parent', hAx); hold on;

arrow = annotation('arrow','Color','r','LineWidth',.25); 
arrow.Parent = gca; 
arrow.X= ([1 size(image,2)]);arrow.Y=([0 0]);
t = title(['Plane: ',num2str(opt.default_plane)],'FontSize',25); 


%-- ADD REFERENCE BANDS
ny = 10; nx = 10; % divide up X and Y into N segments 
ref_ys  = size(image,1)/ny : size(image,1)/ny : size(image,1)-1; 
ref_xs = size(image,2)/nx : size(image,2)/nx : size(image,2)-1;
yline(ref_ys,'color','c')
xline(ref_xs,'color','m') 

for ii =1:length(ref_ys)
    text(10,ref_ys(ii)-5,num2str(ny-ii),'Color','c','FontSize',15)
end

for ii = 1:length(ref_xs)
    text(ref_xs(ii)+1,10,num2str(ii),'Color','m','FontSize',15)
end


%% CREATE SLIDER FIGURE WITH HISTOGRAMS
% Create a second figure for the sliders and histogram

DepthSlider = figure('Name', 'Z-Stack Control', 'NumberTitle', 'off', ...
    'Position',figs.zslider.Position, 'Color', 'White');

% Set default values for sliders
low_in_red = slider.lowred; 
high_in_red = slider.highred; 
gamma_red = slider.gammared; 

low_in_green = slider.lowgreen;
high_in_green = slider.highgreen; 
gamma_green = slider.gammagreen; 
img_num = opt.default_plane; 

%-------- Create sliders and labels for the Red channel (left side)
uicontrol('Style', 'text', 'String', 'Red- Low Thresh:', 'Units', 'normalized', 'Position', [0.05, 0.4, 0.2, 0.05], 'Parent', DepthSlider);
hLowInRed = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', low_in_red, 'Units', 'normalized', 'Position', [0.05, 0.35, 0.3, 0.05], 'Parent', DepthSlider, 'Callback', @updateImage);
uicontrol('Style', 'text', 'String', 'Red- High Thresh:', 'Units', 'normalized', 'Position', [0.05, 0.3, 0.2, 0.05], 'Parent', DepthSlider);
hHighInRed = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', high_in_red, 'Units', 'normalized', 'Position', [0.05, 0.25, 0.3, 0.05], 'Parent', DepthSlider, 'Callback', @updateImage);
uicontrol('Style', 'text', 'String', 'Red- Gamma:', 'Units', 'normalized', 'Position', [0.05, 0.2, 0.2, 0.05], 'Parent', DepthSlider);
hGammaRed = uicontrol('Style', 'slider', 'Min', 0.1, 'Max', 2, 'Value', gamma_red, 'Units', 'normalized', 'Position', [0.05, 0.15, 0.3, 0.05], 'Parent', DepthSlider, 'Callback', @updateImage);
%---------- Create sliders and labels for the Green channel (right side)
uicontrol('Style', 'text', 'String', 'Green- Low Thresh:', 'Units', 'normalized', 'Position', [0.4, 0.4, 0.2, 0.05], 'Parent', DepthSlider);
hLowInGreen = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', low_in_green, 'Units', 'normalized', 'Position', [0.4, 0.35, 0.3, 0.05], 'Parent', DepthSlider, 'Callback', @updateImage);
uicontrol('Style', 'text', 'String', 'Green- High Thresh:', 'Units', 'normalized', 'Position', [0.4, 0.3, 0.2, 0.05], 'Parent', DepthSlider);
hHighInGreen = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', high_in_green, 'Units', 'normalized', 'Position', [0.4, 0.25, 0.3, 0.05], 'Parent', DepthSlider, 'Callback', @updateImage);
uicontrol('Style', 'text', 'String', 'Green- Gamma:', 'Units', 'normalized', 'Position', [0.4, 0.2, 0.2, 0.05], 'Parent', DepthSlider);
hGammaGreen = uicontrol('Style', 'slider', 'Min', 0.1, 'Max', 2, 'Value', gamma_green, 'Units', 'normalized', 'Position', [0.4, 0.15, 0.3, 0.05], 'Parent', DepthSlider, 'Callback', @updateImage);

%----------- Create Z-Stack Plane Selection Slider 
%(X and Y sliders removed) 
if stack
    uicontrol('Style', 'text', 'String', ['Z-Stack Plane ','(est=',num2str(opt.default_plane),'):'], 'Units', 'normalized', 'Position', [0.2, 0.07, 0.15, 0.05],'Parent', DepthSlider);
    img_slidern = uicontrol('Style', 'slider', 'Min', 1, 'Max', size(image, 4), 'SliderStep', [1/(size(image, 4)-1), 1/(size(image, 4)-1)], 'Value', opt.default_plane, 'Units', 'normalized', 'Position', [0.25, 0.03, 0.05, 0.05], 'Parent', DepthSlider, 'Callback', @updateImage);
    plane_text = uicontrol('Style', 'text', 'String', num2str(opt.default_plane), 'Units', 'normalized', 'Position', [0.2, 0.03, 0.05, 0.03], 'Parent', DepthSlider);
end


% Create an axes for displaying the histogram
hHistAx = axes('Parent', DepthSlider, 'Position', [0.1, 0.5, 0.8, 0.4]);


%% GET SUPPLEMENTAL INFORMATION / MAKE LINES FOR HISTOGRAM 
% Get the maximum height of the histogram    
[hc1,~]= histcounts(redChannel(:), 256);
[hc2,~]= histcounts(greenChannel(:), 256);
h1max = max(hc1); h2max = max(hc2);
maxheight=max([h1max,h2max]);

%Initialize the heights of the lines / gamma line
%maxheight= 1;
rGammaX = low_in_red:.01:high_in_red; 
rGammaY= imadjust(rGammaX,[],[],gamma_red);
gGammaX = low_in_green:.01:high_in_green; 
gGammaY= imadjust(gGammaX,[],[],gamma_green);


% Initialize line objects for intensity markers after the histogram is plotted
hLowRedLine = line([low_in_red, low_in_red-.02], [0, maxheight], 'Color', [.5 0 0], 'Parent', hHistAx);
hold(hHistAx, 'on');
hHighRedLine = line([high_in_red, high_in_red-.02], [0, maxheight], 'Color', [.5 0 0], 'Parent', hHistAx);
hLowGreenLine = line([low_in_green, low_in_green], [0, maxheight], 'Color', [0 .5 0], 'Parent', hHistAx);
hHighGreenLine = line([high_in_green, high_in_green], [0, maxheight], 'Color', [0 .5 0], 'Parent', hHistAx);

GammaRedLine = line(rGammaX,rGammaY,'color',[.5 0 0],'Parent',hHistAx); 
GammaGreenLine= line(gGammaX,gGammaY,'color',[0 .5 0],'Parent',hHistAx); 

% Plot the initial histogram based on the input image
[h1,h2]=plotHistogram();
%% updateImage FUNCTION
    % Callback function to update the image and histogram based on slider values
    function updateImage(~, ~)
        % ---- GET SLIDER VALUES
        low_in_red = get(hLowInRed, 'Value');
        high_in_red = get(hHighInRed, 'Value');
        gamma_red = get(hGammaRed, 'Value');
        low_in_green = get(hLowInGreen, 'Value');
        high_in_green = get(hHighInGreen, 'Value');
        gamma_green = get(hGammaGreen, 'Value');
        if stack 
            img_num = round(get(img_slidern,'Value')); 
            set(plane_text, 'String', [num2str(img_num)]); 
        end
        % ENFORCE LOW_IN < HIGH_IN
        if low_in_red >= high_in_red
            low_in_red = high_in_red - 0.01;
        end
        if low_in_green >= high_in_green
            low_in_green = high_in_green - 0.01;
        end

        % ADJUST IMAGE BASED ON SLIDER VALS     

        % --- GET Z-STACK SLIDER VALS 

        image = opt.zstack(:,:,:,img_num); 
        crimage = image;

        % --- MAKE NEW IMAGE
        adj_img = cat(3, ...
            imadjust(crimage(:,:,1), [low_in_red, high_in_red], [], gamma_red), ...
            imadjust(crimage(:,:,2), [low_in_green, high_in_green], [], gamma_green), ...
            crimage(:, :, 3));  % Blue channel is left unchanged
        set(hImg, 'CData', adj_img);
      
        %--- ARROW POSITION
        narrowy= mean(find(cur_ypixz==img_num)); 
        if img_num<min(cur_ypixz)
            set(arrow,'Y',[1 1])
        elseif img_num>max(cur_ypixz)
            set(arrow,'Y',[size(image,2)-1,size(image,2)-1])
        else
            set(arrow,'Y',[narrowy narrowy])         
        end
        %--- HISTOGRAM       
        red = image(:,:,1); green = image(:,:,2); 
        red(red==0)=[]; green(green==0)=[]; 
        redc=histcounts(red,256); greenc=histcounts(green,256); 
        maxred =max(redc(:)); maxgreen=max(greenc(:)); 
        m= max([maxred,maxgreen]); 
        set(h1,'Data',red(:))
        set(h2,'Data',green(:))
        set(hHistAx,'YLim',[0 m])
        t.String = ['Plane: ',num2str(img_num)]; 

        %----- HISTOGRAM
        % Update the intensity lines in the histogram
        set(hLowRedLine, 'XData', [low_in_red, low_in_red],'YData',[0 m]);
        set(hHighRedLine, 'XData', [high_in_red, high_in_red],'YData',[0 m]);
        set(hLowGreenLine, 'XData', [low_in_green, low_in_green],'YData',[0 m]);
        set(hHighGreenLine, 'XData', [high_in_green, high_in_green],'YData',[0 m]);

        % Update the Gamma Line Values
        rGammaX = low_in_red:.0001:high_in_red; 
        rGammaY= imadjust(rGammaX,[low_in_red high_in_red],[],gamma_red);
        gGammaX = low_in_green:.0001:high_in_green; 
        gGammaY= imadjust(gGammaX,[low_in_green high_in_green],[],gamma_green);

        % Set Gamma Lines 
        set(GammaRedLine,'XData',rGammaX,'YData',rGammaY*m)
        set(GammaGreenLine,'XData',gGammaX,'YData',gGammaY*m)
    end
%% plotHistogram FUNCTION 
    function [h1, h2] = plotHistogram()          
            % Plot the histogram of both channels
            h1= histogram(hHistAx, redChannel(:), 256, 'FaceColor', 'r', 'EdgeColor', 'k', 'FaceAlpha', 0.5);
            hold(hHistAx, 'on');
            h2= histogram(hHistAx, greenChannel(:), 256, 'FaceColor', 'g', 'EdgeColor', 'k', 'FaceAlpha', 0.5);
  
            title(hHistAx, 'Histogram of Red and Green Channels','FontSize',25);
            xlabel(hHistAx, 'Intensity');
            ylabel(hHistAx, 'Pixel Count');
       
            % Update the intensity lines in the histogram
            set(hLowRedLine, 'XData', [low_in_red, low_in_red],'YData',[0 maxheight]);
            set(hHighRedLine, 'XData', [high_in_red, high_in_red],'YData',[0 maxheight]);
            set(hLowGreenLine, 'XData', [low_in_green, low_in_green],'YData',[0 maxheight]);
            set(hHighGreenLine, 'XData', [high_in_green, high_in_green],'YData',[0 maxheight]);
            
            % Set Gamma Lines 
            set(GammaRedLine,'XData',rGammaX,'YData',rGammaY*maxheight)
            set(GammaGreenLine,'XData',gGammaX,'YData',gGammaY*maxheight)
    end

end 
%%

