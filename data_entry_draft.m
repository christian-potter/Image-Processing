%% LOAD FILES 

%% UPDATE ID_VECT HERE

%% COUNT NUMBER OF FRAMES THAT ARE IN EACH T-SERIES
% need to see if I can use ops.firsttiffs to automatically determine how
% many folders there are

[tseries_frames]= de.tseries_frames(ops);
nframes= sum(tseries_frames);
[tsync] = de.compress_tsync(tsync,nframes); 
%%


%% THORSYNC PRE-PROCESSING 


%% MAKE STIMULUS TABLE 
