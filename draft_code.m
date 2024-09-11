%% LOAD 

load('/Volumes/Potter/From Abby/#37_TTX/Ready for Suite2p/suite2p/combined/Fall.mat')

%% MAKE SAMPLE RED/ GREEN CELL VECT 

sample_rcthresh= prctile(redcell(:,2),75); 
red_vect = redcell(:,2)>sample_rcthresh; 
in_vect = red_vect; 
ex_vect = ~in_vect; 

id_vect= zeros(length(red_vect),1); 
id_vect(ex_vect)=1; 
id_vect(in_vect)=2; 
id_vect([5 10 15])=3; 
iscell(:,1)=1; 

%% ONLY INCLUDE ISCELL == 1

cellstat= stat(iscell(:,1)==1); 
id_vect = id_vect(iscell(:,1)==1); 

%% RECOGNIZE NUMBER OF PLANES 

for i = 1:length(cellstat)
    curstat= cellstat{i}; 
    roi_planeidx(i)=curstat.iplane+1; % add 1 to the plane 
end

nplanes = length(unique(roi_planeidx));



%% DEFAULT VALUES
p = 1; 
r_thresh=3 ; g_thresh=3; 
atype= 'mean';ftype='mean'; 
img_mode='combined'; 

%% RUN MAIN MENU 
figure(1)
while p ~= -1      
    [gclim,rclim] = plot.plane_masks(p,ops,cellstat,g_thresh,r_thresh,id_vect,roi_planeidx,ftype,atype,'mode',img_mode); 
    input_str=prompt.menu_str(1); 
    answer = input (input_str,"s"); 

    if strcmp(answer,'a')
        cprompt = ['Enter ROIs you wish to change:',char(10),char(10)]; 
        [id_vect] = prompt.change_rois(id_vect,cprompt);        
    elseif strcmp(answer,'s')
        if p+1 <= nplanes
            p= p+1;
        elseif p+1 > nplanes  
            p = 1; 
        end 
    elseif strcmp(answer,'d')
        if p-1 == 0 
            p = nplanes; 
        elseif p-1 > 0
            p = p-1; 
        end
    elseif strcmp(answer,'f') %threshold is always 2 digit even if it is a merged image 
        [g_thresh,r_thresh]= prompt.change_brightness(gclim,rclim); 

    elseif strcmp(answer,'r')
        [ftype,atype]=prompt.img_type(atype,ftype);    
     
    elseif strcmp (answer,'q')
        if sum(id_vect==3)<0
            disp('No ROIs currently unclassified.',char(10))
            unc_vect = input('Enter neurons you wish to unclassify:'); 
            id_vect(unc_vect)=3; 
            id_vect= prompt.examine_unclassified(roi_planeidx,id_vect,ops,cellstat,g_thresh,r_thresh); 
        else 
            id_vect= prompt.examine_unclassified(roi_planeidx,id_vect,ops,cellstat,g_thresh,r_thresh); 
        end

    elseif strcmp(answer,'c')
        answer = input(['C: Combine Anatomical and Functional Channels',char(10),'S: Separate Anatomical and Functional Channels',char(10)],'s');
        if strcmp(answer,'c')
            img_mode='combined';
        elseif strcmp(answer,'s')
            img_mode = 'separate'; 
        end

    end

end


%% EXCLUDE STILL-UNCERTAIN NEURONS






