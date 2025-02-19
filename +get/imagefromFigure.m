function imgData = imagefromFigure(nfigs)
    % GETIMAGEFROMFIGURE Extracts image data from the current figure.
    % This function retrieves the image data from the current figure's axes.

    % Get the current figure
    %fig = gcf;
    fig = nfigs.rgb; 
    % Find all image objects in the figure
    imgHandles = findall(fig, 'Type', 'image');
    
    if isempty(imgHandles)
        error('No image found in the current figure.');
    end
    
    % Assuming the first image object is the desired one
    imgHandle = imgHandles(1);
    
    % Get the image data
    imgData = get(imgHandle, 'CData');
end