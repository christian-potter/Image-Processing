%% XY DRIFT (2/19/25)
figure
plot(ops.xoff)
hold on 
plot(ops.yoff)
legend({'xdrift','ydrift'})
xlabel('Frame')
ylabel('Drift Value')
title({'X/Y Drift Estimated By Suite2p Relative to Functional Image','Dataset #511'})
utils.sf

%%