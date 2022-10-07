%%%%% Calculating Median as an approximation to Z0(or fo or Bo) %%%%%%%%%%%
%  Z0 calculation may be incorrect if through plane regression 
% is used to in case of highly varying slices , first and last slices
% in the stack . Therefore the median can be taken as an approximation
% to the Z0 value.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Z0 = CalculateZ0(fieldmap,mask)
[n m] = size(fieldmap);

mask_vec = reshape(mask,n*m,1);
fieldmap_vec = reshape(fieldmap,n*m,1);

index = find(mask_vec == 1);   %% Indices of masked areas where shimROI ==1 

for k = 1 : size(index,1)
    X(k) = 1;
    Y(k) = fieldmap_vec(index(k));
end

%Z0 = median(Y);
Z0 = regress(Y',X');
