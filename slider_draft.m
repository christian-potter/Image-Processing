%% LOAD DATA / CREATE VARIABLES 
 load('sample_ws.mat')

 imgsize=size(ops.refImg);
 greenwin = ops.meanImg(1:imgsize(1),1:imgsize(2)); 
 redwin= ops.meanImg_chan2(1:imgsize(1),1:imgsize(2));
 corrwin=ops.Vcorr(1:imgsize(1),1:imgsize(2)); 

 rgwin(:,:,1)=redwin; rgwin(:,:,3)= zeros(imgsize(1),imgsize(2)); rgwin(:,:,2)= greenwin; 
 crwin(:,:,1)=zeros(imgsize(1),imgsize(2)); crwin(:,:,2)=corrwin;crwin(:,:,3)=redwin; 

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
iscell(:,1)=1; 
cellstat= stat(iscell(:,1)==1); 
id_vect = id_vect(iscell(:,1)==1); 

%% RECOGNIZE NUMBER OF PLANES 

for i = 1:length(cellstat)
    curstat= cellstat{i}; 
    roi_planeidx(i)=curstat.iplane+1; % add 1 to the plane 
end

nplanes = length(unique(roi_planeidx));

%% GET MASKS / DETERMINE COLOR
[mask_coords]=get.mask_coordinates(stat); 

mask_colors= nan(3,length(id_vect)); 

for i = 1:size(mask_colors,2)
    if id_vect(i)==2
        mask_colors(:,i)=[0 0 1]; 
    elseif id_vect(i)==1
        mask_colors(:,i)=[1 0 0]; 
    elseif id_vect(i)==0
        mask_colors(:,i)=[0 1 0]; 
    elseif id_vect(i)==3
        mask_colors(:,i)=[1 0 1]; 
    end
end


%% CALULATE THE SHIFT IN IDX  
p = 1; 
idxshifts=0;
idxshifts=[idxshifts,find(diff(roi_planeidx)==1)];
%% CSHIFT/RSHIFT
planesize= size(ops.refImg);

cshift=0; 
if mod(p,2)==0
    cshift=planesize(2);
end 
rshift=floor((p-1)/2)*planesize(1);

%% DEFAULT POSITIONS
figs.rgb.Position=[54 800 600 400]; 
figs.functional.Position=[100 800 600 400];
figs.anatomical.Position=[54 900 600 400]; 
figs.slider.Position=[100 900 600 400];

 %% ADJUST IMAGE 
[nfigs]=adjustImagev2(cstack,p,idxshifts,roi_planeidx,mask_coords,mask_colors,cshift,rshift,figs);

%% SAVE POSITIONS 
figs = utils.save_positions(nfigs,figs); 

%% IMAGE STACK DRAFT 
x= tiffreadVolume('/Volumes/ross/Christian/#511 Data/#511 Structural 16 bit 2-channel.tif');

i = x(:,:,101); 
j = x(:,:,102); 
k = zeros(288,512); 

xy(:,:,1)= i; xy(:,:,2)=j; xy(:,:,3)=k; 

xy = utils.normalize_img (xy); 

figure; imshow(xy)

cstack = utils.convert_img(x);
