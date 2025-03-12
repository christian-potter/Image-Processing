function outputMatrix = offsetRows(inputMatrix, offsetValue)
    % Get the number of rows and columns in the input matrix
   % Get the number of rows and columns in the input matrix
    [numRows, numCols] = size(inputMatrix);
    
    % Create an offset vector for each row
    rowOffsets = (1:numRows)' * offsetValue; % Column vector
    
    % Expand the offsets to match the matrix dimensions
    offsetMatrix = repmat(rowOffsets, 1, numCols);
    
    % Apply the negative offset to each row
    outputMatrix = inputMatrix - offsetMatrix;
end