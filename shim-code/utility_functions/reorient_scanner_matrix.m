function [matrix_reoriented] = reorient_scanner_matrix(normal_field,alignment)
%REORIENT_SCANNER_MATRIX Reorients the b0 (in Hz) or anatomical matrix from the scanner

% Reorient the b0 and anatomical matrices such that they are aligned with the scanners axes
% Original dimensions of b0 and mag were z,y,x (80,80,28)...
% But we want them to be y,x,z (80,28,80) to align with scanners axes
% Axes of the 3T scanner:
% up - down = y axis
% left-right = x axis
% head-foot = z axis
% Field of view for scanner (found in the info.pardef struct from
% loadParRec.m)
% FOV_ap_fh_rl_mm: '160.000  160.000  70.000'
% AP (anterior/posterior) = 160 mm
% FT (foot/head) = 160 mm
% RL (right/left) = 70 mm

% 2nd dimension (y) is first, then third dimension (x), then the 1st dimension (z) is last.
% 
% alignment is a vector whose elements indicate the the dimension that each
% axis needs to be placed in. e.g. alignment = [2,3,1] means orient the
% matrix such that the second dimension is first, third dimension is second
%, and first dimension is last. 

%matrix_reoriented = permute(normal_field,alignment); 

matrix_reoriented = [];
for i = 1:size(normal_field,4)
    matrix_reoriented(:,:,:,i) = permute(normal_field(:,:,:,i),alignment); 
end

end

