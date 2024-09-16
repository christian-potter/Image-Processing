fig = figure;

h = ops.meanImg(:); h(h==0)=[]; 
histogram(h)
xr = xregion(2,350);
