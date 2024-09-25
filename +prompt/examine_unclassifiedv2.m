function [id_vect,nfigs] = examine_unclassifiedv2(p,zstack,id_vect,ops,stat,crshift,figs,opt)

arguments
    p double 
    zstack double
    id_vect (:,1) double
    ops struct
    stat cell
    crshift double
    figs struct
    opt.surround double = 20; 
 
end

unc = find(id_vect==3); 
i = 1; 
completion = 0; 


% determine index of neuron for inspect_roi 
while completion ~= 1
    %- 
    if i > length(unc)  % -- put option to go back to other planes here 
        completion = 1; 
        disp(["All Unclassified ROIs in this plane have been sorted",char(10)])
    else   
        %-
        nfigs= adjustImagev2(p,stat,crshift,figs,ops,id_vect,'surround',opt.surround,'idx',unc(i),'type','zstack','zstack',zstack); 
        
        id_str=prompt.neuron_idstr(id_vect,unc(i)); 
        disp(id_str)
        
        % menu_str #3
        inputstr=prompt.menu_str(3);
        change= input(inputstr,"s"); 
        
        if strcmp(change,'a')
            id_vect(unc(i))=1; 
            i = i+1; 
             
        elseif strcmp(change,'s')
            id_vect(unc(i))=2; 
            i = i+1; 
         
        elseif strcmp(change,'d')
            id_vect(unc(i))=0;
            i = i+1; 
        
        elseif strcmp(change,'f')
            id_vect(unc(i))=3; 
            i = i+1; 
        
        elseif strcmp(change,'r')
            completion = 1; 
        end
    
    end


end
