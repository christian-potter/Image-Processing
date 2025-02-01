function [id_vect] = main_menu(id_vect,figs,p, ops, cellstat,ftype,atype,img_mode)

while p ~= -1   
    close all 
    [crshift]=get.crshift(ops,p);
    [nfigs] = adjustImagev2(p,cellstat,crshift,figs,ops,id_vect,'functional',ftype,'anatomical',atype,'type',img_mode); 
    input_str=prompt.menu_str(1); 
    answer = input (input_str,"s"); 
    
    if strcmp(answer,'a')
        cprompt = ['Enter ROIs you wish to change:',char(10),char(10)]; 
        [id_vect] = prompt.change_rois(id_vect,cprompt);  

    elseif strcmp(answer,'s')
        if p+1 <= nplanes
            p= p+1;
        elseif p+1 > nplanes  
            p = 1;   
        end

    elseif strcmp(answer,'d')
        if p-1 == 0 
            p = nplanes; 
        elseif p-1 > 0
            p = p-1; 
        end
    elseif strcmp(answer,'r')
        [ftype,atype]=prompt.img_type(atype,ftype); 
    
    elseif strcmp (answer,'q')
        if sum(id_vect==3)<0
            close all 
            disp('No ROIs currently unclassified.',char(10))
            unc_vect = input('Enter neurons you wish to unclassify:'); 
            id_vect(unc_vect)=3; 
            [id_vect,nfigs] = prompt.examine_unclassifiedv2(p,zstack,id_vect,ops,stat,crshift,figs,'surround',20); 
        else 
            close all 
            [id_vect,nfigs] = prompt.examine_unclassifiedv2(p,zstack,id_vect,ops,stat,crshift,figs,'surround',20); 
        end
    elseif strcmp(answer,'c')
        answer = input(['C: Combine Anatomical and Functional Channels',char(10),'S: Separate Anatomical and Functional Channels',char(10)],'s');
        if strcmp(answer,'c')
            img_mode='rgb';
        elseif strcmp(answer,'s')
            img_mode = 'separate'; 
        end
    elseif strcmp(answer,'w')
        figs = utils.save_positions(nfigs,figs); 

    end


end
