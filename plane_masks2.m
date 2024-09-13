%% MAKE FIGURE AND SLIDER 

fig = uifigure('Position',[1 100 1280 900]);
g = uigridlayout(fig); 
%g.RowHeight = {'1x','fit'};
%g.ColumnWidth = {'1x'};

ax = uiaxes(g);
%imshow(rgwin,'Parent',ax)
%ax = uiaxes(fig); 
im =uiimage(g,'ImageSource',rgwin)%'Position',[1 100 1280 900]);

sld = uislider(g,"range","Limits",[0 1],"Value",[0 .5]);
x = .1; y = .8; 





