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
end

[roi_planeidx,~,~] = get.roipidx_shift(stat); 

%% Determine index of neuron for inspect_roi 

unc = find(id_vect==3); % start with unclassified on the current plane 


%% RUN WHILE LOOP 
i = 1; 
completion = 0; 
while completion ~= 1
    close all 
    %- 
    if i > length(unc) | roi_planeidx(unc(i))~=p % complete if you go onto ROI in the next plane 
        completion = 1; 
        disp(["All Unclassified ROIs in this plane have been sorted"])
    else   
        %-
        [nfigs,~]= adjustImagev2(p,stat,crshift,figs,ops,id_vect,ypix_zplane,'zstack_drift',zstack_drift,'surround',opt.surround,'idx',unc(i),'type','zstack','zstack',zstack,'refimg',opt.refimg,'adjusted_xyz',adjusted_xyz);    
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
        %--Return to Main Menu
        elseif strcmp(change,'r')
            completion = 1; 
        %--Save Figure Positions
        elseif strcmp(change,'w')
            figs = utils.save_positions(nfigs,figs); 
        end

    end


end
