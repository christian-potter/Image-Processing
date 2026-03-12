%% LOAD 550 
dsnum= 550; 
[Fall,tseries_md,zstack,zstack_md,tsync] = utils.load_Data_Organization(dsnum); 
raw_tsync = md.read_h5('/Volumes/Warwick/DRGS/#550/SDH/Functional/ThorSync/TS#550_000/Episode_0000.h5'); 

[ypix_zdist,zlocs,totalpdist]= dep.fa_zdist(tseries_md,zstack_md,raw_tsync); 
%% ALIGN FUNCTIONAL AND ANATOMICAL 
stat = Fall.stat; 
stat = stat(Fall.iscell(:,1)==1); 
ref_cell = [82 37 ]; % cell id, zplane  

%[ypix_zdist,zlocs,totalpdist] = dep.fa_zdist(tseries_md,zstack_md,raw_tsync); 
[ypix_zplane,zlocs] = dep.modify_alignment(zlocs,ypix_zdist,stat,ref_cell,tseries_md,zstack_md); 
%% 
load("/Users/ctp21/Desktop/Analysis/Image-Processing/work-positions.mat")

%% SETTINGS 
%zstack=zs;
p = 1;% Choose Plane 
atype= 'mean';ftype='max'; %choose default anatomical and functional image types 
nplanes=5;
zstack_drift = [Fall.ops.xoff(end) Fall.ops.yoff(end)]; % estimates the x/y coordinates of the z-stack by taking last value of x and y offset 
colororder = 'grb'; % change between 'grb' and 'rgb' if your z-stack channels are switched 
%%
id_vect = ones(sum(Fall.iscell(:,1)==1),1)*3; 
cellstat = stat; %stat(Fall.iscell(:,1)==1);
%% RUN MAIN MENU
zs=zstack;
[id_vect,figs,ref_bands] = prompt.main_menu(id_vect,figs,p,Fall.ops,cellstat,ftype,atype,nplanes,ypix_zplane,zs,colororder,zstack_drift);


%% DEPTH ESTIMATION
% based on pia completely disappearing from at least one block in the first
% or last X or Y row 
first_full_x = ; first_x= 9; 
first_full_y = ; first_y = 10; 

%%
% based first cell body in at least one block in the first
% or last X or Y row 
first_x= 1; first_full_x = 40;
first_y =1; first_full_y =11; 

%%

%% DETERMINE BINARY THRESHOLD 
zs = zstack
thresh = prctile(zstack(:),70); 


figure
histogram(zstack(:),'binwidth',.0001)
xline(thresh,'color','r')
title('Distribution of Intensity Values in ')
utils.sf
%% 
zs = zstack; 
zs= zs>thresh; 


stack_size = 30; 
dorsal_stack = squeeze(mean(zs(:,:,[1 2],1:stack_size),[3 4])); 
%dorsal_stack = nan(size(zs,1),size(zs,2)); 


%%
figure
utils.sf

subplot(2,1,2)
hold on 
y = mean(dorsal_stack,2); 
% Fit a second order polynomial to y
p_y = polyfit((1:length(y))', y, 2); % Fit a second order polynomial
y_fit = polyval(p_y, (1:length(y))'); % Evaluate the polynomial at the original x values
plot(y)
plot(y_fit)
xlabel('Y Coordinate')
ylabel('Pixel Intensity')
title('Second Order Polynomial Fit to Gradient in Y Dimension')
legend({'Data','Fit'})

axis([0 200 .1 .7])

subplot(2,1,1)
hold on 
x = mean(dorsal_stack,1); 
p_x = polyfit((1:length(x))', x, 1); % Fit a second order polynomial to x
x_fit = polyval(p_x, (1:length(x))'); % Evaluate the polynomial at the original x values
plot(x)
plot(x_fit)
xlabel('X Coordinate')
title('First Order Polynomial Fit to Gradient in X Dimension')
ylabel('Pixel Intensity')
legend({'Data','Fit'})
sgtitle('Red And Green Averaged Together')

axis([0 600 .1 .7])