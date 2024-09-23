function [nfigs] = save_positions(nfigs,figs)

% Function that saves output from adjustImage and makes new structure with 
% default positions overwritten only by actually used outputs from figs

f = fields(nfigs); 

for i = 1:length(f)
    try isnan(nfigs.(f{i})); 
        nfigs.(f{i})= figs.(f{i}); 
    catch
        nfigs.(f{i})=nfigs.(f{i}); 
    end
end





