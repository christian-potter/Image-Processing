function [anatIdxByFuncMask,overlapMaskVol,pOverlap] = matchFunctionalToAnatomicalMasks(funcMaskVol, anatMaskVol)
%MATCHFUNCTIONALTOANATOMICALMASKS Match each functional mask to an anatomical mask.
%
% anatIdxByFuncMask = matchFunctionalToAnatomicalMasks(funcMaskVol, anatMaskVol)
%
% Inputs
%   funcMaskVol : X x Y x Z numeric matrix
%       0 = background
%       Positive integers = functional mask identities
%
%   anatMaskVol : X x Y x Z numeric matrix
%       0 = background
%       Positive integers = anatomical mask identities
%
% Outputs
%   anatIdxByFuncMask : cell vector, one entry per unique functional mask ID
%       Length equals the number of unique nonzero functional mask IDs.
%       Entry i corresponds to the i-th functional mask ID in ascending order.
%       - If no anatomical mask overlaps that functional mask: []
%       - If a match exists: N x 3 numeric array of [x y z] indices for the
%         matched anatomical mask
%       If multiple anatomical masks overlap, the one with the greatest
%       number of overlapping voxels is chosen.
%
% Example
%   out = matchFunctionalToAnatomicalMasks(funcMaskVol, anatMaskVol);
%
% Notes
%   - This function treats any shared voxel between a functional mask and an
%     anatomical mask as a potential match.
%   - Functional and anatomical mask IDs are allowed to reuse the same numbers;
%     IDs are interpreted independently in each volume.

    arguments
        funcMaskVol (:,:,:) {mustBeNumeric, mustBeNonempty}
        anatMaskVol (:,:,:) {mustBeNumeric, mustBeNonempty}
    end

    if ~isequal(size(funcMaskVol), size(anatMaskVol))
        error('funcMaskVol and anatMaskVol must have the same size.');
    end
    overlapMaskVol = zeros(size(anatMaskVol)); 

    % Get unique nonzero functional mask IDs
    funcIDs = unique(funcMaskVol(:));
    funcIDs(funcIDs == 0) = [];

    anatIdxByFuncMask = cell(numel(funcIDs), 1);
    pOverlap = zeros(numel(funcIDs),1); 

    for iFunc = 1:numel(funcIDs)
     
        thisFuncID = funcIDs(iFunc);

        % Logical mask for this functional object
        funcLogical = (funcMaskVol == thisFuncID);

        % Anatomical IDs present at overlapping voxels
        overlappingAnatIDs = anatMaskVol(funcLogical);
        overlappingAnatIDs = overlappingAnatIDs(overlappingAnatIDs > 0);


        if isempty(overlappingAnatIDs)
            anatIdxByFuncMask{iFunc} = [];
            pOverlap(iFunc)=0; 
            continue
        end

        % Count overlap size for each overlapping anatomical mask
        candidateAnatIDs = unique(overlappingAnatIDs);
        overlapPercents = zeros(size(candidateAnatIDs));

        for j = 1:numel(candidateAnatIDs)
            overlapPercents(j) = sum(overlappingAnatIDs == candidateAnatIDs(j))/sum(funcLogical(:));
        end

        % Pick the anatomical mask with maximum overlap
        [p, maxIdx] = max(overlapPercents);
        bestAnatID = candidateAnatIDs(maxIdx);

        % Return all voxel indices of the matched anatomical mask
        [x, y, z] = ind2sub(size(anatMaskVol), find(anatMaskVol == bestAnatID));
        anatIdxByFuncMask{iFunc} = [x, y, z];
        overlapMaskVol(anatMaskVol==bestAnatID)=iFunc; 
        pOverlap(iFunc)=p; 

    end
end