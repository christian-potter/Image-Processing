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

%% RECOGNIZE NUMBER OF PLANES 

for i = 1:length(stat)
    curstat= stat{i}; 
    roi_planeidx(i)=curstat.iplane+1; % add 1 to the plane 
end

nplanes = length(unique(roi_planeidx));

%% VERIFY RED CELL SELECTION FOR EACH PLANE AND SELECT CANDIDATE CELLS 
figure(1)

thresh = [5 5]; 
p = 1; 
rg_gain =[1 1]; 


while p ~= -1  
    
    plot.plane_masks(p,ops,stat,thresh,id_vect) 
    input_str=prompt.menu_str(1); 
    answer = input (input_str,"s"); 

    if strcmp(answer,'a')
        cprompt = ['Enter ROIs you wish to change:',char(10),char(10)]; 
        [id_vect] = prompt.change_rois(id_vect,cprompt);        
    elseif strcmp(answer,'s')
        if p+1 < 
        p= p+1; 
    elseif strcmp(answer,'d')
        p = p-1; 
    elseif strcmp(answer,'f') %threshold is always 2 digit even if it is a merged image 
        cprompt= ['Current Threshold = ',num2str(thresh),char(10),'Enter the New Threshold:'] ; 
        thresh = input(cprompt); 
    elseif strcmp(answer,'f') %threshold is always 2 digit even if it is a merged image 
        p = -1; 
    end
    



end


%% LOOK AT UNCERTAIN NEURONS






