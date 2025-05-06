function [nfigs,nadjusted_xyz] = adjustImagev2(p,stat,plane_crshift,figs,ops,id_vect,ypix_zplane,opt)
arguments 
    p double 
    stat cell 
    plane_crshift double 
    figs struct 
    ops struct 
    id_vect double 
    ypix_zplane cell % mapping between y pixel value and the z-stack plane it should be on 
    opt.adjusted_xyz double 
    opt.zstack_drift double % option to specify the amount of drift between functional and z-stack  
    opt.type string = 'functional'% can be functional or zstack  
    opt.functional string = 'mean'
    opt.anatomical string = 'mean'
    opt.idx (1,1) double % individual idx if examining an individual neuron 
    opt.zstack double = 0
    opt.surround double = 100
    opt.refsurround double = 100
    opt.default_plane (1,1) double = 1 % default plane in the z-stack
    opt.colororder string = 'rgb'
end 
%% DESCRIPTION
% options:
% opt.type = 'functional'/'zstack' => 
% opt.idx = '
%% NOTES
%* eventually need to remove 
%% GET VARIABLES
[roi_planeidx,idxshifts,~] = get.roipidx_shift(stat);
[mask_coords]=get.mask_coordinates(stat,'type','outline'); % functional coords 
[stackmask_coords]=get.mask_coordinates(stat,'type','outline');% zstack coords
[mask_colors] = get.mask_colors(id_vect); 

if isfield(opt,'adjusted_xyz')
    xyshift_x=opt.adjusted_xyz(1);xyshift_y=opt.adjusted_xyz(2);
end

%% DETERMINE STARTING Z-PLANE 

if isfield(opt,'idx')&&isfield(opt,'adjusted_xyz')
    ypix= stat{opt.idx}.med(1); %first is weirdly Y
    %ypix = ypix-crshift(1); 
    curplane = ypix_zplane{p}; 
    opt.default_plane=curplane(ypix)+opt.adjusted_xyz(3); 
elseif isfield(opt,'adjusted_xyz')
    opt.idx = 1:length(stat); 
    count =1; iplane =-1; 
    while iplane~=p
        iplane=stat{count}.iplane+1; 
        count =count+1; 
    end
    ypix = stat{count}.med(1); % first ROI in plane 
    curplane = ypix_zplane{p} +opt.adjusted_xyz(3); 
    opt.default_plane=curplane(ypix-plane_crshift(2))+opt.adjusted_xyz(3); 
end

%% CREATE VARIABLES
hFigImg= NaN; fFigImg= NaN; aFigImg = NaN; hFigSlider = NaN;
%% GET RED/GREENWIN
[redwin,greenwin]= get.redgreen_images(opt.anatomical,opt.functional,ops,plane_crshift); 
%% DEFINE IMAGE 
if strcmp(opt.type,'functional')
    image(:,:,1) = redwin; 
    image(:,:,2) = greenwin;
    image(:,:,3) = zeros(size(redwin,1),size(redwin,2)); 
    image = utils.normalize_img(image); 
    redChannel = image(:,:,1); greenChannel = image(:,:,2);
    stack = false; 

elseif strcmp(opt.type,'zstack')
    stack = true; 
    image = opt.zstack; 
    nzstack_drift = opt.zstack_drift+opt.adjusted_xyz([1 2])'; 
    for i = 1:size(image,4)
       image(:,:,:,i) = utils.normalize_img(image(:,:,:,i));        
    end
    if strcmp(opt.colororder,'grb')
        image(:,:,[1 2],:)=image(:,:,[2 1],:);
    end
    opt.zstack = image; % normalize zstack now before cropping 
    if isscalar(opt.idx)
        [image,zx1,zy1] = get.roi_surround(image,opt.idx,stat,opt.surround,ops,'zstack_drift',nzstack_drift,'plane',p);
    else
        zx1=0; zy1=0; 
    end
 
    redChannel = image(:, :, 1,opt.default_plane);greenChannel = image(:,:,2,opt.default_plane);    

end

%% CREATE FIGURES FOR COLOR/ BW IMAGES
% Create a figure for the image display
if strcmp(opt.type,'functional')
    %Create RGB image 
    hFigImg = figure('Name', 'RGB Image', 'NumberTitle', 'off', 'Position',figs.rgb.Position, 'Color', 'White');
    hAx = axes('Parent', hFigImg, 'Position', [0.01, 0.01, 0.99, 0.99]);
    hImg = imshow(image, 'Parent', hAx); hold on; 
    masks=plot.mask_boundaries(mask_colors,mask_coords(roi_planeidx==p),plane_crshift,idxshifts(p),'masktype','outline');
  
