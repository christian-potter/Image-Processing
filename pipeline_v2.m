%% LOAD 
% edit function 
[zstack,tlapse_md,zstack_md,tsync,s2p,ypix_zplane] = utils.load_drgs(548,'plot'); 
load(s2p); 

%% DEFAULT ID_VECT
id_vect = ones(sum(iscell(:,1)==1),1)*3; 
cellstat = stat(iscell(:,1)==1);
%%
load('/Volumes/ross/Christian/DRGS/#548/Fall.mat')
%% LOAD FIGURE POSITIONS 
load('work-positions.mat')
figs.zstack = figs.rgb; 
figs.zslider=figs.slider;
figs.ref=figs.rgb; 
%% SETTINGS 
%zstack=zs;
p = 3;% Choose Plane 
atype= 'mean';ftype='max'; %choose default anatomical and functional image types 
nplanes=4;
zstack_drift = [ops.xoff(end) ops.yoff(end)]; % estimates the x/y coordinates of the z-stack by taking last value of x and y offset 
colororder = 'grb'; % change between 'grb' and 'rgb' if your z-stack channels are switched 
%%

%% RUN MAIN MENU
[id_vect,figs] = prompt.main_menu(id_vect,figs,p,ops,cellstat,ftype,atype,nplanes,ypix_zplane,zstack,'grb',zstack_drift);


%% PLANE 1

ex = [5 7 2 11 18 2 38 51 53 52 40 37 29 37 44 30 34 17 49 22 13 10 47 23 27 35 25 
    31 39 12 ]; 

in =[4 9 14 15 50 36 8 36 41 24 28 42 6 48 1 43 3
    ];

spbn = []; 

del =[20 16 21 45 32 33 19 26 46]; 


%% PLANE 2 
ex =[102 81 86 79 57 54  70 91 96 78 56 101 104 58 64 67 69 71 75 109 106 95 85 87 65 83 62 110 60  
    ];  

in=[99 105 103 59 55 99 90 80 63 107 97 74 92 94 100 
    ];

spbn = []; 

del = [82 76 77 93 72 61 89 88 66 68 73 84 98 108]; 

%% PLANE 3 
ex =[121 163 149 144 168 178 156 152 124 135 124 135 150 157 166 146 140 175 188 148 116 184 111 176 187 194 129 190 172 167 112 113 158 169 114 193 164 136 128 141 132 185 181 134
    ]; 

in = [186 180 170 159  186 151 177 133 127 122 120 189 175
    ]; 

spbn =[174 
    ];

del=[143 191 195 130 142 192 145 165 155 154 137 126 117 139 115 119 182 179 183 162 171 153 147 118 123 125 131 173 160]; 

%% PLANE 4 
ex =[]; 

in = []; 

spbn =[];

del=[]; 

%%
notes = {'not completely confident in #9'}