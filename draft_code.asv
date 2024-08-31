%% LOAD 

load('/Volumes/Potter/From Abby/#37_TTX/Ready for Suite2p/suite2p/combined/Fall.mat')

%% MAKE SAMPLE RED/ GREEN CELL VECT 

sample_rcthresh= prctile(redcell(:,2),75); 
red_vect = redcell(:,2)>sample_rcthresh; 
in_vect = red_vect; 
ex_vect = ~in_vect; 
proj_vect=logical(zeros(length(red_vect),1)); 


%% VERIFY RED CELL SELECTION FOR EACH PLANE AND SELECT CANDIDATE CELLS 

 
figure(1)

thresh = 5; 
p = 1; 

while p ~= -1  
    plot.plane_masks(p,ops,stat,thresh,in_vect,ex_vect,proj_vect)
    
    input_str=prompt_input(); 
    answer = input (inputstr,"s"); 

    if strcmp(answer,'a')
        prompt = ['Enter ROIs you wish to change',char(10)]; 
        exinput= input(prompt);
        

    end
    
end



%%


% rwindow = ops.meanImg_chan2(xshift+1:xshift+planesize(1),yshift+1:yshift+planesize(2));
% gwindow = ops.meanImg(xshift+1:xshift+planesize(1),yshift+1:yshift+planesize(2));
% %rgwindow(:,:,1)=rwindow;rgwindow(:,:,2)=gwindow;rgwindow(:,:,3)=zeros(planesize(1),planesize(2)); 
% 
%pause



%%
figure;
imshow(ops.meanImg)
hold on
clim([0 max(max(ops.meanImg))/5])

for i = 1:length(maskcoords)

    xcoords=maskcoords{i}(:,1); ycoords=maskcoords{i}(:,2); 
    plot(double(xcoords),double(ycoords),'r','LineWidth',2)
    text(max(xcoords)+1,max(ycoords)+1,num2str(i),'Color','r') % make text of ROI index 
end




