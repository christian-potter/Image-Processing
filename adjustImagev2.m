function [nfigs] = adjustImagev2(p,stat,crshift,figs,ops,id_vect,ypix_zplane,xyshift,opt)
arguments 
    p double 
    stat cell 
    crshift double 
    figs struct 
    ops struct 
    id_vect double 
    ypix_zplane cell 
    xyshift double 
    opt.type string = 'rgb'
    opt.functional string = 'mean'
    opt.anatomical string = 'mean'
    opt.idx (1,1) double % individual idx if examining an individual neuron 
    opt.zstack double = 0; 
    opt.surround double = 50
    opt.default_plane (1,1) double = 1 % default plane in the z-stack
end 

%% GET VARIABLES
[roi_planeidx,idxshifts,nplanes] = get.roipidx_shift(stat);
[mask_coords]=get.mask_coordinates(stat,'type','outline');
[stackmask_coords]=get.mask_coordinates(stat,'type','mask');
[mask_colors] = get.mask_colors(id_vect); 

%% DETERMINE STARTING PLANE 

if isfield(opt,'idx')
    ypix= stat{opt.idx}.med(2); 
    crshift = get.crshift(ops,p); 
    ypix = ypix-crshift(1); 
    curplane = ypix_zplane{p}; 
    opt.default_plane=curplane(ypix); 
end

%% CREATE VARIABLES
hFigImg= NaN; fFigImg= NaN; aFigImg = NaN; hFigSlider = NaN;
%% GET RED/GREENWIN
[redwin,greenwin]= get.redgreen_images(opt.anatomical,opt.functional,ops,crshift); 
%% DEFINE IMAGE 

if strcmp(opt.type,'rgb')
    image(:,:,1) = redwin; 
    image(:,:,2) = greenwin;
    image(:,:,3) = zeros(size(redwin,1),size(redwin,2)); 
    image = utils.normalize_img(image); 
    redChannel = image(:,:,1); greenChannel = image(:,:,2);
    stack = false; 

elseif strcmp(opt.type,'separate')
    aimage = redwin; fimage = greenwin; 
    aimage = utils.normalize_img(aimage); fimage = utils.normalize_img(fimage); 
    redChannel = aimage; greenChannel = fimage;
    stack = false; 

elseif strcmp(opt.type,'zstack')
    stack = true; 
    image = opt.zstack; 
    [image,x1,y1] = get.roi_surround(image,opt.idx,stat,opt.surround,xyshift);
    %-- normalize image
    for i = 1:size(image,4)
        for j=1:size(image,3)
            image(:,:,j,i) = utils.normalize_img(image(:,:,j,i));
        end
    end
    redChannel = image(:, :, 1,1);greenChannel = image(:, :, 2,1);
end

%% CREATE FIGURES FOR COLOR/ BW IMAGES
% Create a figure for the image display
if strcmp(opt.type,'rgb')
    %Create RGB image 
    hFigImg = figure('Name', 'RGB Image', 'NumberTitle', 'off', 'Position',figs.rgb.Position, 'Color', 'White');
    hAx = axes('Parent', hFigImg, 'Position', [0.01, 0.01, 0.99, 0.99]);
    hImg = imshow(image, 'Parent', hAx); hold on; 
    plot.mask_boundaries(mask_colors,mask_coords(roi_planeidx==p),crshift,idxshifts(p),'masktype','outline');
  

elseif strcmp(opt.type,'zstack')
    %Create RGB image 
    hFigImg = figure('Name', 'RGB Image', 'NumberTitle', 'off', 'Position',figs.zstack.Position, 'Color', 'White');
    hAx = axes('Parent', hFigImg, 'Position', [0.01, 0.01, 0.99, 0.99]);
    hImg = imshow(image(:,:,:,1), 'Parent', hAx); hold on; 
    plot.mask_boundaries(mask_colors(:,1),stackmask_coords(opt.idx),[x1-xyshift(1) y1-xyshift(2)],opt.idx,"idxtype",'specified','masktype','mask');

end

% CODE FOR SEPARATE IMAGES 
% elseif strcmp(opt.type,'separate')
%     %Create functional channel image 
%     fFigImg = figure('Name', 'Functional Image', 'NumberTitle', 'off', 'Position',figs.functional.Position, 'Color', 'White');
%     fAx = axes('Parent', fFigImg, 'Position', [0.01, 0.01, 0.99, 0.99]);
%     fImg = imshow(fimage, 'Parent', fAx);
%     hold on 
%     plot.mask_boundaries(mask_colors,mask_coords(roi_planeidx==p),crshift,idxshifts(p));
% 
%     % Create anatomical channel image 
%     aFigImg = figure('Name', 'Anatomical Image', 'NumberTitle', 'off', 'Position',figs.anatomical.Position, 'Color', 'White');
%     aAx = axes('Parent', aFigImg, 'Position', [0.01, 0.01, 0.99, 0.99]);
%     aImg = imshow(aimage, 'Parent', aAx);
%     hold on 
%     plot.mask_boundaries(mask_colors,mask_coords(roi_planeidx==p),crshift,idxshifts(p));
% end

