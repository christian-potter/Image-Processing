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

%% MAKE PLOT OF 
figure 
hold on 
for p = 1:tlapse.nplanes+tlapse.flybackFrames
    curframes = find(tsync.framecount==p); 
    curpiezo = tsync.piezo(curframes); 
    plot(curframes,curpiezo,'LineWidth',2)
    
end

xticklabels([])
ylabel('Z Position')
xlabel('Timepoint')
utils.sf 
title('#545 Piezo Frame Acquisition')
legend({'frame 1','frame 2','frame 3','frame 4','fb1','fb2'})