function [md] = extract_metadata(xml)

headers = {'<Timelapse','<LSM name','<PMT enable','<Pockels type="1"','<Streaming enable','<ZStage name'};
headidx= nan(length(headers),1); 

%get row index for each header 
for i = 1:size(xml,1)
    rowstr = xml{i,1};
    
    for j = 1:length(headers)
        if contains(rowstr,headers{j})
            headidx(j)=i; 
        end
    end

end

%% FOR EACH HEADER SPECIFY THE KEYWORDS TO LOOK FOR 
header{1} = {'timepoints'};
header{2} = {'pixelSizeUM','widthUM','heightUM','pixelX','pixelY','dwellTime','averageNum'}; 
header{3} = {'gainA','gainB'}; 
header{4} = {'start','stop'}; 
header{5} = {'flybackTimeAdjustMS','flybackLines','flybackFrames'};
header{6} = {'steps','stepSizeUM','startPos','setupPositionMM'}; 

%% CONVERT TO NAMES THAT WILL BE USED IN STRUCTURE 

values= {'timepoints','pixelsize','width_mm','height_mm','xpix','ypix','dwellTime','averageNum','green_gain','red_gain','start','stop','flybackTime','flybackLines','flybackFrames','nplanes','stepSize','startPos','setupPosition'};

%%
count = 0; 
for i = 1:length(header)
  
    rowstr = char(xml{headidx(i),1}); 
    patterns = header{i}; 
    for j = 1:length(patterns)
       
        count = count+1; 
        pat = patterns{j}; n = strlength(pat); 

        start = strfind(rowstr,pat);
        ending = start+n; 
      

        redstr = rowstr(ending:ending+10); 
        
        quotes=strfind(redstr,'"'); 
        
        value = str2double(redstr(quotes(1)+1:quotes(2)-1)); 

        md.(values{count})=value;


    end
    
end
