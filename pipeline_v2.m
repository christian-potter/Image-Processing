%% LOAD 
[zstack,tlapse,zstack_md,tsync,s2p,ypix_zplane] = utils.load_drgs(541,'plot'); 
load(s2p); 
%%
id_vect = ones(sum(iscell(:,1)==1),1)*3; 
cellstat = stat(iscell(:,1)==1);

%% LOAD FIGURE POSITIONS 
load('work-positions.mat')
figs.zstack = figs.rgb; 
figs.zslider=figs.slider;
figs.ref=figs.rgb; 
%% RUN MAIN MENU
%zstack=zs;
p = 1;% Choose Plane 
atype= 'mean';ftype='max'; %choose  
img_mode='functional'; 
nplanes=4;
zstack_drift = [ops.xoff(end) ops.yoff(end)];
[id_vect,figs] = prompt.main_menu(id_vect,figs,p,ops,cellstat,ftype,atype,img_mode,nplanes,ypix_zplane,zstack1,'grb',zstack_drift);

%%

ex = [325 362 351 368 360 294 331 315 352 342 292 301 327 333 340 357 339 373 363 370
    332 349 336 313] ; 

in = [366 348 322 343 364 335 316
    328 ]; 

sp = [] ;

del = [320 323 338 334 361 337 347 345 344 367 317 374 292 318 353 356 298 341 299 329 321 369 371 369 371  330 346 355 354 350 303 289 359 365 372 319 314 358 308 309 310 287 336 304
    326 324 306 209 206 300] ; 

%%