%% CREATE SLIDER FIGURE WITH HISTOGRAMS
% Create a second figure for the sliders and histogram
if stack
    hFigSlider = figure('Name', 'Adjustments & Histogram', 'NumberTitle', 'off', ...
        'Position',figs.zslider.Position, 'Color', 'White');
else
    hFigSlider = figure('Name', 'Adjustments & Histogram', 'NumberTitle', 'off', ...
        'Position',figs.slider.Position, 'Color', 'White');

end


% Set default values for sliders
low_in_red = 0;
high_in_red = 1;
gamma_red = 1;

low_in_green = 0;
high_in_green = 1;
gamma_green = 1;
img_num = 1; 

% Create sliders and labels for the Red channel (left side)
uicontrol('Style', 'text', 'String', 'Red Channel - Low Thresh:', 'Position', [50, 180, 150, 20], 'Parent', hFigSlider);
hLowInRed = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', low_in_red, ...
    'Position', [50, 165, 400, 20], 'Parent', hFigSlider, 'Callback', @updateImage);

uicontrol('Style', 'text', 'String', 'Red Channel - High Thresh:', 'Position', [50, 140, 150, 20], 'Parent', hFigSlider);
hHighInRed = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', high_in_red, ...
    'Position', [50, 125, 400, 20], 'Parent', hFigSlider, 'Callback', @updateImage);

uicontrol('Style', 'text', 'String', 'Red Channel - Gamma:', 'Position', [50, 100, 150, 20], 'Parent', hFigSlider);
hGammaRed = uicontrol('Style', 'slider', 'Min', 0.1, 'Max', 2, 'Value', gamma_red, ...
    'Position', [50, 85, 400, 20], 'Parent', hFigSlider, 'Callback', @updateImage);

% Create sliders and labels for the Green channel (right side)
uicontrol('Style', 'text', 'String', 'Green Channel - Low Thresh:', 'Position', [550, 180, 150, 20], 'Parent', hFigSlider);
hLowInGreen = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', low_in_green, ...
    'Position', [550, 165, 400, 20], 'Parent', hFigSlider, 'Callback', @updateImage);

uicontrol('Style', 'text', 'String', 'Green Channel - High Thresh:', 'Position', [550, 140, 150, 20], 'Parent', hFigSlider);
hHighInGreen = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', high_in_green, ...
    'Position', [550, 125, 400, 20], 'Parent', hFigSlider, 'Callback', @updateImage);

uicontrol('Style', 'text', 'String', 'Green Channel - Gamma:', 'Position', [550, 100, 150, 20], 'Parent', hFigSlider);
hGammaGreen = uicontrol('Style', 'slider', 'Min', 0.1, 'Max', 2, 'Value', gamma_green, ...
    'Position', [550, 85, 400, 20], 'Parent', hFigSlider, 'Callback', @updateImage);

% Z-Stack Slider 
if stack
    uicontrol('Style', 'text', 'String', ['Z-Stack Plane ','(est=',num2str(opt.default_plane),'):'], 'Position', [140, 60, 125, 20], 'Parent', hFigSlider);
    img_slidern = uicontrol('Style', 'slider', 'Min', 1, 'Max', size(image, 4), 'Value', opt.default_plane, ...
        'Position', [140, 40, 40, 20], 'Parent', hFigSlider, 'Callback', @updateImage);
    plane_text = uicontrol('Style', 'text', 'String', num2str(opt.default_plane), ...
        'Position', [190, 40, 20, 20], 'Parent', hFigSlider);
end


% Position hXshift and hYshift sliders beneath hGammaGreen
if stack 
    uicontrol('Style', 'text', 'String', ['X Shift: (est=',num2str(xyshift(1)),')'], 'Position', [50, 70, 75, 20], 'Parent', hFigSlider);
    xshift_text =uicontrol('Style', 'text', 'String',[num2str(xyshift(1))] , 'Position', [50, 50, 20, 20], 'Parent', hFigSlider,'Callback', @updateImage);
    hXShift = uicontrol('Style', 'slider', 'Min', -50, 'Max', 50, 'Value', xyshift(1), ...
        'Position', [70, 50, 50, 20], 'Parent', hFigSlider, 'Callback', @updateImage);

    uicontrol('Style', 'text', 'String', ['Y Shift: (est=',num2str(xyshift(2)),')'], 'Position', [50, 10, 75, 20], 'Parent', hFigSlider);
    yshift_text =uicontrol('Style', 'text', 'String', [num2str(xyshift(2))], 'Position', [50, 30, 20, 20], 'Parent', hFigSlider,'Callback', @updateImage);
    hYShift = uicontrol('Style', 'slider', 'Min', -50, 'Max', 50, 'Value', xyshift(2), ...
        'Position', [70, 30, 50, 20], 'Parent', hFigSlider, 'Callback', @updateImage);
end


