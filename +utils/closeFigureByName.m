function closeFigureByName(figName)
    figHandles = findall(0, 'Type', 'figure'); % Get all figure handles
    for i = 1:length(figHandles)
        if strcmp(get(figHandles(i), 'Name'), figName) % Compare figure name
            close(figHandles(i)); % Close the matching figure
            %fprintf('Closed figure: %s\n', figName);
            return;
        end
    end
    %fprintf('No figure found with name: %s\n', figName);
end
