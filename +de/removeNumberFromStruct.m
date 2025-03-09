function updatedStruct = removeNumberFromStruct(X, inputStruct)
    % Function to remove the number X from all fields in a structure
    % Inputs:
    %   X - The number to remove
    %   inputStruct - The input structure
    % Output:
    %   updatedStruct - The structure with X removed from all fields

    updatedStruct = inputStruct; % Copy input structure
    fieldNames = fieldnames(inputStruct); % Get all field names

    for i = 1:numel(fieldNames)
        fieldData = inputStruct.(fieldNames{i}); % Get field content

        % Check if the field is numeric
        if isnumeric(fieldData)
            updatedStruct.(fieldNames{i}) = fieldData(fieldData ~= X);
        end
    end
end
