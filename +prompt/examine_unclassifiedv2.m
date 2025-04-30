function [id_vect,nfigs,figs] = examine_unclassifiedv2(p,zstack,id_vect,ops,stat,crshift,figs,ypix_zplane,zstack_drift,adjusted_xyz,opt)
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
    opt.colororder string= 'rgb'; 
end
%% DESCRIPTION


%% Determine index of neuron for inspect_roi 

[roi_planeidx,~,~] = get.roipidx_shift(stat);
unc = find(id_vect==3); 
roi_planeidx= roi_planeidx(id_vect==3); 

unc=unc(roi_planeidx==p); % start with unclassified on the current plane 
%% RUN WHILE LOOP 
i =1; 
completion = 0; 
while completion ~= 1
    utils.closeFigureByName('Z-Stack')
    utils.closeFigureByName('Z-Stack Control')
    %- 
    if i > length(unc) % complete if you go onto ROI in the next plane 
        completion = 1; 
        nfigs=figs;
        disp(["All Unclassified ROIs in this plane have been sorted"])
    else   
        %-
        [nfigs,~]= adjustImagev2(p,stat,crshift,figs,ops,id_vect,ypix_zplane,'zstack_drift',zstack_drift,'surround',opt.surround,'idx',unc(i),'type','zstack','zstack',zstack,'refimg',opt.refimg,'adjusted_xyz',adjusted_xyz,'colororder',opt.colororder);    
        id_str=prompt.neuron_idstr(id_vect,unc(i)); 
        disp(id_str)
 
        % menu_str #3
        inputstr=prompt.menu_str(3);
        change= input(inputstr,"s"); 
        %--Change to EX
        if strcmp(change,'a')
            id_vect(unc(i))=1; 
            i = i+1; 
        %--Change to IN
        elseif strcmp(change,'s')
            id_vect(unc(i))=2; 
            i = i+1; 
        %--Change to SPBN 
        elseif strcmp(change,'d')
            id_vect(unc(i))=0;
            i = i+1; 
        %--Keep Uncertain
        elseif strcmp(change,'f')
            id_vect(unc(i))=3; 
            i = i+1; 
        %-- Add to delete_vect 
        elseif strcmp(change,'z')
            id_vect(unc(i)) = 4; 
        %--Return to Main Menu
        elseif strcmp(change,'r')
            completion = 1; 
        %--Save Figure Positions
        elseif strcmp(change,'w')
            figs = utils.save_positions(nfigs,figs); 
        end

    end


end
