
%% LOAD Dataset 
dsnum= 545; 
[Fall,tseries_md,zstack,zstack_md,tsync,ypix_zplane] = utils.load_Data_Organization(dsnum); 
raw_tsync = md.read_h5('/Volumes/Warwick/DRGS/#550/SDH/Functional/ThorSync/TS#550_000/Episode_0000.h5'); 

[ypix_zdist,zlocs,totalpdist]= dep.fa_zdist(tseries_md,zstack_md,raw_tsync); 
%%
load('/Volumes/Warwick/DRGS/#545/SDH/Processed/cellpose/soma_labels.mat')
load('/Volumes/Warwick/DRGS/#545/SDH/Processed/cellpose/nuclear_labels.mat')
load('/Volumes/Warwick/DRGS/#545/SDH/Processed/id_vect.mat') 
zrgb = permute(zstack, [1 2 4 3]);
%% ALIGN FUNCTIONAL AND ANATOMICAL 
stat = Fall.stat; 
cellstat = stat(Fall.iscell(:,1)==1); 
cellstat(id_vect==4)= [];
%%
ref_cell = [82 37 ]; % cell id, zplane  

[ypix_zdist,zlocs,totalpdist] = dep.fa_zdist(tseries_md,zstack_md,raw_tsync); 
[ypix_zplane,zlocs] = dep.modify_alignment(zlocs,ypix_zdist,stat,ref_cell,tseries_md,zstack_md); 

%% INSERT MASKS INTO RGB IMAGE

zrgb = permute(zstack, [1 2 4 3]);

%zrgb(:,:,:,1)=zstack(:,:,2,:); 
%zrgb(:,:,:,2)=zstack(:,:,1,:); 


fmasks3d = zeros(size(zrgb,[1:3])); 

xoff = -6; yoff = 0; 
perror=[];
for i =1:length(cellstat)

    if pOverlap(i) >.2
        xpix = cellstat{i}.xpix; 
        ypix = cellstat{i}.ypix; 
        plane = cellstat{i}.iplane+1; 
        zplanes = ypix_zplane{plane};
    
        if min(xpix)>size(Fall.ops.refImg,2)
            xpix = xpix - size(Fall.ops.refImg,2); 
        end
        if min(ypix)>size(Fall.ops.refImg,1)
            ypix = ypix - size(Fall.ops.refImg,1); 
        end
        %crshift = get.crshift(Fall.ops,plane); 
    
        for r = 1:length(ypix)
            x= xpix(r)+xoff; y = ypix(r)+yoff; 
            if x < 1  
                x = 1; 
                perror =[perror,plane]; 
            end
    
            % elseif x > size(Fall.ops.refImg,2)
            %     x = x - size(Fall.ops.refImg,2); 
            %     perror =[perror,plane]; 
            % end    
            % 
            if y < 1  
                y = 1; 
                perror =[perror,plane]; 
            end
            % elseif y > size(Fall.ops.refImg,1)
            %     y = y - size(Fall.ops.refImg,1); 
            %     perror =[perror,plane]; 
            % end    
            %fmasks3d(y,x,zplanes(y))= i; 
            zrgb(y,x,zplanes(y),3)= 1;  
            %zplanes(y)
        end
    end

    
end
%%
binsoma = soma_labels>0 ; 
h = plotv.volshow_rgb_dualAlpha(zrgb,'OverlayData',binsoma); 

%%

for i =1:length(stat)
    planeidx(i) = stat{i}.iplane+1; 
end
%%
volshow(overlap_labels)

%%
[anatIdxByFuncMask,overlap_labels,pOverlap]= cp.matchFunctionalToAnatomicalMasks(fmasks3d,soma_labels);

%%
% convert logical binsoma to 0.5 where true, preserving 3D size
binsoma = double(binsoma) * 0.5;
 
above_thresh = find(pOverlap>.2);

obinsoma= ismember(overlap_labels,above_thresh);

%obinsoma = overlap_labels>0 ;

obinsoma = double(obinsoma)*.5; 
csoma = binsoma + obinsoma; 

h = plotv.volshow_rgb_dualAlpha(zrgb,'OverlayData',csoma); 
%%
h = plotv.volshow_rgb_dualAlpha(zrgb,'OverlayData',soma_labels); 

%%
id_vect(id_vect==4)=[]; 
% anatIdxByFuncMask is assumed to be a cell array or numeric array mapping anatomical masks
n = numel(anatIdxByFuncMask);
numRows = zeros(size(anatIdxByFuncMask));
medCol3 = NaN(size(anatIdxByFuncMask));

for k = 1:n
    idx = anatIdxByFuncMask{k};
    if isempty(idx)
        numRows(k) = 0;
        medCol3(k) = NaN;
    else
        % ensure idx has at least 3 columns; handle vector case
        if ismatrix(idx) && size(idx,2) >= 3
            numRows(k) = size(idx,1);
            medCol3(k) = median(idx(:,3));
        else
            % if idx is a vector, treat each element as a row and take median of that vector
            v = idx(:);
            numRows(k) = numel(v);
            medCol3(k) = median(v);
        end
    end
