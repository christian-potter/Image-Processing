function [id_vect,figs,ref_bands] = main_menu(id_vect,figs,p,ops,cellstat,ftype,atype,nplanes,ypix_zplane,zstack,colororder,zstack_drift)
%% DESCRIPTION 
% INPUTS 
% id_vect: vector 1 x neurons
% figs: structure containing figure positions
% p: current plane
% ops: suite2p file with reference image info 
% cellstat: stat(iscell==1) 
% ftype: functional image type 
% atype: anatomical image type 
% img_mode: 'functional' / 'zstack' 
% nplanes: total number of planes in dataset 
% ypix_zplane: estimated location in zstack for each ypix val in each plane
% zstack: X x Y x RGB x Z matrix 
% colororder: 'rgb'/ 'grb' of colors for the zstack 
% zstack_drift: updated mapping estimate between zstack and functional
    % images 

%% INITIALIZE SETTINGS 
padjusted_xyz = zeros(3,nplanes); % updated to contain user-adjusted mapping between zstack and functional images 
fslider.lowred = 0; zslider.lowred = 0; 
fslider.highred = .5; zslider.highred = .5; 
fslider.gammared= 1; zslider.gammared= 1; 
fslider.lowgreen = 0; zslider.lowgreen = 0; 
fslider.highgreen = .5;zslider.highgreen = .5;
fslider.gammagreen = 1; zslider.gammagreen = 1; 

ref_bands = []; 
%% RUN MAIN MENU 
while p ~= -1   % loop function until user exits 
    
    [plane_crshift]=get.crshift(ops,p);
    
    if exist("fslider_fig") == 1 %only trigger if there are existing figures
      [fslider,zslider] = utils.save_slidervals(fslider_fig,zslider_fig); 
    end 

    close all 
    %-- generate functional image/ control panel 
    [nffigs,~,fslider_fig] = adjustImagev2(p,cellstat,plane_crshift,figs,fslider,ops,id_vect,ypix_zplane,'functional',ftype,'anatomical',atype,'type','functional'); 
    %-- generate zstack image/ control panel 
    [nzfigs,~,zslider_fig]= adjustImagev2(p,cellstat,plane_crshift,figs,zslider,ops,id_vect,ypix_zplane,'zstack_drift',zstack_drift,'type','zstack','zstack',zstack,'adjusted_xyz',padjusted_xyz(:,p),'colororder',colororder);    
    
    % --- PROMPT USER --------------------------------------- 
    input_str=prompt.menu_str(1); 
    answer = input (input_str,"s"); 
    
    %--Reclassify Neurons -----------------------------------
    if strcmp(answer,'a')
        cprompt = ['Enter ROIs you wish to change:',char(10)]; 
        [id_vect] = prompt.change_rois(id_vect,cprompt);  
    %--Go to Next Plane -------------------------------------
    elseif strcmp(answer,'s')
        if p+1 <= nplanes
            p= p+1;
        elseif p+1 > nplanes  
            p = 1;   
        end
    %--Go to Previous Plane -----------------------------------
    elseif strcmp(answer,'d')
        if p-1 == 0 
            p = nplanes; 
        elseif p-1 > 0
            p = p-1; 
        end
    %--Change Image Type  --------------------------------------
    elseif strcmp(answer,'r')
        [ftype,atype]=prompt.img_type(atype,ftype); 
    %--Save Figure Positions -----------------------------------
    elseif strcmp(answer,'w')
        figs = utils.save_positions(nffigs,nzfigs,figs); 
    %--Save Current id_vect  -----------------------------------
    elseif strcmp(answer,'e')
        p = -1; 
    %--Align Z-Stack  -------------------------------------------
    elseif strcmp(answer,'z')
        % *** NEEDS TO BE UPDATED TO NEW FIGURE CONVENTIONS **** 
        % refimg = get.imagefromFigure(nfigs);
        % input_str =prompt.menu_str(5); 
        % answer = input(input_str,"s");
        % if strcmp(answer,'e')
        %     answer = input('Enter X,Y,Z-Plane Vector:'); 
        %     padjusted_xyz(p,:)=answer; 
        % 
        % elseif strcmp(answer,'r')
        %     answer = input('Select a cell as reference:'); 
        %     [padjusted_xyz(p,:)] = prompt.align_zstack(p,zstack,id_vect,ops,cellstat,plane_crshift,figs,ypix_zplane,zstack_drift,padjusted_xyz(:,p),'surround',0,'refimg',refimg,'specified_roi',answer);
        % end
    
    % ---- Set Depth ---------------------------------------------
    elseif strcmp(answer,'v')
        % save slider values and clear figures so conditional at beginning
        % is not triggered 
        [fslider,zslider] = utils.save_slidervals(fslider_fig,zslider_fig); 
        clear fslider_fig zslider_fig
        start  = 1; 
        
        while start~=0
            close all
            % create depth figure/ slider 
            set_depth(figs,zslider,ypix_zplane,'zstack',zstack,'colororder',colororder)
            % prompt user     
            input_str=prompt.menu_str(6); 
            answer = input (input_str,"s"); 

            if strcmp(answer,'a') % if "enter values for reference bands'
                cprompt = ['Enter z-stack plane that first intersects with X reference bands :',char(10),'(If first plane has already broken, enter 0 for corresponding entry)',char(10)];
                ref_bands.x= input(cprompt);

            elseif strcmp(answer,'s') % if "enter values for reference bands'
                cprompt = ['Enter z-stack plane that first intersects with Y reference bands :',char(10),'(If first plane has already broken, enter 0 for corresponding entry)',char(10)];
                ref_bands.y= input(cprompt); 

            elseif strcmp(answer,'q') % if "quit"
                start = 0; 
            end

        end

    end
    %---- END MENU OPTIONS 



end