elseif strcmp(opt.type,'zstack')
    hFigImg = figure('Name', 'Z-Stack', 'NumberTitle', 'off', 'Position',figs.zstack.Position, 'Color', 'White');
    hAx = axes('Parent', hFigImg, 'Position', [0.01, 0.01, 0.99, 0.99]);
    hImg = imshow(image(:,:,:,opt.default_plane), 'Parent', hAx); hold on; 
    if isscalar(opt.idx)
        [masks,texts] = plot.mask_boundaries(mask_colors(:,1),stackmask_coords(opt.idx),plane_crshift,opt.idx,"idxtype",'specified','masktype','outline','crop_x1y1',[zx1 zy1],'image',image(:,:,:,1));
    else
        [masks,texts]=plot.mask_boundaries(mask_colors,mask_coords(roi_planeidx==p),plane_crshift,idxshifts(p),'masktype','outline');
    end
    orig_maskx=cell(length(masks),1);orig_masky=cell(length(masks),1);
    orig_textx=cell(length(masks),1);orig_texty=cell(length(masks),1);
    for n = 1:length(masks)
        masks{n}.XData = masks{n}.XData+nzstack_drift(1); 
        orig_maskx{n} = masks{n}.XData;orig_textx{n}= texts{n}.Position(1); 
        masks{n}.YData = masks{n}.YData+nzstack_drift(2); 
        orig_masky{n}= masks{n}.YData; orig_texty{n}= texts{n}.Position(2); 
    end
    arrow = annotation('arrow','Color','r','LineWidth',.25); 
    arrow.Parent = gca; 
    arrow.X= ([1 size(image,2)]);arrow.Y=([0 0]);

end

%% CREATE SLIDER FIGURE WITH HISTOGRAMS
% Create a second figure for the sliders and histogram
if stack
    hFigSlider = figure('Name', 'Z-Stack Control', 'NumberTitle', 'off', ...
        'Position',figs.zslider.Position, 'Color', 'White');
elseif ~stack
    hFigSlider = figure('Name', 'Image Control', 'NumberTitle', 'off', ...
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
uicontrol('Style', 'text', 'String', 'Red- Low Thresh:', 'Units', 'normalized', 'Position', [0.05, 0.4, 0.2, 0.05], 'Parent', hFigSlider);
hLowInRed = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', low_in_red, 'Units', 'normalized', 'Position', [0.05, 0.35, 0.3, 0.05], 'Parent', hFigSlider, 'Callback', @updateImage);
uicontrol('Style', 'text', 'String', 'Red- High Thresh:', 'Units', 'normalized', 'Position', [0.05, 0.3, 0.2, 0.05], 'Parent', hFigSlider);
hHighInRed = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', high_in_red, 'Units', 'normalized', 'Position', [0.05, 0.25, 0.3, 0.05], 'Parent', hFigSlider, 'Callback', @updateImage);
uicontrol('Style', 'text', 'String', 'Red- Gamma:', 'Units', 'normalized', 'Position', [0.05, 0.2, 0.2, 0.05], 'Parent', hFigSlider);
hGammaRed = uicontrol('Style', 'slider', 'Min', 0.1, 'Max', 2, 'Value', gamma_red, 'Units', 'normalized', 'Position', [0.05, 0.15, 0.3, 0.05], 'Parent', hFigSlider, 'Callback', @updateImage);
% Create sliders and labels for the Green channel (right side)
uicontrol('Style', 'text', 'String', 'Green- Low Thresh:', 'Units', 'normalized', 'Position', [0.4, 0.4, 0.2, 0.05], 'Parent', hFigSlider);
hLowInGreen = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', low_in_green, 'Units', 'normalized', 'Position', [0.4, 0.35, 0.3, 0.05], 'Parent', hFigSlider, 'Callback', @updateImage);
uicontrol('Style', 'text', 'String', 'Green- High Thresh:', 'Units', 'normalized', 'Position', [0.4, 0.3, 0.2, 0.05], 'Parent', hFigSlider);
hHighInGreen = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, 'Value', high_in_green, 'Units', 'normalized', 'Position', [0.4, 0.25, 0.3, 0.05], 'Parent', hFigSlider, 'Callback', @updateImage);
uicontrol('Style', 'text', 'String', 'Green- Gamma:', 'Units', 'normalized', 'Position', [0.4, 0.2, 0.2, 0.05], 'Parent', hFigSlider);
hGammaGreen = uicontrol('Style', 'slider', 'Min', 0.1, 'Max', 2, 'Value', gamma_green, 'Units', 'normalized', 'Position', [0.4, 0.15, 0.3, 0.05], 'Parent', hFigSlider, 'Callback', @updateImage);
% Z-stack plane selection 
if stack
    uicontrol('Style', 'text', 'String', ['Z-Stack Plane ','(est=',num2str(opt.default_plane),'):'], 'Units', 'normalized', 'Position', [0.2, 0.07, 0.15, 0.05],'Parent', hFigSlider);
    img_slidern = uicontrol('Style', 'slider', 'Min', 1, 'Max', size(image, 4), 'SliderStep', [1/(size(image, 4)-1), 1/(size(image, 4)-1)], 'Value', opt.default_plane, 'Units', 'normalized', 'Position', [0.25, 0.03, 0.05, 0.05], 'Parent', hFigSlider, 'Callback', @updateImage);
    plane_text = uicontrol('Style', 'text', 'String', num2str(opt.default_plane), 'Units', 'normalized', 'Position', [0.2, 0.03, 0.05, 0.03], 'Parent', hFigSlider);
