%% LOAD 

[zstack,tlapse,zstack_md,tsync,s2p,ypix_zplane] = utils.load_drgs(545,'noplot'); 
load(s2p)
%%

figure
hold on

firstframe = find(tsync.pandaframes==1); 
pframes = tsync.pandaframes(firstframe(1):end); 
nframes = find(pframes==0);

firstframe = find(tsync.pandaframes==1); 
frames = tsync.frames(firstframe(1):end); 
tframes = find(frames==0); 


scatter(tframes,ones(1,length(tframes)),50)
%scatter(1:length(tsync.framecount),ones(length(tsync.framecount),1))
scatter(nframes,ones(1,length(nframes)),50,'filled'); 

xlabel('Frame Num')
title('Synchronized 1P and 2P Frames')
yticks([])

legend({'2p Frames','1p Frames'})

utils.sf

%% HISTOGRAM OF INTER-PANDAFRAMES-INTERVAL

figure
histogram(diff(nframes),'BinWidth',1)
hold on

%histogram(diff(tframes),'BinWidth',1)

%%
figure
plot(diff(nframes))
