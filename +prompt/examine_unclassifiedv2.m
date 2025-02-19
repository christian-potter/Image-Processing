function [id_vect,nfigs,figs] = examine_unclassifiedv2(p,zstack,id_vect,ops,stat,crshift,figs,ypix_zplane,xyshift,opt)
arguments
    p double 
    zstack double
    id_vect (:,1) double
    ops struct
    stat cell
    crshift double
    figs struct
    ypix_zplane cell 
    xyshift double
    opt.surround double = 200;  
    opt.refimg
end


[roi_planeidx,~,~] = get.roipidx_shift(stat); 
unc = find(id_vect==3&roi_planeidx==p); % start with unclassified on the current plane 
i = 1; 
completion = 0; 


% determine index of neuron for inspect_roi 
while completion ~= 1
    close all 
    %- 
    if i > length(unc)  % -- put option to go back to other planes here 
        completion = 1; 
        disp(["All Unclassified ROIs in this plane have been sorted",char(10)])
    else   
        %-
        nfigs= adjustImagev2(p,stat,crshift,figs,ops,id_vect,ypix_zplane,xyshift,'surround',opt.surround,'idx',unc(i),'type','zstack','zstack',zstack,'refimg',opt.refimg);    
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
        %--Keep Uncerctain
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
