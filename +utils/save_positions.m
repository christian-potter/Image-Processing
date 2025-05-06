function [updated_figs] = save_positions(nffigs,nzfigs,figs)

% Function that saves output from adjustImage and makes new structure with 
% default positions overwritten only by actually used outputs from figs

f = fields(nffigs); 

for i = 1:length(f)
    % if isstruct(nffigs.(f{i}))
    %     updated_figs.(f{i})= nzfigs.(f{i}).Position; 
    % elseif isstruct(nzfigs.(f{i}))
    %     updated_figs.(f{i})= nffigs.(f{i}).Position; 
    % end

    updated_figs.rgb.Position = nffigs.rgb.Position; 
    updated_figs.slider.Position =nffigs.slider.Position; 
    updated_figs.zstack.Position=nzfigs.zstack.Position; 
    updated_figs.zslider.Position = nzfigs.zslider.Position; 

end





