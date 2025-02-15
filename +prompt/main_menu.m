function [id_vect] = main_menu(id_vect,figs,p, ops, cellstat,ftype,atype,img_mode,nplanes,ypix_zplane,zstack,stat,xyshift)

while p ~= -1   
    close all 
    [crshift]=get.crshift(ops,p);
    [nfigs] = adjustImagev2(p,cellstat,crshift,figs,ops,id_vect,ypix_zplane,xyshift,'functional',ftype,'anatomical',atype,'type',img_mode); 
    input_str=prompt.menu_str(1); 
    answer = input (input_str,"s"); 
    
    %--Reclassify Neurons
    if strcmp(answer,'a')
        cprompt = ['Enter ROIs you wish to change:',char(10),char(10)]; 
        [id_vect] = prompt.change_rois(id_vect,cprompt);  
    %--Go to Next Plane
    elseif strcmp(answer,'s')
        if p+1 <= nplanes
            p= p+1;
        elseif p+1 > nplanes  
            p = 1;   
        end
    %--Go to Previous Plane 
    elseif strcmp(answer,'d')
        if p-1 == 0 
            p = nplanes; 
        elseif p-1 > 0
            p = p-1; 
        end
    %--Change Image Type 
    elseif strcmp(answer,'r')
        [ftype,atype]=prompt.img_type(atype,ftype); 
    %--Examine Uncertain
    elseif strcmp (answer,'q')
        if sum(id_vect==3)<0
            close all 
            disp('No ROIs currently unclassified.',char(10))
            unc_vect = input('Enter neurons you wish to unclassify:'); 
            id_vect(unc_vect)=3; 
            [id_vect,nfigs] = prompt.examine_unclassifiedv2(p,zstack,id_vect,ops,stat,crshift,figs,ypix_zplane,xyshift,'surround',50); 
        else 
            close all 
            [id_vect,nfigs] = prompt.examine_unclassifiedv2(p,zstack,id_vect,ops,stat,crshift,figs,ypix_zplane,xyshift,'surround',50); 
        end
   %--Combine/Separate Images 
    elseif strcmp(answer,'c')
        answer = input(['C: Combine Anatomical and Functional Channels',char(10),'S: Separate Anatomical and Functional Channels',char(10)],'s');
        if strcmp(answer,'c')
            img_mode='rgb';
        elseif strcmp(answer,'s')
            img_mode = 'separate'; 
        end
    %--Save Figure Positions
    elseif strcmp(answer,'w')
        figs = utils.save_positions(nfigs,figs); 
    %--Align Z-Stack 
    elseif strcmp(answer,'z')
        answer = input('Select a cell as reference:'); 
        prompt.align_zstack(answer,p,zstack,ops,xyshift)

    end


end
