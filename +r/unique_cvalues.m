function [cvect] = unique_cvalues(cmatrix,opt)
arguments 
    cmatrix double 
    opt.remzero logical = true 
end

% Function that extracts only the upper part of the cmatrix. Can remove 0
% correlations if needed 

cmatrix = triu(cmatrix,1); 

cmatrix =cmatrix(:); 

if opt.remzero
    cmatrix(cmatrix == 0)=[];
end

cvect = cmatrix; 