% Create an axes for displaying the histogram
hHistAx = axes('Parent', hFigSlider, 'Position', [0.1, 0.5, 0.8, 0.4]);

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
        % Get current slider values for both Red and Green channels
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

        % Ensure that low_in is not greater than high_in for both channels
        if low_in_red >= high_in_red
            low_in_red = high_in_red - 0.01;
        end

        if low_in_green >= high_in_green
            low_in_green = high_in_green - 0.01;
        end

        % Adjust the image based on slider values to RGB image 
        if strcmp(opt.type,'rgb') || strcmp(opt.type,'zstack') % why is this an OR statement? 
            if stack 
               
                xyshift_x = get(hXShift, 'Value');
                xyshift_y = get(hYShift, 'Value');
                set(xshift_text, 'String', [num2str(xyshift_x)]);
                set(yshift_text, 'String', [num2str(xyshift_y)]);
                image = opt.zstack; 
                [crimage, x1, y1] = get.roi_surround(image, opt.idx, stat, opt.surround, [xyshift_x, xyshift_y]);
               
                adj_img = cat(3, ...
                    imadjust(crimage(:, :, 1,img_num), [low_in_red, high_in_red], [], gamma_red), ...
                    imadjust(crimage(:, :, 2,img_num), [low_in_green, high_in_green], [], gamma_green), ...
                    crimage(:, :, 3,img_num));  % Blue channel is left unchanged
                
                % Update the displayed image
                set(hImg, 'CData', adj_img);
                red = image(:,:,1,img_num); green = image(:,:,2,img_num); 
                red(red==0)=[]; green(green==0)=[]; 
                redc=histcounts(red,256); greenc=histcounts(green,256); 
                maxred =max(redc(:)); maxgreen=max(greenc(:)); 
                m= max([maxred,maxgreen]); 
                set(h1,'Data',red(:))
                set(h2,'Data',green(:))
                set(hHistAx,'YLim',[0 m])

            else
                adj_img = cat(3, ...
                    imadjust(image(:, :, 1), [low_in_red, high_in_red], [], gamma_red), ...
                    imadjust(image(:, :, 2), [low_in_green, high_in_green], [], gamma_green), ...
                    image(:, :, 3));  % Blue channel is left unchanged
                % Update the displayed image
                set(hImg, 'CData', adj_img);
                red = image(:,:,1,img_num); green = image(:,:,2,img_num); 
                red(red==0)=[]; green(green==0)=[]; 
                redc=histcounts(red,256); greenc=histcounts(green,256); 
                maxred =max(redc(:)); maxgreen=max(greenc(:)); 
                m= max([maxred,maxgreen]); 
            end


        elseif strcmp(opt.type,'separate')
            adj_fimg = imadjust(fimage,[low_in_green, high_in_green], [], gamma_green); 
            adj_aimg = imadjust(aimage,[low_in_red, high_in_red], [], gamma_red); 
            set(fImg,'CData',adj_fimg)
            set(aImg,'CData',adj_aimg)
            red = adj_aimg; green= adj_fimg; 
            red(red==0)=[]; green(green==0)=[]; 
            redc=histcounts(red,256); greenc=histcounts(green,256); 
            maxred =max(redc(:)); maxgreen=max(greenc(:)); 
            m= max([maxred,maxgreen]); 
        end
        

 % Update the intensity lines in the histogram
        set(hLowRedLine, 'XData', [low_in_red, low_in_red],'YData',[0 m]);
        set(hHighRedLine, 'XData', [high_in_red, high_in_red],'YData',[0 m]);
        set(hLowGreenLine, 'XData', [low_in_green, low_in_green],'YData',[0 m]);
        set(hHighGreenLine, 'XData', [high_in_green, high_in_green],'YData',[0 m]);

        % Update the Gamma Line Values
        rGammaX = low_in_red:.0001:high_in_red; 
        rGammaY= imadjust(rGammaX,[],[],gamma_red);
        gGammaX = low_in_green:.0001:high_in_green; 
        gGammaY= imadjust(gGammaX,[],[],gamma_green);

        % Set Gamma Lines 
        set(GammaRedLine,'XData',rGammaX,'YData',rGammaY*m)
        set(GammaGreenLine,'XData',gGammaX,'YData',gGammaY*m)
    end
%% plotHistogram FUNCTION
    % Function to plot the histogram
    function [h1, h2] = plotHistogram()          
            % Plot the histogram of both channels
            h1= histogram(hHistAx, redChannel(:), 256, 'FaceColor', 'r', 'EdgeColor', 'k', 'FaceAlpha', 0.5);
            hold(hHistAx, 'on');
            h2= histogram(hHistAx, greenChannel(:), 256, 'FaceColor', 'g', 'EdgeColor', 'k', 'FaceAlpha', 0.5);
  
            title(hHistAx, 'Histogram of Red and Green Channels');
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

%% SAVE POSITIONS 
if strcmp(opt.type,'rgb')
    nfigs.rgb = hFigImg; 
    nfigs.slider = hFigSlider; 
elseif strcmp(opt.type,'zstack')
    nfigs.zstack = hFigImg; 
    nfigs.zslider=hFigSlider;
end

end

%%



