%% MAKE DUAL SLIDER 

function rangeSliderApp
fig = uifigure;
load('sample_ws.mat')

h = ops.meanImg(:); h(h==0)=[]; 
histogram(h)
img= ops.meanImg;img=rescale(img); 

g = uigridlayout(fig);
g.RowHeight = {'1x','fit'};
g.ColumnWidth = {'1x'};

ax = uiaxes(g);
histogram(ax,h);
xr = xregion(ax,10,35);

sld = uislider(g,"range", ...
    "Limits",[0 1], ...
    "Value",[.1 .7]);

figure(1)
clf
imshow(img)

[sld.ValueChangingFcn,img] = @(src,event) updateRange(src,event,xr,img);
end

function [img]=updateRange(src,event,xr,img)
val = event.Value;
xr.Value = val;
img = imadjust(img,val);
end



