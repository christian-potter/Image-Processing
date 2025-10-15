function [fslider,zslider] = save_slidervals(fslider_fig,zslider_fig)
%% DESCRIPTION 
% updates slider values based on those previously used in figure 


fslider.gammagreen = fslider_fig.Children(1).Value; 
fslider.highgreen = fslider_fig.Children(3).Value; 
fslider.lowgreen= fslider_fig.Children(5).Value; 

fslider.gammared = fslider_fig.Children(7).Value; 
fslider.highred = fslider_fig.Children(9).Value; 
fslider.lowred= fslider_fig.Children(11).Value; 

zslider.y = zslider_fig.Children(2).Value;
zslider.x =zslider_fig.Children(5).Value; 
%zslider.z = zslider_fig.Children(8).Value; % for the moment, do not update zvalues  

zslider.gammagreen = zslider_fig.Children(10).Value; 
zslider.highgreen = zslider_fig.Children(12).Value; 
zslider.lowgreen= zslider_fig.Children(14).Value; 
zslider.gammared = zslider_fig.Children(16).Value; 
zslider.highred = zslider_fig.Children(18).Value; 
zslider.lowred= zslider_fig.Children(20).Value; 



end
