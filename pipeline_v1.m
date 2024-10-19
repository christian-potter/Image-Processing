%% LOAD 

load('/Volumes/Potter/From Abby/#37_TTX/Ready for Suite2p/suite2p/combined/Fall.mat')

%%

load('/Volumes/ross/Christian/suite2p/combined/Fall.mat')

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

%% DEFAULT POSITIONS
% figs.rgb.Position=[54 800 600 400]; 
% figs.functional.Position=[100 800 600 400];
% figs.anatomical.Position=[54 900 600 400]; 
% figs.slider.Position=[100 900 600 400];
 load('work-positions.mat')
%% CREATE IMAGE STACK 
zstack= get.zstack('/Volumes/ross/Christian/#511 Data/#511 Structural 16 bit 2-channel.tif');
%%
% use this to load individual tiffs. _00X at the end is the first or second
% timepoint 
% have function choose the timepoint 

'/Volumes/Warwick/DRGS project/#511 3-28-24/SDH/Final FOV/Structural/1x resolution (26)/SDH#511_026/ChanB_001_001_208_002.tif'

% metadata for zstack
'/Volumes/Warwick/DRGS project/#511 3-28-24/SDH/Final FOV/Structural/1x resolution (26)/SDH#511_026/Experiment.xml'
%% DEFAULT VALUES
p = 1; 
atype= 'mean';ftype='mean'; 
img_mode='rgb'; 
nplanes=5; 
%%


while p ~= -1   
    close all 
    [crshift]=get.crshift(ops,p);
    [nfigs] = adjustImagev2(p,cellstat,crshift,figs,ops,id_vect,'functional',ftype,'anatomical',atype,'type',img_mode); 
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
    elseif strcmp(answer,'r')
        [ftype,atype]=prompt.img_type(atype,ftype); 
    
    elseif strcmp (answer,'q')
        if sum(id_vect==3)<0
            close all 
            disp('No ROIs currently unclassified.',char(10))
            unc_vect = input('Enter neurons you wish to unclassify:'); 
            id_vect(unc_vect)=3; 
            [id_vect,nfigs] = prompt.examine_unclassifiedv2(p,zstack,id_vect,ops,stat,crshift,figs,'surround',20); 
        else 
            close all 
            [id_vect,nfigs] = prompt.examine_unclassifiedv2(p,zstack,id_vect,ops,stat,crshift,figs,'surround',20); 
        end
    elseif strcmp(answer,'c')
        answer = input(['C: Combine Anatomical and Functional Channels',char(10),'S: Separate Anatomical and Functional Channels',char(10)],'s');
        if strcmp(answer,'c')
            img_mode='rgb';
        elseif strcmp(answer,'s')
            img_mode = 'separate'; 
        end
    elseif strcmp(answer,'w')
        figs = utils.save_positions(nfigs,figs); 

    end


end