end

% assign outputs to variables used later
d_vect = numRows;
med_vect = medCol3;
%% VOLUME 
d_vect(d_vect==0)=NaN;d_vect(d_vect==739)=1600; 
rd_vect= d_vect;rid_vect = id_vect; 
labelNames= {'SPBN','Excitatory','Inhibitory'}; 
vectorNames={'Volume',''}; 
nanvect = nan(length(rid_vect),1); 
plotGroupedViolins(rid_vect,[0 1 2],labelNames,vectorNames,rd_vect,nanvect)
%yyaxis right
%yticks([-150:10:0])
%% DEPTH 
d_vect(d_vect==0)=NaN;
labelNames= {'SPBN','Excitatory','Inhibitory'}; 
vectorNames={'Volume',''}; 
nanvect = nan(length(id_vect),1); 
plotGroupedViolins(id_vect,[0 1 2],labelNames,vectorNames,d_vect,nanvect)
%yyaxis right
%yticks([-150:10:0])


%%
figure
histogram(vols,'BinWidth',50)
diam=mean(vols); 
xline(mean(vols),'color','r')
title('Distribution of Cell Volumes Detected by Cellpose')
xlabel('Cubic Microns')
ylabel('Frequency')
utils.sf

%%
[abc, stats] = computePrincipalAxesFromCoordCells(anatIdxByFuncMask); 
%%
labelNames= {'SPBN','Excitatory','Inhibitory'}; 
vectorNames={'a','b','c'};
plotGroupedViolins(id_vect,[0 1 2],labelNames,vectorNames,abc(:,1),abc(:,2),abc(:,3))

%%

[abc, shapeIndex, stats] = computePrincipalAxesAndShapeIndex(anatIdxByFuncMask); 
%%
vectorNames={'Shape Index'}
plotGroupedViolins(id_vect,[0 1 2],labelNames,vectorNames,shapeIndex)
yline([-.5 0 .5],'HandleVisibility','off')
yyaxis right
yticks([-.5 0 .5])
yticklabels({'Horizontal','Spherical','Vertical'})
ylabel('Shape Index')
yyaxis left

% make left and right y-axes have the same limits and ticks
ax = gca;
% get left and right limits
yyaxis left
yl_left = ylim;
yt_left = yticks;
yyaxis right
yl_right = ylim;
yt_right = yticks;
% determine combined limits
yl_combined = [min([yl_left(1), yl_right(1)]) max([yl_left(2), yl_right(2)])];
% apply combined limits and set ticks to match left-side ticks (or unify)
yyaxis left
ylim(yl_combined)
yticks(yt_left)
yyaxis right
ylim(yl_combined)
% set right-side ticks to match left-side tick positions
yticks(yt_left)

hLeg = findall(gcf,'Type','Legend');
delete(hLeg);
utils.sf
%%
imagesc(out.surfaceMapSmooth);
colorbar
%%

zrgb(:,:,:,3)=out.surfaceVolumeSmooth;
h = plotv.volshow_rgb_dualAlpha(zrgb,'OverlayData',soma_labels); 
%%
plotShapeIndexEllipsoids3D([-0.9 -0.5 0 0.5 0.9]);
%%
hFig = plotShapeIndexEquationWithSchematic(1.2)

%%
zgrb = zrgb(:,:,:,[2 1 3]); 
%%zrgb = permute(zrgb, [2 1 3 4]);


% display first 20 patches (or fewer) in a 4x5 subplot, normalize each independently
nShow = min(20, numel(patches));
nShow = 40; 
nRows = 5; nCols = 8;
figure;
for k = 1:nShow
    img = patches{k};
    if isempty(img)
        % create blank RGB patch if missing
        img = zeros(sz(1),sz(2),3,'like',overlap_labels);
    end
    % ensure img is HxWx3 and convert to double for normalization
    if ndims(img) == 2
        img = repmat(img,1,1,3);
    elseif ndims(img) == 3 && size(img,3) == 1
        img = repmat(img,1,1,3);
    elseif ndims(img) == 4
        img = squeeze(img);
        if size(img,3) == 1
            img = repmat(img,1,1,3);
        end
    end
    imgd = double(img);
    % normalize per-image for good brightness: scale to [0,1] based on min/max
    mn = min(imgd(:));
    mx = max(imgd(:));
    if mx > mn
        imgn = (imgd - mn) / (mx - mn);
    else
        imgn = zeros(size(imgd));
    end
    % display
    subplot(nRows,nCols,k);
    imshow(imgn);
    axis image off;
    title(sprintf('Patch %d', k));
end
% if fewer than 20, fill remaining subplots with empty axes
for k = nShow+1 : nRows*nCols
    subplot(nRows,nCols,k);
    axis off;
end
utils.sf