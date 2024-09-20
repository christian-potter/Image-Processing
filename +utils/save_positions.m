function [nfigs] = save_positions(figs,dfigs)

% Function that saves output from adjustImage and makes new structure with 
% default positions overwritten only by actually used outputs from figs

f = fields(figs); 

for i = 1:length(f)
    try isnan(figs.(f{i}))
        nfigs.(f{i})= dfigs.(f{i}); 
    catch
        nfigs.(f{i})=figs.(f{i}); 
    end
end





