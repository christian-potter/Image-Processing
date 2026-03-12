zstack = readZStack_ChanAChanB('/Volumes/Warwick/DRGS/#551/SDH/Structural/#551 1030 post'); 

%%
opts = struct;
opts.ApplyToChannels = [1 2]; % red+green only
opts.Gaussian = struct("Enable",true,"Sigma",2,"Mode","perPlane");
opts.TopHat   = struct("Enable",true,"Type","white","Radius",20,"Mode","perPlane");

stackOut = processZStack(zstack, opts); 

%%

out = ij_like_filters(zstack); 

%% SETTINGS 
padjusted_xyz = zeros(3,nplanes); % updated to contain user-adjusted mapping between zstack and functional images 
fslider.lowred = 0; zslider.lowred = 0; 
fslider.highred = .5; zslider.highred = .5; 
fslider.gammared= 1; zslider.gammared= 1; 
fslider.lowgreen = 0; zslider.lowgreen = 0; 
fslider.highgreen = .5;zslider.highgreen = .5;
fslider.gammagreen = 1; zslider.gammagreen = 1; 

y = ones(size(zstack,1)); 
for i = 1:4
    ypix_zplane{i} = y; 
end
%%
%zstack=zs;
p = 1;% Choose Plane 
cellstat=stat(1:10); id_vect = ones(length(cellstat)); 

[plane_crshift]=get.crshift(ops,p);
atype= 'mean';ftype='max'; %choose default anatomical and functional image types 
nplanes=4;
zstack_drift = [ops.xoff(end) ops.yoff(end)]; % estimates the x/y coordinates of the z-stack by taking last value of x and y offset 
colororder = 'rgb'; % change between 'grb' and 'rgb' if your z-stack channels are switched 
[nzfigs,~,zslider_fig]= adjustImage(p,cellstat,plane_crshift,figs,zslider,ops,id_vect,ypix_zplane,'zstack_drift',zstack_drift,'type','zstack','zstack',zstack,'adjusted_xyz',padjusted_xyz(:,p),'colororder',colororder);    

%%

