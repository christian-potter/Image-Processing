function [zstack]= zstack(filestr)

x= tiffreadVolume(filestr); 
zstack = utils.convert_img(x);