end
% Position hXshift and hYshift sliders beneath hGammaGreen
if stack 
    uicontrol('Style', 'text', 'String', ['X Shift: (est=',num2str(nzstack_drift(1)),')'],'units','normalized', 'Position', [0.05, 0.11, 0.1, 0.05], 'Parent', hFigSlider);
    hXShift = uicontrol('Style', 'slider', 'Min', -100, 'Max', 100, 'Value', nzstack_drift(1), 'Units', 'normalized', 'Position', [0.1, 0.07, 0.03, 0.05], 'Parent', hFigSlider, 'Callback', @updateImage);
    xshift_text = uicontrol('Style', 'text', 'String',[num2str(nzstack_drift(1))] , 'Units', 'normalized', 'Position', [0.05, 0.07, 0.04, 0.05], 'Parent', hFigSlider,'Callback', @updateImage);

    uicontrol('Style', 'text', 'String', ['Y Shift: (est=',num2str(nzstack_drift(2)),')'],'units','normalized', 'Position', [0.05, .02, 0.1, 0.05], 'Parent', hFigSlider);
    hYShift = uicontrol('Style', 'slider', 'Min', -100, 'Max', 100, 'Value', nzstack_drift(2), 'Units', 'normalized', 'Position', [0.1, -0.01, 0.03, 0.05], 'Parent', hFigSlider, 'Callback', @updateImage);
    yshift_text = uicontrol('Style', 'text', 'String', [num2str(nzstack_drift(2))], 'Units', 'normalized', 'Position', [0.05, -0.01, 0.05, 0.05], 'Parent', hFigSlider,'Callback', @updateImage);
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
        if stack 
            % --- GET Z-STACK SLIDER VALS 
            xyshift_x = get(hXShift, 'Value');
            xyshift_y = get(hYShift, 'Value');
            set(xshift_text, 'String', [num2str(xyshift_x)]);
            set(yshift_text, 'String', [num2str(xyshift_y)]);
            image = opt.zstack(:,:,:,img_num); 
            if isscalar(opt.idx)
                [crimage, zx1, zy1] = get.roi_surround(image, opt.idx, stat, opt.surround,ops,'zstack_drift', [xyshift_x, xyshift_y],'plane',p);
            else
                crimage = image; zx1=0;zy1=0;
            end

            % --- MAKE NEW IMAGE
            adj_img = cat(3, ...
                imadjust(crimage(:,:,1), [low_in_red, high_in_red], [], gamma_red), ...
                imadjust(crimage(:,:,2), [low_in_green, high_in_green], [], gamma_green), ...
                crimage(:, :, 3));  % Blue channel is left unchanged
            set(hImg, 'CData', adj_img);
            % --- UPDATE MASKS/TEXT 
            for m = 1:length(masks)
                set(masks{m},'XData',orig_maskx{m}+xyshift_x,'YData',orig_masky{m}+xyshift_y)
                set(texts{m},'Position',[orig_textx{m}+xyshift_x,orig_texty{m}+xyshift_y,0]) % third coordinate is 0
            end
            %--- ARROW POSITION
            narrowy= mean(find(curplane==img_num)); 
            if img_num<min(curplane)
                set(arrow,'Y',[1 1])
            elseif img_num>max(curplane)
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
        elseif ~stack 
            % --- MAKE NEW IMAGE 
            adj_img = cat(3, ...
                imadjust(image(:, :, 1), [low_in_red, high_in_red], [], gamma_red), ...
                imadjust(image(:, :, 2), [low_in_green, high_in_green], [], gamma_green), ...
                image(:, :, 3));  % Blue channel is left unchanged
            % --- UPDATE IMAGE 
            set(hImg, 'CData', adj_img);
            red = image(:,:,1); green = image(:,:,2); % why is this 4D? 
            red(red==0)=[]; green(green==0)=[]; 
            redc=histcounts(red,256); greenc=histcounts(green,256); 
            maxred =max(redc(:)); maxgreen=max(greenc(:)); 
            m= max([maxred,maxgreen]); 
        end
        %----- HISTOGRAM
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
if strcmp(opt.type,'functional')
    nfigs.rgb = hFigImg; 
    nfigs.slider = hFigSlider; 
    nfigs.zstack = figs.zstack; 
    nfigs.zslider = figs.zslider; 
    nadjusted_xyz = [0 0 0]; 
elseif strcmp(opt.type,'zstack')
    nfigs.rgb = figs.rgb; 
    nfigs.slider = figs.slider; 
    nfigs.zstack = hFigImg; 
    nfigs.zslider=hFigSlider;
    nadjusted_xyz = [nzstack_drift-xyshift_x,nzstack_drift-xyshift_y,opt.default_plane - img_num]; 
end

end

%%



