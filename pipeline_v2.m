%% LOAD 
% edit function 
[zstack,tlapse_md,zstack_md,tsync,s2p,ypix_zplane] = utils.load_drgs(548,'plot'); 
load(s2p); 
cellstat = stat(iscell(:,1)==1);
%% DEFAULT ID_VECT
id_vect = ones(sum(iscell(:,1)==1),1)*3; 
%%
load('/Volumes/ross/Christian/DRGS/#548/Fall.mat')
%% LOAD FIGURE POSITIONS 
load('work-positions.mat')
figs.zstack = figs.rgb; 
figs.zslider=figs.slider;
figs.ref=figs.rgb; 
%% SETTINGS 
%zstack=zs;
p = 1;% Choose Plane 
atype= 'mean';ftype='max'; %choose default anatomical and functional image types 
nplanes=4;
zstack_drift = [ops.xoff(end) ops.yoff(end)]; % estimates the x/y coordinates of the z-stack by taking last value of x and y offset 
colororder = 'grb'; % change between 'grb' and 'rgb' if your z-stack channels are switched 
%%

%% RUN MAIN MENU
[id_vect,figs] = prompt.main_menu(id_vect,figs,p,ops,cellstat,ftype,atype,nplanes,ypix_zplane,zstack,'grb',zstack_drift);


%% PLANE 1

ex = [4 12 22 20 24 31 21 24 10 26 2 18 25 19 14 23 36 45 44 42 43 37 41 49 48 57 33 38 40 34 61 63 35 39 53 55 51 52 56 60]; 

in =[5 11 17 13 1 29 16 15 3 28 8 27 32 6 46 50 62 58] ; 

spbn = [9]; 

del =[7 30 59 64 54 47]; 


%% PLANE 2 
ex =[75 85 86 91 86 66 72 71 70 87 84 71 109 102 65 100 93 107 95 111 113 89 83 94 97 110 105 108 118 117 134 128 122 127 141 149 139 144 136 126 121 129 133 131 137 148];  

in=[74 69 77 92 79 81 80 68 95 96 98 73 104 83 90 124 115
    ];

spbn = []; 

del = [114 76 88 82 106 99 67 112 78 103 106 101 120 116 132 135 146 140 130 119 123 125 143 150 151 138 142 147 145]; 

%% PLANE 3 
ex =[167 170 172 161 165 177 155 158 184 162 182 195 198 200 199 153 166 157 169 164 214 215 218 228 189 205 219 210 240 236 243 262
    222]; 

in = [171 174 160 175 179 168 213 194 209 239 234 248 233 
    212]; 

spbn =[];

del=[154 159 176 156 163 173 183 180 152 188 186 181 178 187 190 192 211 201 203]; 



%%
notes = {'not completely confident in #9'}