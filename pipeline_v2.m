%% LOAD 
[zs,tlapse,zstack,tsync,s2p,ypix_zplane] = load_drgs(511); 
load(s2p); 
%% CREATE SAMPLE ID_VECT

sample_rcthresh= prctile(redcell(:,2),75); 
red_vect = redcell(:,2)>sample_rcthresh; 
in_vect = red_vect; 
ex_vect = ~in_vect; 

id_vect= zeros(length(red_vect),1); 
id_vect(ex_vect)=1; 
id_vect(in_vect)=2; 
%id_vect([5 10 15])=3; 
%iscell(:,1)=1; % why do I do this 
%%

cellstat= stat(iscell(:,1)==1); 
id_vect = id_vect(iscell(:,1)==1); 

%% LOAD FIGURE POSITIONS 
load('work-positions.mat')

%% RUN MAIN MENU
p = 1; 
atype= 'mean';ftype='mean'; 
img_mode='rgb'; 
nplanes=5; 

[id_vect] = prompt.main_menu(id_vect,figs,p,ops,cellstat,ftype,atype,img_mode,nplanes,ypix_zplane);

%%
