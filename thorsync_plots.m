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

%% MECHANICAL STIMULATOR THORSYNC VALUES
figure
plot(tsync.mforce)
hold on 
plot(tsync.mlength)
xlabel('Time')
ylabel({'Thorsync Value','(AU)'})
title('Thorsync data for mechanical stimulation')
utils.sf
legend({'Force','Length'})