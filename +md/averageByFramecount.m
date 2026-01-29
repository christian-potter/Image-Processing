function T_avg = averageByFramecount(T,frameBinSize)
arguments 
    T table % Individual, uncompressed thorsync file associated with one tseries 
    frameBinSize double % taken from tlapse metadata. equal to nplanes + nflyback 
end

%%

% Get unique sorted framecount values
uniqueFrames = unique(T.framecount);

% Exclude first, which is 0 
uniqueFrames = uniqueFrames(2:end);

% Determine how many bins we can make
nBins = floor(numel(uniqueFrames) / frameBinSize);
m = mod(numel(uniqueFrames) , frameBinSize);
% Get all variable names
varNames = T.Properties.VariableNames;

% Determine numeric variables
isNum = varfun(@isnumeric, T, 'OutputFormat', 'uniform');
isNum(strcmp(varNames, 'framecount')) = false;  % we'll handle framecount manually

% Preallocate output as a struct array to convert to table later
resultStruct = repmat(cell2struct(cell(size(varNames)), varNames, 2), nBins, 1);

for b = 1:nBins
    %Get framecount values in current bin
    % if b~= nBins
    %     framesInBin = uniqueFrames((b-1)*frameBinSize + (1:frameBinSize));
    % else % if there is an incomplete bin at the end 
    %     x  = (b-1)*frameBinSize + (1:frameBinSize); 
    %     framesInBin = uniqueFrames(x(1:m)); % take only the modulo elements of the last bin 
    % end
    % 
    framesInBin = uniqueFrames((b-1)*frameBinSize + (1:frameBinSize));
    
    % Get rows in the table matching those framecounts
    rows = ismember(T.framecount, framesInBin);
    Tbin = T(rows, :);

    % Fill in each variable
    for v = 1:numel(varNames)
        varName = varNames{v};
        columnData = Tbin.(varName);

        if strcmp(varName, 'framecount')
            resultStruct(b).(varName) = b;  % assign average framecount
        elseif isNum(v)
            resultStruct(b).(varName) = mean(columnData);
        else
            disp('non-numeric')
            % Non-numeric: assign default empty or NaN
            if iscell(columnData)
                resultStruct(b).(varName) = {[]};
            elseif isstring(columnData)
                resultStruct(b).(varName) = "";
            elseif iscategorical(columnData)
                resultStruct(b).(varName) = categorical(missing);
            else
                resultStruct(b).(varName) = NaN;
            end
        end
    end
end

% Convert result to table
T_avg = struct2table(resultStruct);

end

