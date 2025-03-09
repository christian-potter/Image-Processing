%% LOAD FILES 
[zs,tlapse,zstack,tsync,s2p,ypix_zplane,idvect] = utils.load_drgs(518,'noplot'); 
load(s2p); 
%% UPDATE ID_VECT HERE

%% COUNT NUMBER OF FRAMES THAT ARE IN EACH T-SERIES
% need to see if I can use ops.firsttiffs to automatically determine how
% many folders there are

[tseries_frames]= de.tseries_frames(ops);
nframes= sum(tseries_frames);
[tsync] = de.compress_tsync(tsync,nframes); 
%% MAKE STIMULUS STRUCTURE 
%needs to be a structure that can incorportate the appropriate variables from
%thorsync later 

stim = de.enter_stimuli(tseries_frames,8);
%** use ops.file_list to get actual saved values for t-series 
%% THORSYNC PRE-PROCESSING 



%%





%% TODO 
% df/f calculation 
% 