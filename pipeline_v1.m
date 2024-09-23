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
r_thresh=1 ; g_thresh=1; 
atype= 'mean';ftype='mean'; 
img_mode='separate'; 

figure(1)
while p ~= -1   
    [crshift]=get.rcshift(ops,p);
    [nfigs] = adjustImagev2(image,p,idxshifts,roi_planeidx,mask_coords,mask_colors,crshift,figs); 
    input_str=prompt.menu_str(1); 
    answer = input (input_str,"s"); 


