function rangeSliderApp
fig = uifigure;
g = uigridlayout(fig);
g.RowHeight = {'1x','fit'};
g.ColumnWidth = {'1x'};

ax = uiaxes(g);
plot(ax,peaks);
xr = xregion(ax,10,35);

sld = uislider(g,"range", ...
    "Limits",[0 50], ...
    "Value",[10 35]);

sld.ValueChangingFcn = @(src,event) updateRange(src,event,xr);
end

function updateRange(src,event,xr)
val = event.Value;
xr.Value = val;
end