function [tseries_md,tseries_frames] =  frames_per_tseries(raw_filename,tsync)
arguments 
    raw_filename string % location of "Raw" file with Experiment.xml files in each folder 
    tsync table % compressed thorsync file 

end 
%% DESCRIPTION
% takes Final FOV > Functional > Raw file directory and gets the XML for each one
% returns combined structure with info for each 

%OUTPUTS
% tseries_md = concatenated structure of all metadata files
% *METADATA CONTAINING THE FRAMES PER TSERIES IS NOT ALWAYS ACCURATE

% tseries_frames = vector where entries indicate number of frames per
    % tseries (loaded from file,not metadata)

%% GO TO/ RETURN FROM DIRECTORY 
rf = cd; 
cd(raw_filename)
direct = dir; 
cd(rf)

%% INDEX THROUGH FOLDERS IN RAW  
count = 0; 
for i = 1:length(direct)
    if contains(direct(i).name,'#') && direct(i).isdir % if the filename has a '#' and is a folder 
        count = count+1; 
        %-- read experiment metadata 
        tseries_path = [raw_filename,'/',string(direct(i).name),'/Experiment.xml'] ; 
        tseries_path = strjoin(tseries_path,''); 
        tseries_xml=md.importxml(tseries_path);
        [tseries_md(count)] = md.extract_metadata(tseries_xml);

        
        %-- read tiff 
        % % * FIX THIS *** 
        % tiff_name = [raw_filename,'/',string(direct(i).name),'/Image_scan_1_region_0_1.tif']; 
        % tiff_name = strjoin(tiff_name,''); 
        % try % see if there is an additional file  
        %     info2 = imfinfo(tiff_name); 
        %     tiff_num =2; 
        % catch 
        %     tiff_num = 1; 
        %     info2=[]; 
        % end 
        % 
        % tiff_name = [raw_filename,'/',string(direct(i).name),'/Image_scan_1_region_0_0.tif']; 
        % tiff_name = strjoin(tiff_name,''); 
        % info = imfinfo(tiff_name);  % Get information about the TIF file
        % 
        % tseries_frames(count) = numel(info)/(2*tseries_md(count).nplanes); % 2 (R+G) * nplanes 
        % if tiff_num == 2
        %     tseries_frames(count) = tseries_frames(count)+(numel(info2)/ (2*tseries_md(count).nplanes)); 
        % elseif tiff_num == 1
        %     disp(direct(i).name) 
        % end      
     
    end

end
%% GET tseries_frames FROM tsync
tseries_frames = get.tseries_frames(tsync); 


%% *** use this for split folder instead of raw folder if needed 
% %% GO TO/ RETURN FROM DIRECTORY 
% rf = cd; 
% cd(split_filename)
% direct = dir; 
% cd(rf)
% 
% %% GET TSERIES FRAMES FROM SPLIT FOLDER 
% 
% 

%load('/Volumes/Warwick/DRGS project/#545 4-4-25/Final FOV/Functional/Split/Split files only'
%% TAKE CUMULATIVE SUM 

%tseries_frames = cumsum(tseries_frames); 

end