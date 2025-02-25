function [nadjusted_xyz] = align_zstack(p,zstack,id_vect,ops,stat,crshift,figs,ypix_zplane,zstack_drift,adjusted_xyz,opt)

arguments
    p double 
    zstack double
    id_vect (:,1) double
    ops struct
    stat cell
    crshift double
    figs struct
    ypix_zplane cell 
    zstack_drift double
    adjusted_xyz double 
    opt.surround double = 200;  
    opt.refimg double 
    opt.specified_roi double 
end

unc = opt.specified_roi; 


%% RUN WHILE LOOP 
% at some point change this so that you can do for multiple planes 
% also allow for selection of an individual coordinate 
%    ** however, advantage of the mask is that you can align on top of zstack
%    more precisely 

i = 1; 
completion = 0; 

while completion ~=1
    [nfigs,nadjusted_xyz]= adjustImagev2(p,stat,crshift,figs,ops,id_vect,ypix_zplane,'zstack_drift',zstack_drift,'surround',opt.surround,'idx',unc(i),'type','zstack','zstack',zstack,'refimg',opt.refimg,'adjusted_xyz',adjusted_xyz);
    answer = input(['Enter S to Save Z-Stack Alignment',char(10)],"s"); 

    if strcmp(answer,'s')
        completion =1; 
    else
        disp('Invalid Input')
    end




end

