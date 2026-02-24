%% LOAD 
% edit function 
[zstack,tlapse_md,zstack_md,tsync,s2p,ypix_zplane] = utils.load_drgs(541,'plot'); 
load(s2p); 

%% DEFAULT ID_VECT
id_vect = ones(sum(iscell(:,1)==1),1)*3; 
cellstat = stat(iscell(:,1)==1);
%% MAKE YPIX/ZPLANE
tseries_md.nplanes = 4; 
ypix_zplane = functional_anatomical_zmap(dsnum,tseries_md,zstack_md,raw_tsync,'plot',true); 

%% FIX YPIX_ZPLANE 
ref_cell = [82 37 ]; % cell id, zplane  

[ypix_zdist,zlocs] = dep.fa_zdist(tseries_md,zstack_md,tsync); 
[ypix_zplane] = dep.modify_alignment(zlocs,ypix_zdist,stat,ref_cell,tseries_md,zstack_md); 


%% LOAD FIGURE POSITIONS 
load('home_positions.mat')
figs.zstack = figs.rgb; 
figs.zslider=figs.slider;
figs.ref=figs.rgb; 
%% SETTINGS 
%zstack=zs;
p = 1;% Choose Plane 
atype= 'mean';ftype='max'; %choose default anatomical and functional image types 
nplanes=5;
zstack_drift = [ops.xoff(end) ops.yoff(end)]; % estimates the x/y coordinates of the z-stack by taking last value of x and y offset 
colororder = 'grb'; % change between 'grb' and 'rgb' if your z-stack channels are switched 

%% RUN MAIN MENU
%zs=zstack;
[id_vect,figs,ref_bands] = prompt.main_menu(id_vect,figs,p,ops,cellstat,ftype,atype,nplanes,ypix_zplane,zs,colororder,zstack_drift);

%% CREATE ID VARIABLES
ex1=[];ex2=[];ex3=[];ex4=[];
in1 = []; in2=[]; in3=[]; in4=[];
spbn1=[]; spbn2=[]; spbn3=[];spbn4=[]; 
del1=[]; del2=[]; del3=[];del4=[]; 
%%  PLANE 1 
ex1 = [ 8 16 11 5 29  34 48 51 21 33 56 27 68 44 25 46 52 57 65 75 37 43
    ]; 

in1 = [7 10 47 16 31 30 35 53 58 54 56 71 36 45 46 41 45 39 23 32 50 42 73 81 63 76 61 29 19 72
    ]; 

spbn1 = [3 28 17 12 59 62 74 49 
    ];

del1 = [26 60 55 15 22 9 24 13 20 14 18 38 40 43 78 1 2 4 6 66 69 42 77 64 79 80 
    ];
%%  PLANE 2 
ex2 = [236 184 190 198 236  132 83 125 115 99 108 102 155 146 144 131 130 113 159 170 168 169 185 192 173 197 204 160 118 124 141 156 109 87 92 
    ]; 

in2 = [226 211 209 200 213 82 93 136 157 138 132 91 142 152 130 150 228 174 183 160 163 
    180 191 167]; 

spbn2 = [217 175 90 
    ];

del2 = [181 150 230 237 130
    ];

%%
ex = [ex1 ex2 ex3 ex4]; 
in = [in1 in2 in3 in4]; 
spbn = [spbn1 spbn2 spbn3 spbn4]; 
del = [del1 del2 del3 del4]; 

id_vect(ex)=1; id_vect(in)=2; id_vect(spbn)=3; id_vect(del)=4; 

%% UNCERTAIN ID
unc = [47 49 90]; 
% CANDIDATES FOR CROSSTALK 
% 155, 

%% QUESTIONABLE MASK


%% NOTES 
n().i= ; n().t = ''; 
n(1).i = 47; n(1).t = 'Probably is 2 cells combined'; 

n(2).i=73 ; n(2).t = 'questionable'; 

%% CORRECT CROSS-TALK 
mask = false(size(ops.meanImg)); 
mask(cellstat{8}.ypix,cellstat{8}.xpix)=true; 
mask(cellstat{155}.ypix,cellstat{155}.xpix)=true; 

% G and R are your raw channels (2D arrays)
[Rcorr, alpha, b, stats] = correctCrosstalk_quantileEnvelope(ops.meanImg,ops.meanImg_chan2, ...
    'Quantile', 0.30, ...
    'NumBins', 128, ...
    'MinPixelsPerBin', 100, ...
    'TileSize', 0, ...        % set e.g. 128 for tile-wise correction
    'SmoothAlpha', 1.0, ...
    'Verbose', true, ...
    'Mask',mask);

% Visual check
figure; 
subplot(3,1,1); imagesc(ops.meanImg_chan2); axis image off; title('Red (measured)'); colorbar;
subplot(3,1,2); imagesc(ops.meanImg); axis image off; title('Green'); colorbar;
subplot(3,1,3); imagesc(Rcorr); axis image off; title('Red (corrected)'); colorbar;
%%
% Create RGB images for visualization
sz = size(ops.meanImg);
rgb_orig = zeros([sz,3]);
rgb_corr = zeros([sz,3]);

% Place green channel as ops.meanImg, red channel as ops.meanImg_chan2 (original) and Rcorr (corrected)
rgb_orig(:,:,2) = mat2gray(ops.meanImg);            % green
rgb_orig(:,:,1) = mat2gray(ops.meanImg_chan2);      % red

rgb_corr(:,:,2) = mat2gray(ops.meanImg);            % green
rgb_corr(:,:,1) = mat2gray(Rcorr);                  % red

% Display side-by-side
figure;
subplot(2,1,1);
imshow(rgb_orig);
title('Original: Red = chan2, Green = chan1');

subplot(2,1,2);
imshow(rgb_corr);
title('Corrected: Red = Rcorr, Green = chan1');


%% ADJUST YPIX_ZPLANE


%% CONVERT REFERENCE BANDS INTO NEW COORDINATES 


%% SAVE FILES

